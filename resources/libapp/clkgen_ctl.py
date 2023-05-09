# ------------------------------------------------------------------------------
#  Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
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
"""Clock generator controller for applications running on Arista 7130 switches.

Deprecated: Use the `clock_generator` module instead.
"""
from __future__ import absolute_import

import os
import warnings

import hal
import hal.si5345


warnings.warn(
    "clkgen_ctl is deprecated. Please use the clock_generator module instead.",
    DeprecationWarning,
)


class ClkGenDevice(object):  # pylint:disable=too-many-instance-attributes
    """Clock generator (clkgen) controller."""

    appdir = os.path.dirname(__file__)

    def __init__(self):
        self.clkgen = hal.si5345.Si5345(hal.i2c.label_to_bus("mezzanine"), 0x6B)
        profile_dir = self.appdir + "/clkgen_profiles/"

        self.default_cfg = profile_dir + "default_lb2_lyrebird_si5345.txt"
        self.ETH_cfg = profile_dir + "eth156OCXO_lb2_lyrebird_si5345.txt"
        self.ETH161_cfg = profile_dir + "eth161_lb2_lyrebird_si5345.txt"
        self.PAL_cfg = profile_dir + "pal148OCXO_lb2_lyrebird_si5345.txt"
        self.PALx2_cfg = profile_dir + "pal297OCXO_lb2_lyrebird_si5345.txt"
        self.NTSC_cfg = profile_dir + "ntsc148OCXO_lb2_lyrebird_si5345.txt"
        self.NTSCx2_cfg = profile_dir + "ntsc297OCXO_lb2_lyrebird_si5345.txt"

    # ---------------------------------------------------------------------------
    # Command handlers
    # ---------------------------------------------------------------------------
    def set_clkgenconfig(self, profile):
        """Sets clkgen profile.

        Configures clkgen with the specified profile and waits for the device
        to be ready.

        Args:
            profile (str): Name of profile to apply. Possible values are:
                "eth", "eth161", "pal", "ntsc", "palx2", "ntscx2".
        """
        if profile == "eth":
            self.clkgen.config(self.ETH_cfg)
        elif profile == "eth161":
            self.clkgen.config(self.ETH161_cfg)
        elif profile == "pal":
            self.clkgen.config(self.PAL_cfg)
        elif profile == "ntsc":
            self.clkgen.config(self.NTSC_cfg)
        elif profile == "palx2":
            self.clkgen.config(self.PALx2_cfg)
        elif profile == "ntscx2":
            self.clkgen.config(self.NTSCx2_cfg)
        else:
            self.clkgen.config(self.default_cfg)

        while not self.clkgen.device_ready:
            pass

    def rst_clkgenconfig(self):
        """Resets clkgen profile to the default value."""
        self.clkgen.config(self.default_cfg)

        while not self.clkgen.device_ready:
            pass
