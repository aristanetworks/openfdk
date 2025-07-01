# ------------------------------------------------------------------------------
#  Copyright (c) 2024 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    Network Utility Functions
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------
"""Network Utility Functions for applications running on Arista 7130 switches."""
from __future__ import absolute_import

import subprocess


# ------------------------------------------------------------------------------
# EOS Iptables Support
# ------------------------------------------------------------------------------
def _run_iptables(action, chain, jump, protocol, port):
    # Newer versions of EOS have reorganised iptables rules, e.g. rules moved
    # from INPUT to EOS_INPUT, chain renamed from SERVICE to EOS_SERVICE.
    prefix = "EOS_" if subprocess.call("iptables --list SERVICE".split()) else ""
    cmd = "iptables --{} {} --protocol {} --dport {} --jump {}".format(
        action, prefix + chain, protocol, port, prefix + jump
    )
    if action in ["append"]:
        return not subprocess.check_call(cmd.split())
    if action in ["check", "delete"]:
        return not subprocess.call(cmd.split())
    raise ValueError("action not supported")


def service_add(protocol, port):
    return _run_iptables("append", "INPUT", "SERVICE", protocol, port)


def service_remove(protocol, port):
    return _run_iptables("delete", "INPUT", "SERVICE", protocol, port)


def service_check(protocol, port):
    return _run_iptables("check", "INPUT", "SERVICE", protocol, port)


# ------------------------------------------------------------------------------
# EOS ARP Support
# ------------------------------------------------------------------------------
def _run_arptables(action, ipadr, macadr=None):
    if action in ["append"]:
        cmd = "arp -s {} {}".format(str(ipadr), str(macadr).replace("-", ":"))
        return not subprocess.check_call(cmd.split())
    if action in ["delete"]:
        cmd = "arp --delete {}".format(str(ipadr))
        return not subprocess.call(cmd.split())
    raise ValueError("action not supported")


def arp_add(ipadr, macadr):
    return _run_arptables("append", ipadr, macadr)


def arp_remove(ipadr):
    return _run_arptables("delete", ipadr)


def arp_ping(intf, ipadr):
    cmd = "arping -I {} -c 1 {}".format(str(intf), str(ipadr))
    exp = "Unicast reply from {}".format(str(ipadr)).encode("utf-8")
    try:
        result = subprocess.check_output(cmd.split())
        response = exp in result
    except:  # pylint: disable=bare-except
        response = False

    return response
