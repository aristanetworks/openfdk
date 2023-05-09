# pylint: disable=W,C,R,E

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

from __future__ import absolute_import, print_function

import ctypes
import logging
import os
from math import copysign

import clockapp_mosapi as mosapi
from errors import TimeSampleError
from ptp import PTP4l as PTP
from six.moves import range


class PPSTimeSampleTimeoutError(TimeSampleError):
    pass


class PTPTimeSampleError(TimeSampleError):
    pass


###############
### AddSkip ###
###############


class AddSkip(object):
    quality = 0
    # note: clamp at 500M ppb results in add/skip value of 2, which is 333ms/second.
    #       add one to coerce rounding in adjust() to program 500ms/s
    CLAMP = 500000001

    def __init__(self, appname):
        app = mosapi.get_app_by_name(appname)
        self.chron = app.reg.ts.chron
        self.adjust(0)

    def adjust(self, ppb):

        #  We do clamp in the PI to avoid windup, but also cofirm here
        if ppb > self.CLAMP:
            ppb = self.CLAMP
        elif ppb < -self.CLAMP:
            ppb = -self.CLAMP

        try:
            # value depends only on magnitude of desired ppb ...
            val = int(1000000000 / abs(ppb))

            if val == 0:
                # should never happen with sensible clamp values, but be 110%
                # certain the above divide never results in rounded zero
                val = 1

            # ... direction depends only on it's sign
            addskip = int(ppb > 0)

        except ZeroDivisionError:
            # ppb of zero means ppb was sufficiently low, so may as well do nothing
            val = 0
            addskip = 0

        self.chron.apply_add_skip_period = 1
        self.chron.add_skip_period = val
        self.chron.add_skipn = addskip
        self.chron.apply_add_skip_period = 0

        # representation of value as written to registers
        self.raw = float(copysign(val, ppb))
        return ppb


###########
### PPS ###
###########

import time

from scc import SCC


class ChronPPS(object):
    def __init__(self, appname):
        self.quality = 10
        self.scc = SCC()

        self.app = mosapi.get_app_by_name(appname)
        self.spartan_reg = self.app.reg.ts.spartan_pps
        self.chron_reg = self.app.reg.ts.chron

        self.downtime = None
        self.cabledelay = None

    def get_cabledelay(self):
        try:
            cabledelay = int(round(float(open("/var/run/metamako/sync/cable_delay").read())))
        except IOError as e:
            if e.errno == 2:  # No Such file or directory
                cabledelay = 0
            else:
                raise

        if self.cabledelay != cabledelay:
            if self.cabledelay is None:
                logging.info("PPS Cabledelay initially set: {}".format(cabledelay))
            else:
                logging.info("PPS Cabledelay changed: {} --> {}".format(self.cabledelay, cabledelay))
        self.cabledelay = cabledelay
        return cabledelay

    def sample(self):
        # we're about to wait anyway, may as well do this busywork now.
        cabledelay = self.get_cabledelay()

        try:
            ms_since_pps, time_of_pps = self.scc.wait_pps()
            if self.downtime:
                logging.error("PPS Resumed after {:.2f}s".format(time.time() - self.downtime))
                self.downtime = None
        except RuntimeError as e:
            if not self.downtime:
                logging.info("PPS Down")
                self.downtime = time.time()
            raise PPSTimeSampleTimeoutError(e.message)

        sys_time = int(round(time_of_pps)) * 1000000000
        sec = self.spartan_reg.timestamp_high
        nsec = self.spartan_reg.timestamp_low
        pps_time = sec * 1000000000 + nsec + cabledelay
        return sys_time, pps_time

    def set_time(self):
        self.scc.wait_pps()
        pps_time = int(round(time.time())) * 1000000000

        # 6 extra ns because there is 3 cycles latency in the latch process
        pps_time += 1000000000 + 6

        self.chron_reg.apply_initval = 7
        self.chron_reg.initval_high = (pps_time >> 32) & 0xFFFFFFFF
        self.chron_reg.initval_low = (pps_time >> 0) & 0xFFFFFFFF
        self.chron_reg.initval_s = pps_time / 1000000000
        self.chron_reg.initval_ns = pps_time % 1000000000
        self.chron_reg.apply_initval = 4
        self.scc.wait_pps()

        # call apps 'time_is_init' method (if it has one), so that the app can perform 'on init' setup
        if hasattr(self.app, "time_is_init"):
            self.app.time_is_init()


###########
### PTP ###
###########

