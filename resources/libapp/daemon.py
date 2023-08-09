# ------------------------------------------------------------------------------
#  Copyright (c) 2022-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
#    fdk-support@arista.com
#
#  Description:
#    Helpers for writing EosSdk daemons.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------
"""Helpers for writing EosSdk daemons."""
import logging
import six

from . import cli, serial
from .loghandler import EOSTraceHandler

if six.PY3:
    from collections.abc import Set, MutableMapping
else:
    from collections import Set, MutableMapping  # pylint: disable=deprecated-class


class ConfigAccessor(Set):
    def __init__(self, ctx):
        self.ctx = ctx

    def __contains__(self, item):
        return self.ctx.agent_option_exists(serial.dumps(item.key))

    def __iter__(self):
        for key in self.ctx.agent_option_iter():
            yield cli.ConfigItem(serial.loads(key), serial.loads(self.ctx.agent_option(key)))

    def __len__(self):
        return sum(1 for _ in self)


class ConfigMixin(object):
    @property
    def config(self):
        return ConfigAccessor(self.get_agent_mgr())

    def on_agent_option(self, name, value):
        return self.on_agent_config(cli.ConfigItem(serial.loads(name), serial.loads(value)))

    def on_agent_config(self, item):
        raise NotImplementedError


class StatusMutator(cli.StatusAccessor, MutableMapping):
    def __setattr__(self, name, value):
        self[name] = value

    def __getitem__(self, key):
        data = self.ctx.status(self._extend_prefix(key))
        if not data:
            return StatusMutator(self.ctx, self._extend_prefix(key))
        return serial.loads(data)

    def __setitem__(self, key, value):
        return self.ctx.status_set(self._extend_prefix(key), serial.dumps(value))

    def __delitem__(self, key):
        StatusMutator(self.ctx, self._extend_prefix(key)).clear()
        return self.ctx.status_del(self._extend_prefix(key))

    def _status_iter(self):
        for key in self.ctx.status_iter():
            yield key


class StatusMixin(object):
    """A mixin for a daemon class that provides automatic serializing and
    deserializing of status.
    """

    @property
    def status(self):
        """A proxy for accessing and modifying a daemon's status that
        automatically serializes and deserializes.
        """
        return StatusMutator(self.get_agent_mgr())


class LoggingMixin(object):
    def __init__(self, name):
        self.trace_handler = EOSTraceHandler(name)
        self.trace_handler.setLevel(logging.DEBUG)  # Leave what levels to export to EOS tracing.
        logging.getLogger().addHandler(self.trace_handler)
