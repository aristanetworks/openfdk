# ------------------------------------------------------------------------------
#  Copyright (c) 2025 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    Helpers for accessing identifying information about the system.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

import io
import re


def eos_version():
    """Returns the EOS version as a tuple of integers.

    This function parses the '/etc/swi-version' file to extract the
    major, minor, and patch numbers from the running EOS image.

    For example, for version string "4.32.2F", this function
    would return (4, 32, 2).

    If '/etc/swi-version' is not present, it returns an empty tuple.
    """
    try:
        with io.open("/etc/swi-version", encoding="utf-8") as swi_version:
            m = re.search(r"SWI_VERSION=((?:\d+\.)+\d+)-?(.*)", swi_version.read())
            return tuple(int(i) for i in m.group(1).split("."))
    except IOError:  # BUG1276022: This should be changed to FileNotFoundError when we're py3 only.
        return tuple()
