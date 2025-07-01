# ------------------------------------------------------------------------------
#  Copyright (c) 2022 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
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
    from collections.abc import Set, MutableMapping, Mapping
else:
    from collections import Set, MutableMapping, Mapping  # pylint: disable=deprecated-class


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
        if name.startswith("_"):
            object.__setattr__(self, name, value)
        else:
            self[name] = value

    def __setitem__(self, key, value):
        path = self._extend_path(key)
        self._add_path(path)
        self._ctx.status_set(path, serial.dumps(value))

    def __delitem__(self, key):
        node = self._create(key)
        node.clear()
        self._del_path(node._path)
        self._ctx.status_del(node._path)

    def _create(self, key):
        return self.__class__(self._ctx, self._extend_path(key), self)

    def _status_iter(self):
        for key in self._ctx.status_iter():  # pylint: disable=use-yield-from
            yield key

    def deepupdate(self, other):
        if not isinstance(other, Mapping):
            raise TypeError("other must be a Mapping")

        for key, value in six.iteritems(other):
            if isinstance(value, Mapping):
                self[key].deepupdate(value)
            else:
                self[key] = value


class StatusMixin(object):
    """A mixin for a daemon class that provides automatic serializing and
    deserializing of status.
    """

    @property
    def status(self):
        """A proxy for accessing and modifying a daemon's status that
        automatically serializes and deserializes.
        """
        if not hasattr(self, "_status"):
            self._status = StatusMutator(self.get_agent_mgr())
        return self._status


class LoggingMixin(object):
    def __init__(self, name):
        self.trace_handler = EOSTraceHandler(name)
        self.trace_handler.setLevel(logging.DEBUG)  # Leave what levels to export to EOS tracing.
        logging.getLogger().addHandler(self.trace_handler)
