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

from __future__ import absolute_import

from collections import deque
from math import copysign


class PIController(object):
    def __init__(self, pval=0.2, ival=0.01, clamp=500, integral=0):
        self.p = pval
        self.i = ival
        self.clamp = clamp
        self.i_effort = integral
        # Initial values of the previous effort and error.
        self.effort_1 = integral
        self.error_1 = 0

    def step(self, error):
        p_effort = error * self.p
        i_effort = self.i_effort + (error * self.i)
        effort = i_effort + p_effort

        # Clamp the output, don't accumulate if we're over threshold
        if abs(effort) > self.clamp:
            return copysign(self.clamp, effort)

        # The magnitude of effort wasn't greater than +/- clamp, we're OK!
        self.i_effort = i_effort
        return effort

    def incremental_PI(self, error):
        # The naming convention is:
        # _0 = the current time
        # _1 = one sample period ago (the previous value)

        # Constants for the "incremental" version of the PI controller
        K0 = self.p + self.i / 2.0
        K1 = -self.p + self.i / 2.0

        # "Incremental" version of the PI controller
        delta_effort = K0 * error + K1 * self.error_1
        effort_0 = self.effort_1 + delta_effort

        # Clamp the effort to the limit of the allowable control effort.
        # In this case, there is no change in the control effort.
        if effort_0 > self.clamp:
            effort_0 = self.clamp
        elif effort_0 < -self.clamp:
            effort_0 = -self.clamp

        # Store the `effort[n]` and `error[n]` for use in the next iteration
        # where they will be `effort[n-1]` and `error[n-1]`
        self.effort_1 = effort_0
        self.error_1 = error
        return effort_0

    def __call__(self, error):
        return self.incremental_PI(error)

    def __str__(self):
        return "<PI: P({}) I({}:{})>".format(self.p, self.i, self.i_effort)


class MAF(object):
    def __init__(self, depth):
        self.fifo = deque(maxlen=depth)

    @property
    def val(self):
        return sum(self.fifo) / float(len(self.fifo))

    def step(self, v):
        self.fifo.append(v)
        return self.val

    def __call__(self, v):
        return self.step(v)

    def __str__(self):
        return "<MAF[{}/{}]: {}>".format(len(self.fifo), self.fifo.maxlen, self.val)
