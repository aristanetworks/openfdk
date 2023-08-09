# ------------------------------------------------------------------------------
#  Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
#    fdk-support@arista.com
#
#  Description:
#    FPGA access library.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------
"""Wrappers for accessing FPGAs and other devices on 7130 switches."""

from __future__ import absolute_import, division, print_function

import os
import re
import subprocess
import time

from netaddr import EUI
from six.moves import range

from . import IS_EOS, register_accessor, clock_generator

# FIXME: Use Subprocess32 once it is available in EOS.
# if sys.version_info[0] >= 3:
#    import subprocess
# else:
#    import subprocess32 as subprocess

if not IS_EOS:
    import mosapi
else:
    from AgentDirectory import agentIsRunning

skus = [
    {
        # Pattern matches all 7130C (Cassowary) Devices
        "sku_pattern": re.compile(r"DCS-7130-\d{2}CP?($|-.*)"),
        "fpgas": [
            {
                "identifier": "Fpga1",
                "label": "mezzanine.default",
                "board_standard": "c",
                "interfaces": {
                    "i2c_app": {
                        "bus_label": "i2c-gpio-1",
                        "mos_label": "mezzanine.default",
                    },
                    "i2c_sys": {},
                    "app_ports": "1-76",
                    "jtag": {},
                    "pcie": {},
                    "clkgen": {},
                },
            },
        ],
    },
    {
        # Pattern matches all 7130K (Kookaburra) Devices
        "sku_pattern": re.compile(r"DCS-7130-\d{2}K[ACL]?($|-.*)"),
        "fpgas": [
            {
                "identifier": "Fpga1",
                "label": "mezzanine.default",
                "board_standard": "k",
                "interfaces": {
                    "i2c_app": {
                        "bus_label": "i2c-gpio-1",
                        "mos_label": "mezzanine.default",
                    },
                    "i2c_sys": {},
                    "app_ports": "1-34",
                    "jtag": {},
                    "pcie": {},
                    "clkgen": {},
                },
            },
        ],
    },
    {
        # Pattern matches all 7130L (Lyrebird-VU7P-2) Devices
        "sku_pattern": re.compile(r"DCS-7130-\d{2}L(A|C)?S?($|-.*)"),
        "fpgas": [
            {
                "identifier": "Fpga1",
                "label": "mezzanine.default",
                "board_standard": "l",
                "interfaces": {
                    "i2c_app": {
                        "chan_number": 5,
                        "mos_label": "mezzanine.default",
                    },
                    "i2c_sys": {
                        "chan_number": 1,
                        "address": 0x66,
                        "mos_label": "main_sys",
                    },
                    "app_ports": "1-60",
                    "jtag": {},
                    "pcie": {
                        "root_port": "8086:1f12",
                        "root_port_name": "Atom processor C2000 PCIe Root Port 3",
                        "root_port_vendor": "Intel Corporation",
                        "link_width": 8,
                    },
                    "clkgen": {
                        "device": "Si5345",
                        "chan_number": 0,
                        "address": 0x6B,
                        "mos_label": "mezzanine",
                    },
                },
            },
        ],
    },
    {
        # Pattern matches all 7130LB (Lyrebird-VU9P-3) Devices
        "sku_pattern": re.compile(r"DCS-7130-\d{2}LB(A|C)?S?($|-.*)"),
        "fpgas": [
            {
                "identifier": "Fpga1",
                "label": "mezzanine.default",
                "board_standard": "lb2",
                "interfaces": {
                    "i2c_app": {
                        "chan_number": 5,
                        "mos_label": "mezzanine.default",
                    },
                    "i2c_sys": {
                        "chan_number": 1,
                        "address": 0x66,
                        "mos_label": "main_sys",
                    },
                    "app_ports": "1-60",
                    "jtag": {},
                    "pcie": {
                        "root_port": "8086:1f12",
                        "root_port_name": "Atom processor C2000 PCIe Root Port 3",
                        "root_port_vendor": "Intel Corporation",
                        "link_width": 8,
                    },
                    "clkgen": {
                        "device": "Si5345",
                        "chan_number": 0,
                        "address": 0x6B,
                        "mos_label": "mezzanine",
                    },
                },
            },
        ],
    },
    {
        # Pattern matches all 7130EA (EMU-VU9P-2) Devices
        "sku_pattern": re.compile(r"DCS-7130-\d{2}EAS?($|-.*)"),
        "fpgas": [
            {
                "identifier": "Fpga1",
                "label": "mezzanine.central",
                "board_standard": "ed_central",
                "interfaces": {
                    "i2c_app": {
                        "chan_number": 5,
                        "mos_label": "mezzanine.central",
                    },
                    "i2c_sys": {
                        "chan_number": 1,
                        "address": 0x66,
                        "mos_label": "main_sys",
                    },
                    "app_ports": "1-56",
                    "jtag": {
                        "usb_path": "1-1.4.2",
                    },
                    "pcie": {
                        "root_port": "8086:1f12",
                        "root_port_name": "Atom processor C2000 PCIe Root Port 3",
                        "root_port_vendor": "Intel Corporation",
                        "link_width": 8,
                    },
                    "clkgen": {
                        "device": "Si5345",
                        "chan_number": 0,
                        "address": 0x6B,
                        "mos_label": "mezzanine",
                    },
                },
            },
        ],
    },
    {
        # Pattern matches all 7130EB (EMU-VU9P-3) Devices
        "sku_pattern": re.compile(r"DCS-7130-\d{2}EBS?($|-.*)"),
        "fpgas": [
            {
                "identifier": "Fpga1",
                "label": "mezzanine.central",
                "board_standard": "eh_central",
                "interfaces": {
                    "i2c_app": {
                        "chan_number": 5,
                        "mos_label": "mezzanine.central",
                    },
                    "i2c_sys": {
                        "chan_number": 1,
                        "address": 0x66,
                        "mos_label": "main_sys",
                    },
                    "app_ports": "1-56",
                    "jtag": {
                        "usb_path": "1-1.4.2",
                    },
                    "pcie": {
                        "root_port": "8086:1f12",
                        "root_port_name": "Atom processor C2000 PCIe Root Port 3",
                        "root_port_vendor": "Intel Corporation",
                        "link_width": 8,
                    },
                    "clkgen": {
                        "device": "Si5345",
                        "chan_number": 0,
                        "address": 0x6B,
                        "mos_label": "mezzanine",
                    },
                },
            },
        ],
    },
    {
        # Pattern matches all 7130E (EMU-KU095-2) Devices
        "sku_pattern": re.compile(r"DCS-7130-\d{2}ES?($|-.*)"),
        "fpgas": [
            {
                "identifier": "Fpga1",
                "label": "mezzanine.central",
                "board_standard": "e_central",
                "interfaces": {
                    "i2c_app": {
                        "chan_number": 5,
                        "mos_label": "mezzanine.central",
                    },
                    "i2c_sys": {
                        "chan_number": 1,
                        "address": 0x66,
                        "mos_label": "main_sys",
                    },
                    "app_ports": "1-56",
                    "jtag": {
                        "usb_path": "1-1.4.2",
                    },
                    "pcie": {
                        "root_port": "8086:1f12",
                        "root_port_name": "Atom processor C2000 PCIe Root Port 3",
                        "root_port_vendor": "Intel Corporation",
                        "link_width": 8,
                    },
                    "clkgen": {
                        "device": "Si5345",
                        "chan_number": 0,
                        "address": 0x6B,
                        "mos_label": "mezzanine",
                    },
                },
            },
        ],
    },
    {
        # Pattern matches all 7130ED (EMU-3xVU9P-2) Devices
        "sku_pattern": re.compile(r"DCS-7130-\d{2}EDS?($|-.*)"),
        "fpgas": [
            {
                "identifier": "Fpga1",
                "label": "mezzanine.central",
                "board_standard": "ed_central",
                "interfaces": {
                    "i2c_app": {
                        "chan_number": 5,
                        "mos_label": "mezzanine.central",
                    },
                    "i2c_sys": {
                        "chan_number": 1,
                        "address": 0x66,
                        "mos_label": "main_sys",
                    },
                    "app_ports": "1-56",
                    "jtag": {
                        "usb_path": "1-1.4.2",
                    },
                    "pcie": {
                        "root_port": "8086:1f12",
                        "root_port_name": "Atom processor C2000 PCIe Root Port 3",
                        "root_port_vendor": "Intel Corporation",
                        "link_width": 8,
                    },
                    "clkgen": {
                        "device": "Si5345",
                        "chan_number": 0,
                        "address": 0x6B,
                        "mos_label": "mezzanine",
                    },
                },
            },
            {
                "identifier": "Fpga2",
                "label": "mezzanine.leaf_a",
                "board_standard": "ed_leaf",
                "interfaces": {
                    "i2c_app": {
                        "chan_number": 6,
                        "mos_label": "mezzanine.leaf_a",
                    },
                    "i2c_sys": {
                        "chan_number": 2,
                        "address": 0x66,
                        "mos_label": "sec_sys",
                    },
                    "app_ports": "57-70",
                    "jtag": {
                        "usb_path": "1-1.4.3",
                        "index": 0,
                    },
                    "pcie": {
                        "root_port": "8086:1f10",
                        "root_port_name": "Atom processor C2000 PCIe Root Port 1",
                        "root_port_vendor": "Intel Corporation",
                        "link_width": 4,
                    },
                    "clkgen": {},
                },
            },
            {
                "identifier": "Fpga1",
                "label": "mezzanine.leaf_b",
                "board_standard": "ed_leaf",
                "interfaces": {
                    "i2c_app": {
                        "chan_number": 7,
                        "mos_label": "mezzanine.leaf_b",
                    },
                    "i2c_sys": {
                        "chan_number": 2,
                        "address": 0x67,
                        "mos_label": "sec_sys",
                    },
                    "app_ports": "71-84",
                    "jtag": {
                        "usb_path": "1-1.4.3",
                        "index": 1,
                    },
                    "pcie": {
                        "root_port": "8086:1f11",
                        "root_port_name": "Atom processor C2000 PCIe Root Port 2",
                        "root_port_vendor": "Intel Corporation",
                        "link_width": 4,
                    },
                    "clkgen": {},
                },
            },
        ],
    },
    {
        # Pattern matches all 7130EP (EMU-3xKU095-2) Devices
        "sku_pattern": re.compile(r"DCS-7130-\d{2}EPS?($|-.*)"),
        "fpgas": [
            {
                "identifier": "Fpga1",
                "label": "mezzanine.central",
                "board_standard": "e_central",
                "interfaces": {
                    "i2c_app": {
                        "chan_number": 5,
                        "mos_label": "mezzanine.central",
                    },
                    "i2c_sys": {
                        "chan_number": 1,
                        "address": 0x66,
                        "mos_label": "main_sys",
                    },
                    "app_ports": "1-56",
                    "jtag": {
                        "usb_path": "1-1.4.2",
                    },
                    "pcie": {
                        "root_port": "8086:1f12",
                        "root_port_name": "Atom processor C2000 PCIe Root Port 3",
                        "root_port_vendor": "Intel Corporation",
                        "link_width": 8,
                    },
                    "clkgen": {
                        "device": "Si5345",
                        "chan_number": 0,
                        "address": 0x6B,
                        "mos_label": "mezzanine",
                    },
                },
            },
            {
                "identifier": "Fpga2",
                "label": "mezzanine.leaf_a",
                "board_standard": "e_leaf",
                "interfaces": {
                    "i2c_app": {
                        "chan_number": 6,
                        "mos_label": "mezzanine.leaf_a",
                    },
                    "i2c_sys": {
                        "chan_number": 2,
                        "address": 0x66,
                        "mos_label": "sec_sys",
                    },
                    "app_ports": "57-70",
                    "jtag": {
                        "usb_path": "1-1.4.3",
                        "index": 0,
                    },
                    "pcie": {
                        "root_port": "8086:1f10",
                        "root_port_name": "Atom processor C2000 PCIe Root Port 1",
                        "root_port_vendor": "Intel Corporation",
                        "link_width": 4,
                    },
                    "clkgen": {},
                },
            },
            {
                "identifier": "Fpga3",
                "label": "mezzanine.leaf_b",
                "board_standard": "e_leaf",
                "interfaces": {
                    "i2c_app": {
                        "chan_number": 7,
                        "mos_label": "mezzanine.leaf_b",
                    },
                    "i2c_sys": {
                        "chan_number": 2,
                        "address": 0x67,
                        "mos_label": "sec_sys",
                    },
                    "app_ports": "71-84",
                    "jtag": {
                        "usb_path": "1-1.4.3",
                        "index": 1,
                    },
                    "pcie": {
                        "root_port": "8086:1f11",
                        "root_port_name": "Atom processor C2000 PCIe Root Port 2",
                        "root_port_vendor": "Intel Corporation",
                        "link_width": 4,
                    },
                    "clkgen": {},
                },
            },
        ],
    },
    {
        # Pattern matches all 7130EH (EMU-3xVU9P-3) Devices
        "sku_pattern": re.compile(r"DCS-7130-\d{2}EHS?($|-.*)"),
        "fpgas": [
            {
                "identifier": "Fpga1",
                "label": "mezzanine.central",
                "board_standard": "eh_central",
                "interfaces": {
                    "i2c_app": {
                        "chan_number": 5,
                        "mos_label": "mezzanine.central",
                    },
                    "i2c_sys": {
                        "chan_number": 1,
                        "address": 0x66,
                        "mos_label": "main_sys",
                    },
                    "app_ports": "1-56",
                    "jtag": {
                        "usb_path": "1-1.4.2",
                    },
                    "pcie": {
                        "root_port": "8086:1f12",
                        "root_port_name": "Atom processor C2000 PCIe Root Port 3",
                        "root_port_vendor": "Intel Corporation",
                        "link_width": 8,
                    },
                    "clkgen": {
                        "device": "Si5345",
                        "chan_number": 0,
                        "address": 0x6B,
                        "mos_label": "mezzanine",
                    },
                },
            },
            {
                "identifier": "Fpga2",
                "label": "mezzanine.leaf_a",
                "board_standard": "eh_leaf",
                "interfaces": {
                    "i2c_app": {
                        "chan_number": 6,
                        "mos_label": "mezzanine.leaf_a",
                    },
                    "i2c_sys": {
                        "chan_number": 2,
                        "address": 0x66,
                        "mos_label": "sec_sys",
                    },
                    "app_ports": "57-70",
                    "jtag": {
                        "usb_path": "1-1.4.3",
                        "index": 0,
                    },
                    "pcie": {
                        "root_port": "8086:1f10",
                        "root_port_name": "Atom processor C2000 PCIe Root Port 1",
                        "root_port_vendor": "Intel Corporation",
                        "link_width": 4,
                    },
                    "clkgen": {},
                },
            },
            {
                "identifier": "Fpga3",
                "label": "mezzanine.leaf_b",
                "board_standard": "eh_leaf",
                "interfaces": {
                    "i2c_app": {
                        "chan_number": 7,
                        "mos_label": "mezzanine.leaf_b",
                    },
                    "i2c_sys": {
                        "chan_number": 2,
                        "address": 0x67,
                        "mos_label": "sec_sys",
                    },
                    "app_ports": "71-84",
                    "jtag": {
                        "usb_path": "1-1.4.3",
                        "index": 1,
                    },
                    "pcie": {
                        "root_port": "8086:1f11",
                        "root_port_name": "Atom processor C2000 PCIe Root Port 2",
                        "root_port_vendor": "Intel Corporation",
                        "link_width": 4,
                    },
                    "clkgen": {},
                },
            },
        ],
    },
    {
        # Pattern matches all 7130LBR (Tamarama) Devices
        "sku_pattern": re.compile("DCS-7130LB[2R]-.*"),
        "fpgas": [
            {
                "identifier": "Fpga1",
                "label": "Application FPGA 1",
                "board_standard": "lb2",
                "interfaces": {
                    "i2c_app": {
                        "pci": "01:00.0",
                        "accelerator": 12 if IS_EOS and agentIsRunning("ar", "PLSmbusMediator") else 10,
                        "bus_number": 0,
                    },
                    "i2c_sys": {
                        "pci": "01:00.0",
                        "accelerator": 18 if IS_EOS and agentIsRunning("ar", "PLSmbusMediator") else 16,
                        "bus_number": 0,
                        "address": 0x66,
                    },
                    "app_ports": "",  # FIX ME!!!
                    "jtag": {
                        "index": 0,
                        "options": ["-J10000000"],
                    },
                    "pcie": {
                        "root_port": "10b5:8725",
                        "root_port_name": (
                            "PEX 8725 24-Lane, 10-Port PCI Express Gen 3 (8.0 GT/s) Multi-Root Switch with DMA"
                        ),
                        "root_port_vendor": "PLX Technology, Inc.",
                        "link_width": 2,
                        "port_num": 1,
                    },
                    "clkgen": {
                        "device": "LMK05318",
                        "accelerator": 2,
                        "bus_number": 5,
                        "address": 0x66,
                        "pci": "01:00.0",
                        "scd_pll_lock": ["0x300", 13],
                    },
                },
            },
            {
                "identifier": "Fpga2",
                "label": "Application FPGA 2",
                "board_standard": "lb2",
                "interfaces": {
                    "i2c_app": {
                        "pci": "01:00.0",
                        "accelerator": 13 if IS_EOS and agentIsRunning("ar", "PLSmbusMediator") else 11,
                        "bus_number": 0,
                    },
                    "i2c_sys": {
                        "pci": "01:00.0",
                        "accelerator": 18 if IS_EOS and agentIsRunning("ar", "PLSmbusMediator") else 16,
                        "bus_number": 1,
                        "address": 0x66,
                    },
                    "app_ports": "",  # FIX ME!!!
                    "jtag": {
                        "index": 1,
                        "options": ["-J10000000"],
                    },
                    "pcie": {
                        "root_port": "10b5:8725",
                        "root_port_name": (
                            "PEX 8725 24-Lane, 10-Port PCI Express Gen 3 (8.0 GT/s) Multi-Root Switch with DMA"
                        ),
                        "root_port_vendor": "PLX Technology, Inc.",
                        "link_width": 2,
                        "port_num": 2,
                    },
                    "clkgen": {
                        "device": "LMK05318",
                        "accelerator": 2,
                        "bus_number": 5,
                        "address": 0x65,
                        "pci": "01:00.0",
                        "scd_pll_lock": ["0x300", 14],
                    },
                },
            },
        ],
    },
    {
        # Pattern matches all 7132LB (Malabar) Devices
        "sku_pattern": re.compile("DCS-7132LB-.*"),
        "fpgas": [
            {
                "identifier": "Fpga1",
                "label": "Application FPGA 1",
                "board_standard": "lb2",
                "interfaces": {
                    "i2c_app": {
                        "pci": "01:00.0",
                        "accelerator": 11 if IS_EOS and agentIsRunning("ar", "PLSmbusMediator") else 9,
                        "bus_number": 0,
                    },
                    "i2c_sys": {
                        "pci": "01:00.0",
                        "accelerator": 12 if IS_EOS and agentIsRunning("ar", "PLSmbusMediator") else 10,
                        "bus_number": 0,
                        "address": 0x66,
                    },
                    "app_ports": "",  # FIX ME!!!
                    "jtag": {
                        "index": 0,
                        "options": ["-J15000000"],
                    },
                    "pcie": {
                        "root_port": "1022:1453",
                        "root_port_name": "Family 17h (Models 00h-0fh) PCIe GPP Bridge",
                        "root_port_vendor": "Advanced Micro Devices, Inc. [AMD]",
                        "link_width": 4,
                        "port_num": 0,
                    },
                    "clkgen": {
                        "device": "LMK05318",
                        "accelerator": 2,
                        "bus_number": 3,
                        "address": 0x65,
                        "pci": "01:00.0",
                        "scd_pll_lock": ["0x300", 13],
                    },
                },
            },
        ],
    },
]

