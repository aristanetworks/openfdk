# ------------------------------------------------------------------------------
#  Copyright (c) 2019-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
#    fdk-support@arista.com
#
#  Description:
#    Helper functions for accessing pci_ids.json
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

from abc import abstractmethod
from collections import defaultdict

import gzip
import logging
import os

from . import helpers


class Parsable:
    @abstractmethod
    def parse(self, _):
        # type: (str) -> Parsable
        pass


class ProgIf(Parsable):  # pylint: disable=abstract-method
    def __init__(self, pciid, name):
        # type: (str, str) -> None
        self.id = pciid
        self.name = name


class SubClass(Parsable):
    def __init__(self, pciid, name):
        # type: (str, str) -> None
        self.id = pciid
        self.name = name
        self.sub_by_id = {}
        self.sub_by_name = defaultdict(list)

    def parse(self, line):
        by_tabs = line.split("  ", 1)
        ret = ProgIf(*by_tabs)
        self.sub_by_id[ret.id] = ret
        self.sub_by_name[ret.name].append(ret)
        return ret


class Class(Parsable):
    def __init__(self, pciid, name):
        # type: (str, str) -> None
        self.id = pciid
        self.name = name
        self.sub_by_id = {}
        self.sub_by_name = defaultdict(list)

    def parse(self, line):
        by_tabs = line.split("  ", 1)
        ret = SubClass(*by_tabs)
        self.sub_by_id[ret.id] = ret
        self.sub_by_name[ret.name].append(ret)
        return ret


class SubVendor(Parsable):  # pylint: disable=abstract-method
    def __init__(self, subvendor_device, name):
        # type: (str, str) -> None
        self.subvendor, self.subdevice = subvendor_device.split()
        self.subvendor = self.subvendor
        self.subdevice = self.subdevice
        self.name = name


class Device(Parsable):
    def __init__(self, pciid, name):
        # type: (str, str) -> None
        self.id = pciid
        self.name = name
        self.sub_by_subvendor = {}
        self.sub_by_subdevice = {}
        self.sub_by_name = defaultdict(list)

    def parse(self, line):
        by_tabs = line.split("  ", 1)
        ret = SubVendor(*by_tabs)
        self.sub_by_subvendor[ret.subvendor] = ret
        self.sub_by_subdevice[ret.subdevice] = ret
        self.sub_by_name[ret.name].append(ret)
        return ret


class Vendor(Parsable):
    def __init__(self, pciid, name):
        # type: (str, str) -> None
        self.id = pciid
        self.name = name
        self.sub_by_id = {}
        self.sub_by_name = defaultdict(list)

    def parse(self, line):
        by_tabs = line.split("  ", 1)
        ret = Device(*by_tabs)
        self.sub_by_id[ret.id] = ret
        self.sub_by_name[ret.name].append(ret)
        return ret


class Base(Parsable):
    class_by_id = {}
    class_by_name = defaultdict(list)  # type: defaultdict[str,list[Class|Vendor]]
    vendor_by_id = {}
    vendor_by_name = defaultdict(list)  # type: defaultdict[str,list[Class|Vendor]]

    def parse(self, line):
        by_tabs = line.split("  ", 1)
        if by_tabs[0].startswith("C"):
            by_tabs[0] = by_tabs[0][2:]
            subclass = Class
            by_id = self.class_by_id
            by_name = self.class_by_name
        else:
            subclass = Vendor
            by_id = self.vendor_by_id
            by_name = self.vendor_by_name
        ret = subclass(*by_tabs)
        by_id[ret.id] = ret
        by_name[ret.name].append(ret)
        return ret


def parse(text):
    # type: (str) -> Base
    previous_ntabs = 0
    stack = []  # type: list[Parsable]
    parent = Base()  # type: Parsable
    current = Base()  # type: Parsable
    for line in text.splitlines():
        n_tabs = line.count("\t", 0, 2)  # There are at most 2 tabs
        stripped_line = line.lstrip()
        if not stripped_line or stripped_line[0] == "#":
            # If the line is empty or starts with '#', then its a comment or doesn't otherwise matter
            continue
        if n_tabs < previous_ntabs:
            for _ in range(previous_ntabs - n_tabs):
                current = parent
                parent = stack.pop()
        elif n_tabs > previous_ntabs:
            stack.append(parent)
            parent = current
        previous_ntabs = n_tabs
        current = parent.parse(stripped_line)
    if stack:
        parent = stack[0]
    # Typing doesn't recognize that unwinding the stack will end up with us have Base
    return parent  # type: ignore


