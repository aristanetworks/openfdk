# ------------------------------------------------------------------------------
#  Copyright (c) 2021 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    Clock synchronisation daemon for ts_ipcore.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

from __future__ import absolute_import, print_function

import datetime
import time

import cs4321
import hal.cdr

from .scc import SCC

# Clockapp module for CDR et8
# Not yet any real clean way to specify which Et to use, or use multiple in one second (as timewheeld does)
# So for now this is likely to remain a curiosity


class Et8(object):

    quality = 0
    CLAMP = 500000000

    def __init__(self):
        self.scc = SCC()
        self.slice = 7
        self.dir = cs4321.INGRESS_DIR
        self.adjust(0)

    def sample(self):
        phy_time = self.snapshot_on_pps()  # will wait
        sys_time = int(round(time.time())) * 1000000000
        return sys_time, phy_time

    def snapshot_on_pps(self):
        timesnap = cs4321.cs_ptp_time_t()
        with hal.cdr.Device(self.slice):
            cs4321.ptp_snapshot_on_pps(self.slice, self.dir, 1, timesnap)
        return int(timesnap.sec * 10**9) + int(timesnap.ns + 1.0 * timesnap.subns / 0xFFFFFFFF)

    def set_time(self):
        timesnap = cs4321.cs_ptp_time_t()
        timesnap.sec = int((datetime.datetime.utcnow() - datetime.datetime(1970, 1, 1)).total_seconds()) + 1
        timesnap.ns = 0
        timesnap.subns = 0
        with hal.cdr.Device(self.slice):
            cs4321.ptp_timewheel_autosync(self.slice, timesnap, self.dir)

    def adjust(self, ppb):
        base = 3.10303030305
        new_period = base * (1 + (ppb / 1000000000.0))

        new_period_ptp = cs4321.cs_ptp_period_t()
        new_period_ptp.ns = int(new_period)
        new_period_ptp.subns = int((1.0 * new_period - int(new_period)) * 0xFFFFFFFF)

        # Set new period into timewheel
        with hal.cdr.Device(self.slice):
            cs4321.ptp_period_set(self.slice, new_period_ptp, self.dir)
        return float(new_period)

    def ptp_period(self):
        period = cs4321.cs_ptp_period_t()
        with hal.cdr.Device(self.slice):
            cs4321.ptp_period_get(self.slice, period, self.dir)
        return period.ns + 1.0 * period.subns / 0xFFFFFFFF


if __name__ == "__main__":
    et = Et8()
    while True:
        a, b = et.sample()
        print(time.time(), b - a)
