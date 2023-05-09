# ------------------------------------------------------------------------------
#  Copyright (c) 2019-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
#    fdk-support@arista.com
#
#  Description:
#    FPGA-related helper functions for PCIe PIO example application
#
#    This code is part of a proof of concept of PCIe on Arista's 7130E and 7130L
#    Series platforms. This application provides a means to verify that PCIe is
#    functional on these platforms and should not be used as a guideline for PCIe
#    designs on these platforms. This method of interfacing to PCIe will become
#    unsupported once MOS API adds official support for PCIe.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

from .. import IS_EOS

if not IS_EOS:
    import mosapi


def get_pcie_bifurcations(fpgas):
    if len(fpgas) == 1:
        m = mosapi.get_device_by_label("mezzanine")
        if m.device_name == "LY":
            # Mellanox uses the other eight lanes
            return ["x8x8"]
        if m.device_name == "EM":
            return ["x8x8", "x8x4x4"]
    elif len(fpgas) == 3:
        return ["x8x4x4"]

    return None
