# pylint: disable=W,C,R,E

# ------------------------------------------------------------------------------
#  Copyright (c) 2021 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
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

from __future__ import absolute_import

from chron import ChronPPS, ChronPTP, ChronSystem
from freerun import Freerun


def get_all():
    return [ChronPPS, ChronPTP, ChronSystem, Freerun]


def get(name):
    name = name.lower()
    for it in get_all():
        refname = it.__name__.lower()
        if refname == name:
            return it
    raise LookupError(name)
