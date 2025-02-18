# ------------------------------------------------------------------------------
#  Copyright (c) 2021 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    The muxcore example CLI implementation.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------
"""Utilities for writing CliPlugins."""
from __future__ import absolute_import, print_function
import collections
import re
import json
import six
from . import IS_EOS, device, serial

if six.PY3:
    from collections.abc import Mapping, MutableSet
else:
    from collections import Mapping, MutableSet  # pylint: disable=deprecated-class

try:
    import CliExtension
    import CliExtensionLib
except ImportError:

    class MockedCliExtension:
        class CliCommandClass:
            pass

        class ShowCommandClass:
            pass

    CliExtension = MockedCliExtension()

try:
    import eossdk
except ImportError:

    class MockSDK:
        pass

    eossdk = MockSDK()


class ConfigCommandClass(CliExtension.CliCommandClass):
    def __init__(self):
        # FIXME: Can we make the syntax available to the CliPlugin directly?
        for namespace, cmds in six.iteritems(CliExtensionLib.registeredCommands):
            for name, cmd in six.iteritems(cmds):
                if cmd == self.__class__:
                    self.syntax = CliExtensionLib.loadedCommands[namespace][name]["syntax"]

    def handler(self, ctx):
        key = collections.OrderedDict()
        for arg in _tokenize(self.key_syntax):
            if arg in ctx.args:
                key[arg] = ctx.args[arg]

        value = collections.OrderedDict()
        for arg in _tokenize(self.syntax):
            if arg in ctx.args:
                value[arg] = ctx.args[arg]

        config = ConfigMutator(ctx.daemon.config)
        config.add(ConfigItem(key, value))

    def noHandler(self, ctx):
        args = {key: ctx.args[key] for key in ctx.args if not key[:2] == "__"}
        config = ConfigMutator(ctx.daemon.config)
        for item in list(config):
            if item.matches(args):
                config.discard(item)


class ConfigItem(Mapping):
    def __init__(self, key, value):
        self.key = key
        self.value = value or {}

    def __getitem__(self, key):
        # We need to be able to store falsy values, so we can't do something
        # like `self.key.get(...) or ...`, as something like `0` or `None` might
        # be a valid key.
        try:
            return self.key[key]
        except KeyError:
            return self.value[key]

    def __iter__(self):
        return iter(self.value)

    def __len__(self):
        return len(self.value)

    def __str__(self):
        return " ".join(str(value) for value in six.itervalues(self.value))

    def matches(self, args):
        if isinstance(args, six.string_types):
            return all(arg in self for arg in _tokenize(args, optionals=False))
        return all(self.get(arg) == args[arg] for arg in args)


class ConfigMutator(MutableSet):
    def __init__(self, ctx):
        self.ctx = ctx

    def __contains__(self, value):
        return serial.loads(self.ctx.config(serial.dumps(value.key))) == value.value

    def __iter__(self):
        for key, value in self.ctx.configIter():
            yield ConfigItem(serial.loads(key), serial.loads(value))

    def __len__(self):
        return sum(1 for _ in self)

    def add(self, value):
        return self.ctx.configSet(serial.dumps(value.key), serial.dumps(value.value))

    def discard(self, value):
        return self.ctx.configDel(serial.dumps(value.key))


class StatusAccessor(Mapping, dict):
    """A wrapper around statuses in Sysdb that provides python objects.

    This mapping handles the translation between python objects and serialized
    representations stored in Sysdb under daemon/agent/status.  Those values
    are always strings which this class assumes are JSON encoded.  Strings
    which are not correctly encoded will result in ValueError/JsonDecodeError
    exceptions.
    """

    def __init__(self, ctx, prefix=""):
        object.__setattr__(self, "ctx", ctx)
        object.__setattr__(self, "prefix", prefix)

    def __getattr__(self, name):
        try:
            return self[name]
        except KeyError:
            raise AttributeError

    def __getitem__(self, key):
        # This class is used from two different contexts:
        # 1. From CliExtension, where missing keys return None.
        # 2. From EosSdk, where missing keys return an empty string.
        # This code doesn't distinguish between the two cases.
        data = self.ctx.status(self._extend_prefix(key))
        if not data:
            status = StatusAccessor(self.ctx, self._extend_prefix(key))
            if not status:
                raise KeyError
            return status
        return serial.loads(data)

    def __iter__(self):
        prog = re.compile(re.escape(self.prefix) + r"(?:(?:\A|/)([^/\[\]]+)|\[([^/\[\]]+)\])")
        keys = set()
        for key in self._status_iter():
            m = prog.match(key)
            if m:
                keys.add(m.group(1) or int(m.group(2)))
        for key in keys:  # pylint: disable=use-yield-from
            yield key

    def __len__(self):
        return sum(1 for _ in self)

    def _extend_prefix(self, key):
        if isinstance(key, six.integer_types):
            key = "{}[{}]".format(self.prefix, key)
        elif self.prefix:
            key = "{}/{}".format(self.prefix, key)
        return key

    def _status_iter(self):
        for key, _ in self.ctx.statusIter():
            yield key


def _tokenize(syntax, optionals=True):
    if optionals:
        syntax = re.sub(r"\[([^]]+)\]", r"\1", syntax)
    else:
        syntax = re.sub(r"\[([^]]+)\]", r"", syntax)
    for token in syntax.split():  # pylint: disable=use-yield-from
        yield token


def running_config(ctx):
    result = []

    config = ConfigMutator(ctx.config)
    for item in config:
        result.append(str(item))

    if ctx.config.isEnabled():
        result.append("no disabled")

    return result


def fpga_options(ctx):  # pylint: disable=unused-argument
    return device.get_fpga_identifiers()


def get_eth_intfs(ctx):
    # pylint: disable=unused-argument
    if IS_EOS:
        if not hasattr(get_eth_intfs, "eth_intfs"):
            sdk = eossdk.Sdk("libappIntfGetter")
            eapi = sdk.get_eapi_mgr()
            ethIntfsList = list(
                json.loads(eapi.run_show_cmd("show interfaces status").responses()[0])["interfaceStatuses"].keys()
            )
            ethIntfsList = filter(lambda intf: intf.startswith("Eth"), ethIntfsList)
            get_eth_intfs.eth_intfs = {k: k for k in ethIntfsList}
        return get_eth_intfs.eth_intfs
    return []


class ShowEnabledBaseCmd(CliExtension.ShowCommandClass):
    """Subclassing me will provide enabled/running status.

    Attributes:
        daemon (str): Name of the daemon.

    The derived class must initialize the data object with a call to
    super(<DerivedClass>, self).handler(ctx) which will return a dict with the
    <enabled> and <running> keys.

    Furthermore, the same must be done in the render function:
    e.g. super(<DerivedClass>, self).render(data)
    which will print the enabled/running status.
    """

    daemon = None

    def __init__(self):
        CliExtension.ShowCommandClass.__init__(self)
        assert self.daemon, "Daemon name must be defined."

    def handler(self, ctx):
        result = {"enabled": False, "running": False}
        daemon = ctx.getDaemon(self.daemon)

        if daemon is None:
            # Daemon is not currently running
            return result

        status = StatusAccessor(daemon.status)

        result["enabled"] = daemon.config.isEnabled()
        result["running"] = getattr(status, "running", False)

        return result

    def render(self, data):
        print("Enabled: {}".format("Yes" if data["enabled"] else "No"))
        print("Running: {}".format("Yes" if data["running"] else "No"))