board_standards = {
    "c": {
        "fpga": "10AX115",
        "image_type": "sof",
        "speed_grade": "",
    },
    "k": {
        "fpga": "XC7VX415T",
        "image_type": "bit",
        "speed_grade": "",
    },
    "l": {
        "fpga": "VU7P",
        "image_type": "bit",
        "speed_grade": "2",
    },
    "lb2": {
        "fpga": "VU9P",
        "image_type": "bit",
        "speed_grade": "3",
    },
    "e_central": {
        "fpga": "KU095",
        "image_type": "bit",
        "speed_grade": "2",
    },
    "e_leaf": {
        "fpga": "KU095",
        "image_type": "bit",
        "speed_grade": "2",
    },
    "eh_central": {
        "fpga": "VU9P",
        "image_type": "bit",
        "speed_grade": "3",
    },
    "eh_leaf": {
        "fpga": "VU9P",
        "image_type": "bit",
        "speed_grade": "3",
    },
    "ed_central": {
        "fpga": "VU9P",
        "image_type": "bit",
        "speed_grade": "2l",
    },
    "ed_leaf": {
        "fpga": "VU9P",
        "image_type": "bit",
        "speed_grade": "2l",
    },
}


def _irangestr(range_str):
    for s in range_str.split(","):
        try:
            low, high = s.split("-")
            low, high = int(low), int(high)
            for i in range(low, high + 1):
                yield i
        except ValueError:
            yield int(s)


