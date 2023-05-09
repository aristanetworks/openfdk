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

import CliExtension

from cliexample import libapp


class ShowCliExampleStatusCmd(libapp.cli.ShowEnabledBaseCmd):
    daemon = "CliExampleDaemon"

    def handler(self, ctx):
        result = super(ShowCliExampleStatusCmd, self).handler(ctx)
        result["status"] = {}

        daemon = ctx.getDaemon("CliExampleDaemon")

        if daemon is None:
            # Daemon is not currently running
            return result

        status = libapp.cli.StatusAccessor(daemon.status)

        result["status"]["ip address"] = status.get("ip address")
        result["status"]["ip address secondary"] = status.get("ip address secondary")

        return result

    def render(self, data):
        super(ShowCliExampleStatusCmd, self).render(data)
        print("CliExample status store:")
        for k, v in data["status"].items():
            print("  {}\t{}".format(k, v))


class IpAddressCmd(libapp.cli.ConfigCommandClass):
    key_syntax = "ip address [secondary]"


class DisabledCmd(CliExtension.CliCommandClass):
    def handler(self, ctx):
        ctx.daemon.config.disable()

    def noHandler(self, ctx):
        ctx.daemon.config.enable()

    defaultHandler = handler


def Plugin(ctx):  # pylint: disable=unused-argument
    CliExtension.registerCommand("showCliExampleStatus", ShowCliExampleStatusCmd, namespace="arista.cliexample")
    CliExtension.registerCommand("ipAddress", IpAddressCmd, namespace="arista.cliexample")
    CliExtension.registerCommand("disabled", DisabledCmd, namespace="arista.cliexample")
