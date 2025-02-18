# ------------------------------------------------------------------------------
#  Copyright (c) 2019 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    Detect and build a collection of PCI(e) devices on the platform by reading
#    device configuration space directly through sysfs (/sys/bus/pci).
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

import logging
import mmap
import os
import re
import subprocess

from . import helpers, shell

# FIXME: Fix up the protected-access violations in this file.
# pylint: disable=protected-access

# Regex patterns
# BDF format is [Domain:]Bus:Device.Function
bdf_re = re.compile("^([0-9a-fA-F]{4}:)?[0-9a-fA-F]{2}:[0-1][0-9a-fA-F].[0-7]$")


class PCIDeviceManager(object):
    """Class to manage all the PCI devices in the system"""

    SYSFS_PCI_PATH = "/sys/bus/pci"
    SYSFS_PCI_DEVICES_PATH = SYSFS_PCI_PATH + "/devices"

    def __init__(self, autodetect=True):
        self.all_devices = {}
        if autodetect:
            self.detect_pci_devices()

    # Factory method for PCI(e) bridges/endpoints
    def _pci_device_factory(self, bdf):
        """
        Creates one of the following objects:
            - PCIEndpoint if header type is 0x00 and PCIe capability is not present
            - PCIBridge if header type is 0x01 and PCIe capability is not present
            - PCIEndpoint if header type is 0x00 and PCIe capability is present
            - PCIBridge if header type is 0x01 and PCIe capability is present
        """

        device_path = self.SYSFS_PCI_DEVICES_PATH + "/" + bdf
        config_path = device_path + "/config"
        try:
            config = PCIDevice._config_load(config_path)
        except subprocess.CalledProcessError:
            # Device with specified BDF does not exist
            logging.info("Could not find device with BDF %s to create", bdf)
            return None
        except ValueError:
            # Device likely got removed whilst we were processing it
            logging.info("Could not load config for BDF %s", bdf)
            return None

        header_type = PCIDevice._config_read_header_type(config)
        if header_type == PCIEndpoint._HEADER_TYPE:
            is_pcie = PCIDevice._config_check_pcie_capability(config)
            obj = PCIeEndpoint if is_pcie else PCIEndpoint
        elif header_type == PCIBridge._HEADER_TYPE:
            is_pcie = PCIDevice._config_check_pcie_capability(config)
            obj = PCIeBridge if is_pcie else PCIBridge
        else:
            logging.info("Detected device %s with invalid header type %x", bdf, header_type)
            return None

        try:
            return obj(bdf=bdf, manager=self, device_path=device_path, config=config)
        except FileNotFoundError:
            # Device was removed whilst it was being loaded
            logging.info("Detected device %s has been removed", bdf)
            return None

    def _delete_device(self, bdf):
        """Remove a device from the device manager"""

        self.all_devices.pop(bdf, None)

    ###########################################################################
    #
    # External API starts here
    #
    ###########################################################################

    def detect_pci_devices(self, bdfs=None):
        """
        Create a list of PCI devices in the system. Invalidates all existing references to detected devices.
        Param bdfs: List of BDFs of devices to detect, includes all devices in the system by default
        """

        self.rescan_pci_devices()
        if not bdfs:
            bdfs = [bdf_re.match(dev).string for dev in os.listdir(self.SYSFS_PCI_DEVICES_PATH)]
        for bdf in bdfs:
            new_device = self._pci_device_factory(bdf)
            if new_device:
                self.all_devices[bdf] = new_device
            else:
                device_path = self.SYSFS_PCI_DEVICES_PATH + "/" + bdf
                try:
                    shell.echo("1", outfile=device_path + "/remove", root=True)
                except subprocess.CalledProcessError:
                    logging.info("Device %s was already removed", bdf)
                self._delete_device(bdf)

    def rescan_pci_devices(self):
        """Rescan all PCI devices in the system."""

        shell.echo("1", outfile=self.SYSFS_PCI_PATH + "/rescan", root=True)

    @staticmethod
    def lspci_devices(  # pylint: disable=too-many-arguments
        bdf="::.", vendor_id="", device_id="", class_id="", verbose=False, root=False
    ):
        """Get a list of PCI devices as given by lspci"""

        # Filter by BDF
        flags = " -s " + bdf
        # Filter by vendor and class IDs, format is [vendor_id]:[device_id][:class_id]
        flags += " -d " + vendor_id + ":" + device_id + ":" + class_id

        if verbose:
            flags += " -vv"

        return shell.shellcmd("lspci" + flags, root=root)

    def get_pci_devices_by_id(self, vendor_id, device_id):
        """Return a list of PCI devices which match the given vendor and device IDs"""

        return [
            dev
            for dev in self.all_devices.values()
            if dev.vendor_id == int(vendor_id, 16) and dev.device_id == int(device_id, 16)
        ]

    def get_pci_devices_by_bdf_re(self, regexp):
        """Return a list of PCI devices whose BDF matches the given regular expression"""

        return [dev for (bdf, dev) in self.all_devices.items() if regexp.match(bdf)]


