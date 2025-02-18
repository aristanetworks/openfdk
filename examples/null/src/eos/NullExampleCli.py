#!/usr/bin/env arista-python
# ------------------------------------------------------------------------------
#  Copyright (c) 2021 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    The null example CLI implementation.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------


import CliExtension

from null import libapp


class ShowNullStatusCmd(libapp.cli.ShowEnabledBaseCmd):
    daemon = "NullExampleDaemon"

    def handler(self, ctx):
        result = super().handler(ctx)
        result["fpgas"] = {}

        daemon = ctx.getDaemon(self.daemon)

        if daemon is None:
            # Daemon is not currently running
            return result

        status = libapp.cli.StatusAccessor(daemon.status)

        result["fpgas"] = status.get("fpgas", {})

        return result

    def render(self, data):
        super().render(data)
        for f, v in data["fpgas"].items():
            print("{} appName: {}".format(f.title(), v))


# disabled / no disabled
class DisabledCmd(CliExtension.CliCommandClass):
    def handler(self, ctx):
        ctx.daemon.config.disable()

    def noHandler(self, ctx):
        ctx.daemon.config.enable()

    defaultHandler = handler


# Register the commands.


def Plugin(ctx):  # pylint: disable=unused-argument
    CliExtension.registerCommand("show_null_status", ShowNullStatusCmd, namespace="arista.null")
    CliExtension.registerCommand("disabled", DisabledCmd, namespace="arista.null")
