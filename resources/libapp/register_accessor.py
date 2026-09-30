# ------------------------------------------------------------------------------
#  Copyright (c) 2021 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    FPGA register access library
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

from __future__ import absolute_import, print_function

import re
from glob import glob

from . import IS_EOS

if IS_EOS:
    import PLSmbusUtil
    import Smbus_pb2
    from . import pl_smbus_burst

try:
    import hal

    class MakoRegAccess(hal.i2c.Device):  # type: ignore
        ALLOWABLE_ADDR = [0x72, 0x73, 0x66, 0x67]  # Is this limitation arbitrary??

        def __init__(self, label=None, addr=None, awidth=None):
            self.awidth = awidth if awidth else 16

            if label in hal.base.mezzanine._fpgas:  # type: ignore
                # label is an FPGA name
                fpga = hal.base.mezzanine._fpgas[label]  # type: ignore
                bus = fpga["i2c_comm"]["bus"]
                if addr is not None:
                    address = addr
                else:
                    address = fpga["i2c_comm"]["address"]
            else:
                try:
                    bus = hal.i2c.label_to_bus(label)  # type: ignore
                except ValueError:
                    raise Exception("There is no bus associated with {}".format(label))
                if addr is not None:
                    address = addr
                else:
                    raise Exception("Cannot initialise register access")
            hal.i2c.Device.__init__(self, bus, address)  # type: ignore

        def read_reg(self, addr):
            try:
                assert self.locked == 0, "Register access interrupted, please re-start your CLI session."
                self.grab()
                self.write_i2c_block_data((addr >> 8) & 0xFF, [(addr) & 0xFF])
                r = self.read_i2c_block_data(0xFF, 4)
            finally:
                assert self.locked == 1, "Register access interrupted, please re-start your CLI session."
                self.release()
            return r[0] << 24 | r[1] << 16 | r[2] << 8 | r[3]

        def write_reg(self, addr, value):
            b = [
                (addr) & 0xFF,
                (value >> 24) & 0xFF,
                (value >> 16) & 0xFF,
                (value >> 8) & 0xFF,
                (value) & 0xFF,
            ]
            try:
                assert self.locked == 0, "Register access interrupted, please re-start your CLI session."
                self.grab()
                self.write_i2c_block_data((addr >> 8) & 0xFF, b)
            finally:
                assert self.locked == 1, "Register access interrupted, please re-start your CLI session."
                self.release()

except ImportError:
    # no hal-based i2c accesses. This is okay when imported on build machines, etc
    pass


class EosRegAccess(object):
    # pylint: disable=R0913
    def __init__(self, label=None, addr=None, pci=None, accelerator=None, awidth=None):
        self._sock = None

        if pci:
            self.pci_addr = PLSmbusUtil.encodePCIAddress(pci)
            self.backend = Smbus_pb2.SCD
        else:
            self.pci_addr = 0
            self.backend = Smbus_pb2.KERNEL_DEV
        self.accel_id = accelerator
        self.bus = label
        self.addr = addr
        self.awidth = awidth if awidth else 16

    @property
    def sock(self):
        if self._sock is None:
            self._sock = PLSmbusUtil.connect()
        return self._sock

    def _submit_burst(self, addrs, values, reads, raw_bytes=False):  # pylint: disable=too-many-locals
        registers = []
        datas = []
        reads_n = []

        for i, addr in enumerate(addrs):
            data_n = []
            reg = []
            for j in reversed(range(int(self.awidth / 8))):
                reg.append((addr >> j * 8) & 0xFF)
            registers.append(reg)

            if reads[i]:
                reads_n.append(reads[i] * (1 if raw_bytes else 4))
            else:
                value = values[i]
                if raw_bytes:
                    data_n += value
                else:
                    for val in value:
                        for j in reversed(range(4)):
                            data_n.append((val >> j * 8) & 0xFF)
                reads_n.append(0)

            datas.append(data_n)
        r = pl_smbus_burst._submit_burst(  # pylint: disable=protected-access
            self.sock,
            self.pci_addr,
            self.accel_id,
            self.bus,
            self.addr,
            registers,
            datas,
            reads_n,
            backend=self.backend,
        )

        # Swap any return data
        if raw_bytes:
            return r

        r_swap = []
        for i, r_i in enumerate(r):
            r_s = [ord(x) if isinstance(x, (str, bytes)) else x for x in r_i]
            for j in range(0, len(r_s), 4):
                r_swap.append(r_s[j + 0] << 24 | r_s[j + 1] << 16 | r_s[j + 2] << 8 | r_s[j + 3])
        return r_swap

    def read_block(self, addr, n=32):
        return self._submit_burst([addr], [], [n], raw_bytes=True)

    def write_block(self, addr, vals):
        assert all(i <= 0xFF for i in vals)
        self.submit_burst([addr], [vals], [0], raw_bytes=True)

    def read_reg(self, addr):
        r = self._submit_burst([addr], [], [1])[0]
        return r

    def write_reg(self, addr, value):
        self._submit_burst([addr], [[value]], [0])


