# ------------------------------------------------------------------------------
#  Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
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

try:
    import hal

    class MakoRegAccess(hal.i2c.Device):  # type: ignore
        ALLOWABLE_ADDR = [0x72, 0x73, 0x66, 0x67]  # Is this limitation arbitrary??

        def __init__(self, label=None, addr=None):
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
    def __init__(self, label=None, addr=None, pci=None, accelerator=None):
        self.sock = PLSmbusUtil.connect()

        if pci:
            self.pci_addr = PLSmbusUtil.encodePCIAddress(pci)
            self.backend = Smbus_pb2.SCD
        else:
            self.pci_addr = 0
            self.backend = Smbus_pb2.KERNEL_DEV
        self.accel_id = accelerator
        self.bus = label
        self.addr = addr

    def read_block(self, addr, n=32):
        result = PLSmbusUtil.read(
            self.sock,
            self.pci_addr,
            self.accel_id,
            self.bus,
            self.addr,
            addr,
            readCurrent=False,
            count=n,
            backend=self.backend,
        )

        return [ord(x) if isinstance(x, (str, bytes)) else x for x in result]

    def write_block(self, addr, vals):
        assert all(i <= 0xFF for i in vals)
        # FIXME: The bytearray call is only needed for Python 2.
        data = bytes(bytearray(vals))
        PLSmbusUtil.write(
            self.sock,
            self.pci_addr,
            self.accel_id,
            self.bus,
            self.addr,
            addr,
            data,
            backend=self.backend,
        )

    def read_reg(self, addr):
        self.write_block((addr >> 8) & 0xFF, [(addr) & 0xFF])
        r = self.read_block(0xFF, 4)
        return r[0] << 24 | r[1] << 16 | r[2] << 8 | r[3]

    def write_reg(self, addr, value):
        b = [
            (addr) & 0xFF,
            (value >> 24) & 0xFF,
            (value >> 16) & 0xFF,
            (value >> 8) & 0xFF,
            (value) & 0xFF,
        ]
        self.write_block((addr >> 8) & 0xFF, b)


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
    ):
        if int(chan_number is not None) + int(bus_number is not None) + int(bool(bus_label)) != 1:
            raise ValueError("Requires one of (chan_number, bus_number, bus_label)")
        if IS_EOS:
            label = (
                bus_number
                if bus_number is not None
                else self.__name_to_bus(bus_label or r"i2c-.*-mux \(chan_id {}\)".format(chan_number)) or bus_label
            )
            self.internal = EosRegAccess(label, address, pci, accelerator)
        else:
            self.internal = MakoRegAccess(mos_label, address)

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
