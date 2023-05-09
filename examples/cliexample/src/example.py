# ------------------------------------------------------------------------------
#  Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
#    fdk-support@arista.com
#
#  Description:
#    Example of integrating with the MOS CLI.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

from __future__ import absolute_import

import os

import mosapi

from . import __version__  # noqa
from . import app_name


class Example(mosapi.App):
    appdir = os.path.dirname(__file__)
    name = app_name


@mosapi.cli_command
def show_hello_world(ctx):
    """show hello world - show storm control status
    Usage: show hello world
    Group: Application CliExample
    Mode: config-app-cliexample
    """
    app = ctx.mode_ctx["app"]
    if not app.is_shutdown():
        return "Hello, World! (I'm shut down)"

    return "Hello, World! (I'm not shut down)"


# We proxy show_muxcore_status to show_storm_status, but in the future, these should become distinct commands.
@mosapi.cli_command
def show_cliexample_status(ctx):  # pylint: disable=unused-argument
    """show cliexample status - show cliexample status
    Group: Application CliExample
    Mode: priv
    """
    app = mosapi.get_app_by_name(Example.name)

    if app.is_shutdown():
        return "Application CLI Example is installed"

    return "Application CLI Example is installed and running"
