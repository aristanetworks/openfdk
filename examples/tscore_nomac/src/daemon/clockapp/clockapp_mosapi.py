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

from mosapi import *


def get_app_by_name(appname):
    assert appname != "", "App name cannot be [empty string]"
    import metamako  # pylint: disable=import-outside-toplevel

    return metamako.get_app(appname)


def boardinfo():
    import hal  # pylint: disable=import-outside-toplevel

    return hal.boardinfo()


def clock_module():
    import hal  # pylint: disable=import-outside-toplevel

    module = hal.get_clock_module()
    return module and module.device_name
