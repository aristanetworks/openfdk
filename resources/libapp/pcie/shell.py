# ------------------------------------------------------------------------------
#  Copyright (c) 2019-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
#    fdk-support@arista.com
#
#  Description:
#    Wrapper to run a command in the shell
#
#    This code is part of a proof of concept of PCIe on Arista's 7130E and 7130L
#    Series platforms. This application provides a means to verify that PCIe is
#    functional on these platforms and should not be used as a guideline for PCIe
#    designs on these platforms. This method of interfacing to PCIe will become
#    unsupported once MOS API adds official support for PCIe.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

import logging
import subprocess


def shellcmd(cmd, input=None, root=False, shell="bash"):  # pylint: disable=redefined-builtin
    """Execute a shell command"""

    shell = ("sudo " if root else "") + shell + " -c "
    logging.debug("%s", shell + cmd)
    stdin = subprocess.PIPE if input else None
    # FIXME: wrap this in with when we move to py3
    proc = subprocess.Popen(  # pylint: disable=consider-using-with
        shell.split() + [cmd],
        stdin=stdin,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    (stdout, _) = proc.communicate(input=input)
    if proc.returncode:
        if stdout:
            logging.debug(stdout)
        # Raise an exception as subprocess.check_output() would have
        raise subprocess.CalledProcessError(returncode=proc.returncode, cmd=shell + cmd, output=stdout)
    return stdout


def echo(msg, outfile=None, root=False):
    """echo a message to stdout, or outfile if provided"""

    cmd = "echo " + msg
    if outfile:
        cmd += " > " + outfile
    shellcmd(cmd, root=root)
