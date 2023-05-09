# pylint: disable=W,C,R,E

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

from __future__ import absolute_import, print_function

import ctypes
import fcntl
import socket

IFNAMSIZ = 16
ETHTOOL_GET_TS_INFO = 0x00000041
SIOCETHTOOL = 0x8946


class Ethtool_ts_info(ctypes.Structure):
    _fields_ = [
        ("cmd", ctypes.c_uint32),
        ("so_timestamping", ctypes.c_uint32),
        ("phc_index", ctypes.c_int32),
        ("tx_types", ctypes.c_uint32),
        ("tx_reserved", ctypes.c_uint32 * 3),
        ("rx_filters", ctypes.c_uint32),
        ("rx_reserved", ctypes.c_uint32 * 3),
    ]


class Ifreq(ctypes.Structure):
    _fields_ = [
        ("ifrn_name", ctypes.c_char * IFNAMSIZ),
        # ifru_data is actually one of a few union members, but
        # for now we only need to set the pointer, so that's all we'll
        # define for now
        ("ifru_data", ctypes.c_void_p),
    ]


class Ethtool(object):
    def __init__(self, iface):
        self.ifreq = Ifreq()
        self.ifreq.ifrn_name = iface
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_IP)

    @property
    def phc_index(self):
        tsinfo = Ethtool_ts_info()
        tsinfo.cmd = ETHTOOL_GET_TS_INFO
        self.ifreq.ifru_data = ctypes.cast(ctypes.pointer(tsinfo), ctypes.c_void_p)
        fcntl.ioctl(self.sock, SIOCETHTOOL, self.ifreq)
        return tsinfo.phc_index

    def __del__(self):
        self.sock.close()


class timespec(ctypes.Structure):
    _fields_ = [("tv_sec", ctypes.c_long), ("tv_nsec", ctypes.c_long)]


def print_struct(s):
    for field_name, field_type in s._fields_:
        print(field_name, getattr(s, field_name))


class PHC(object):
    def __init__(self, interface):
        phc_index = Ethtool(interface).phc_index
        self.fp = open("/dev/ptp{}".format(phc_index))

        def fd_to_clockid(fd):
            CLOCKFD = 3
            return (~fd << 3) | CLOCKFD

        self.clockid = fd_to_clockid(self.fp.fileno())

        librt = ctypes.CDLL("librt.so.1", use_errno=True)
        self.clock_gettime = librt.clock_gettime
        self.clock_gettime.argtypes = [ctypes.c_int, ctypes.POINTER(timespec)]

    def read(self):
        t = timespec()
        self.clock_gettime(self.clockid, ctypes.pointer(t))
        return t.tv_sec * 1000000000 + t.tv_nsec
