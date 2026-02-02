# ------------------------------------------------------------------------------
#  Copyright (c) 2021 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    The libapp package.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------
"""The libapp package."""

from __future__ import absolute_import

try:
    import hal

    IS_EOS = False
except ImportError:
    IS_EOS = True

from . import (
    cli,
    clock_generator,
    daemon,
    device,
    eossdk_utils,
    eossdk_helpers,
    fphy,
    loghandler,
    network,
    pcie,
    profiles,
    register_accessor,
    register_file,
    subprocess,
    system,
    sysctl,
    tuning,
)
