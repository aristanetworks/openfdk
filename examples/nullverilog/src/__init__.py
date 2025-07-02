# ------------------------------------------------------------------------------
#  Copyright (c) 2023 Arista Networks, Inc. All rights reserved.
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

try:
    import mosapi

    IS_MOS = mosapi.IS_MOS
except ImportError:
    IS_MOS = False

__version__ = "UNVERSIONED"
__buildid__ = 0

app_name = "nullverilog"

if IS_MOS:
    from .example import *  # pylint: disable=import-self
