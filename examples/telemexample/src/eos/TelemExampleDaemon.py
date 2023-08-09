#!/usr/bin/env arista-python
# ------------------------------------------------------------------------------
#  Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
#    fdk-support@arista.com
#
#  Description:
#    Example application demonstrating InfluxDB telemetry.
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
import math
import os
import sys

import eossdk

# We have a .zip file locally with our dependencies, build by the makefile.
# This is required for libapp.telemetry
sys.path.insert(
    0,
    os.path.join(os.path.dirname(__file__), "python_deps" + str(sys.version_info[0]) + ".zip"),
)

import libapp  # pylint: disable=wrong-import-position
import libapp.eossdk_utils  # pylint: disable=wrong-import-position
import libapp.telemetry  # pylint: disable=wrong-import-position

logger = logging.getLogger(__name__)


class TelemExampleDaemon(
    libapp.eossdk_utils.EosSdkAgent,
    libapp.daemon.LoggingMixin,
    eossdk.AgentHandler,
    eossdk.TimeoutHandler,
):
    # EOSSDK setup.
    def __init__(self, sdk):
        self.agent_manager = sdk.get_agent_mgr()
        self.timeout_manager = sdk.get_timeout_mgr()

        libapp.daemon.LoggingMixin.__init__(self, sdk.name())
        eossdk.AgentHandler.__init__(self, self.agent_manager)
        eossdk.TimeoutHandler.__init__(self, self.timeout_manager)

        self.telemetry = None
        self.sent_record_counter = 0

    # inherited from AgentHandler
    # http://aristanetworks.github.io/EosSdk/docs/2.10.0/ref/agent.html
    def on_initialized(self):
        """Handler called after the agent has been internally initialized.
        At this point, all managers have synchronized with Sysdb, and the
        agent's handlers will begin firing. In the body of this method, agents
        should check Sysdb and handle the initial state of any configuration and
        status that this agent is interested in."""
        logging.debug("on_initialized")

        # Initialize our telemetry helper function
        self.telemetry = libapp.telemetry.Telemetry(
            "telemexample", "Arista Networks", tags={"example_tag": "example_value"}
        )

        # Set up a timeout to go off after 1s (which will recursively
        # enable the next timeout, so we get a 1s tick).
        self.timeout_time_is(eossdk.now() + 1)

        # Inidicate that the daemon is up.
        self.agent_manager.status_set("daemon_status", "Up")

        # Run on_agent_option any config that already exists.
        logger.info("Loading initial config")
        for k in self.agent_manager.agent_option_iter():
            self.on_agent_option(k, self.agent_manager.agent_option(k))

        # Print for the agent logs in /var/log/agents/*
        logger.debug("Finished initialization")

    def on_agent_option(self, key, val):
        """Handler called when a configuration option of the agent has changed.
        If the option was deleted, this will be called with value set as the
        empty string. Otherwise, value will contain the added or altered string
        corresponding to the option name."""
        logging.debug("on_agent_option %s %s", key, val)

        # Reflect the config back in the status to indicate that we've received it.
        self.agent_manager.status_set(key, val)

        # This app reflects all of its config as influxdb values
        if self.telemetry.ready():
            self.telemetry.send_metrics("telemexample", {key: val})

    def on_agent_enabled(self, enabled):  # pylint: disable=unused-argument
        # Disable the timeout
        self.timeout_time_is(eossdk.never)

        # Remove all status, giving us a clean slate.
        for k in self.agent_manager.status_iter():
            self.agent_manager.status_del(k)

        # Indicate that we shut down cleanly.
        self.agent_manager.agent_shutdown_complete_is(True)

    def on_timeout(self):
        logger.debug("on_timeout")
        self.agent_manager.status_set("last_timeout", str(eossdk.now()))

        period = self.agent_manager.agent_option("period")
        if period == "":
            period = 10.0
        else:
            period = float(period)

        update_period = self.agent_manager.agent_option("update_period")
        if update_period == "":
            update_period = 0.5
        else:
            update_period = float(update_period)

        # Set a new timeout for update_period seconds into the future
        self.timeout_time_is(eossdk.now() + update_period)

        # A full cycle takes period seconds
        sin_value = math.sin(2 * math.pi * eossdk.now() / period)

        # This app reflects all of its config as influxdb values
        if self.telemetry.ready():
            self.telemetry.send_metrics("telemexample", {"sin": sin_value})
            logging.debug("Updated value to: %f", sin_value)
            self.sent_record_counter += 1
            self.agent_manager.status_set("records_sent", str(self.sent_record_counter))
        else:
            logging.debug("Telemetry not ready. Value would have been %f", sin_value)

        logger.debug("on_timeout completed")


def main():
    logging.basicConfig(format="%(asctime)s %(levelname)s: %(name)s: %(message)s", level="DEBUG")

    sdk = eossdk.Sdk("TelemExampleDaemon")
    _ = TelemExampleDaemon(sdk)
    sdk.main_loop(sys.argv)


if __name__ == "__main__":
    main()
