# ------------------------------------------------------------------------------
#  Copyright (c) 2021 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
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

import json
import os
import re
import subprocess
import tempfile
import time

import six

from netaddr import EUI
from six.moves import range

from .register_file import RegisterFile

from . import IS_EOS, register_accessor, clock_generator

# FIXME: Use Subprocess32 once it is available in EOS.
# if sys.version_info[0] >= 3:
#    import subprocess
# else:
#    import subprocess32 as subprocess


if IS_EOS:
    from AgentDirectory import agentIsRunning
    import MakoFdtProfileHelper

    profile_helper = MakoFdtProfileHelper.MakoFdtProfileHelper()
else:
    import mosapi

skus = [
    {
        # Pattern matches all 7130-32L and 7130-48L (Lyrebird-VU7P-2) Devices
        "sku_pattern": re.compile(r"DCS-7130-(32|48)L(A|C)?S?($|-.*)"),
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
                    "scd": {},
                },
            },
        ],
    },
    {
        # Pattern matches all 7130-96L (Lyrebird-VU7P-2) Devices
        "sku_pattern": re.compile(r"DCS-7130-96L(A|C)?S?($|-.*)"),
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
                    "app_ports": "1-28,32-60",
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
                    "scd": {},
                },
            },
        ],
    },
    {
        # Pattern matches all 7130-32LB and 7130-48LB (Lyrebird-VU9P-3) Devices
        "sku_pattern": re.compile(r"DCS-7130-(32|48)LB(A|C)?S?($|-.*)"),
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
                    "scd": {},
                },
            },
        ],
    },
    {
        # Pattern matches all 7130-96LB (Lyrebird-VU9P-3) Devices
        "sku_pattern": re.compile(r"DCS-7130-96LB(A|C)?S?($|-.*)"),
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
                    "app_ports": "1-28,32-60",
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
                    "scd": {},
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
                    "scd": {},
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
                    "scd": {},
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
                    "app_ports": "1-14",
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
                    "scd": {},
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
                    "app_ports": "1-14",
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
                    "scd": {},
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
                    "app_ports": "1-28,32-60",
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
                    },
                    "scd": {
                        "fpga_prog_done": {"sts": 0x4810, "bit": 24},
                        "fpga_seu_alert": {"sts": 0x30B0, "bit": 24},
                        "fpga_pcie_reset": {"set": 0x4000, "clr": 0x4010, "bit": 4},
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
                    "app_ports": "1-28,32-60",
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
                    },
                    "scd": {
                        "fpga_prog_done": {"sts": 0x4910, "bit": 24},
                        "fpga_seu_alert": {"sts": 0x30B0, "bit": 25},
                        "fpga_pcie_reset": {"set": 0x4000, "clr": 0x4010, "bit": 5},
                    },
                },
            },
        ],
    },
    {
        # Pattern matches all 7132LB/7135LB (Malabar/Freshwater) Devices
        "sku_pattern": re.compile("DCS-713[25]LB-.*"),
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
                    "app_ports": "1-28,30-68",
                    "jtag": {
                        "usb_path": "1-1",
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
                    },
                    "scd": {
                        "fpga_prog_done": {"sts": 0x4810, "bit": 24},
                        "fpga_seu_alert": {"sts": 0x30B0, "bit": 24},
                        "fpga_pcie_reset": {"set": 0x4000, "clr": 0x4010, "bit": 4},
                    },
                },
            },
        ],
    },
    {
        # Pattern matches all 7135V (Birdsville) Devices
        "sku_pattern": re.compile("DCS-7135V-.*"),
        "fpgas": [
            {
                "identifier": "Fpga1",
                "label": "Application FPGA 1",
                "board_standard": "bvl",
                "interfaces": {
                    "i2c_app": {
                        "pci": "01:00.0",
                        "accelerator": 12 if IS_EOS and agentIsRunning("ar", "PLSmbusMediator") else 10,
                        "bus_number": 0,
                    },
                    "i2c_sys": {
                        "pci": "01:00.0",
                        "accelerator": 13 if IS_EOS and agentIsRunning("ar", "PLSmbusMediator") else 11,
                        "bus_number": 0,
                        "address": 0x66,
                    },
                    "app_ports": "1-68",
                    "pcie": {
                        "root_port": "1022:1453",
                        "root_port_name": "Family 17h (Models 00h-0fh) PCIe GPP Bridge",
                        "root_port_vendor": "Advanced Micro Devices, Inc. [AMD]",
                        "link_width": 4,
                        "port_num": 0,
                    },
                    "jtag": {},
                    "clkgen": {},
                    "scd": {
                        "fpga_prog_done": {"sts": 0x4810, "bit": 24},
                        "fpga_seu_alert": {"sts": 0x30B0, "bit": 24},
                        "fpga_temp_alert": {"sts": 0x2F10, "clr": 0x2F10, "bit": 25},
                        "fpga_pcie_reset": {"set": 0x4000, "clr": 0x4010, "bit": 4},
                    },
                },
            },
        ],
    },
]

