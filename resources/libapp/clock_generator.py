# ------------------------------------------------------------------------------
#  Copyright (c) 2022 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    Clock generator (clkgen) controller.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------
"""Clock generator controller for applications running on Arista 7130 switches."""

from __future__ import absolute_import

import os
import json
import logging
import re
import time
from functools import wraps

from . import IS_EOS

if not IS_EOS:
    from hal import i2c
else:
    from PlutoSmbusAccessor import PlutoSmbusDaemonAccessor

logger = logging.getLogger(__name__)

# ------------------------------------------------------------------------------
class Si5345(object):

    page_register = 0x1

    def __init__(self, clkgen_interface):
        self.partNum = "si5345"
        self._clkgen_interface = clkgen_interface
        self._device = None

    @property
    def device(self):
        if self._device is None:
            if not IS_EOS:
                self._device = i2c.Device(
                    bus=i2c.label_to_bus(self._clkgen_interface["mos_label"]),
                    addr=self._clkgen_interface["address"],
                )
            else:
                try:
                    self._device = PlutoSmbusDaemonAccessor(
                        mezzanineMuxPort=self._clkgen_interface["chan_number"],
                        address=self._clkgen_interface["address"],
                    )
                except FileNotFoundError:
                    pass  # PlutoSmbus isn't ready yet
        return self._device

    def load_config(self, fileName):
        reg_map = self._reg_map_parser(fileName)
        for item in reg_map:
            page = int(item[0][0:4], 0)
            address = int(item[0][4:6], 16)
            value = int(item[1], 0)
            self._write_byte_data(address, value, page=page)

    def verify_config(self, fileName):
        return fileName

    @property
    def device_ready(self):
        return self._read_byte_data(0xFE, page=0) == 0x0F

    @property
    def _page_select(self):
        return self._read_byte_data(self.page_register)

    @_page_select.setter
    def _page_select(self, page):
        self.device.write_byte_data(self.page_register, page)

    def _paged(f):  # pylint: disable=no-self-argument
        @wraps(f)
        def wrapper(self, *args, **kargs):
            page = kargs.pop("page", None)
            paged = page is not None
            try:
                if paged:
                    if not IS_EOS:
                        # Function only available/needed in hal.i2c
                        self.device.grab()
                    self._page_select = page  # pylint: disable=protected-access
                result = f(self, *args, **kargs)  # pylint: disable=not-callable
            finally:
                if paged and not IS_EOS:
                    # Function only available/needed in hal.i2c
                    self.device.release()

            return result

        return wrapper

    @_paged
    def _read_byte_data(self, address, page=None):  # pylint: disable=unused-argument
        return self.device.read_byte_data(address)

    @_paged
    def _write_byte_data(self, address, value, page=None):  # pylint: disable=unused-argument
        return self.device.write_byte_data(address, value)

    def _reg_map_parser(self, fileName):
        with open(fileName, "r") as f:  # pylint: disable=unspecified-encoding
            reg_map = []
            for line in f:
                obj = re.match(r"(0x\w\w\w\w),(0x\w\w)", line, re.I | re.M)
                if obj:
                    reg_map.append([obj.group(1), obj.group(2)])

            return reg_map


