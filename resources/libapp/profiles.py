# ------------------------------------------------------------------------------
#  Copyright (c) 2024 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    Base profile class for applications
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

from . import device


class ProfileBase:
    def __init__(self, fpga_inst, raw):
        self.raw_dict = raw
        self.fpga_device = device.get_fpga_devices(identifier=fpga_inst)[0]

    @property
    def name(self):
        return self.raw_dict["name"]

    @property
    def description(self):
        return self.raw_dict["description"]

    @property
    def hidden(self):
        return self.raw_dict["hidden"]

    @property
    def bitfile(self):
        return self.raw_dict["bitStream"]["bitFile"]

    @property
    def bitstream_id(self):
        return self.raw_dict["bitStream"]["bitStreamId"]

    @property
    def board_standard(self):
        return self.raw_dict["bitStream"]["boardStd"]

    @property
    def clock_profile(self):
        return self.raw_dict["bitStream"]["clockProfile"]

    # Communicators
    @property
    def pcie_bar(self):
        return self.raw_dict["bitStream"]["communicators"]["pcie"]["region"]

    @property
    def pcie_bdf(self):
        pcie_dev = self.raw_dict["bitStream"]["communicators"]["pcie"]["device"]
        pcie_func = self.raw_dict["bitStream"]["communicators"]["pcie"]["function"]
        return self.fpga_device.pcie.domain + ":" + self.fpga_device.pcie.bus_num + ":" + pcie_dev + "." + pcie_func

    # Port Definitions
    @property
    def raw_portdef(self):
        return self.raw_dict["portDef"]

    # Helpers
    @property
    def is_compatible(self):
        return self.fpga_device.board_standard == self.board_standard