import ctypes

# Hack: use portio directly to poke the GPIO.
# Faster & lower latency/jitter than syscall?
import portio


class ChronClock(object):
    def __init__(self, appname):
        self.app = mosapi.get_app_by_name(appname)
        self.chron = self.app.reg.ts.chron
        self.host_gpio = self.app.reg.ts.host_gpio

        portio.ioperm(0x500 + 0x88, 4, 1)

        sopath = os.path.join(os.path.dirname(__file__), ".", "ptpcmp.so")
        self.ptpcmp = ctypes.CDLL(sopath)
        self.ptpcmp.raise_priority()

    def get_gpio_time(self):
        sec = self.host_gpio.timestamp_high
        nsec = self.host_gpio.timestamp_low
        return sec * 1000000000 + nsec

    def get_one(self):
        t1 = ctypes.c_ulonglong()
        t2 = ctypes.c_ulonglong()
        self.ptpcmp.timed_strobe(self.clockid, ctypes.byref(t1), ctypes.byref(t2))
        sample = self.get_gpio_time()
        return t1.value, sample, t2.value

    def sample(self, num_samps=50):
        time.sleep(-time.time() % 1)
        samps = []
        for x in range(num_samps):
            samps.append(self.get_one())

        samps.sort(key=lambda x: x[2] - x[0], reverse=False)

        t1, sample, t2 = samps[0]
        reference = (t1 + t2) / 2
        return reference, sample

    def set_time(self):
        portio.outl(0x00, 0x500 + 0x88)

        now = time.time()

        value_to_write = now + 1
        time_to_write_at = now + 0.9999988  # emperically, we end up off by ~1.2us, so compensate

        seconds_f, subseconds_f = divmod(value_to_write, 1)
        seconds = int(seconds_f)
        nanoseconds = int(subseconds_f * 1000000000)
        epoch_time = seconds * 1000000000 + nanoseconds

        # preload all registers ..
        self.chron.apply_initval = 9
        self.chron.initval_high = (epoch_time >> 32) & 0xFFFFFFFF
        self.chron.initval_low = (epoch_time >> 0) & 0xFFFFFFFF
        self.chron.initval_s = seconds
        self.chron.initval_ns = nanoseconds
        self.chron.apply_initval = 8

        # .. wait for the correct time ..
        while time.time() < time_to_write_at:
            pass  # spin

        # and latch them in
        portio.outl(0x80, 0x500 + 0x88)

        # call apps 'time_is_init' method (if it has one), so that the app can perform 'on init' setup
        if hasattr(self.app, "time_is_init"):
            self.app.time_is_init()


class ChronPTP(ChronClock):
    def __init__(self, *args, **kwargs):
        self.quality = 5

        self.downtime = None

        ChronClock.__init__(self, *args, **kwargs)
        self.ptp = PTP()

        self._iface = None
        self.clockid = None
        self.iface = None

    @property
    def iface(self):
        return self._iface

    @iface.setter
    def iface(self, iface):
        if iface == self._iface:
            # No change; do nothing
            return

        # something has changed; invalidate the stored clockid ..
        if self.clockid != None:
            self.ptpcmp.close_ptpclock(self.clockid)
            self.clockid = None

        # .. and get a new one if necesary
        if iface:
            self.clockid = self.ptpcmp.open_ptpclock(iface)

        self._iface = iface

    def sample(self, *args, **kwargs):
        try:
            self.iface, time_offset, utc_offset = self.ptp.poll()
            ref, samp = ChronClock.sample(self, *args, **kwargs)
            if self.downtime:
                logging.error("PTP Resumed after {:.2f}s".format(time.time() - self.downtime))
            self.downtime = None
        except NotImplementedError as e:
            raise
        except RuntimeError as e:
            if not self.downtime:
                logging.info("PTP Down")
                self.downtime = time.time()
            raise PTPTimeSampleError(e.message)
        ref += 1383  # Asymmetry Correction
        return ref - utc_offset * 1000000000, samp


class ChronSystem(ChronClock):
    def __init__(self, *args, **kwargs):
        self.quality = 3
        ChronClock.__init__(self, *args, **kwargs)
        self.clockid = 0  # CLOCK_REALTIME


if __name__ == "__main__":
    import sys

    p = ChronPTP()
    for x in range(sys.maxsize):
        try:
            r = p.sample()
            print(x, time.time(), r)
        except Exception as r:
            print(r)
            # raise
            time.sleep(1)
