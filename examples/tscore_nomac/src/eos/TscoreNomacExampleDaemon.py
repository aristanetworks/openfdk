#!/usr/bin/env arista-python
# ------------------------------------------------------------------------------
#  Copyright (c) 2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
#    fdk-support@arista.com
#
#  Description:
#    The tscore nomac example triggers a timestamp when the <trigger> register is
#    written to.
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
import time
from datetime import datetime

from tscore_nomac import libapp
import eossdk


logger = eossdk.Tracer(__name__)


class TscoreNomacExampleDaemon(
    libapp.eossdk_utils.EosSdkAgent,
    eossdk.AgentHandler,
    eossdk.TimeoutHandler,
    libapp.daemon.StatusMixin,
):  # pylint: disable=too-many-instance-attributes
    # EOSSDK setup.
    def __init__(self, sdk):
        self.agent_manager = sdk.get_agent_mgr()
        self.timeout_manager = sdk.get_timeout_mgr()

        self.app_path = "/opt/apps/tscore_nomac"

        self.fpga = None
        self.regfile = None

        logger.enabled_is(0, True)
        logger.enabled_is(1, True)
        logger.enabled_is(3, True)

        eossdk.AgentHandler.__init__(self, self.agent_manager)
        eossdk.TimeoutHandler.__init__(self, self.timeout_manager)

    def get_readable_timestamp(self):
        high = self.regfile.example_ts_0.timestamp_high
        low = self.regfile.example_ts_0.timestamp_low
        return "{}.{:09d}".format(datetime.utcfromtimestamp(high), low)

    # inherited from AgentHandler
    # http://aristanetworks.github.io/EosSdk/docs/2.10.0/ref/agent.html
    def on_initialized(self):
        """Handler called after the agent has been internally initialized.
        At this point, all managers have synchronized with Sysdb, and the
        agent's handlers will begin firing. In the body of this method, agents
        should check Sysdb and handle the initial state of any configuration and
        status that this agent is interested in."""

        logger.trace0("on_initialized")

        # Remove all status, giving us a clean slate.
        self.status.clear()

        # Load the example bitfile on the first available FPGA
        # This example supports l, lb and eh_central board standards.
        fpga = libapp.device.get_fpga_devices()[0]
        assert fpga.board_standard in ["l", "lb2", "eh_central"]
        self.fpga = fpga

        # The bitfiles are suffixed with the board standard string.
        bitfile = "{}/fpga/tscore_nomac-{}.bit".format(self.app_path, fpga.board_standard)
        fpga.load_image(bitfile)
        self.status["Image"] = bitfile

        # Set up a register file.
        self.regfile = libapp.register_file.RegisterFile(
            "{}/fpga/tscore_nomac_registers.csv".format(self.app_path), fpga.communicator
        )

        # Demonstrate that registers can be read immediately.
        logger.trace0("timestamp_low=0x{:08x}".format(self.regfile.example_ts_0.timestamp_low))
        logger.trace0("timestamp_high=0x{:08x}".format(self.regfile.example_ts_0.timestamp_high))

        # Demonstrate libapp functionality of reading 64b registers with _low/_high definitions
        logger.trace0("timestamp_64b=0x{:08x}".format(self.regfile.example_ts_0.timestamp))

        # logger.trace0("App name is: %s", self.regfile.app_name)

        # Indicate the daemon status (read by the CLI code).
        self.status["running"] = True

        self.status["last_timestamp_raw"] = self.regfile.example_ts_0.timestamp
        self.status["last_timestamp"] = self.get_readable_timestamp()

        # Run on_agent_option any config that already exists.
        logger.trace1("Loading initial config")
        for k in self.agent_manager.agent_option_iter():
            self.on_agent_option(k, self.agent_manager.agent_option(k))

        # Set up a timeout to go off after 1s (which will recursively
        # enable the next timeout, so we get a 1s tick).
        self.on_timeout()

        # freerun the clock and initial sync
        chron = self.regfile.ts.chron

        seconds_f, subseconds_f = divmod(time.time(), 1)

        seconds = int(seconds_f)
        nanoseconds = int(subseconds_f * 1000000000)
        the_time = seconds * 1000000000 + nanoseconds

        chron.apply_initval = 1
        chron.initval_high = (the_time >> 32) & 0xFFFFFFFF
        chron.initval_low = (the_time >> 0) & 0xFFFFFFFF
        chron.initval_s = int(the_time / 1000000000)
        chron.initval_ns = the_time % 1000000000
        chron.apply_initval = 0

        # Print for the agent logs in /var/log/agents/*
        logger.trace0("Finished initialization")

    def on_agent_option(self, key, val):
        """Handler called when a configuration option of the agent has changed.
        If the option was deleted, this will be called with value set as the
        empty string. Otherwise, value will contain the added or altered string
        corresponding to the option name."""
        #  Not implemented

    def on_agent_rpc(self, command):
        """Handler called when agentRpc is called from the CLI.
        This function _must_ return a string"""
        logger.trace3("on_agent_rpc - {}".format(command))
        if command.startswith("trigger"):
            # the fpga register file will trigger a timestamp in the tscore when
            # this register is written to
            self.regfile.trigger = 1
        # now pull the timestamp from register
        self.status["last_timestamp_raw"] = self.regfile.example_ts_0.timestamp
        self.status["last_timestamp"] = self.get_readable_timestamp()
        return ""

    # This gets called when we are disabled
    def on_agent_enabled(self, enabled):
        logger.trace3("on_agent_enabled - {}".format(str(enabled)))
        if not enabled:
            sys.stdout.flush()

            # Disable the timeout
            self.timeout_time_is(eossdk.never)

            # Clear the FPGAs
            self.fpga.unload_image()

            # Remove all status, giving us a clean slate.
            self.status.clear()

            # Indicate that we shut down cleanly.
            self.agent_manager.agent_shutdown_complete_is(True)

    def on_timeout(self):
        logger.trace3("on_timeout")
        self.status["last_timeout"] = eossdk.now()

        self.timeout_time_is(eossdk.now() + 1)
        logger.trace3("on_timeout completed")


def main():
    logging.basicConfig(format="%(asctime)s %(levelname)s: %(name)s: %(message)s", level="DEBUG")
    sdk = eossdk.Sdk("TscoreNomacExampleDaemon")
    _ = TscoreNomacExampleDaemon(sdk)
    sdk.main_loop(sys.argv)


if __name__ == "__main__":
    main()
