# pylint: disable=W,C,R

# ------------------------------------------------------------------------------
#  Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
#    fdk-support@arista.com
#
#  Description:
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

from __future__ import absolute_import, print_function

import os
import time


class SCC(object):
    def __init__(self):
        if os.path.exists("/sys/bus/platform/devices/scc-metamako/pps_count"):
            self.fp = open("/sys/bus/platform/devices/scc-metamako/pps_count", "r")

    def wait_pps(self):
        def get_pps_count():
            "ms (in steps of ~4ms) since the last received pulse, as per frontend glue logic."
            self.fp.seek(0)
            return int(self.fp.read())

        now = get_pps_count()
        if now == 1020:
            # if we start saturated out, give it some time
            time.sleep(0.5)

        # wait for the count to step backward, that's an edge
        i = 0
        while True:
            v = get_pps_count()
            if v < now:
                return v, time.time() - v / 1000.0

            sleep = None
            if v < 990:
                #  pulse is a long time away, sleep till then
                sleep = (990 - v) / 1000.0
            elif v < 1000:
                # pulse is close, do a few quick sleeps
                sleep = 0.001
            elif v == 1000:
                # pulse is imminent, just poll at this stage
                sleep = 0
            elif v < 1020:
                # Hmm, pulse is quite late (4ms or worse). Probably missed but lets sleep it out
                sleep = 0.001
            elif v == 1020:
                if i == 0:
                    # saturated max value. First time let it slide
                    sleep = 0.5
                else:
                    # Otherwise barf.
                    # this may cause us to be a little late realiseing PPS returns, but oh well it was pretty bad anyway.
                    raise RuntimeError("PPS Down. Is PPS connected to the device?")

            now = v
            if sleep:
                time.sleep(sleep)
            i += 1
        # How did we even get here? Raise!
        raise RuntimeError("PPS Down. Is PPS connected to the device?")


if __name__ == "__main__":
    import psutil

    scc = SCC()
    me = psutil.Process()
    while True:

        try:
            a = scc.wait_pps()
        except RuntimeError:
            a = "TIMEOUT"
        times = me.cpu_times()
        print("TICK: ", a, times[0] + times[1], me.cpu_percent())
