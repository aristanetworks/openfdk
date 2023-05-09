# ------------------------------------------------------------------------------
#  Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
#    fdk-support@arista.com
#
#  Description:
#    Clock synchronisation daemon for ts_ipcore.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

from __future__ import absolute_import

import fcntl
import logging
import os
import socket
import struct
import subprocess
from collections import defaultdict

logger = logging.getLogger()


def get_clock_id(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    info = fcntl.ioctl(s.fileno(), 0x8927, struct.pack("256s", ifname[:15]))

    # bytes 18-27 are the MAC address
    mac = [ord(c) for c in info[18:24]]

    # this mirror's ptp4l's generate_clock_identity() in util.c
    return "{:02x}{:02x}{:02x}.fffe.{:02x}{:02x}{:02x}".format(mac[0], mac[1], mac[2], mac[3], mac[4], mac[5])


def parse_pmc_output(datasets, lines, clockid):  # pylint: disable=too-many-branches,too-many-statements
    data = defaultdict(dict)
    current = None

    def toval(x):
        try:
            return int(x)
        except ValueError:
            pass

        try:
            return float(x)
        except ValueError:
            pass

        return x

    # Possible lines, derived from pmc.c source code:
    # If there is not exactly one TLV:
    #   <portid> seq <seq> <action>

    # If the TLV is mgmt error status:
    #   <portid> seq <seq> <action> MANAGEMENT_ERROR_STATUS

    # If tlv is unknown: (pmc v1.8 has a bug here, will attempt to decode as mgmt)
    #   <portid> seq <seq> <action> unknown-tlv

    # If tlv is short but not the NULL TLV::
    #   <portid> seq <seq> <action> empty-tlv

    # If a supported TLV name, this is the only case we want:
    #   <portid> seq <seq> <action> MANAGEMENT <tlv>
    #       <details>

    try:
        for line in lines:
            line = line.strip()
            # ignore empty lines
            if not line:
                continue

            # ignore lines about our outgoing request
            if line.startswith("sending: "):
                current = None
                continue

            # handle header lines, all of which contain ' seq ':
            if " seq " in line:
                current = None
                parts = line.split()

                try:
                    dst_portid = parts[0]
                    if not dst_portid.startswith(clockid):
                        logger.debug(
                            "Dropped PTP mgmt frame: Incorrect clockid: %s != %s",
                            dst_portid,
                            clockid,
                        )
                        continue

                    assert parts[1] == "seq"
                    seqnum = int(parts[2])

                    action = parts[3]
                    if action != "RESPONSE":
                        logger.debug("Dropped PTP mgmt frame: unexpected action: %s", action)
                        continue

                    tlvtype = parts[4]
                    if tlvtype != "MANAGEMENT":
                        logger.debug("Dropped PTP mgmt frame: Skipping TLV type: %s", tlvtype)
                        continue

                    tlv = parts[5]
                except IndexError:
                    #  was one of the shorter lines, skip it
                    continue

                try:
                    # outbound request sequence numbers match the order in 'datasets'
                    expected_seq = datasets.index(tlv)
                except ValueError:
                    # if we didn't request this, then we clearly don't care for the response
                    logger.debug("Dropped PTP mgmt frame: Unexpected response: %s", tlv)
                    continue
                if expected_seq != seqnum:
                    logger.debug(
                        "Dropped PTP mgmt frame: Unexpected sequence number: %d!=%d",
                        expected_seq,
                        seqnum,
                    )
                    continue

                current = data[tlv]

            elif current is not None:
                # Some details, stash them into the current response
                parts = line.split()
                current[parts[0]] = toval(" ".join(parts[1:]))  # pylint: disable=unsupported-assignment-operation
            else:
                # not a header, and not something we want to save. Drop.
                pass
                # print "Dropping ", l
    except Exception:
        # Anything unexpected: dump the input that caused it and raise
        logger.critical("\n".join(lines))
        raise
    return dict(data)


def do_pmc(datasets, domain=0, clockid=""):
    get_cmds = ["get {}".format(ds) for ds in datasets]
    cmd = ["/usr/sbin/pmc", "-b", "0", "-u", "-d", str(domain)] + get_cmds
    lines = subprocess.check_output(cmd).split("\n")
    return parse_pmc_output(datasets, lines, clockid)


class PTP4l(object):
    def __init__(self):
        self.iface = None
        self.domain = None
        self.refresh()

    def refresh(self):
        domain = 0
        iface = None
        with open("/etc/ptp4l.conf") as file:  # pylint: disable=unspecified-encoding
            for line in file:
                if line[0] == "[" and "global" not in line:
                    iface = line.strip()[1:-1]
                elif line.startswith("domainNumber"):
                    domain = int(line.split()[1])

        # if domain != self.domain: print "Domain: {} -> {}".format(self.domain, domain)
        # if iface  != self.iface : print "Iface: {} -> {}".format(self.iface, iface)
        self.domain = domain
        if self.iface != iface:
            self.iface = iface
            self.clockid = get_clock_id(iface) if iface else None

    def poll(self):
        self.refresh()
        if not self.iface:
            raise RuntimeError("PTP not configured")
        if not os.path.exists("/var/run/ptp4l"):
            raise RuntimeError("PTP: waiting for socket")

        datasets = ["PORT_DATA_SET", "CURRENT_DATA_SET", "TIME_PROPERTIES_DATA_SET"]
        pmc_output = do_pmc(datasets, self.domain, self.clockid)

        # Occasionally we get back empty dicts. This can happen if the pmc socket
        # was unceremoniously closed on us. Make the following 3 dict lookups
        # appear as any other ptp-down timeout
        try:
            state = pmc_output["PORT_DATA_SET"]["portState"]
        except KeyError:
            raise RuntimeError("Cannot query PTP state")

        if state != "SLAVE":
            raise RuntimeError("PTP not synched (state={})".format(state))

        try:
            time_offset = pmc_output["CURRENT_DATA_SET"]["offsetFromMaster"]
        except KeyError:
            raise RuntimeError("Cannot query PTP time offset from Master")

        if time_offset > 1000000:
            raise RuntimeError("PTP not synched (time_offset = {}ns)".format(time_offset))

        try:
            utc_offset = pmc_output["TIME_PROPERTIES_DATA_SET"]["currentUtcOffset"]
        except KeyError:
            raise RuntimeError("Cannot query PTP UTC offset")

        return self.iface, time_offset, utc_offset