class PCI_IDs(object):
    """Database of PCI IDs, providing name-to-ID and ID-to-name translations"""

    _NUM_HEX_DIGITS = {
        # Vendor and device IDs
        "vendor_id": 4,
        "device_id": 4,
        "subvendor_id": 4,
        "subdevice_id": 4,
        # Class codes
        "class_id": 2,
        "subclass_id": 2,
        "prog_if": 2,
    }

    def __init__(self, pci_ids_files):
        self.db = parse("")  # type: Base
        for maybe_file in pci_ids_files:
            if not os.access(maybe_file, os.R_OK):
                continue
            if maybe_file.endswith(".gz"):
                file_fn = gzip.open
            else:
                file_fn = open
            with file_fn(maybe_file, "r") as f:
                self.db = parse(f.read())  # type: ignore
            break

    @classmethod
    def _id_inttokey(cls, intval, id_type):
        return helpers.hex(intval, pad=cls._NUM_HEX_DIGITS[id_type])

    @classmethod
    def vendor_id_inttokey(cls, intval):
        """
        Convert an integer vendor ID into its hex string representation.
        If leading is True then the string is prefixed with 0x.
        """

        return cls._id_inttokey(intval, "vendor_id")

    @classmethod
    def device_id_inttokey(cls, intval):
        """
        Convert an integer device ID into its hex string representation.
        If leading is True then the string is prefixed with 0x.
        """

        return cls._id_inttokey(intval, "device_id")

    @classmethod
    def class_id_inttokey(cls, intval):
        """
        Convert an integer class ID into its hex string representation.
        If leading is True then the string is prefixed with 0x.
        """

        return cls._id_inttokey(intval, "class_id")

    @classmethod
    def subclass_id_inttokey(cls, intval):
        """
        Convert an integer subclass ID into its hex string representation.
        If leading is True then the string is prefixed with 0x.
        """

        return cls._id_inttokey(intval, "subclass_id")

    @staticmethod
    def get_unique_id(func, name, **kwargs):
        """Helper function to warn if expecting a unique ID"""

        ids = func(name, **kwargs)
        ret_id = ids[0] if ids else None
        if len(ids) > 1:
            logging.info(
                '%s() found unexpected multiple IDs for "%s", returning "%s"',
                func.__name__,
                name,
                ret_id,
            )
        return ret_id

    def get_vendor_name(self, vendor_id):
        """Get the vendor name given a vendor ID."""

        vendor = self.db.vendor_by_id.get(vendor_id)
        if vendor:
            return vendor.name

        return None  # We didn't find it.

    def get_vendor_id(self, vendor_name):
        """Get the vendor ID given a vendor name."""

        vendor = self.db.vendor_by_name.get(vendor_name)
        if vendor:
            return [v.id for v in vendor]

        return None  # We didn't find it.

    def _get_vendor(self, vendor_id=None, vendor_name=None):
        """
        Get the vendor class given a vendor ID or name.
        Vendor name is used only if ID is unspecified.
        """

        if vendor_id:
            return self.db.vendor_by_id.get(vendor_id)
        if vendor_name:
            vendor_id = self.get_vendor_id(vendor_name)
            return self._get_vendor(vendor_id=vendor_id)

        return None  # We didn't find it.

    def get_device_name(self, device_id, vendor_id=None, vendor_name=None):
        """
        Get the device name given a device ID and its vendor ID or name.
        Vendor name is used only if ID is unspecified.
        """

        vendor = self._get_vendor(vendor_id=vendor_id, vendor_name=vendor_name)
        if vendor:
            device = vendor.sub_by_id.get(device_id)
            if device:
                return device.name

        return None  # We didn't find it.

    def get_device_id(self, device_name, vendor_id=None, vendor_name=None):
        """
        Get the device ID given a device name and its vendor ID or name.
        Vendor name is used only if ID is unspecified.
        """

        vendor = self._get_vendor(vendor_id=vendor_id, vendor_name=vendor_name)  # type: Vendor|None
        if vendor:
            device = vendor.sub_by_name.get(device_name)
            if device:
                return [d.id for d in device]

        return None  # We didn't find it.

    def get_class_id(self, class_name):
        """Get the class ID given a class name."""

        dev_class = self.db.class_by_name.get(class_name)
        if dev_class:
            return [c.id for c in dev_class]

        return None  # We didn't find it.

    def _get_class(self, class_id=None, class_name=None):
        """
        Get the class dict given a class ID or name.
        Class name is used only if ID is unspecified.
        """

        if class_id:
            return self.db.class_by_id.get(class_id)
        if class_name:
            class_id = self.get_class_id(class_name)
            return self._get_class(class_id=class_id)

        return None  # We didn't find it.

    def get_subclass_name(self, subclass_id, class_id=None, class_name=None):
        """
        Get the subclass name given a subclass ID and its class ID or name.
        Class name is used only if ID is unspecified.
        """

        dev_class = self._get_class(class_id=class_id, class_name=class_name)
        if dev_class:
            subclass = dev_class.sub_by_id.get(subclass_id)
            if subclass:
                return subclass.name

        return None  # We didn't find it.

    def get_subclass_id(self, subclass_name, class_id=None, class_name=None):
        """
        Get the subclass ID given a subclass name and its class ID or name.
        Class name is used only if ID is unspecified.
        """

        dev_class = self._get_class(class_id=class_id, class_name=class_name)
        if dev_class:
            subclass = dev_class.sub_by_name.get(subclass_name)
            if subclass:
                return [s.id for s in subclass]

        return None  # We didn't find it.