def get_portlist(range_str):
    if isinstance(range_str, str):
        return list(_irangestr(range_str.replace("ap", "")))

    raise ValueError('"{}" is not a valid range : "ap1-3,5,8"'.format(range_str))


class XilinxJTag(object):
    def __init__(self, usb_path=None, index=None, options=None):
        self.index = ["-p", str(index)] if index is not None else []
        self.options = options or []
        self.usb_path = usb_path or ""
        self.__ftdi_args = []

    def __make_ftdi_args(self):
        device_path = "/sys/bus/usb/devices/" + self.usb_path
        devnum_path = device_path + "/devnum"
        busnum_path = device_path + "/busnum"

        if os.access(devnum_path, os.R_OK) and os.access(busnum_path, os.R_OK):
            with open(busnum_path, "r") as f:  # pylint: disable=unspecified-encoding
                self.__ftdi_args.extend(["-B", f.read().strip()])
            with open(devnum_path, "r") as f:  # pylint: disable=unspecified-encoding
                self.__ftdi_args.extend(["-V", f.read().strip()])

    def flash_args(self):
        if self.usb_path and not self.__ftdi_args:
            self.__make_ftdi_args()
        return self.index + self.__ftdi_args + self.options

    def load_image(self, *args, **kwargs):  # pylint: disable=unused-argument
        subprocess.check_call("xc3sprog -v -c metamako".split() + self.flash_args() + list(args))

    def unload_image(self, *args, **kwargs):  # pylint: disable=unused-argument
        subprocess.check_call("xc3sprog -v -c metamako -e".split() + self.flash_args() + list(args))


