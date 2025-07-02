# ------------------------------------------------------------------------------
#  Copyright (c) 2025 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    Arista FPGA System Control Wrapper.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------
"""Wrapper for Arista System Control."""
import ctypes


class PhyConfig(object):
    """
    Provides an interface to configure PHY settings.

    Attributes:
        txdiffctrl (int): TX Differential Swing (5 bits).
        txprecursor (int): TX Pre-Cursor (5 bits).
        txpostcursor (int): TX Post-Cursor (5 bits).
        txpolarity (int): TX Polarity (1 bit).
        rxdfeen (int): Selects between Rx DFE Equalization and LPM Equalization (1 bit).
        rxpolarity (int): RX Polarity (1 bit).
        txinhibit (int): TX Inhibit (1 bit).
        rxinhibit (int): RX Inhibit (1 bit).
        value (int): The raw 32-bit integer value of the register.
    """

    class _U(ctypes.Union):
        class _S(ctypes.Structure):
            _fields_ = [
                ("txdiffctrl", ctypes.c_uint32, 5),
                ("txprecursor", ctypes.c_uint32, 5),
                ("txpostcursor", ctypes.c_uint32, 5),
                ("txpolarity", ctypes.c_uint32, 1),
                ("rxdfeen", ctypes.c_uint32, 1),
                ("rxpolarity", ctypes.c_uint32, 1),
                ("txinhibit", ctypes.c_uint32, 1),
                ("rxinhibit", ctypes.c_uint32, 1),
            ]

        _anonymous_ = ("fields",)
        _fields_ = [("value", ctypes.c_uint32), ("fields", _S)]

    def __init__(self, regfile):
        super().__setattr__("_regfile", regfile)
        super().__setattr__("_phy_config", self._U())

    def __getattr__(self, name):
        self.refresh()
        return getattr(self._phy_config, name)

    def __setattr__(self, name, value):
        self.refresh()
        setattr(self._phy_config, name, value)
        self.commit()

    def refresh(self):
        self._phy_config.value = self._regfile.phy_config

    def commit(self):
        self._regfile.phy_config = self._phy_config.value


class AristaSysctlV2(object):
    """
    Provides an interface to Arista System Control functionalities (Version 2).

    Attributes:
        phy (dict): A dictionary mapping ports to their corresponding
                    PhyConfigs.
    """

    def __init__(self, regfile):
        """
        Initializes the AristaSysctlV2 instance.

        Args:
            regfile (Any): The top-level register file instantiated from
                           `arista_sysctl_v2.csv`.

        """
        self._regfile = regfile
        self.phy = {port: PhyConfig(reg) for port, reg in self._regfile.phy.ap.items()}