class PCIeRegAccess(object):
    def __init__(self, fpgaPCIeDevMngr, bdf, bar=0, awidth=None):
        self.awidth = awidth if awidth else 32
        for r in fpgaPCIeDevMngr.pcie_devices_by_bdf.get(bdf).regions:
            if r.region_num == bar:
                self.region = r

    def read_block(self, addr, n=32):
        r = self.region.read(addr, n)
        return [ord(x) if isinstance(x, (str, bytes)) else x for x in r]

    def write_block(self, addr, vals):
        # FIXME: The bytearray call is only needed for Python 2.
        data = bytes(bytearray(vals))
        self.region.write(addr, data)

    def read_reg(self, addr):
        a = addr << 2
        r = self.read_block(a, 4)
        return r[3] << 24 | r[2] << 16 | r[1] << 8 | r[0]

    def write_reg(self, addr, value):
        a = addr << 2
        b = [
            (value) & 0xFF,
            (value >> 8) & 0xFF,
            (value >> 16) & 0xFF,
            (value >> 24) & 0xFF,
        ]
        self.write_block(a, b)


class RegisterAccessor(object):
    internal = None

    def __init__(  # pylint: disable=too-many-arguments
        self,
        chan_number=None,
        bus_number=None,
        bus_label=None,
        mos_label=None,
        address=0x72,
        pci=None,
        accelerator=None,
        fpgaPCIeDevMngr=None,
        bdf=None,
        bar=0,
        awidth=None,
    ):
        if (
            int(fpgaPCIeDevMngr is not None)
            + int(chan_number is not None)
            + int(bus_number is not None)
            + int(bool(bus_label))
            != 1
        ):
            raise ValueError("Requires one of (chan_number, bus_number, bus_label, fpgaPCIeDevMngr)")
        if bdf is None:
            if IS_EOS:
                label = (
                    bus_number
                    if bus_number is not None
                    else self.__name_to_bus(bus_label or r"i2c-.*-mux \(chan_id {}\)".format(chan_number)) or bus_label
                )
                self.internal = EosRegAccess(label, address, pci, accelerator, awidth)
            else:
                self.internal = MakoRegAccess(mos_label, address, awidth)
        else:
            self.internal = PCIeRegAccess(fpgaPCIeDevMngr, bdf, bar, awidth)

    def __name_to_bus(self, bus):
        # type: (str)->int|None
        for bus_file in glob("/sys/bus/i2c/devices/i2c-*/name"):
            with open(bus_file, "r") as f:  # pylint: disable=unspecified-encoding
                if re.match(bus, f.read().strip()):
                    return int(re.match(r".*/i2c-(\d+)/", bus_file).group(1))

        return None

    def read_reg(self, addr):
        return self.internal.read_reg(addr)

    def write_reg(self, addr, value):
        self.internal.write_reg(addr, value)


__all__ = ("RegisterAccessor",)
