# ------------------------------------------------------------------------------
#  Copyright (c) 2025 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    Support for phy tuning.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------
import json
import logging
import re

from . import IS_EOS, device

if IS_EOS:
    import eossdk
else:

    class MockedEosSdk:
        class EthPhyIntfHandler:
            pass

    eossdk = MockedEosSdk()

logger = logging.getLogger(__name__)

_tuning_data = {
    ("10g", "copper"): {
        1: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        2: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        3: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        4: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        5: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        6: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        7: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        8: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        9: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        10: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        11: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        12: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        13: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        14: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        15: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        16: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        17: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        18: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        19: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        20: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        21: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        22: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        23: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        24: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        25: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 12, "txprecursor": 4},
        26: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 12, "txprecursor": 4},
        27: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 12, "txprecursor": 4},
        28: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 12, "txprecursor": 4},
        33: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        34: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        35: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        36: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        37: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        38: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        39: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        40: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        41: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        42: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        43: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        44: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        45: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        46: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        47: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        48: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        49: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        50: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        51: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        52: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        53: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        54: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        55: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        56: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 2},
        57: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 12, "txprecursor": 4},
        58: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 12, "txprecursor": 4},
        59: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 12, "txprecursor": 4},
        60: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 12, "txprecursor": 4},
        61: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 12, "txprecursor": 4},
        62: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 12, "txprecursor": 4},
        63: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 12, "txprecursor": 4},
        64: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 12, "txprecursor": 4},
        65: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 12, "txprecursor": 4},
        66: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 12, "txprecursor": 4},
        67: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 12, "txprecursor": 4},
        68: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 12, "txprecursor": 4},
    },
    ("10g", "fiber"): {
        1: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        2: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        3: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        4: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        5: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        6: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        7: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        8: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        9: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        10: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        11: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        12: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        13: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        14: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        15: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        16: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        17: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        18: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        19: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        20: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        21: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        22: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        23: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        24: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        25: {"rxdfeen": 0, "txdiffctrl": 15, "txpostcursor": 8, "txprecursor": 0},
        26: {"rxdfeen": 0, "txdiffctrl": 15, "txpostcursor": 8, "txprecursor": 0},
        27: {"rxdfeen": 0, "txdiffctrl": 15, "txpostcursor": 8, "txprecursor": 0},
        28: {"rxdfeen": 0, "txdiffctrl": 15, "txpostcursor": 8, "txprecursor": 0},
        33: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        34: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        35: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        36: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        37: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        38: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        39: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        40: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        41: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        42: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        43: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        44: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        45: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        46: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        47: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        48: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        49: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        50: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        51: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        52: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        53: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        54: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        55: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        56: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 10, "txprecursor": 0},
        57: {"rxdfeen": 0, "txdiffctrl": 15, "txpostcursor": 8, "txprecursor": 0},
        58: {"rxdfeen": 0, "txdiffctrl": 15, "txpostcursor": 8, "txprecursor": 0},
        59: {"rxdfeen": 0, "txdiffctrl": 15, "txpostcursor": 8, "txprecursor": 0},
        60: {"rxdfeen": 0, "txdiffctrl": 15, "txpostcursor": 8, "txprecursor": 0},
        61: {"rxdfeen": 0, "txdiffctrl": 15, "txpostcursor": 8, "txprecursor": 0},
        62: {"rxdfeen": 0, "txdiffctrl": 15, "txpostcursor": 8, "txprecursor": 0},
        63: {"rxdfeen": 0, "txdiffctrl": 15, "txpostcursor": 8, "txprecursor": 0},
        64: {"rxdfeen": 0, "txdiffctrl": 15, "txpostcursor": 8, "txprecursor": 0},
        65: {"rxdfeen": 0, "txdiffctrl": 15, "txpostcursor": 8, "txprecursor": 0},
        66: {"rxdfeen": 0, "txdiffctrl": 15, "txpostcursor": 8, "txprecursor": 0},
        67: {"rxdfeen": 0, "txdiffctrl": 15, "txpostcursor": 8, "txprecursor": 0},
        68: {"rxdfeen": 0, "txdiffctrl": 15, "txpostcursor": 8, "txprecursor": 0},
    },
    ("25g", "copper"): {
        1: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        2: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        3: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        4: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        5: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        6: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        7: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        8: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        9: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        10: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        11: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        12: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        13: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        14: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        15: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        16: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        17: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        18: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        19: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        20: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        21: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        22: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        23: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        24: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        25: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 0, "txprecursor": 10},
        26: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 0, "txprecursor": 10},
        27: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 0, "txprecursor": 10},
        28: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 0, "txprecursor": 10},
        33: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        34: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        35: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        36: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        37: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        38: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        39: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        40: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        41: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        42: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        43: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        44: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        45: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        46: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        47: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        48: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        49: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        50: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        51: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        52: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        53: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        54: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        55: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        56: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 2, "txprecursor": 10},
        57: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 0, "txprecursor": 10},
        58: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 0, "txprecursor": 10},
        59: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 0, "txprecursor": 10},
        60: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 0, "txprecursor": 10},
        61: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 0, "txprecursor": 10},
        62: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 0, "txprecursor": 10},
        63: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 0, "txprecursor": 10},
        64: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 0, "txprecursor": 10},
        65: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 0, "txprecursor": 10},
        66: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 0, "txprecursor": 10},
        67: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 0, "txprecursor": 10},
        68: {"rxdfeen": 1, "txdiffctrl": 31, "txpostcursor": 0, "txprecursor": 10},
    },
    ("25g", "fiber"): {
        1: {"rxdfeen": 0, "txdiffctrl": 17, "txpostcursor": 14, "txprecursor": 2},
        2: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 17, "txprecursor": 3},
        3: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 17, "txprecursor": 3},
        4: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 17, "txprecursor": 3},
        5: {"rxdfeen": 0, "txdiffctrl": 17, "txpostcursor": 14, "txprecursor": 2},
        6: {"rxdfeen": 0, "txdiffctrl": 17, "txpostcursor": 14, "txprecursor": 2},
        7: {"rxdfeen": 0, "txdiffctrl": 17, "txpostcursor": 14, "txprecursor": 2},
        8: {"rxdfeen": 0, "txdiffctrl": 17, "txpostcursor": 14, "txprecursor": 2},
        9: {"rxdfeen": 0, "txdiffctrl": 18, "txpostcursor": 14, "txprecursor": 2},
        10: {"rxdfeen": 0, "txdiffctrl": 18, "txpostcursor": 14, "txprecursor": 2},
        11: {"rxdfeen": 0, "txdiffctrl": 18, "txpostcursor": 14, "txprecursor": 2},
        12: {"rxdfeen": 0, "txdiffctrl": 18, "txpostcursor": 14, "txprecursor": 2},
        13: {"rxdfeen": 0, "txdiffctrl": 9, "txpostcursor": 8, "txprecursor": 2},
        14: {"rxdfeen": 0, "txdiffctrl": 13, "txpostcursor": 12, "txprecursor": 4},
        15: {"rxdfeen": 0, "txdiffctrl": 9, "txpostcursor": 8, "txprecursor": 2},
        16: {"rxdfeen": 0, "txdiffctrl": 18, "txpostcursor": 14, "txprecursor": 2},
        17: {"rxdfeen": 0, "txdiffctrl": 9, "txpostcursor": 8, "txprecursor": 2},
        18: {"rxdfeen": 0, "txdiffctrl": 13, "txpostcursor": 12, "txprecursor": 4},
        19: {"rxdfeen": 0, "txdiffctrl": 9, "txpostcursor": 8, "txprecursor": 2},
        20: {"rxdfeen": 0, "txdiffctrl": 13, "txpostcursor": 12, "txprecursor": 4},
        21: {"rxdfeen": 0, "txdiffctrl": 9, "txpostcursor": 8, "txprecursor": 2},
        22: {"rxdfeen": 0, "txdiffctrl": 13, "txpostcursor": 12, "txprecursor": 4},
        23: {"rxdfeen": 0, "txdiffctrl": 9, "txpostcursor": 8, "txprecursor": 2},
        24: {"rxdfeen": 0, "txdiffctrl": 13, "txpostcursor": 12, "txprecursor": 4},
        25: {"rxdfeen": 0, "txdiffctrl": 12, "txpostcursor": 9, "txprecursor": 5},
        26: {"rxdfeen": 0, "txdiffctrl": 12, "txpostcursor": 9, "txprecursor": 5},
        27: {"rxdfeen": 0, "txdiffctrl": 12, "txpostcursor": 9, "txprecursor": 5},
        28: {"rxdfeen": 0, "txdiffctrl": 12, "txpostcursor": 9, "txprecursor": 5},
        33: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 17, "txprecursor": 3},
        34: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 17, "txprecursor": 3},
        35: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 17, "txprecursor": 3},
        36: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 17, "txprecursor": 3},
        37: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 17, "txprecursor": 3},
        38: {"rxdfeen": 0, "txdiffctrl": 31, "txpostcursor": 17, "txprecursor": 3},
        39: {"rxdfeen": 0, "txdiffctrl": 17, "txpostcursor": 14, "txprecursor": 2},
        40: {"rxdfeen": 0, "txdiffctrl": 17, "txpostcursor": 14, "txprecursor": 2},
        41: {"rxdfeen": 0, "txdiffctrl": 17, "txpostcursor": 14, "txprecursor": 2},
        42: {"rxdfeen": 0, "txdiffctrl": 17, "txpostcursor": 14, "txprecursor": 2},
        43: {"rxdfeen": 0, "txdiffctrl": 17, "txpostcursor": 14, "txprecursor": 2},
        44: {"rxdfeen": 0, "txdiffctrl": 17, "txpostcursor": 14, "txprecursor": 2},
        45: {"rxdfeen": 0, "txdiffctrl": 18, "txpostcursor": 14, "txprecursor": 2},
        46: {"rxdfeen": 0, "txdiffctrl": 18, "txpostcursor": 14, "txprecursor": 2},
        47: {"rxdfeen": 0, "txdiffctrl": 18, "txpostcursor": 14, "txprecursor": 2},
        48: {"rxdfeen": 0, "txdiffctrl": 18, "txpostcursor": 14, "txprecursor": 2},
        49: {"rxdfeen": 0, "txdiffctrl": 9, "txpostcursor": 8, "txprecursor": 2},
        50: {"rxdfeen": 0, "txdiffctrl": 13, "txpostcursor": 12, "txprecursor": 4},
        51: {"rxdfeen": 0, "txdiffctrl": 9, "txpostcursor": 8, "txprecursor": 2},
        52: {"rxdfeen": 0, "txdiffctrl": 13, "txpostcursor": 12, "txprecursor": 4},
        53: {"rxdfeen": 0, "txdiffctrl": 9, "txpostcursor": 8, "txprecursor": 2},
        54: {"rxdfeen": 0, "txdiffctrl": 13, "txpostcursor": 12, "txprecursor": 4},
        55: {"rxdfeen": 0, "txdiffctrl": 9, "txpostcursor": 8, "txprecursor": 2},
        56: {"rxdfeen": 0, "txdiffctrl": 13, "txpostcursor": 12, "txprecursor": 4},
        57: {"rxdfeen": 0, "txdiffctrl": 11, "txpostcursor": 5, "txprecursor": 5},
        58: {"rxdfeen": 0, "txdiffctrl": 11, "txpostcursor": 5, "txprecursor": 5},
        59: {"rxdfeen": 0, "txdiffctrl": 11, "txpostcursor": 5, "txprecursor": 5},
        60: {"rxdfeen": 0, "txdiffctrl": 11, "txpostcursor": 5, "txprecursor": 5},
        61: {"rxdfeen": 0, "txdiffctrl": 11, "txpostcursor": 5, "txprecursor": 5},
        62: {"rxdfeen": 0, "txdiffctrl": 14, "txpostcursor": 10, "txprecursor": 6},
        63: {"rxdfeen": 0, "txdiffctrl": 11, "txpostcursor": 5, "txprecursor": 5},
        64: {"rxdfeen": 0, "txdiffctrl": 14, "txpostcursor": 10, "txprecursor": 6},
        65: {"rxdfeen": 0, "txdiffctrl": 12, "txpostcursor": 9, "txprecursor": 5},
        66: {"rxdfeen": 0, "txdiffctrl": 12, "txpostcursor": 9, "txprecursor": 5},
        67: {"rxdfeen": 0, "txdiffctrl": 12, "txpostcursor": 9, "txprecursor": 5},
        68: {"rxdfeen": 0, "txdiffctrl": 12, "txpostcursor": 9, "txprecursor": 5},
    },
}