board_standards = {
    "bvl": {
        "fpga": "VH1542",
        "image_type": "pdi",
        "speed_grade": "3",
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
}


def _irangestr(range_str):
    for s in range_str.split(","):
        try:
            low, high = s.split("-")
            low, high = int(low), int(high)
            for i in range(low, high + 1):  # pylint: disable=use-yield-from
                yield i
        except ValueError:
            yield int(s)


def get_portlist(range_str):
    if isinstance(range_str, str):
        range_str = range_str.replace("ap", "").split("/")
        if len(range_str) == 2:
            res = range_str[0], list(_irangestr(range_str[1]))
        else:
            res = list(_irangestr(range_str[0]))
    else:
        raise ValueError('"{}" is not a valid range : "ap1-3,5,8 or ap1/1-3,5,8"'.format(range_str))

    return res


class Scd(object):
    def __init__(self, scdRegs):
        self.scdRegs = scdRegs

    def set(self, reg):
        if reg in self.scdRegs.keys():
            if "set" in self.scdRegs[reg]:
                subprocess.check_call(
                    [
                        "sudo",
                        "sh",
                        "-c",
                        "scd write {} {}".format(self.scdRegs[reg]["set"], 1 << self.scdRegs[reg]["bit"]),
                    ]
                )

    def clr(self, reg):
        if reg in self.scdRegs.keys():
            if "clr" in self.scdRegs[reg]:
                subprocess.check_call(
                    [
                        "sudo",
                        "sh",
                        "-c",
                        "scd write {} {}".format(self.scdRegs[reg]["clr"], 1 << self.scdRegs[reg]["bit"]),
                    ]
                )

    def get(self, reg):
        if reg in self.scdRegs.keys():
            if "sts" in self.scdRegs[reg]:
                res = subprocess.check_output(
                    ["sudo", "sh", "-c", "scd read {}".format(self.scdRegs[reg]["sts"])], text=True
                )
                return int(res.split()[1], 16) >> self.scdRegs[reg]["bit"] & 0x1
        return 0


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
        timeout = kwargs.pop("timeout", None)
        try:
            subprocess.check_call(
                "xc3sprog -v -c metamako".split() + self.flash_args() + list(args), timeout=timeout, **kwargs
            )
        except subprocess.TimeoutExpired as _:
            raise TimeoutError()

    def unload_image(self, *args, **kwargs):  # pylint: disable=unused-argument
        subprocess.check_call("xc3sprog -v -c metamako -e".split() + self.flash_args() + list(args), **kwargs)


class Pcie(object):  # pylint: disable=too-many-instance-attributes
    bridge_check_attempts = 3
    rescan_check_attempts = 3

    def __init__(  # pylint: disable=too-many-arguments
        self,
        scd,
        root_port=None,
        root_port_name=None,
        root_port_vendor=None,
        link_width=None,
        port_num=None,
        pseudo_hotplug=False,
    ):
        self.scd = scd
        self.root_port = root_port
        self.root_port_name = root_port_name
        self.root_port_vendor = root_port_vendor
        self.link_width = link_width
        self.port_num = port_num
        self.pseudo_hotplug = pseudo_hotplug
        self._cached_bridge = None
        self.domain = "0000"

    @property
    def bus_num(self):
        bridge = self._find_bridge()
        return self._probe_downstream_bus(bridge)

    def _set_pcie_reset(self, value):
        if value:
            self.scd.set("fpga_pcie_reset")
        else:
            self.scd.clr("fpga_pcie_reset")

    def _find_bridge(self):
        for _ in range(self.bridge_check_attempts):
            bdf_bridges = (
                subprocess.check_output(
                    ["sh", "-c", "lspci -d {} | cut -d' ' -f1".format(self.root_port)],
                    stderr=subprocess.STDOUT,
                    universal_newlines=True,
                )
                .strip()
                .split("\n")
            )
            if self.port_num is not None:
                for bdf_bridge in bdf_bridges:
                    if not subprocess.call(
                        ["sudo", "sh", "-c", "lspci -vv -s {} | grep 'Port #{}'".format(bdf_bridge, self.port_num)],
                        stderr=subprocess.STDOUT,
                        universal_newlines=True,
                    ):
                        return bdf_bridge
            elif len(bdf_bridges) == 1:
                return bdf_bridges[0]
            time.sleep(1)
        raise Exception("Unable to find Pci bridge {}. Is the FPGA programmed?".format(self.root_port))

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

    def _probe_downstream_bus(self, bridge_bdf):
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
        return bus

    def _probe_downstream_device(self, bridge_bdf):
        bus = self._probe_downstream_bus(bridge_bdf)
        downstream_bdf = subprocess.check_output(
            ["sh", "-c", "lspci -s {}: | head -1 | " "cut -d' ' -f1".format(bus)],
            stderr=subprocess.STDOUT,
            universal_newlines=True,
        ).strip()
        if "lspci:" in downstream_bdf:
            return ""
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
        if not self.pseudo_hotplug or not self.root_port:
            return
        self._rescan(0)
        try:
            bridge = self._find_bridge()
            window = self._read_window(bridge)
            if window != "0000fff0":
                self._invalidate_window(bridge)
            self._remove_bridge(bridge)
        except Exception:  # pylint: disable=broad-except
            pass

    def post_load(self):
        if not self.root_port:
            return
        self._set_pcie_reset(False)
        sleep_time = 1
        bdf = ""
        bridge = ""
        for _ in range(self.rescan_check_attempts):
            self._rescan(sleep_time)
            try:
                bridge = self._find_bridge()
                bdf = self._probe_downstream_device(bridge)
                if bdf:
                    break
                if self.pseudo_hotplug:
                    self._remove_bridge(bridge)
            except Exception:  # pylint: disable=broad-except
                pass
            sleep_time += 1
        if bdf:
            self._validate_mmio_access(bdf)
        return

    def pre_clear(self):
        if not self.pseudo_hotplug or not self.root_port:
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
        if not self.pseudo_hotplug or not self.root_port:
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
        self._numeric_id = int(descriptor["identifier"][4:])
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
        self.registers = None

        self.scd = Scd(interfaces["scd"])
        self.jtag = XilinxJTag(**interfaces["jtag"])
        self.pcie = Pcie(scd=self.scd, pseudo_hotplug=self._platform in ["emu", "lyrebird"], **interfaces["pcie"])
        self.clkgen = clock_generator.ClockGenerator(self._platform, self.board_standard, interfaces)

        self._profile_key = None
        self._instance = self._numeric_id

        try:
            self.port_list = list(_irangestr(interfaces["app_ports"]))
        except ValueError:
            self.port_list = []

        self.macaddr_list = self._get_macaddr_list()

        if not IS_EOS:
            self.__mosapi_device__ = mosapi.get_device_by_label(self.label)

        import __main__  # pylint: disable=import-outside-toplevel

        self._script_name = os.path.basename(getattr(__main__, "__file__", __main__.__name__))
        self._app_name = "{}-{}".format(self._script_name, self._instance)

    def name(self):
        return self.identifier

    def load_image(  # pylint: disable=too-many-arguments,too-many-branches
        self,
        bitstream,
        clock_profile="default",
        blocking=True,
        timeout=None,
        ipcores=None,
        register_file=None,
        port_def=None,
    ):
        """Programs the FPGA with a specified bitstream.

        On EOS, the `timeout` and `blocking` flags are supported.

        If `blocking` is False, this function will return immediately after beginning programming. Whether the FPGA has
        been loaded can be checked using the `fpga.applied_profile()` function.

        If `timeout` is not None, this function will raise a TimeoutError if the programming takes longer than
        `timeout` seconds. As EosSdk daemons may be killed if they do not yield back to the main event loop within 30
        seconds, this may be useful to gracefully handle programming taking too long instead of having the entire
        daemon killed.

        Args:
            bitstream (str): The file to be written to the device
            blocking (bool): A boolean indicating if the programming should be non-blocking
            timeout  (Optional[float]): The timeout in seconds for the operation.
            ipcores (Optional[Dict[str, str]]): A dictionary of IP cores to be used
            register_file (Optional[str]): The path to the register file to be used
        """
        timeout_time = time.time() + timeout if timeout is not None else float("inf")
        if ipcores is None:
            ipcores = {}

        if IS_EOS:
            self.unload_image()
        self.clkgen.load_profile(clock_profile)
        if IS_EOS:
            with tempfile.NamedTemporaryFile("w+") as features, tempfile.NamedTemporaryFile("w+") as port_def_file:
                features_arr = [{"name": "fdk", "version": "1.0.0"}]
                for name, ipcore in ipcores.items():
                    if name == "tscore":
                        features_arr.append(
                            {
                                "name": "metachron",
                                "version": "1.0",
                                "communicators": {
                                    "i2c": {
                                        "type": "i2c",
                                        "csv": (
                                            ipcore["register_file"] if ipcore.get("register_file") else register_file
                                        ),
                                        "regspec": (
                                            ipcore["register_file"] if ipcore.get("register_file") else register_file
                                        ),
                                    },
                                },
                            }
                        )

                json.dump(features_arr, features)
                features.flush()

                if port_def is None:
                    port_def = self._default_port_def()

                json.dump(port_def, port_def_file)
                port_def_file.flush()

                self._profile_key = profile_helper.createProfile(
                    "{}-{}".format(self._script_name, self._instance),
                    os.path.abspath(bitstream),
                    self.board_standard,
                    os.path.abspath(bitstream),
                    clockProfile="bypass",
                    features=features.name,
                    portDef=port_def_file.name,
                )
                profile_helper.loadProfile(
                    instance=self._instance,
                    profileKey=self._profile_key,
                    fpgaId=self._numeric_id,
                    waitForLoad=False,
                )

                if blocking:
                    try:
                        while self.profile_state() is None:
                            continue
                        while self.profile_state() == "applying":
                            if time.time() > timeout_time:
                                raise TimeoutError()
                            continue
                        if self.profile_state() != "applied":
                            raise Exception("Failed to program FPGA, state is {}".format(self.profile_state()))
                    except Exception:
                        self.unload_image()
                        raise
        else:
            self.pcie.pre_load()
            self.__mosapi_device__.load_image(bitstream)  # type: ignore
            self.pcie.post_load()

        if register_file:
            self.registers = RegisterFile(register_file, self.communicator)

    def _profile_config(self):
        for config in profile_helper.config.profileConfig:
            if config.fpgaId == self._numeric_id and self._script_name in config.appName:
                return config
        return None

    def _profile_status(self):
        config = self._profile_config()
        if config:
            return profile_helper.status.profileStatus.get(config)
        return None

    def profile_key(self):
        """Return the profile that has been applied to this FPGA. If no profile is loaded, this function returns `None`"""  # pylint: disable=line-too-long
        if not self._profile_key:
            return getattr(self._profile_status(), "profileKey", None)
        return self._profile_key

    def profile_state(self):
        """Returns the state of the profile that has been applied to the FPGA from this program"""
        if IS_EOS:
            return getattr(self._profile_status(), "state", None)
        raise NotImplementedError("profile_state() is not implemented on this platform")

    def is_loaded(self):
        """Returns true if the FPGA is loaded with an image from this program"""
        return self.profile_state() == "applied"

    def unload_image(self):
        """Clears FPGA configuration."""
        if IS_EOS:
            profile_helper.unloadProfile(appName=self._app_name, fpgaId=self._numeric_id)
            for profile_key, profile in six.iteritems(profile_helper.getAvailableProfiles()):
                if profile["appName"] == self._app_name and profile_key not in profile_helper.getActiveProfiles():
                    profile_helper.removeProfile(profile_key)
            self._profile_key = None
        elif not IS_EOS:
            self.pcie.pre_clear()
            self.__mosapi_device__.unload_image()  # type: ignore
            self.pcie.post_clear()
        else:
            return

        self.clkgen.load_profile("default")
        self.registers = None

    def _reset_clkgen_profile(self):
        # An explicit call to reset the clkgen if caught in a strange place
        self.clkgen.load_profile("default")

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
            if "freshwater" in plat.lower():
                platform = "freshwater"
            if "tamarama" in plat.lower():
                platform = "tamarama"
            if "birdsville" in plat.lower():
                platform = "birdsville"

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
            # From AID5889 Section 2.10-Media Access
            if "Fpga1" in self.identifier:
                maclist = [EUI(basemac + 134 + adr) for adr in range(64)]
            if "Fpga2" in self.identifier:
                maclist = [EUI(basemac + 198 + adr) for adr in range(64)]
        elif self._platform in ["malabar", "freshwater", "birdsville"]:
            # From AID7800 Section 2.6-Media Access; AID8600 Section 2.7-Media Access
            maclist = [EUI(basemac + 6 + adr) for adr in range(68)]
        else:
            raise ValueError("There are no assigned MAC addresses for this FPGA/Platform.")

        return maclist

    def _default_port_def(self):
        port_def = {
            str(port): {
                "type": "FPHY",
                "speed": {
                    "default": "10G",
                    "options": {"OFF": "OFF", "1G": "1G", "10G": "10G", "25G": "25G"},
                },
            }
            for port in self.port_list
        }
        return port_def


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
    sku = get_sku()
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


def get_fpga_identifiers():
    """Returns a list of application FPGAs in the system.

    By default get_fpga_devices will return all application FPGAs in the system
    but the result can be filtered by specifying a board standard or identifier
    for a particular FPGA.
    """
    ret_list = {}  # type: dict[str, str]
    sku = get_sku()
    ret_list = {
        descriptor["identifier"] if IS_EOS else descriptor["label"]: descriptor["board_standard"]
        for device_map in skus
        for descriptor in device_map["fpgas"]
        if device_map["sku_pattern"].match(sku)
    }
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


def get_sku():
    try:
        import hal  # pylint: disable=import-outside-toplevel

        return hal.sku()
    except ImportError:
        with open("/etc/prefdl") as prefdl:  # pylint: disable=unspecified-encoding
            return re.search(r"SKU: (.*)", prefdl.read()).group(1)


__all__ = (
    "Fpga",
    "get_fpga_devices",
    "get_fpga_identifiers",
    "get_interface_macaddr",
    "get_sku",
)
