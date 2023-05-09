# ------------------------------------------------------------------------------
#  Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
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

from __future__ import absolute_import

import time

import clockapp_mosapi as mosapi
from errors import TimeSampleError


class FreeRunError(TimeSampleError):
    pass


class Freerun(object):
    quality = -1
    CLAMP = 1000000000

    def __init__(self, appname):
        self.app = mosapi.get_app_by_name(appname)

    # return the current system time as both the reference and
    # sampled time. This will result in zero perceived error
    # for both frequency and absolute time.
    def sample(self):
        raise FreeRunError("timesource freerun")

    def set_time(self):
        chron = self.app.reg.ts.chron

        seconds_f, subseconds_f = divmod(time.time(), 1)

        seconds = int(seconds_f)
        nanoseconds = int(subseconds_f * 1000000000)
        the_time = seconds * 1000000000 + nanoseconds

        chron.apply_initval = 1
        chron.initval_high = (the_time >> 32) & 0xFFFFFFFF
        chron.initval_low = (the_time >> 0) & 0xFFFFFFFF
        chron.initval_s = the_time / 1000000000
        chron.initval_ns = the_time % 1000000000
        chron.apply_initval = 0

        # call apps 'time_is_init' method (if it has one), so that the app can perform 'on init' setup
        if hasattr(self.app, "time_is_init"):
            self.app.time_is_init()