class TuningMixin:
    """Mixin class to handle PHY tuning for DCS-7132LB devices.

    Defines the `on_eth_phy_intf_transceiver_present` method, which applies
    appropriate tuning to an Ap interface when a new transceiver is inserted.

    Also defines the `on_initialized` method, which should be called during agent
    initialization. This enables interface watching and applies initial tuning
    to any transceivers already present."""

    def on_initialized(self):
        if device.get_sku().startswith("DCS-7132LB-"):
            self.watch_all_eth_phy_intfs(True)
            for intf_id in self.eth_phy_intf_manager.eth_phy_intf_iter():
                self.on_eth_phy_intf_transceiver_present(
                    intf_id, self.eth_phy_intf_manager.transceiver_present(intf_id)
                )

    def on_eth_phy_intf_transceiver_present(self, intf_id, present):
        if intf_id.intf_type() != eossdk.INTF_TYPE_ETH or not present:
            return
        speed = "25g" if self.eth_phy_intf_manager.link_speed(intf_id) == eossdk.LINK_SPEED_25GBPS else "10g"
        media = "copper" if "CR" in self._media(intf_id) else "fiber"
        source = self._l1_source(intf_id)
        if source is None:
            return
        m = re.match(r"Application(?P<fpga>\d+)/(?P<port>\d+)", source)
        if not m:
            return
        port = int(m.group("port"))

        # apply tuning
        phy = self.sysctl.phy[port]
        settings = _tuning_data[speed, media][port]
        logger.info("Applying %s %s tuning to Ap1/%s", speed, media, port)
        for setting, value in settings.items():
            setattr(phy, setting, value)

    def _l1_source(self, intf_id):
        response = self.eapi_mgr.run_show_cmd("show l1 source interface {}".format(intf_id.to_string()))
        return json.loads(response.responses()[0])["interfaces"][intf_id.to_string()]["sourceInterface"]

    def _media(self, intf_id):
        response = self.eapi_mgr.run_show_cmd("show interfaces {} transceiver hardware".format(intf_id.to_string()))
        return json.loads(response.responses()[0])["interfaces"][intf_id.to_string()].get("mediaType")