# -------------------------------------------------------------------------------
class LMK05318(object):
    def __init__(self, clkgen_interface):
        self._clkgen_interface = clkgen_interface
        self._device = None
        self._part_num = None

    @property
    def device(self):
        if self._device is None:
            try:
                self._device = PlutoSmbusDaemonAccessor(
                    bus=self._clkgen_interface["bus_number"],
                    address=self._clkgen_interface["address"],
                    accelId=self._clkgen_interface["accelerator"],
                    pci=self._clkgen_interface["pci"],
                )
            except FileNotFoundError:
                pass  # PlutoSmbus isn't ready yet
        return self._device

    @property
    def partNum(self):
        if self._part_num is None:
            self._part_num = self._get_part_number()
        return self._part_num

    def load_config(self, fileName):
        reg_map = self._reg_map_parser(fileName)

        datablock = None
        addrlast = None
        for item in reg_map:
            address = int(item[0], 16)
            address_bytes = bytearray.fromhex(item[0])
            data = int(item[1], 16)
            if address in [12, 157, 164] or address >= 353:
                # Special consideration - mask writes according to Userguide section 9.5.5
                res = self.device.read_byte_data(address_bytes)
                if address == 12:
                    mask = 0xA7
                else:
                    mask = 0xFF
                wr_data = (res & mask) | (data & ~mask)
            else:
                wr_data = data

            # Build up sequential blocks of writes to improve I2C performance
            if addrlast is None or address != addrlast + 1:
                if addrlast is not None:
                    self.device.write_i2c_block_data(
                        datablock["baddr"],  # pylint: disable=unsubscriptable-object
                        datablock["data"],  # pylint: disable=unsubscriptable-object
                    )
                datablock = {"baddr": address_bytes, "data": bytearray([wr_data])}
            else:
                datablock["data"] += bytearray([wr_data])  # pylint: disable=unsupported-assignment-operation
            addrlast = address

        # Don't forget the final write
        self.device.write_i2c_block_data(datablock["baddr"], datablock["data"])

        # Now soft reset the chip
        self._soft_reset()

    def verify_config(self, fileName):
        reg_map = self._reg_map_parser(fileName)

        exclusion_list = [
            0x004,  # PART_ID
            0x005,
            0x006,
            0x007,
            # 0x00D,  # APLL and XO Loss of Lock/Source (RO)
            # 0x00E,  # DPLL Status (RO)
            # 0x048,  # Output Active Status (RO)
            # 0x050,  # BAW Lock Detection
            # 0x07c,  # PLL1_NUM_STAT
            # 0x07d,
            # 0x07e,
            # 0x07f,
            0x09B,  # NVM Stored CRC
            0x09D,  # NVM Program Count
            0x09D,  # NVM Live CRC
            # 0x0a2,  # RAM Read/Write Data
            # 0x16f,  # ??? Unknown
        ]

        for item in reg_map:
            address = int(item[0], 16)
            address_bytes = bytearray.fromhex(item[0])
            data = int(item[1], 16)

            res = self.device.read_byte_data(address_bytes)

            if address not in exclusion_list:
                if res != data:
                    print("Address {}, expected {}, got {}".format(hex(address), hex(data), hex(res)))

        return 1

    @property
    def device_ready(self):
        # Check if APLL2 is in PDN
        # Note - Cannot use PLL Locked status in SCD because this isn't "PLL Locked"
        # SCD status is actually an "ack" of a good input reference clock only.

        apll2_is_down = (self.device.read_byte_data(bytearray.fromhex("0064")) & 0x01) != 0
        res = self.device.read_byte_data(bytearray.fromhex("000D")) & 0x0C
        pll_is_locked = bool((res == 0) or (res == 8 and apll2_is_down))

        # res = self.device.read_byte_data(bytearray.fromhex("000D"))
        # print("APLL Status Register 0x0D, got {}".format(hex(res)))
        # res = self.device.read_byte_data(bytearray.fromhex("000E"))
        # print("DPLL Status Register 0x0E, got {}".format(hex(res)))

        return pll_is_locked

    def _soft_reset(self):
        res = self.device.read_byte_data(bytearray.fromhex("000C"))
        self.device.write_byte_data(bytearray.fromhex("000C"), res | 0x80)
        self.device.write_byte_data(bytearray.fromhex("000C"), res & 0x7F)

        # Insert a blocking read here to make sure all transactions have completed
        # before moving on
        res = self.device.read_byte_data(bytearray.fromhex("000C"))

    def _reg_map_parser(self, fileName):
        with open(fileName, "r") as f:  # pylint: disable=unspecified-encoding
            reg_map = []
            for line in f:
                obj = re.match(r"(R\w*)\t0x(\w\w\w\w)(\w\w)", line, re.I | re.M)
                if obj:
                    reg_map.append([obj.group(2), obj.group(3)])

            return reg_map

    @property
    def _REVID(self):
        return self.device.read_byte_data(bytearray.fromhex("0003"))

    def _get_part_number(self):
        """Get the actual LMK part number."""
        # pylint: disable=line-too-long
        # ref: https://e2e.ti.com/support/clock-timing-group/clock-and-timing/f/clock-timing-forum/1163773/lmk05318b-how-to-tell-the-difference-between-lmk05318a-vs-lmk05318b
        # revB -> REVID = 0x22, 0x32, 0x42 (first, second, third revision)
        # revA -> REVID = 0x11
        revPart = "b" if self._REVID != 0x11 else ""
        return "lmk05318" + revPart


