#!/usr/bin/env arista-python
# ------------------------------------------------------------------------------
#  Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
#    fdk-support@arista.com
#
#  Description:
#    The null example daemon which responds to changes in config, and
#    publishes status. This is an EosSdk daemon.
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

import eossdk
from null import libapp

logger = logging.getLogger(__name__)


class NullExampleDaemon(
    libapp.eossdk_utils.EosSdkAgent,
    libapp.daemon.LoggingMixin,
    eossdk.AgentHandler,
    eossdk.TimeoutHandler,
    libapp.daemon.StatusMixin,
):  # pylint: disable=too-many-instance-attributes

    # EOSSDK setup.
    def __init__(self, sdk):
        self.agent_manager = sdk.get_agent_mgr()
        self.timeout_manager = sdk.get_timeout_mgr()

        self.appdir = "/opt/apps/null"
        self.loaded_fpgas = []
        self.fpga_registers = {}

        libapp.daemon.LoggingMixin.__init__(self, sdk.name())
        eossdk.AgentHandler.__init__(self, self.agent_manager)
        eossdk.TimeoutHandler.__init__(self, self.timeout_manager)

    # inherited from AgentHandler
    # http://aristanetworks.github.io/EosSdk/docs/2.10.0/ref/agent.html
    def on_initialized(self):
        """Handler called after the agent has been internally initialized.
        At this point, all managers have synchronized with Sysdb, and the
        agent's handlers will begin firing. In the body of this method, agents
        should check Sysdb and handle the initial state of any configuration and
        status that this agent is interested in."""

        logger.debug("on_initialized")

        # Remove all status, giving us a clean slate.
        self.status.clear()

        fpgas = libapp.device.get_fpga_devices()

        self.status["fpgas"] = {}

        for fpga in fpgas:
            fpga_name = fpga.name().lower()

            if fpga.board_standard not in (
                "e_central",
                "e_leaf",
                "eh_central",
                "eh_leaf",
                "l",
                "lb2",
            ):
                logger.error("This Application is not compatible with the current Device Board Standard.")
                continue

            bit = self.appdir + "/fpga/null-{}.bit".format(fpga.board_standard)

            logger.debug("Programming %s ...", fpga_name.title())
            fpga.load_image(bit)
            self.loaded_fpgas.append(fpga)

            csvfile = self.appdir + "/fpga/null_registers.csv"

            self.fpga_registers[fpga_name] = libapp.register_file.RegisterFile(csvfile, fpga.communicator)

        # Demonstrate that registers can be read immediately.
        for fpga_name, regfile in self.fpga_registers.items():
            logger.debug("Fpga: %s appName is: %s", fpga_name, regfile.app_name)

        self.status["fpgas"] = {f: r.app_name for f, r in self.fpga_registers.items()}

        # Indicate the daemon status (read by the CLI code).
        self.status["running"] = True

        # Run on_agent_option any config that already exists.
        logger.info("Loading initial config")
        for k in self.agent_manager.agent_option_iter():
            self.on_agent_option(k, self.agent_manager.agent_option(k))

        # Set up a timeout to go off after 1s (which will recursively
        # enable the next timeout, so we get a 1s tick).
        self.on_timeout()

        # Print for the agent logs in /var/log/agents/*
        logger.debug("Finished initialization")

    def on_agent_option(self, key, val):
        """Handler called when a configuration option of the agent has changed.
        If the option was deleted, this will be called with value set as the
        empty string. Otherwise, value will contain the added or altered string
        corresponding to the option name."""
        #  Not implemented

    # This gets called when we are disabled
    def on_agent_enabled(self, enabled):
        logger.debug("on_agent_enabled - %s", str(enabled))
        if not enabled:
            sys.stdout.flush()

            # Disable the timeout
            self.timeout_time_is(eossdk.never)

            # Clear the FPGAs
            for fpga in self.loaded_fpgas:
                fpga.unload_image()

            # Remove all status, giving us a clean slate.
            self.status.clear()

            # Indicate that we shut down cleanly.
            self.agent_manager.agent_shutdown_complete_is(True)

    def on_timeout(self):
        logger.debug("on_timeout")
        self.status["last_timeout"] = eossdk.now()

        self.timeout_time_is(eossdk.now() + 1)
        logger.debug("on_timeout completed")


def main():
    logging.basicConfig(format="%(asctime)s %(levelname)s: %(name)s: %(message)s", level="DEBUG")
    sdk = eossdk.Sdk("NullExampleDaemon")
    _ = NullExampleDaemon(sdk)
    sdk.main_loop(sys.argv)


if __name__ == "__main__":
    main()
