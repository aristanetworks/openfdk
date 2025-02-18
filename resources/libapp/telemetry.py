# ------------------------------------------------------------------------------
#  Copyright (c) 2021 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    Telemetry API based on InfluxDB
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------
"""The telemetry module provides a wrapper for time-series telemetry output.
For example, sampled packet counters, time offsets, etc.
"""

from __future__ import absolute_import

import os
import socket

from telegraf.protocol import Line


class Telemetry(object):
    """A client for sending telemetry to Telegraf.

    Args:
        appname (str): The value to included as the "application" tag.
        author (str): The value to be included as the "author" tag.
        tags (dict[str, Any]): Any other default tags to be included with each
            metric.
    """

    def __init__(self, appname, author, tags=None):
        if tags is None:
            tags = {}
        self.appname = appname
        self.author = author
        self.address = "/var/run/telegraf.sock"
        self.default_tags = dict(
            {
                "application": appname,
                "author": author,
            }
        )
        self.default_tags.update(**tags)
        self.telegraf_sock = None

    def ready(self):
        """Returns whether telegraf socket is ready.

        Returns (bool):
            True if telegraf is ready, False otherwise.
        """
        return os.access(self.address, os.R_OK)

    def connect(self):
        """Connects to Telegraf socket."""
        self.telegraf_sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.telegraf_sock.connect(self.address)

    def disconnect(self):
        """Closes Telegraf socket."""
        self.telegraf_sock.close()

    def add_default_tags(self, tags=None):
        """Adds extra default tags to the set included with metrics.

        Args:
            tags (dict[str, Any]): Extra default tags to be included with each
                metric.
        """
        if tags is None:
            tags = {}
        self.default_tags.update(tags)

    def send_metrics(self, measurement, values, tags=None, timestamp=None):
        """Sends a metric to the Telegraf socket.

        Args:
            measurement (str): The name of the actual measurement.
            values (Any | dict[str, Any]): The value or collection of values.
            tags (Optional[dict[str, Any]): Dict of extra tags if any.
            timestamp (int): The timestmap for the datapoint in
                nanosecond-precision Unix time.
        """
        if tags is None:
            tags = {}
        if values in (None, {}):
            raise Exception("Please specify values to log")
        tags.update(self.default_tags)
        line = Line(measurement, values, tags, timestamp)
        data = line.to_line_protocol().encode("utf8") + b"\n"
        try:
            self.connect()
            self.telegraf_sock.sendall(data)
            self.disconnect()
        except socket.error as e:
            raise e
