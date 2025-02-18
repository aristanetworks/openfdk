# ------------------------------------------------------------------------------
#  Copyright (c) 2019 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    Manager for PCI devices on FPGAs
#
#    This code is part of a proof of concept of PCIe on Arista's 7130E and 7130L
#    Series platforms. This application provides a means to verify that PCIe is
#    functional on these platforms and should not be used as a guideline for PCIe
#    designs on these platforms. This method of interfacing to PCIe will become
#    unsupported once MOS API adds official support for PCIe.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

from __future__ import division

import collections
import logging
import re
import time

from . import device, helpers, pci, pci_ids


class FpgaPCIeDeviceManager(object):
    """Class to manage PCIe devices on FPGAs in the system"""

    PCI_IDS = [
        "/usr/share/hwinfo/pci.ids",
        "/usr/share/hwdata/pci.ids",
        "/usr/share/pci.ids.gz",
    ]

    def __init__(self, fpgas, autodetect=True):
        self.pci_ids = pci_ids.PCI_IDs(self.PCI_IDS)
        self.fpgas = fpgas
        self.pci_devmgr = pci.PCIDeviceManager(autodetect=autodetect)
        self.pcie_devices = self._get_managed_pcie_devices()

    @property
    def pcie_devices_by_bdf(self):
        return {dev.bdf: dev for v in self.pcie_devices.values() for dev in v["devices"]}

    @property
    def pcie_bridges_by_bdf(self):
        return {v["bridge"].bdf: v["bridge"] for v in self.pcie_devices.values() if v["bridge"]}

    def _get_managed_pcie_devices(self):

        devices = self._get_fpga_pci_devices()
        for fpga in self.fpgas:
            if fpga.pcie.link_width:
                # Only manage PCIe devices
                devices[fpga.name()]["devices"] = [dev for dev in devices[fpga.name()]["devices"] if dev.is_pcie_device]
            else:
                # If link width is not set then we don't manage any PCIe device on that FPGA
                devices.pop(fpga.name())
        return devices

    def _get_fpga_pci_devices(self):
        """
        Return a dictionary of PCI devices on the FPGAs and their underlying bridge, keyed by FPGA label, e.g.
            {
                "mezzanine.central": {
                    "bridge"  : <bridge>,
                    "devices" : [<PCI device>]
                },
                "mezzanine.leaf_a": {
                    "bridge"  : <bridge>,
                    "devices" : [<PCI device>]
                },
                "mezzanine.leaf_b": {
                    "bridge"  : <bridge>,
                    "devices" : [<PCI device>]
                }
            }
        """

        pci_devices = {}
        for fpga in self.fpgas:
            if getattr(fpga.pcie, "root_port", None):
                vendor_id, bridge_id = fpga.pcie.root_port.split(":")
            else:
                vendor_name = fpga.pcie.root_port_vendor
                vendor_id = self.pci_ids.get_unique_id(self.pci_ids.get_vendor_id, vendor_name)
                bridge_name = fpga.pcie.root_port_name
                bridge_id = self.pci_ids.get_unique_id(self.pci_ids.get_device_id, bridge_name, vendor_id=vendor_id)
                logging.debug(
                    "Looking for bridge with vendor ID %s and device ID %s",
                    str(vendor_id),
                    str(bridge_id),
                )

            try:
                bridges = self.pci_devmgr.get_pci_devices_by_id(vendor_id, bridge_id)
                bridge = None
                for b in bridges:
                    if getattr(b, "port_num") == fpga.pcie.port_num:
                        bridge = b
                        break
                else:
                    # If there were no bridges, this will cause an index error and go to the
                    # handler below
                    bridge = bridges[0]
                if not bridge:
                    # There were bridges, but we didn't match on one
                    bridge = bridges[0]

                # Return all PCI devices on the secondary bus of the bridge since the bridge
                # is connected to only the FPGA
                domain = bridge.bdf.split(":")[0]
                bdf_re = re.compile(domain + ":" + helpers.hex(bridge.secondary_bus, pad=2) + ":.*")
                logging.debug("Looking for PCI device on bus %s", str(bridge.secondary_bus))
                pci_devices[fpga.name()] = {
                    "bridge": bridge,
                    "devices": self.pci_devmgr.get_pci_devices_by_bdf_re(bdf_re),
                }
            except IndexError:
                pci_devices[fpga.name()] = {"bridge": None, "devices": []}

        return pci_devices

    @staticmethod
    def _complete_bdf(bdf):
        """Fill in missing leading zeroes in a BDF"""

        # Allow leading zeroes to be left out
        bdf_re = re.compile(
            "^(?P<domain>[0-9a-fA-F]{1,4}:)?"
            "(?P<bus>[0-9a-fA-F]{1,2}):"
            "(?P<device>[0-1]?[0-9a-fA-F])."
            "(?P<function>[0-7])$"
        )
        m = bdf_re.match(bdf)
        if not m:
            raise ValueError("Invalid BDF {}".format(bdf))

        domain = m.group("domain")
        domain = helpers.hex(int(domain.split(":")[0], 16), pad=4) if domain else "0000"
        bus = helpers.hex(int(m.group("bus"), 16), pad=2)
        dev = helpers.hex(int(m.group("device"), 16), pad=2)
        fn = m.group("function")
        return "{}:{}:{}.{}".format(domain, bus, dev, fn)

    def _get_region(self, bdf, region_num):
        """Return the region which matches the specified BDF and region number"""

        try:
            return [r for r in self.pcie_devices_by_bdf[bdf].regions if r.region_num == region_num][0]
        except KeyError:
            raise ValueError("No device with BDF {}".format(bdf))
        except IndexError:
            raise ValueError("{}: Invalid region {}".format(bdf, region_num))

    ###########################################################################
    #
    # External API starts here
    #
    ###########################################################################

    def wait_for_pci_devices(self, nsecs=2.0):
        # Wait a while to let the devices finish training before rescanning

        time.sleep(nsecs)

    def check_pcie_bifurcation(self):
        """Check that the PCIe bifurcation set in the BIOS is correct and prompt a reboot if it is not"""

        # Check that the link widths for the bridges are as expected
        for fpga in self.fpgas:
            exp_link_width = fpga.pcie.link_width
            in_use = bool(exp_link_width)
            if in_use:
                bridge = self.pcie_devices[fpga.name()]["bridge"]
                if not bridge or exp_link_width > bridge.max_link_width:
                    # Unexpected link width, change to PCIe bifurcation within BIOS is required.
                    bifurc = device.get_pcie_bifurcations(self.fpgas)
                    msg = (
                        "\nIncorrect PCIe bifurcation detected, some devices will not show up or will "
                        "have downtrained link widths. Please reboot and change within BIOS.\n"
                        "Acceptable configurations are: {}".format(", ".join(bifurc))
                    )
                    print(msg)
                    logging.warning(msg)
                    break

    def enable_access_pci_devices(self, memory=False):
        """Enable memory (and I/O - unimplemented) access to managed PCI devices"""

        for dev in self.pcie_devices_by_bdf.values():
            dev.memspace_access_enabled = memory

    def check_access_pci_devices(self, trxn_size=4):  # pylint: disable=too-many-branches
        """
        Check the PCI devices to make sure that they are mapped correctly and there is read/write access.
        Param trxn_size: Split read/writes into multiple transactions of at most trxn_size bytes as
                         some devices may not be able to handle transactions greater than a certain size.
                         If None, then there is no size limit and only one transaction is used.
        """

        # Check that we can read/write to the devices
        unmapped = collections.defaultdict(dict)
        inaccessible = collections.defaultdict(dict)
        for fpga_label, pcie_device in self.pcie_devices.items():
            for dev in pcie_device["devices"]:
                err_regions = {"unmapped": [], "inaccessible": []}

                offset = 0x0
                pattern = "feedface".decode("hex")

                # Only test memory-mapped regions
                for test_region in dev.memspace_regions:
                    # Write and readback a dummy value from the device memory
                    try:
                        old = test_region.read(offset, len(pattern), trxn_size=trxn_size)
                        test_region.write(offset, pattern, trxn_size=trxn_size)
                        if test_region.read(offset, len(pattern), trxn_size=trxn_size) != pattern:
                            err_regions["inaccessible"].append(test_region.region_num)
                            continue
                        test_region.write(offset, old, trxn_size=trxn_size)
                    except pci.RegionNotMappedError:
                        # The operating system has not mapped the region.
                        err_regions["unmapped"].append(test_region.region_num)

                if err_regions["unmapped"]:
                    unmapped[fpga_label][dev.bdf] = err_regions["unmapped"]
                if err_regions["inaccessible"]:
                    inaccessible[fpga_label][dev.bdf] = err_regions["inaccessible"]

        s = "\n"
        if unmapped:
            s += "Some memory-space regions on the following devices are not mapped:\n"
            for fpga_label in sorted(unmapped):
                for bdf in sorted(unmapped[fpga_label]):
                    regions = sorted(unmapped[fpga_label][bdf])
                    s += "    {} {}: Region {}\n".format(fpga_label, bdf, ", Region ".join(map(str, regions)))

        if inaccessible:
            s += "Some memory-space regions on the following devices are inaccessible:\n"
            for fpga_label in sorted(inaccessible):
                for bdf in sorted(inaccessible[fpga_label]):
                    regions = sorted(inaccessible[fpga_label][bdf])
                    s += "    {} {}: Region {}\n".format(fpga_label, bdf, ", Region ".join(map(str, regions)))

        if unmapped or inaccessible:
            s = s.rstrip()
            print(s)
            logging.warning(s)

        return not (unmapped or inaccessible)

    def rescan_pci_devices(self, remove=False, remove_bridge=False):
        """Rescan for PCI devices on the FPGAs"""

        if remove:
            # Remove devices on the FPGAs
            self.remove_pci_devices(remove_bridge=remove_bridge)
        self.pci_devmgr.detect_pci_devices()
        self.pcie_devices = self._get_managed_pcie_devices()

    def remove_pci_devices(self, remove_bridge=False):
        """Remove all PCI devices on the FPGAs. Return a list of BDFs of the removed devices."""

        bdfs = self.pcie_devices_by_bdf.keys()
        if remove_bridge:
            bdfs += self.pcie_bridges_by_bdf.keys()
        devices = self.pcie_devices_by_bdf.values()
        if remove_bridge:
            devices += self.pcie_bridges_by_bdf.values()
        for dev in devices:
            dev.remove()
        self.pcie_devices = self._get_managed_pcie_devices()
        logging.debug("Removing PCI devices %s", str(bdfs))
        return bdfs

    def lspci_devices(self, bdf=None, verbose=False, root=False):
        """List PCI devices on the FPGAs as given by lspci"""

        if bdf:
            return pci.PCIDeviceManager.lspci_devices(bdf=bdf, verbose=verbose, root=root)

        devlist = sorted(
            list(self.pcie_devices_by_bdf.values()),
            key=lambda dev: dev.bdf,
        )
        ret = ""
        for dev in devlist:
            ret += pci.PCIDeviceManager.lspci_devices(bdf=dev.bdf, verbose=verbose, root=root)
        return ret

    def list_devices(self, verbose=False):  # pylint: disable=too-many-locals
        """
        List PCIe devices on the FPGAs as a table in the format (values in brackets are the link capabilities) e.g.

        FPGA              BDF          Link Speed   Link Width Subclass          Vendor             Device
        ----              ---          ----------   ---------- --------          ------             ------
        mezzanine.central 0000:03:00.0 5.0(8.0)GT/s x8(x8)     Memory controller Xilinx Corporation Device name
        """

        # List of rows of the table, initialise with headings
        rows = []
        for fpga_label in sorted(self.pcie_devices):
            devices = sorted(self.pcie_devices[fpga_label]["devices"], key=lambda dev: dev.bdf)
            for dev in devices:
                link_speed = "{:.1f}({:.1f})GT/s".format(dev.link_speed_gtps, dev.max_link_speed_gtps)
                link_speed = {
                    "actual": dev.link_speed_gtps,
                    "max": dev.max_link_speed_gtps,
                }
                link_width = "x{:d}(x{:d})".format(dev.link_width, dev.max_link_width)
                link_width = {
                    "actual": dev.link_width,
                    "max": dev.max_link_width,
                }
                row = {
                    "FPGA": fpga_label,
                    "BDF": dev.bdf,
                    "Link Speed": link_speed,
                    "Link Width": link_width,
                }

                if verbose:
                    class_code = self.pci_ids.class_id_inttokey(dev.class_code)
                    subclass_code = self.pci_ids.subclass_id_inttokey(dev.subclass_code)
                    subclass = {
                        "id": dev.subclass_code,
                        "name": self.pci_ids.get_subclass_name(subclass_code, class_id=class_code),
                    }

                    vendor_id = self.pci_ids.vendor_id_inttokey(dev.vendor_id)
                    vendor = {
                        "id": dev.vendor_id,
                        "name": self.pci_ids.get_vendor_name(vendor_id),
                    }

                    device_id = self.pci_ids.device_id_inttokey(dev.device_id)
                    devname = {
                        "id": dev.device_id,
                        "name": self.pci_ids.get_device_name(device_id, vendor_id=vendor_id),
                    }

                    row.update({"Subclass": subclass, "Vendor": vendor, "Device": devname})
                rows.append(row)
        return rows

    def list_regions(self, verbose=False):
        """
        List the memory regions of PCIe devices on the FPGAs as a table in the format e.g.

        FPGA              BDF     Region   Base Address Size Prefetchable
        ----              ---     ------   ------------ ---- ------------
        mezzanine.central 03:00.0 Region 0 0xdfd00000   2K   Yes
        """

        rows = []

        for fpga_label in sorted(self.pcie_devices):
            devices = sorted(self.pcie_devices[fpga_label]["devices"], key=lambda dev: dev.bdf)
            for dev in devices:
                regions = sorted(dev.regions, key=lambda region: region.region_num)
                for region in regions:
                    memtype = "Mem" if region.maps_into_memory else "I/O"
                    region_info = {
                        "num": region.region_num,
                        "type": memtype,
                    }
                    base_address = {
                        "address": region.base_addr,
                        "width": region.addr_width,
                    }
                    row = {
                        "FPGA": fpga_label,
                        "BDF": dev.bdf,
                        "Region": region_info,
                        "Base Address": base_address,
                        "Size": region.size,
                    }
                    if verbose:
                        row["Prefetchable"] = bool(region.prefetchable)
                    rows.append(row)

        return rows

    def read_region(
        self, bdf, region_num, offset, nbytes, align=True, trxn_size=4
    ):  # pylint: disable=too-many-arguments
        """
        Read the values at address range [offset:offset+nbytes-1] (inclusive) of the specified region.
        Param bdf: [Domain:]Bus:Device.Function identifier, Domain defaults to 0x0000
        Param nbytes: Number of bytes to read. A value of 0 reads the entire region starting from offset.
        Param align: Align accesses to word boundaries, defaults to True
        Param trxn_size: Split the read into multiple read transactions of at most trxn_size bytes as
                         some devices may not be able to handle transactions greater than a certain size.
                         If None, then there is no size limit and only one transaction is used.
                         Must be a multiple of the region's word size.
        """

        region = self._get_region(self._complete_bdf(bdf), region_num)
        nbytes = nbytes if nbytes else max(region.size - offset, 0)
        return region.read(offset, nbytes, align=align, trxn_size=trxn_size)

    def write_region(  # pylint: disable=too-many-arguments
        self, bdf, region_num, value, offset, nbytes=None, align=True, trxn_size=4
    ):
        """
        Write a value at an offset from the base address of the specified region. If nbytes is greater than the length
        of value then value is repeated.
        Param bdf: [Domain:]Bus:Device.Function identifier, Domain defaults to 0x0000
        Param nbytes: Number of bytes to write. A value of 0 fills the entire region starting from offset.
                      Must be a multiple of the length of value. Defaults to the length of value.
        Param align: Align accesses to word boundaries, defaults to True
        Param trxn_size: Split the write into multiple write transactions of at most trxn_size bytes as
                         some devices may not be able to handle transactions greater than a certain size.
                         If None, then there is no size limit and only one transaction is used.
                         Must be a multiple of the region's word size.
        """

        region = self._get_region(self._complete_bdf(bdf), region_num)
        if nbytes is None:
            nbytes = len(value)
        else:
            nbytes = nbytes if nbytes else max(region.size - offset, 0)
            if nbytes % len(value):
                raise ValueError(
                    "Number of bytes ({}) to be written must be a multiple of the length ({}) "
                    "of the specified word".format(nbytes, len(value))
                )
        region.write(offset, value * (nbytes // len(value)), align=align, trxn_size=trxn_size)
