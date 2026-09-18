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

from . import IS_EOS, device, fphy, register_file, sysctl

if IS_EOS:
    import eossdk
else:

    class MockedEosSdk:
        class EthPhyIntfHandler:
            pass

    eossdk = MockedEosSdk()

logger = logging.getLogger(__name__)


class TuningMixin:
    """Mixin for applying FPGA transceiver tuning through a matching PHY interface.

    This mixin uses the `arista_sysctl_v2` PHY configuration record layout.
    Use it where the corresponding PHY interface is provided by the board
    support package. The application must provide `fpga`, `app_path`, an
    `EthPhyIntfHandler`, an `eth_phy_intf_manager`, and an eAPI manager. Call
    `on_initialized` and `on_agent_enabled` alongside the application's own
    handler lifecycle.

    The mixin reacts to initial interface state, link-speed changes, and
    transceiver insertion.
    """

    def __init__(self, _):
        self.fphy = None
        self.sysctl = None

    def on_initialized(self):
        # Set up fphy/sysctl
        if self.fphy is None:
            # Set up sysctl
            if self.sysctl is None:
                self.sysctl = sysctl.AristaSysctlV2(
                    register_file.RegisterFile(
                        "{}/fpga/arista_sysctl_v2.csv".format(self.app_path), self.fpga.sys_communicator
                    )
                )

            self.fphy = fphy.FPhy()
            self.fphy.initialise(self.fpga.id, self.sysctl, self.fpga.tuning_data)

        # Set up the ports
        for intf_id in self.eth_phy_intf_manager.eth_phy_intf_iter():
            if device.get_sku().startswith("DCS-7132LB-"):
                if intf_id.intf_type() != eossdk.INTF_TYPE_ETH:
                    continue
            else:
                if not intf_id.to_string().startswith("FpgaFunction"):
                    continue
            self.watch_eth_phy_intf(intf_id, True)
            self._apply_tuning(intf_id)

    def on_agent_enabled(self, enabled):
        if not enabled:
            self.fphy = None

    def on_eth_phy_intf_link_speed(self, intf_id, _):
        self._apply_tuning(intf_id)

    def on_eth_phy_intf_transceiver_present(self, intf_id, _):
        self._apply_tuning(intf_id)

    def _apply_tuning(self, intf_id):
        if device.get_sku().startswith("DCS-7132LB-"):
            port = int(re.match(r"Application\d+/(\d+)", self._l1_source(intf_id)).group(1))
            # FIXME: if we can get the media type via EosSdk we can avoid this
            while self._medium(intf_id) is None:
                pass
            medium = "copper" if "CR" in self._medium(intf_id) else "fiber"
        else:
            port = int(re.match(r"FpgaFunction\d+/(\d+)", intf_id.to_string()).group(1))
            medium = "copper"
        if self.fphy is not None:
            self.fphy.set_speed(port, self._link_speed(intf_id), medium)

    def _l1_source(self, intf_id):
        response = self.eapi_mgr.run_show_cmd("show l1 source interface {}".format(intf_id.to_string()))
        return json.loads(response.responses()[0])["interfaces"][intf_id.to_string()]["sourceInterface"]

    def _link_speed(self, intf_id):
        link_speed = self.eth_phy_intf_manager.link_speed(intf_id)
        if link_speed == eossdk.LINK_SPEED_1GBPS:
            return "1G"
        if link_speed == eossdk.LINK_SPEED_25GBPS:
            return "25G"
        return "10G"

    def _medium(self, intf_id):
        response = self.eapi_mgr.run_show_cmd("show interfaces {} transceiver hardware".format(intf_id.to_string()))
        return json.loads(response.responses()[0])["interfaces"][intf_id.to_string()].get("mediaType") or ""
