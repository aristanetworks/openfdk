#!/usr/bin/env arista-python
# ------------------------------------------------------------------------------
#  Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
#    fdk-support@arista.com
#
#  Description:
#    Example application demonstrating CLI.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

from __future__ import absolute_import, division, print_function

import logging
import sys

import json
import eossdk
import libapp
import libapp.eossdk_utils


logger = logging.getLogger(__name__)

daemon_name = "CliExampleDaemon"


class CliExampleDaemon(
    libapp.eossdk_utils.EosSdkAgent,
    libapp.daemon.LoggingMixin,
    libapp.daemon.ConfigMixin,
    libapp.daemon.StatusMixin,
    eossdk.AgentHandler,
):
    def __init__(self, sdk):
        self.agent_mgr = sdk.get_agent_mgr()

        libapp.daemon.LoggingMixin.__init__(self, sdk.name())
        eossdk.AgentHandler.__init__(self, self.agent_mgr)

    # inherited from AgentHandler
    # http://aristanetworks.github.io/EosSdk/docs/2.10.0/ref/agent.html
    def on_initialized(self):
        """Handler called after the agent has been internally initialized.
        At this point, all managers have synchronized with Sysdb, and the
        agent's handlers will begin firing. In the body of this method, agents
        should check Sysdb and handle the initial state of any configuration and
        status that this agent is interested in."""

        logger.info("on_initialized")

        # Remove all status, giving us a clean slate.
        self.status.clear()

        # Run on_agent_option any config that already exists.
        logger.info("Loading initial config")
        for item in self.config:
            self.on_agent_config(item)

        # Indicate the daemon status (read by the CLI code).
        self.status["running"] = True

    def on_agent_config(self, item):
        """Handler called when a configuration option of the agent has changed.
        If the option was deleted, this will be called with value set as the
        empty string. Otherwise, value will contain the added or altered string
        corresponding to the option name."""

        logger.info("on_agent_config %s %s", json.dumps(item.key), json.dumps(item.value))

        if item.matches("ip address [secondary]"):
            if "secondary" not in item:
                key = "ip address"
            else:
                key = "ip address secondary"

            if item.value:
                self.status[key] = item["<ip>"]
            else:
                del self.status[key]

    def on_agent_enabled(self, enabled):
        logger.info("on_agent_enabled %s", enabled)
        # Remove all status, giving us a clean slate.
        self.status.clear()

        # Indicate that we shut down cleanly.
        self.agent_mgr.agent_shutdown_complete_is(True)


def main():
    logging.basicConfig(format="%(asctime)s %(levelname)s: %(name)s: %(message)s", level="INFO")

    sdk = eossdk.Sdk(daemon_name)
    _ = CliExampleDaemon(sdk)
    sdk.main_loop(sys.argv)


if __name__ == "__main__":
    main()
