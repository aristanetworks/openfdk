# ------------------------------------------------------------------------------
#  Copyright (c) 2021 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    MOSAPI integration for the Null example design.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

from __future__ import absolute_import, print_function

import os

import mosapi

from . import __version__  # noqa
from . import app_name
from .libapp import device as libapp_device
from .libapp import register_file as libapp_register_file


class Example(mosapi.App):
    appdir = os.path.dirname(__file__)
    name = app_name

    def __init__(self, *args, **kwargs):
        super(Example, self).__init__(*args, **kwargs)

        # Get the FPGA targets...
        self.fpga_devices = libapp_device.get_fpga_devices()
        self.fpgas = []
        self.fpgaRegisters = {}
        csvfile = self.appdir + "/fpga/%s_registers.csv" % (self.name)

        # And validate they are part of a compatibility list for this application...
        for f in self.fpga_devices:
            if f.board_standard in (
                "eh_central",
                "eh_leaf",
                "l",
                "lb2",
            ):
                self.fpgas.append(f)
                self.fpgaRegisters[f.name()] = libapp_register_file.RegisterFile(csvfile, f.communicator)
        if not self.fpgas:
            raise RuntimeError("This application does not support any Board Standards on this platform.")

    # ---------------------------------------------------------------------------
    def program_fpga(self, fpga):
        """
        Program the FPGA with the appropriate bitstream file.
        """
        bit = self.appdir + "/fpga/%s-%s.bit" % (self.name, fpga.board_standard)
        if os.path.exists(bit):
            print(("Programming %s FPGA ..." % fpga.label))
            fpga.load_image(bit)
        else:
            raise RuntimeError("No compatible image found for this board standard")

    def clear_fpga(self, fpga):
        """
        Clears the current FPGA bitstream.
        """
        print(("Clearing %s FPGA..." % fpga.label))
        fpga.unload_image()

    def no_shutdown(self, ctx=None):
        for fpga in self.fpgas:
            self.program_fpga(fpga)
        super(Example, self).no_shutdown(ctx)

    def shutdown(self, ctx=None):
        for fpga in self.fpgas:
            self.clear_fpga(fpga)
        super(Example, self).shutdown(ctx)

    def get_fpga_idx(self, label):
        for fpga in self.fpgas:
            if label in fpga.label:
                return self.fpgas.index(fpga)

            if label == "default" and "central" in fpga.label:
                return self.fpgas.index(fpga)
        return None

    def get_portlist(self, *args, **kwargs):
        return libapp_device.get_portlist(*args, **kwargs)

    def show_null_status(self):
        result = {"running": False, "enabled": False, "fpgas": {}}
        if not self.is_shutdown():
            result["running"] = True
            result["enabled"] = True
            result["fpgas"] = {f: r.app_name for f, r in self.fpgaRegisters.items()}

        return result


# -------------------------------------------------------------------------------
# CLI command to show basic status
# -------------------------------------------------------------------------------
@mosapi.cli_command
def show_null_status(ctx):
    """show null status - show null status
    Group: Application null
    Mode: priv
    """
    app = mosapi.get_app_by_name(Example.name)
    result = app.show_null_status()
    if ctx.json_api:
        return result

    print("Enabled: {}".format("Yes" if result["enabled"] else "No"))
    print("Running: {}".format("Yes" if result["running"] else "No"))
    for f, v in result["fpgas"].items():
        print("{} appName: {}".format(f, v))

    return None


# -------------------------------------------------------------------------------
# RAW Register Interface CLI Commands
# -------------------------------------------------------------------------------
@mosapi.cli_command
def show_registers(ctx):
    """show registers - Show all registers
    Usage: show registers
    Group: Application Null
    Mode: config-app-null
    """
    app = ctx.mode_ctx["app"]
    if not app.is_shutdown():
        print("Default/Central Registers -")
        idx = app.get_fpga_idx("default")
        app.fpgaRegisters[idx].dump()

        idx = app.get_fpga_idx("leaf_a")
        if idx is not None:
            print("\nLeaf A Registers ----------")
            app.fpgaRegisters[idx].dump()

        idx = app.get_fpga_idx("leaf_b")
        if idx is not None:
            print("\nLeaf B Registers ----------")
            app.fpgaRegisters[idx].dump()


@mosapi.cli_command
def read_register(ctx, fpga="default", name=""):
    """read register - read from fpga register by name
    Usage: read register [default|central|leaf_a|leaf_b] NAME
    Group: Application Null
    Mode: config-app-null
    """
    app = ctx.mode_ctx["app"]
    if not app.is_shutdown():
        idx = app.get_fpga_idx(fpga)
        if idx is not None:
            return format(app.fpgaRegisters[idx].read_reg(name), "#08x")
    return None


@mosapi.cli_command
def write_register(ctx, fpga="default", name="", value=""):
    """write register - write to fpga register by name
    Usage: write register [default|central|leaf_a|leaf_b] NAME HEXNUMBER
    Group: Application Null
    Mode: config-app-null
    """
    app = ctx.mode_ctx["app"]
    val = int(value, 0)

    if not app.is_shutdown():
        idx = app.get_fpga_idx(fpga)
        if idx is not None:
            app.fpgaRegisters[idx].write_reg(name, val)
