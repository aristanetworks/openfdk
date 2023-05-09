#!/usr/bin/env arista-python
# ------------------------------------------------------------------------------
#  Copyright (c) 2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
#    fdk-support@arista.com
#
#  Description:
#    The tscore_nomac example CLI implementation.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

from __future__ import absolute_import, division, print_function

import CliExtension

from tscore_nomac import libapp


class ShowTscoreNomacStatusCmd(libapp.cli.ShowEnabledBaseCmd):
    daemon = "TscoreNomacExampleDaemon"

    def handler(self, ctx):
        result = super(ShowTscoreNomacStatusCmd, self).handler(ctx)
        result["lastTimestampRaw"] = None
        result["lastTimestamp"] = None

        daemon = ctx.getDaemon(self.daemon)

        if daemon is None:
            # Daemon is not currently running
            return result

        status = libapp.cli.StatusAccessor(daemon.status)

        result["lastTimestampRaw"] = status.get("last_timestamp_raw")
        result["lastTimestamp"] = status.get("last_timestamp")

        return result

    def render(self, data):
        super(ShowTscoreNomacStatusCmd, self).render(data)
        print("Last timestamp raw: {}".format(data["last_timestamp_raw"]))
        print("Last timestamp: {}".format(data["last_timestamp"]))


class TriggerCmd(CliExtension.CliCommandClass):
    def handler(self, ctx):
        return CliExtension.agentRpc(ctx, "TscoreNomacExampleDaemon", "trigger")


# disabled / no disabled
class DisabledCmd(CliExtension.CliCommandClass):
    def handler(self, ctx):
        ctx.daemon.config.disable()

    def noHandler(self, ctx):
        ctx.daemon.config.enable()

    defaultHandler = handler


# Register the commands.
def Plugin(ctx):  # pylint: disable=unused-argument
    CliExtension.registerCommand("show_tscore_nomac_status", ShowTscoreNomacStatusCmd, namespace="arista.tscore_nomac")
    CliExtension.registerCommand("disabled", DisabledCmd, namespace="arista.tscore_nomac")
    CliExtension.registerCommand("trigger", TriggerCmd, namespace="arista.tscore_nomac")
