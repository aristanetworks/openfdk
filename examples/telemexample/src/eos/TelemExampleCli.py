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

import collections
import six

import CliExtension
import TableOutput  # FIXME: TableOutput is not (yet) a public API.


class ShowTelemExampleStatusCmd(CliExtension.ShowCommandClass):
    def handler(self, ctx):
        result = {"enabled": False, "running": False, "records_sent": 0, "settings": {}}
        daemon = ctx.getDaemon("TelemExampleDaemon")

        if daemon is None:
            # Daemon is not currently running
            return result

        result["enabled"] = daemon.config.isEnabled()
        result["running"] = daemon.status.status("daemon_status") == "Up"

        records_sent = daemon.status.status("records_sent")
        if records_sent:
            records_sent = int(records_sent)

        result["settings"] = collections.OrderedDict()
        period_val = daemon.status.status("period")
        if period_val:
            result["settings"]["period"] = float(period_val)

        return result

    def render(self, data):
        print("Enabled: {}".format("Yes" if data["enabled"] else "No"))
        print("Running: {}".format("Yes" if data["running"] else "No"))

        table = TableOutput.createTable(["Setting", "Value"])
        for key, value in six.iteritems(data["settings"]):
            table.newRow(key, value)
        print(table.output())


# disabled / no disabled
class DisabledCmd(CliExtension.CliCommandClass):
    def handler(self, ctx):
        ctx.daemon.config.disable()

    def noHandler(self, ctx):
        ctx.daemon.config.enable()

    defaultHandler = handler


# Sinusoid period
class PeriodCmd(CliExtension.CliCommandClass):
    def handler(self, ctx):
        ctx.daemon.config.configSet("period", ctx.args["<period>"])

    def noHandler(self, ctx):
        ctx.daemon.config.configDel("period")


def Plugin(ctx):  # pylint: disable=unused-argument
    CliExtension.registerCommand(
        "show_telemexample_status",
        ShowTelemExampleStatusCmd,
        namespace="arista.telemexample",
    )
    CliExtension.registerCommand("period", PeriodCmd, namespace="arista.telemexample")
    CliExtension.registerCommand("disabled", DisabledCmd, namespace="arista.telemexample")
