# ------------------------------------------------------------------------------
#  Copyright (c) 2021 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    FPhy driver
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

from __future__ import absolute_import, print_function
import logging


logger = logging.getLogger(__name__)


class FPhy(object):
    """Transceiver tuning driver for a matching PHY configuration interface.

    Uses `arista_sysctl_v2` PHY configuration records to apply values from
    `Fpga.tuning_data`. The register names and layout must match the PHY
    interface used by the application.
    """

    def __init__(self):
        self._fpga = None
        self._sysctl = None
        self._tuning_data = None

    def initialise(self, fpga, sysctl, tuning_data):
        """Initialise the transceiver tuning path.

        Args:
            fpga: FPGA identifier used when reporting tuning activity.
            sysctl: `AristaSysctlV2` instance exposing PHY configuration
                records.
            tuning_data: Mapping returned by `Fpga.tuning_data`.

        This configures the inputs used by `set_speed`.
        """
        self._fpga = fpga
        self._sysctl = sysctl
        self._tuning_data = tuning_data

    def set_speed(self, port, speed, medium=None, multichannel=False):
        """Apply tuning for a port speed and medium.

        Args:
            port (int): One-based AP number.
            speed (str): Requested link speed.
            medium (str): Supported medium for the requested speed.
            multichannel (bool): Multichannel operation, which is unsupported.

        The values are written through the matching `arista_sysctl_v2` PHY
        configuration record. The requested speed and medium must be supplied
        by the platform's `Fpga.tuning_data`.
        """
        assert not multichannel
        if speed == "OFF" or not self._tuning_data:
            return
        phy = self._sysctl.phy[port]
        settings = self._tuning_data[speed, medium][port]
        logger.info("Applying %s %s tuning to Ap%s/%s", speed, medium, self._fpga, port)
        phy.txdiffctrl = settings["MainTap"]
        phy.txprecursor = settings["Pre1Tap"]
        phy.txpostcursor = settings["Post1Tap"]
        phy.rxdfeen = settings.get("DfeEnabled", False)