class Pcie(object):
    bridge_check_attempts = 5
    rescan_check_attempts = 5

    def __init__(  # pylint: disable=too-many-arguments
        self,
        root_port=None,
        root_port_name=None,
        root_port_vendor=None,
        link_width=None,
        port_num=None,
    ):
        self.root_port = root_port
        self.root_port_name = root_port_name
        self.root_port_vendor = root_port_vendor
        self.link_width = link_width
        self.port_num = port_num
        self._cached_bridge = None

    def _find_bridge(self):
        for _ in range(self.bridge_check_attempts):
            bdf_bridge = subprocess.check_output(
                ["sh", "-c", "lspci -d {} | cut -d' ' -f1".format(self.root_port)],
                stderr=subprocess.STDOUT,
                universal_newlines=True,
            ).strip()
            if bdf_bridge:
                return bdf_bridge
            time.sleep(1)
        raise Exception("Unable to find Pci bridge {}".format(self.root_port))

    def _rescan(self, sleep_time=1):
        time.sleep(sleep_time)
        subprocess.check_call(["sudo", "sh", "-c", "echo 1 > /sys/bus/pci/rescan"])

    def _remove_bridge(self, bdf):
        path = "/sys/bus/pci/devices/0000:{}/remove".format(bdf)
        subprocess.check_call(["sudo", "sh", "-c", "echo 1 > %s" % path])

    def _read_window(self, bdf):
        window = subprocess.check_output(
            ["setpci", "-s", bdf, "MEMORY_BASE.L"],
            stderr=subprocess.STDOUT,
            universal_newlines=True,
        ).strip()
        return window

    def _invalidate_window(self, bdf):
        subprocess.check_call(["setpci", "-s", bdf, "MEMORY_BASE.L=0000fff0"])

    def _probe_downstream_device(self, bridge_bdf):
        bus = subprocess.check_output(
            [
                "sh",
                "-c",
                "lspci -s {} -vv | xargs -s 8192 | "
                "sed -e 's/.*\\(secondary=[0-9]*\\).*/\\1/g' | "
                "cut -d'=' -f2".format(bridge_bdf),
            ],
            stderr=subprocess.STDOUT,
            universal_newlines=True,
        ).strip()
        downstream_bdf = subprocess.check_output(
            ["sh", "-c", "lspci -s {}: | head -1 | " "cut -d' ' -f1".format(bus)],
            stderr=subprocess.STDOUT,
            universal_newlines=True,
        ).strip()
        return downstream_bdf

    def _validate_mmio_access(self, bdf):
        command_b = subprocess.check_output(
            ["setpci", "-s", bdf, "COMMAND.B"],
            stderr=subprocess.STDOUT,
            universal_newlines=True,
        ).strip()
        value = int(command_b, 16)
        if not value & 0b10:
            subprocess.check_call(
                ["setpci", "-s", bdf, "COMMAND.B={}".format(value | 0b10)],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
            )

    def pre_load(self):
        if not self.root_port:
            return
        self._rescan(0)
        bridge = self._find_bridge()
        window = self._read_window(bridge)
        if window != "0000fff0":
            self._invalidate_window(bridge)
        self._remove_bridge(bridge)

    def post_load(self):
        if not self.root_port:
            return
        sleep_time = 1
        bdf = ""
        bridge = ""
        for i in range(self.rescan_check_attempts):
            try:
                bridge = self._find_bridge()
                bdf = self._probe_downstream_device(bridge)
                if bdf:
                    break
                self._remove_bridge(bridge)
            except Exception:  # pylint: disable=broad-except
                if i == self.rescan_check_attempts - 1:
                    raise
            self._rescan(sleep_time)
            sleep_time += 1
        if bdf:
            self._validate_mmio_access(bdf)
        else:
            raise Exception("PCI device did not come up")

    def pre_clear(self):
        if not self.root_port:
            return
        self._rescan(0)
        bridge = ""
        try:
            bridge = self._find_bridge()
            self._remove_bridge(bridge)
        except Exception:  # pylint: disable=broad-except
            pass
        self._cached_bridge = bridge

    def post_clear(self):
        if not self.root_port:
            return
        self._rescan()
        if self._cached_bridge:
            self._invalidate_window(self._cached_bridge)
            self._remove_bridge(self._cached_bridge)
            self._rescan()


