# pylint: disable=W,C,R,E

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


class ClockBase(object):
    def clamp(self, v):
        return max(-self.CLAMP, min(v, self.CLAMP))


from chron import AddSkip
from clockModules import CMA, CMAsa3xm, CMAmro50, CMO, lbCMO


def get_all():
    return [AddSkip, lbCMO, CMO, CMA, CMAsa3xm, CMAmro50]


def get(name):
    name = name.lower()
    for it in get_all():
        clockname = it.__name__.lower()
        if clockname == name:
            return it
    raise LookupError("Clock not supported: {}".format(name))
