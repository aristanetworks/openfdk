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

from __future__ import absolute_import

import pdb
import sys
import traceback
import types
from functools import wraps

import six

# This file provides a utility to automatically wrap all EOS SDK
# handlers in debug code.

# Because exceptions that escape handlers are caught by the SDK's
# underlying event loop, Python agents can be tricky to debug. These
# helper utilities will print out the stacktrace of the error and, if
# the agent is run from a TTY, will then drop the user in a debug
# session at the point where the error occurred.

# To use, simply inherit from EosSdkAgent:
#
#    import eossdk_utils
#    class MyAgent(eossdk_utils.EosSdkAgent, eossdk.AgentHandler, etc):
#         def on_initialized(self):
#             ...
#


# Implementation:
def debug_fn(func):
    """This wrapper tries to run the wrapped function. If the function
    raises an Exception, print the traceback, and, if the user is at a
    TTY, drop the user into an interactive debug session."""

    @wraps(func)
    def wrapped_fn(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception as e:
            traceback.print_exc()
            if sys.stdout.isatty():
                pdb.post_mortem()
            raise e

    return wrapped_fn


class SdkAgentMetaClass(type):
    def __new__(mcs, classname, bases, classDict):
        """Wraps all functions in this class that start with "on_" with
        the above debug_fn"""
        newClassDict = {}
        for attributeName, attribute in classDict.items():
            if isinstance(attribute, types.FunctionType) and attributeName.startswith("on_"):
                # Wrap all "on_" handler functions with debugging helper code.
                attribute = debug_fn(attribute)
            newClassDict[attributeName] = attribute
        return type.__new__(mcs, classname, bases, newClassDict)


# Class to inherit from:


class EosSdkAgent(six.with_metaclass(SdkAgentMetaClass, object)):
    """To add debgging capabilities to your agent, subclass this EosSdkAgent."""