class Fpga(object):  # pylint: disable=too-many-instance-attributes
    """An FPGA in the system.

    Typically accessed via get_fpga_devices().

    Attributes:
        label (str): Legacy (MOS-style) name of the FPGA.
        identifier (str): The name of the FPGA on EOS.
        board_standard (str): The FPGA bitstream compatibility standard.
        communicator (RegisterAccessor): The interface to use to access
            registers via the i2c_app bus.
        sys_communicator (RegisterAccessor): The interface to use to access
            registers via the i2c_sys bus.
        port_list (List[int]): List of ap interfaces on this FPGA.
        macaddr_list (List[netaddr.EUI]): List of MAC addresses allocated to this FPGA.
        part (str): Part number of the FPGA.
        jtag (JTAG): JTAG interface to the FPGA.
        pcie (Pcie): PCIe interface to the FPGA.
        clkgen (ClockGenerator): ClockGenerator device interface for FPGA reference clocks.
    """

    def __init__(self, descriptor):
        self.label = descriptor["label"]
        self.identifier = descriptor["identifier"]
        self.board_standard = descriptor["board_standard"]
        self._platform = self._get_platform_name()

        board_standard_info = board_standards[self.board_standard]
        self.part = board_standard_info["fpga"]
        self.image_type = board_standard_info["image_type"]
        self.speed_grade = board_standard_info["speed_grade"]

        interfaces = descriptor["interfaces"]
        self.communicator = register_accessor.RegisterAccessor(**interfaces["i2c_app"])
        if len(interfaces["i2c_sys"]):
            self.sys_communicator = register_accessor.RegisterAccessor(**interfaces["i2c_sys"])

        self.jtag = XilinxJTag(**interfaces["jtag"])
        self.pcie = Pcie(**interfaces["pcie"])
        self.clkgen = clock_generator.ClockGenerator(self._platform, self.board_standard, interfaces)

        try:
            self.port_list = list(_irangestr(interfaces["app_ports"]))
        except ValueError:
            self.port_list = []

        self.macaddr_list = self._get_macaddr_list()

        if not IS_EOS:
            self.__mosapi_device__ = mosapi.get_device_by_label(self.label)

    def name(self):
        return self.identifier

    def load_image(self, *args, **kwargs):
        """Programs the FPGA with a specified bitstream.

        Args:
            bitstream (str): The file to be written to the device.
            with_pcie (bool): A boolean indicating if the image uses PCIe, and
                needs a bus rescan, etc.
        """
        pcie = kwargs.pop("with_pcie", False)
        clk_profile = kwargs.pop("clock_profile", "default")

        self.clkgen.load_profile(clk_profile)
        if pcie:
            self.pcie.pre_load()
        if IS_EOS:
            self.jtag.load_image(*args, **kwargs)  # type: ignore
        else:
            self.__mosapi_device__.load_image(*args, **kwargs)  # type: ignore
        if pcie:
            self.pcie.post_load()

    def unload_image(self, *args, **kwargs):
        """Clears FPGA configuration.

        Args:
            with_pcie (bool): A boolean indicating if the loaded image uses
                PCIe.
        """
        pcie = kwargs.pop("with_pcie", False)
        if pcie:
            self.pcie.pre_clear()
        if IS_EOS:
            self.jtag.unload_image(*args, **kwargs)  # type: ignore
        else:
            self.__mosapi_device__.unload_image(*args, **kwargs)  # type: ignore
        if pcie:
            self.pcie.post_clear()

        self.clkgen.load_profile("default")

    def _reset_clkgen_profile(self):
        # An explicit call to reset the clkgen if caught in a strange place
        self.clkgen.load_profile("default")

    def reserve(self):
        raise NotImplementedError

    def unreserve(self):
        raise NotImplementedError

    def _get_platform_name(self):
        plat = "Dropbear"  # Set a default platform
        if IS_EOS:
            with open("/etc/prefdl") as prefdl:  # pylint: disable=unspecified-encoding
                plat = re.search(r"SID: (.*)", prefdl.read()).group(1)

        platform = ""
        if "Dropbear" in plat:
            if "_central" in self.board_standard or "_leaf" in self.board_standard:
                platform = "emu"
            else:
                platform = "lyrebird"
        else:
            if "malabar" in plat.lower():
                platform = "malabar"
            if "tamarama" in plat.lower():
                platform = "tamarama"

        return platform

    def _get_macaddr_list(self):
        # TODO : The following information should be obtained from the platform FDL.
        # Access to the FDL is currently being implemented
        basemac = int(get_interface_macaddr("ma1"))

        if self._platform in ["emu", "lyrebird"]:
            # FPGA MAC addresses are 128 from ma1mac - 1 + 128...
            if "Fpga1" in self.identifier:
                maclist = [EUI(basemac + 127 + adr) for adr in range(80)]  # 80 addresses assigned for default FPGA
            if "Fpga2" in self.identifier:
                maclist = [EUI(basemac + 207 + adr) for adr in range(24)]  # 24 addresses assigned for leaf FPGA
            if "Fpga3" in self.identifier:
                maclist = [EUI(basemac + 231 + adr) for adr in range(24)]  # 24 addresses assigned for leaf FPGA
        elif self._platform == "tamarama":
            # From AID5889
            if "Fpga1" in self.identifier:
                maclist = [EUI(basemac + 134 + adr) for adr in range(64)]
            if "Fpga2" in self.identifier:
                maclist = [EUI(basemac + 198 + adr) for adr in range(64)]
        elif self._platform == "malabar":
            # From AID7800
            maclist = [EUI(basemac + 6 + adr) for adr in range(68)]
        else:
            raise ValueError("There are no assigned MAC addresses for this FPGA/Platform.")

        return maclist