# ------------------------------------------------------------------------------
class ClockGenerator(object):  # pylint:disable=too-many-instance-attributes
    """Clock generator (clkgen) controller."""

    libappdir = os.path.dirname(__file__)
    clkprofiledir = libappdir + "/clkgen_profiles/"

    def __init__(self, platform, brdStandard, interface):
        with open("{}clkgen_profiles.json".format(self.clkprofiledir)) as file:  # pylint: disable=unspecified-encoding
            self.clkgenProfiles = json.load(file)

        self.platform = platform
        self.brdStandard = brdStandard

        self.noClkGen = True
        if "device" in interface["clkgen"]:
            if interface["clkgen"]["device"] == "Si5345":
                self.clkgen = Si5345(interface["clkgen"])
                self.noClkGen = False
            if interface["clkgen"]["device"] == "LMK05318":
                if interface["clkgen"]["accelerator"] is not None:
                    self.clkgen = LMK05318(interface["clkgen"])
                    self.noClkGen = False
                else:
                    print(
                        """\
WARNING: PLSmbusMediator not running! \
Clkgen part left with manufacturers default settings.\
"""
                    )

    @property
    def partNum(self):
        return self.clkgen.partNum

    def check_profile(self, profile):
        """Verifies that the profile exists for the platform."""
        if self.noClkGen:
            return "NA"  # not supported

        try:
            config_filename = self.clkgenProfiles[profile][self.platform][self.brdStandard][self.partNum]["config_file"]
            os.path.exists(self.clkprofiledir + config_filename)
        except Exception:  # pylint: disable=broad-except
            return "Null"  # Doesn't exist

        return config_filename  # Exists

    def load_profile(self, profile, verify=False, quiet=False, timeout=None):
        """Loads a clock generator profile.

        Configures clkgen with the specified profile and waits for the device
        to return ready.

        Args:
            profile (str): Name of profile to apply.
        """
        deadline = time.time() + timeout if timeout is not None else float("inf")

        # Skip programming if there is no clkgen part or we are keeping what is
        # already programmed
        if self.noClkGen or profile == "keep":
            return

        # Wait till we can communicate with the device
        while self.clkgen.device is None:
            if time.time() > deadline:
                raise TimeoutError("Timed out waiting for clkgen device communication")
            logger.info("Waiting for clkgen device to be present")

        # Check profile exists
        config_filename = self.check_profile(profile)
        if config_filename == "Null":
            raise Exception(
                "Clock Profile {} does not exist for this platform/board_standard configuration.".format(profile)
            )

        if not quiet and profile != "default":
            print("Loading Clock Generator Profile: {}".format(self.clkgenProfiles[profile]["description"]))
        self.clkgen.load_config(self.clkprofiledir + config_filename)
        while not self.clkgen.device_ready:
            if time.time() > deadline:
                raise TimeoutError("Timed out waiting for clkgen device to be ready")
            logger.info("Waiting for clkgen device to be ready")

        if verify:
            self.clkgen.verify_config(self.clkprofiledir + config_filename)
