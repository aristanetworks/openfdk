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
    def __init__(self):
        self._fpga = None
        self._sysctl = None
        self._tuning_data = None

    def initialise(self, fpga, sysctl, tuning_data):
        self._fpga = fpga
        self._sysctl = sysctl
        self._tuning_data = tuning_data

    def set_speed(self, port, speed, medium=None, multichannel=False):
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
