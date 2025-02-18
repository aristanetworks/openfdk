#!/usr/bin/env python
# ------------------------------------------------------------------------------
#  Copyright (c) 2021 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    EOS SDK utils from the EOSSDK examples directory on github.
#    https://github.com/aristanetworks/EosSdk/blob/master/examples/eossdk_utils.py
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------
"""Python logging for EOS apps."""

from __future__ import absolute_import, division, print_function

import logging

try:
    import eossdk
except Exception:  # pylint: disable=broad-except
    pass

logger = logging.getLogger(__name__)

# LogRecord objects are documented here: https://docs.python.org/3/library/logging.html#logrecord-objects
# Handler objects are documented here: https://docs.python.org/3/library/logging.html#handler-objects


class EOSTraceHandler(logging.Handler):
    """
    A handler class which uses EOS tracing.
    """

    _tracer = None

    def __init__(self, name):
        logging.Handler.__init__(self)
        self._name = name
        self._tracer = eossdk.Tracer(name)
        self._tracer.enabled_is(0, True)

    def emit(self, record):
        try:
            tracer = self._tracer
            msg = self.format(record)

            if record.levelno <= logging.DEBUG:
                tracer.trace8(msg)
            elif record.levelno <= logging.INFO:
                tracer.trace6(msg)
            elif record.levelno <= logging.WARNING:
                tracer.trace4(msg)
            elif record.levelno <= logging.ERROR:
                tracer.trace2(msg)
            else:
                # record.levelno ~= logging.CRITICAL
                tracer.trace0(msg)

        except BaseException:  # pylint: disable=broad-except
            self.handleError(record)