def get_fpga_devices(board_standard=None, identifier=None):
    """Returns a list of application FPGAs in the system.

    By default get_fpga_devices will return all application FPGAs in the system
    but the result can be filtered by specifying a board standard or identifier
    for a particular FPGA.

    Args:
        board_standard (Optional[str]): The board standard to restrict the
            resulting FPGA list to, if any.
        identifier (Optional[str]): The name of a particular FPGA to limit the
            result to.
    """
    ret_list = []  # type: list[Fpga]
    try:
        import hal  # pylint: disable=import-outside-toplevel

        sku = hal.sku()
    except ImportError:
        with open("/etc/prefdl") as prefdl:  # pylint: disable=unspecified-encoding
            sku = re.search(r"SKU: (.*)", prefdl.read()).group(1)
    ret_list = [
        Fpga(descriptor)
        for device_map in skus
        for descriptor in device_map["fpgas"]
        if device_map["sku_pattern"].match(sku)
    ]
    ret_list = [
        fpga
        for fpga in ret_list
        if (board_standard is None or board_standard == fpga.board_standard)
        and (identifier is None or identifier == fpga.name())
    ]
    return ret_list


def get_interface_macaddr(interface=None):
    """Returns the mac address of a particular port.

    Args:
        interface [str]: The name of a particular port.
    """
    try:
        with open("/sys/class/net/" + interface.lower() + "/address") as fd:  # pylint: disable=unspecified-encoding
            return EUI(fd.read().strip())
    except Exception:  # pylint: disable=broad-except
        return EUI("00:00:00:00:00:00")


__all__ = (
    "Fpga",
    "get_fpga_devices",
)