class RegionNotMappedError(OSError):
    pass


class PCIMemoryRegion(object):  # pylint: disable=too-many-instance-attributes
    """Class representing a memory region of a PCI device"""

    def __init__(  # pylint: disable=too-many-arguments
        self,
        dev,
        region_num,
        resource_path,
        addr_width,
        maps_into_memory,
        base_addr,
        size,
        prefetchable,
        word_size=4,
    ):
        self.dev = dev
        self.region_num = region_num
        self.resource_path = resource_path
        self.addr_width = addr_width
        self.maps_into_memory = maps_into_memory
        self.base_addr = base_addr
        self.size = size
        self.prefetchable = prefetchable
        self.word_size = word_size

        self._mapping = None

    @property
    def mapping(self):
        if not self._mapping:
            self._mapping = self._mmap(self.size)
        return self._mapping

    def _mmap(self, length, offset=0x0):
        """
        Map length bytes from the memory region starting at offset.
        Param offset: Base of the range to map, this will be rounded down to the nearest multiple of
                      the system page size.
        """

        # Need to chmod the file first to have read-write permissions
        # Save current mode
        mode = "{:o}".format(os.stat(self.resource_path).st_mode & helpers._mask_lower(9))
        shell.shellcmd("chmod 666 {}".format(self.resource_path), root=True)
        fd = os.open(self.resource_path, os.O_RDWR)
        mapping = mmap.mmap(fd, length, offset=offset)
        os.close(fd)
        shell.shellcmd("chmod {} {}".format(mode, self.resource_path), root=True)
        return mapping

    def _check_rw_access(self, offset, nbytes, align, trxn_size):
        """Check that a read/write access of nbytes at offset is valid"""

        if not self.is_mapped:
            raise RegionNotMappedError("{}: Memory region is not mapped".format(self.dev.bdf))

        if not self.maps_into_memory:
            raise OSError("{}: Cannot access I/O space".format(self.dev.bdf))

        if not self.dev.memspace_access_enabled:
            raise OSError("{}: Memory space access is not enabled".format(self.dev.bdf))

        if offset < 0 or offset + nbytes > self.size:
            raise ValueError("Address out of range")

        if align and trxn_size and trxn_size % self.word_size:
            raise ValueError(
                "Transaction size {:d} is not a multiple of word size {:d}".format(trxn_size, self.word_size)
            )

    ###########################################################################
    #
    # External API starts here
    #
    ###########################################################################

    @property
    def is_mapped(self):
        """Whether or not the operating system has mapped the region"""

        return self.base_addr != 0x0

    # FIXME: Allow mmapping a region first for better performance if frequent accesses are required.
    def read(self, offset, nbytes, align=True, trxn_size=4):
        """
        Return a string of little endian bytes read from the memory region starting at offset.
        Beware of concurrency issues if other processes are also accessing the memory region.
        Param align: Align accesses to word boundaries, defaults to True
        Param trxn_size: Split the read into multiple read transactions of at most trxn_size bytes as
                         some devices may not be able to handle transactions greater than a certain size.
                         If None, then there is no size limit and only one transaction is used.
                         Must be a multiple of the region's word size.
        """

        self._check_rw_access(offset, nbytes, align=align, trxn_size=trxn_size)

        data = b""

        # First read the unaligned part at the start
        if align and offset % self.word_size:
            lo = (offset // self.word_size) * self.word_size
            self.mapping.seek(lo)
            to_read = min(nbytes, lo + self.word_size - offset)
            data += self.mapping.read(self.word_size)[offset - lo : offset - lo + to_read]
            nbytes -= to_read
        else:
            self.mapping.seek(offset)

        trxn_size = trxn_size if trxn_size else nbytes
        while nbytes >= trxn_size:
            data += self.mapping.read(trxn_size)
            nbytes -= trxn_size

        # Read the remaining aligned part
        if nbytes >= self.word_size:
            to_read = (nbytes // self.word_size) * self.word_size
            data += self.mapping.read(to_read)
            nbytes -= to_read

        # Finally read the unaligned part at the end
        if nbytes > 0:
            data += self.mapping.read(self.word_size)[0:nbytes]
        return data

    def write(self, offset, value, align=True, trxn_size=4):
        """
        Write a string of little endian bytes to the memory region starting at offset.
        Beware of concurrency issues if other processes are also accessing the memory region.
        Param align: Align accesses to word boundaries, defaults to True
        Param trxn_size: Split the write into multiple write transactions of at most trxn_size bytes as
                         some devices may not be able to handle transactions greater than a certain size.
                         If None, then there is no size limit and only one transaction is used.
                         Must be a multiple of the region's word size.
        """

        nbytes = len(value)
        self._check_rw_access(offset, nbytes, align=align, trxn_size=trxn_size)

        # First write the unaligned part at the start
        if align and offset % self.word_size:
            lo = (offset // self.word_size) * self.word_size
            # Read the existing word
            self.mapping.seek(lo)
            word = self.mapping.read(self.word_size)
            i = min(nbytes, lo + self.word_size - offset)
            word = word[0 : offset - lo] + value[:i] + word[offset - lo + i :]
            self.mapping.seek(lo)
            self.mapping.write(word)
        else:
            self.mapping.seek(offset)
            i = 0

        trxn_size = trxn_size if trxn_size else nbytes
        while nbytes - i >= trxn_size:
            self.mapping.write(value[i : i + trxn_size])
            i += trxn_size

        # Write the remaining aligned part
        if nbytes - i >= self.word_size:
            to_write = ((nbytes - i) // self.word_size) * self.word_size
            self.mapping.write(value[i : i + to_write])
            i += to_write

        # Finally write the unaligned part at the end
        if nbytes - i > 0:
            # Read the existing word
            pos = self.mapping.tell()
            word = self.mapping.read(self.word_size)
            word = value[i:] + word[nbytes - i :]
            self.mapping.seek(pos)
            self.mapping.write(word)


class PCICapability(object):
    """Class representing a PCI capability"""

    # (address, nbytes) of generic registers for each capability
    _REGISTERS = {"_CAP_ID": (0x0, 1), "_NEXT_CAP_PTR": (0x1, 1)}

    # Initalise with an invalid header type, this will be overriden by subclasses
    cap_id = 0xFF


class PCIExpressCapability(PCICapability):
    """Class representing the PCI Express capability"""

    cap_id = 0x10
    _cap_size = 0x3C

    _REGISTERS = PCICapability._REGISTERS.copy()
    # FIXME: Incomplete
    _REGISTERS.update({"_LINK_CAP": (0xC, 4), "_LINK_STATUS": (0x12, 2)})

    # Helper functions for each register type to extract fields
    _LINK_CAP_DECODE = {
        "_MAX_LINK_SPEED": lambda reg: reg & helpers._mask_lower(4),
        "_MAX_LINK_WIDTH": lambda reg: (reg >> 4) & helpers._mask_lower(6),
        "_PORT_NUM": lambda reg: (reg >> 24),
    }

    _LINK_STATUS_DECODE = {
        "_LINK_SPEED": lambda reg: reg & helpers._mask_lower(4),
        "_LINK_WIDTH": lambda reg: (reg >> 4) & helpers._mask_lower(6),
    }

    def __init__(self, cap):
        """
        Param capability: bytearray containing the capability
        """

        link_cap = PCIDevice._config_read(cap, *self._REGISTERS["_LINK_CAP"])
        self.max_link_speed = self._LINK_CAP_DECODE["_MAX_LINK_SPEED"](link_cap)
        self.max_link_width = self._LINK_CAP_DECODE["_MAX_LINK_WIDTH"](link_cap)
        self.port_num = self._LINK_CAP_DECODE["_PORT_NUM"](link_cap)
        link_status = PCIDevice._config_read(cap, *self._REGISTERS["_LINK_STATUS"])
        self.link_speed = self._LINK_STATUS_DECODE["_LINK_SPEED"](link_status)
        self.link_width = self._LINK_STATUS_DECODE["_LINK_WIDTH"](link_status)


class PCIDevice(object):  # pylint: disable=too-many-instance-attributes
    """
    Class representing a PCI device.
    This class should really only be constructed through PCI(e)Endpoint or PCI(e)Bridge.
    """

    # (address, nbytes) of registers in the PCI configuration space
    _CONFIG_SPACE = {
        "_VENDOR_ID": (0x0, 2),
        "_DEVICE_ID": (0x2, 2),
        "_COMMAND": (0x4, 2),
        "_STATUS": (0x6, 2),
        "_REVISION_ID": (0x8, 1),
        "_PROG_IF": (0x9, 1),
        "_SUBCLASS_CODE": (0xA, 1),
        "_CLASS_CODE": (0xB, 1),
        "_HEADER_TYPE": (0xE, 1),
        "_CAP_PTR": (0x34, 1),
    }

    # Helper functions for each register type to extract fields
    _COMMAND_DECODE = {
        "_IO_SPACE_EN": lambda reg: reg & helpers._mask([0]),
        "_MEM_SPACE_EN": lambda reg: reg & helpers._mask([1]),
    }

    _HEADER_TYPE_DECODE = {
        "_HEADER_TYPE": lambda reg: reg & helpers._mask_lower(7),
        "_MULTI_FUNCTION": lambda reg: reg & helpers._mask([7]),
    }

    _BASE_ADDRESS_REGS_DECODE = {
        "_IO_SPACE": lambda reg: reg & helpers._mask([0]),
        "_64_BIT": lambda reg: reg & helpers._mask([2]),  # Only valid for registers that map to memory space
        "_PREFETCHABLE": lambda reg: reg & helpers._mask([3]),  # Only valid for registers that map to memory space
    }

    # Helper functions for each register to set fields
    _COMMAND_ENCODE = {
        "_IO_SPACE_EN": lambda reg, value: reg | (value & helpers._mask([0])),
        "_MEM_SPACE_EN": lambda reg, value: reg | ((value << 1) & helpers._mask([1])),
    }

    # Accesses to addresses starting from this require root permission
    _CONFIG_SPACE_PRIV_BASE = 0x40

    # Initalise with an invalid header type, this will be overriden by subclasses
    _HEADER_TYPE = 0xFF

    # FIXME: Incomplete
    # PCI capabilities
    _CAPABILITIES = {PCIExpressCapability.cap_id: PCIExpressCapability}

    def __init__(self, bdf=None, manager=None, device_path=None, config=None):
        """
        This just marks that a device with the specified BDF exists.
        Call self.fill_info() to set device info.
        """

        if bdf_re.match(bdf):
            self.bdf = bdf
            self.manager = manager
            self.device_path = device_path
            self.config_path = self.device_path + "/config"
            self.resource_path = self.device_path + "/resource"
            self.rescan_path = self.device_path + "/rescan"
            self.remove_path = self.device_path + "/remove"
            self._init_info(config=config)
        else:
            raise ValueError("Invalid BDF {}".format(bdf))

    def _init_info(self, config=None):
        """Read and save PCI configuration space info for the device"""

        if not config:
            config = self._config_load(self.config_path)

        # FIXME: Does not fully read configuration space

        # Check that the header type matches
        header_type = self._config_read_header_type(config)
        if header_type != self._HEADER_TYPE:
            raise Exception(
                "{}: Device header type is incorrect, expected {:x}, hardware is {}".format(
                    self.bdf, self._HEADER_TYPE, header_type
                )
            )

        # Capabilities
        caps = self._config_decode_capabilities(config)

        # Check that the device is correctly classified as PCI or PCIe
        is_pcie = PCIExpressCapability.cap_id in caps
        if is_pcie != self.is_pcie_device:
            # is_pcie indicates if the hardware device is PCI or PCIe.
            # self.is_pci_device indicates if this class is for PCI or PCIe.
            raise Exception(
                "{}: {} device expected, hardware is {}".format(
                    self.bdf,
                    "PCIe" if self.is_pcie_device else "PCI",
                    "PCIe" if is_pcie else "PCI",
                )
            )

        # Device identification
        self.vendor_id = self._config_read(config, *self._CONFIG_SPACE["_VENDOR_ID"])
        self.device_id = self._config_read(config, *self._CONFIG_SPACE["_DEVICE_ID"])
        self.revision_id = self._config_read(config, *self._CONFIG_SPACE["_REVISION_ID"])
        self.prog_if = self._config_read(config, *self._CONFIG_SPACE["_PROG_IF"])
        self.subclass_code = self._config_read(config, *self._CONFIG_SPACE["_SUBCLASS_CODE"])
        self.class_code = self._config_read(config, *self._CONFIG_SPACE["_CLASS_CODE"])
        self.header_type = self._HEADER_TYPE

        # Memory regions
        self.regions = self._config_decode_regions(config)

        self.caps = caps

    @staticmethod
    def _config_load(config_path):
        """Read the device's config file and return it as a bytearray."""

        # Read the standard PCI header, accesses after _CONFIG_SPACE_PRIV_BASE require root permission
        cmd = "hexdump -ve '1/1 \" %.2x\"' " + config_path
        config_bytes = [int(b, 16) for b in shell.shellcmd(cmd, root=True).split()]
        config = bytearray(config_bytes)
        return config

    @staticmethod
    def _config_read(config, addr, nbytes):
        """
        Read bytes addr:(addr + nbytes) from the device's config file as an integer.
        Param config: bytearray of the device's config file
        """

        ret = 0
        for i in range(addr + nbytes - 1, addr - 1, -1):
            ret = (ret << 8) + config[i]
        return ret

    @classmethod
    def _config_read_header_type(cls, config):
        # Bit 7 of the header type is used to indicate if the device has multiple functions
        reg = cls._config_read(config, *cls._CONFIG_SPACE["_HEADER_TYPE"])
        return cls._HEADER_TYPE_DECODE["_HEADER_TYPE"](reg)

    def _config_decode_regions(self, config):  # pylint: disable=too-many-locals
        """Decode base address registers to figure out the device's memory regions"""

        regions = []

        # Base address registers:
        #     Bits 0 to 3 are read-only.
        #     If bit 0 is 0 then the corresponding memory region maps into I/O space:
        #         - bit 1 is reserved,
        #     If bit 0 is 1 then the region maps into memory space:
        #         - bit 1 is reserved (as of PCI Local Bus Spec. Rev. 3.0),
        #         - bit 2 indicates base address register width:
        #               - 32 bits if bit 2 is 0
        #               - 64 bits if bit 2 is 1
        #         - bit 3 indicates if the region is prefetchable
        with open(self.resource_path) as f:  # pylint: disable=unspecified-encoding
            bar_num = 0
            (addr, nbytes) = self._CONFIG_SPACE["_BASE_ADDRESS_REGS"]
            end = addr + nbytes
            while addr < end:
                bar_width = 4
                bar = self._config_read(config, addr, bar_width)
                resource = f.readline().split()
                if bar != 0:
                    is_memory_space = not bool(self._BASE_ADDRESS_REGS_DECODE["_IO_SPACE"](bar))
                    if is_memory_space:
                        # Maps into memory space
                        bar_width = 8 if self._BASE_ADDRESS_REGS_DECODE["_64_BIT"](bar) else 4
                        prefetchable = bool(self._BASE_ADDRESS_REGS_DECODE["_PREFETCHABLE"](bar))
                    else:
                        # Maps into I/O space
                        prefetchable = None

                    # We can get the base address and region size from the device's resource file in sysfs.
                    base_addr = int(resource[0], 16)
                    end_addr = int(resource[1], 16)
                    if bar_width == 8:
                        # Takes up two base address registers
                        resource = f.readline().split()
                        base_addr = (int(resource[0], 16) << 32) + base_addr
                        end_addr = (int(resource[1], 16) << 32) + end_addr
                    size = end_addr - base_addr + 1

                    resource_path = self.device_path + "/resource" + str(bar_num)
                    regions.append(
                        PCIMemoryRegion(
                            self,
                            bar_num,
                            resource_path,
                            bar_width,
                            is_memory_space,
                            base_addr,
                            size,
                            prefetchable,
                        )
                    )

                addr += bar_width
                bar_num += bar_width // 4

        return regions

    def _config_decode_capabilities(self, config):
        """Follow the capability linked list to determine the capabilities which this device supports"""

        caps = {}
        cap_ptr = self._config_read(config, *self._CONFIG_SPACE["_CAP_PTR"])
        while cap_ptr != 0:
            (offset, reg_size) = PCICapability._REGISTERS["_CAP_ID"]
            cap_id = self._config_read(config, cap_ptr + offset, reg_size)
            cap_class = PCIDevice._CAPABILITIES.get(cap_id)
            if cap_class:
                cap_end = cap_ptr + cap_class._cap_size
                cap = config[cap_ptr:cap_end]
                caps[cap_id] = cap_class(cap)
                cap_ptr = self._config_read(cap, *PCICapability._REGISTERS["_NEXT_CAP_PTR"])
            else:
                # FIXME: Capability is not supoorted
                (offset, reg_size) = PCICapability._REGISTERS["_NEXT_CAP_PTR"]
                cap_ptr = self._config_read(config, cap_ptr + offset, reg_size)

        return caps

    @classmethod
    def _config_check_pcie_capability(cls, config):
        """Check the device's config file to find out if it supports the PCIe capability"""

        # Follow the linked list
        cap_ptr = cls._config_read(config, *cls._CONFIG_SPACE["_CAP_PTR"])
        while cap_ptr != 0:
            (offset, reg_size) = PCICapability._REGISTERS["_CAP_ID"]
            cap_id = cls._config_read(config, cap_ptr + offset, reg_size)
            if cap_id == PCIExpressCapability.cap_id:
                return True
            (offset, reg_size) = PCICapability._REGISTERS["_NEXT_CAP_PTR"]
            cap_ptr = cls._config_read(config, cap_ptr + offset, reg_size)

        return False

    ###########################################################################
    #
    # External API starts here
    #
    ###########################################################################

    @property
    def is_pcie_device(self):
        return False

    @property
    def iospace_regions(self):
        """List of regions mapped into I/O space"""

        return [region for region in self.regions if not region.maps_into_memory]

    @property
    def memspace_regions(self):
        """List of regions mapped into memory space"""

        return [region for region in self.regions if region.maps_into_memory]

    @property
    def memspace_access_enabled(self):
        """Whether memory space accesses are enabled"""

        if not hasattr(self, "_memspace_access_enabled"):
            reg = self.config_read_setpci(*self._CONFIG_SPACE["_COMMAND"])
            self._memspace_access_enabled = bool(self._COMMAND_DECODE["_MEM_SPACE_EN"](reg))
        return self._memspace_access_enabled

    @memspace_access_enabled.setter
    def memspace_access_enabled(self, en):
        """Whether memory space accesses are enabled"""

        reg = self._COMMAND_ENCODE["_MEM_SPACE_EN"](self.memspace_access_enabled, int(en))
        self.config_write_setpci(reg, *self._CONFIG_SPACE["_COMMAND"])
        self._memspace_access_enabled = en

    def nmi_generation_control(self, disable):
        # See http://aid/7866 for details on NMI control
        _CAP_REGS = {
            "device_control": (0x8, 2, "CAP_EXP"),
            "ce_mask": (0x14, 4, "ECAP_AER"),
            "ue_mask": (0x8, 4, "ECAP_AER"),
        }

        device_control = self.config_read_setpci(*_CAP_REGS["device_control"])
        ce_mask = self.config_read_setpci(*_CAP_REGS["ce_mask"])
        ue_mask = self.config_read_setpci(*_CAP_REGS["ue_mask"])

        if disable:
            device_control &= ~0b111
            ue_mask |= 0b1 << 5
            ce_mask |= 0b1 << 0
        else:
            device_control |= 0b111
            ue_mask &= ~(0b1 << 5)
            ce_mask &= ~(0b1 << 0)

        self.config_write_setpci(device_control, *_CAP_REGS["device_control"])
        self.config_write_setpci(ce_mask, *_CAP_REGS["ce_mask"])
        self.config_write_setpci(ue_mask, *_CAP_REGS["ue_mask"])

    def rescan(self, remove=False):
        """
        Rescan the device.

        If the device is not removed then rescanning is successful only if the corresponding object
        type of the underlying hardware does not change, e.g. from PCIEndpoint to PCIeBridge.
        Otherwise an exception is raised.

        If the device is removed then all references to it are invalidated.
        Get a new reference to the device by specifying its BDF to PCIDeviceManager.
        """

        if remove:
            bdf = self.bdf
            manager = self.manager
            self.remove()
            manager.rescan_pci_devices()
            manager.detect_pci_devices(bdfs=[bdf])
        else:
            shell.echo("1", outfile=self.rescan_path, root=True)
            config = self._config_load(self.config_path)
            self._init_info(config=config)

    def remove(self):
        """Remove the device from the system. All references to the device are invalidated."""

        if self.bdf:
            try:
                shell.echo("1", outfile=self.remove_path, root=True)
            except subprocess.CalledProcessError:
                logging.info("Device %s was already removed", self.bdf)

            # Remove the device from its device manager
            self.manager._delete_device(self.bdf)
            self.manager = None
            self.bdf = None

    def config_read_setpci(self, addr, nbytes, cap_name=None):
        """
        Read bytes addr:(addr + nbytes) from the device's PCI configuration space as an integer.
        Uses setpci for simplicity. The returned integer represents a bitstring in little endian format.
        This method is very slow because it may spawn a new subprocess for each byte read.
        Prefer using config_read instead, which reads from the device's config file.
        """

        width = {1: "b", 2: "w", 4: "l"}.get(nbytes)
        cap = "{}+".format(cap_name) if cap_name is not None else ""

        if width:
            # Try reading word size first
            try:
                cmd = "setpci -s {} {}{}.{}".format(self.bdf, cap, helpers.hex(addr), width)
                return int(shell.shellcmd(cmd), 16)
            except subprocess.CalledProcessError:
                # Might fail because setpci does not like the address alignment,
                # instead just read one byte at a time
                pass

        ret = 0
        for i in range(addr + nbytes - 1, addr - 1, -1):
            cmd = "setpci -s {} {}.b".format(self.bdf, helpers.hex(i))
            ret = (ret << 8) + int(shell.shellcmd(cmd), 16)
        return ret

    def config_write_setpci(self, value, addr, nbytes, cap_name=None):
        """
        Write value as a length nbytes bitstring to the device's configuration space, starting at address addr.
        Param value: integer interpreted as a little endian bitstring of length nbytes
        """

        width = {1: "b", 2: "w", 4: "l"}.get(nbytes)
        cap = "{}+".format(cap_name) if cap_name is not None else ""

        if width:
            # Try writing word size first
            try:
                cmd = "setpci -s {} {}{}.{}={}".format(self.bdf, cap, helpers.hex(addr), width, helpers.hex(value))
                shell.shellcmd(cmd, root=True)
                return
            except subprocess.CalledProcessError:
                # Might fail because setpci does not like the address alignment,
                # instead just write one byte at a time
                pass

        for i in range(addr, addr + nbytes - 1):
            byte = value & helpers.mask_lower(8)
            cmd = "setpci -s {} {}.b={}".format(self.bdf, helpers.hex(i), helpers.hex(byte))
            value >>= 8


class PCIEndpoint(PCIDevice):
    """Class representing a PCI endpoint"""

    # Total number of base address registers
    _NUM_BARS = 6

    # Specify the size of the BAR region
    _CONFIG_SPACE = PCIDevice._CONFIG_SPACE.copy()
    _CONFIG_SPACE.update(
        {
            # Variable number of BARs depending on device type, given by _NUM_BARS
            "_BASE_ADDRESS_REGS": (0x10, _NUM_BARS * 4)
        }
    )

    _HEADER_TYPE = 0x0

    def __init__(self, config=None, **kwargs):
        super(PCIEndpoint, self).__init__(config=config, **kwargs)
        logging.debug("Device %s is a %s", self.bdf, self.__class__.__name__)


class PCIBridge(PCIDevice):
    """Class representing a PCI bridge"""

    # Total number of base address registers
    _NUM_BARS = 2

    # Specify the size of the BAR region
    _CONFIG_SPACE = PCIDevice._CONFIG_SPACE.copy()
    _CONFIG_SPACE.update(
        {
            # Variable number of BARs depending on device type, given by _NUM_BARS
            "_BASE_ADDRESS_REGS": (0x10, _NUM_BARS * 4),
            "_SECONDARY_BUS_NUMBER": (0x19, 1),
        }
    )

    _HEADER_TYPE = 0x1

    def __init__(self, config=None, **kwargs):
        super(PCIBridge, self).__init__(config=config, **kwargs)
        self.secondary_bus = self._config_read(config, *self._CONFIG_SPACE["_SECONDARY_BUS_NUMBER"])
        logging.debug("Device %s is a %s", self.bdf, self.__class__.__name__)


class PCIeDevice(PCIDevice):
    """Class representing a PCIe device"""

    # Convert link speed encoding to GT/s
    _LINK_SPEED_TO_GTPS = {1: 2.5, 2: 5.0, 3: 8.0}

    # Convert link speed encoding to Gb/s
    _LINK_SPEED_TO_GBPS = {
        1: _LINK_SPEED_TO_GTPS[1] * 8 / 10,  # 8b10b encoding
        2: _LINK_SPEED_TO_GTPS[2] * 8 / 10,  # 8b10b encoding
        3: _LINK_SPEED_TO_GTPS[3] * 128 / 130,  # 128b130b encoding
    }

    def __init__(self, **kwargs):
        super(PCIeDevice, self).__init__(**kwargs)

    @property
    def is_pcie_device(self):
        return True

    def _decode_link_speed(self, link_speed, units=None):
        """
        Return the max link speed (of a single lane) in various units:
        Param: units
            "GTps"   : Return link_speed in units of GT/s
            "Gbps"   : Return link_speed in units of Gb/s
            Otherwise: Return link_speed as passed in
        """

        if units == "GTps":
            return self._LINK_SPEED_TO_GTPS[link_speed]

        if units == "Gbps":
            return self._LINK_SPEED_TO_GBPS[link_speed]

        return link_speed

    @property
    def max_link_speed(self):
        return self.caps[PCIExpressCapability.cap_id].max_link_speed

    @property
    def max_link_speed_gtps(self):
        return self._decode_link_speed(self.max_link_speed, units="GTps")

    @property
    def max_link_speed_gbps(self):
        return self._decode_link_speed(self.max_link_speed, units="Gbps")

    @property
    def max_link_width(self):
        return self.caps[PCIExpressCapability.cap_id].max_link_width

    @property
    def link_speed(self):
        return self.caps[PCIExpressCapability.cap_id].link_speed

    @property
    def link_speed_gtps(self):
        return self._decode_link_speed(self.link_speed, units="GTps")

    @property
    def link_speed_gbps(self):
        return self._decode_link_speed(self.link_speed, units="Gbps")

    @property
    def link_width(self):
        return self.caps[PCIExpressCapability.cap_id].link_width

    @property
    def port_num(self):
        return self.caps[PCIExpressCapability.cap_id].port_num


class PCIeEndpoint(PCIeDevice, PCIEndpoint):
    """Class representing a PCIe endpoint"""

    def __init__(self, config=None, **kwargs):
        super(PCIeEndpoint, self).__init__(config=config, **kwargs)


class PCIeBridge(PCIeDevice, PCIBridge):
    """Class representing a PCIe bridge"""

    def __init__(self, config=None, **kwargs):
        super(PCIeBridge, self).__init__(config=config, **kwargs)
