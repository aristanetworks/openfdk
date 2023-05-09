# ------------------------------------------------------------------------------
#  Copyright (c) 2018-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
#    fdk-support@arista.com
#
#  Description:
#    Register access library.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

from __future__ import absolute_import, print_function

import collections
import csv
import logging
import os.path
import re
import time

import six
from six.moves import range

regex = re.compile("(?P<name>\\w+)\\[(?P<num>\\d+)\\]")

#
def Retryable(retry_list):
    """Utility decorator to wrap methods which might flake (like i2c accesses).
    Pass a list of sleeptimes and the decorated function is repeatedly called,
    backing off the specified time,  until success, or the list is exhausted.
    Upon failure, the most recently caught exception bubbles up."""

    def inner(func):
        def retryIt(*args, **kwargs):
            for t in retry_list:
                try:
                    return func(*args, **kwargs)
                except Exception as e:  # pylint: disable=broad-except
                    import __main__  # pylint: disable=import-outside-toplevel

                    last_exc = e
                    scriptname = os.path.basename(__main__.__file__)
                    logging.error(
                        "%s: %s failed: %s. Retrying in %fs",
                        scriptname,
                        func.__name__,
                        str(e),
                        t,
                    )
                    time.sleep(t)
            logging.critical(
                "%s: %d consecutive failures on %s. Giving up",
                scriptname,
                len(retry_list),
                func.__name__,
            )
            raise last_exc

        return retryIt

    return inner


class RegisterDescriptor(object):
    def __init__(self, cls_instance, name, register):
        self.public_name = name
        self.private_name = "_register_" + name
        # create the private instance attribute
        setattr(cls_instance, self.private_name, register)
        # have to insert a global class attribute descriptor
        setattr(cls_instance.__class__, name, self)

    def __get__(self, obj, objtype=None):
        instance_register = getattr(obj, self.private_name)
        return instance_register.read()

    def __set__(self, obj, val):
        instance_register = getattr(obj, self.private_name)
        instance_register.write(val)


class Register(object):
    RETRIES = [0.001, 0.010, 0.100, 0.200, 0.250, 1]

    def __init__(  # pylint: disable=unused-argument,too-many-arguments,redefined-builtin
        self, reg_accessor, parent, number, name, type, writeable, width=32, **kw
    ):
        self.name = name
        self.addr = int(number)
        self.rtype = type
        self.writeable = writeable.lower() == "true"
        self.width = width
        self.regaccess = reg_accessor
        self.parent = parent

    def __get__(self, parent, cls=None):
        return self.read()

    def __set__(self, obj, val):
        self.write(val)

    @Retryable(RETRIES)
    def read(self):
        return self.regaccess.read_reg(self.addr)

    def write(self, value):
        if not self.writeable:
            raise AttributeError("Register {} is not writeable".format(self.name))
        return self._write(value)

    @Retryable(RETRIES)
    def _write(self, value):
        self.regaccess.write_reg(self.addr, value)


class Node(object):
    def __init__(self, parent):
        self._registers = collections.OrderedDict()
        self._nodes = collections.OrderedDict()
        self._arrays = collections.OrderedDict()
        self._parent = None
        self.parent = parent
        if parent:
            self._offs = parent._offs

    def register_list(self):
        result = []
        for _, details in self._registers.items():
            result.append(details)
        for _, v in self._nodes.items():
            result.extend(v.register_list())
        return result

    def dumps(self, buf, level=0):
        indent = " " * (level * 4)

        for name, details in self._registers.items():
            name, reg = details
            buf.write("{}{:3d} 0x{:08x} - {}\n".format(indent, reg.addr, reg.read(), name))

        for k, v in self._nodes.items():
            buf.write("{}{}:\n".format(indent, k))
            v.dumps(buf, level + 1)

        for name, array in self._arrays.items():
            for i, n in enumerate(array):
                buf.write("{}{}[{}]:\n".format(indent, name, i + self._offs))
                n.dumps(buf, level + 1)

    def dump(self, level=0):
        indent = " " * (level * 4)

        for name, details in self._registers.items():
            name, reg = details
            print("{}{:3d} 0x{:08x} - {}".format(indent, reg.addr, reg.read(), name))

        for k, v in self._nodes.items():
            print("{}{}:".format(indent, k))
            v.dump(level + 1)

        for name, array in self._arrays.items():
            for i, n in enumerate(array):
                print("{}{}[{}]:".format(indent, name, i + self._offs))
                n.dump(level + 1)


class RootNode(Node):  # pylint: disable=too-many-instance-attributes
    def __init__(self, array_offset=0):
        self._name = "root"
        self._all_registers = {}
        self._offs = array_offset
        Node.__init__(self, parent=None)

    def read_reg(self, key):
        return self._all_registers[key].read()

    def write_reg(self, key, value):
        self._all_registers[key].write(value)


def make_node(name, parent):
    nodename = name

    class N(Node):
        _name = nodename

    N.__name__ = "{}".format(nodename)
    return N(parent)


def add_64(node, basename):
    lo = "{}_low".format(basename)
    hi = "{}_high".format(basename)

    def r64(node):
        vhi = getattr(node, hi)
        vlo = getattr(node, lo)
        return (vhi << 32) | vlo

    setattr(node.__class__, basename, property(r64))


def add_str(node, basename):
    cls = node.__class__

    str_regs = []
    for i in range(32):
        regname = "{}_{}_{}".format(basename, i * 4, i * 4 + 3)

        if regname in cls.__dict__:
            str_regs.append(regname)
        else:
            break

    def rstr(node):
        def int_to_chars(i):
            return [
                chr((i >> 0) & 0xFF),
                chr((i >> 8) & 0xFF),
                chr((i >> 16) & 0xFF),
                chr((i >> 24) & 0xFF),
            ]

        bs = [int_to_chars(getattr(node, p)) for p in str_regs]
        chars = [item for sublist in bs for item in sublist]
        string = "".join([c for c in chars if c != chr(0x00)])
        return string

    setattr(cls, basename, property(rstr))


# Existing code expects to be able to iterate over an "array" of registers, so
# this implements that behaviour while still allowing 1-based indexing,
# sparseness, etc.
class RegisterArray(collections.OrderedDict):
    def __getitem__(self, key):
        try:
            return super(RegisterArray, self).__getitem__(key)
        except KeyError:
            raise IndexError

    def __iter__(self):
        for key in super(RegisterArray, self).__iter__():
            yield self[key]


def walk_nodes(start, parts, may_insert=False, array_offset=0):
    n = start
    for part in parts:
        match = regex.match(part)

        if match:
            name = match.groupdict()["name"]
            num = int(match.groupdict()["num"]) - array_offset

            if not hasattr(n, name):
                if may_insert:
                    new_array = RegisterArray()
                    setattr(n, name, new_array)
                    n._arrays[name] = new_array  # pylint: disable=protected-access
                else:
                    raise AttributeError("Array {} not in {}".format(name, parts))

            array = getattr(n, name)

            if num not in array:
                if may_insert:
                    array[num] = make_node(part, parent=n)
                else:
                    raise AttributeError("Item {}[{}] not in {}".format(name, num, parts))
            n = array[num]

        else:
            if not hasattr(n, part):
                if may_insert:
                    new_node = make_node(part, parent=n)
                    setattr(n, part, new_node)
                    n._nodes[part] = new_node  # pylint: disable=protected-access
                else:
                    raise AttributeError("Node {} not in {}".format(part, parts))
            n = getattr(n, part)
    return n


def RegisterFile(csvfile, accessor, array_offset=0):  # pylint: disable=too-many-locals
    """A wrapper around register file described by a CSV file.

    Example:
        >>> regfile = libapp.register_file.RegisterFile(
        ...     "fpga/muxcore_registers.csv", fpga.communicator
        ... )
        >>> struct.pack(
        ...    "<IIII", regfile.app_name_0, regfile.app_name_1, regfile.app_name_2, regfile.app_name_3
        ... )
        'lseries_muxcore '

    Args:
        csvfile (str): Path to the CSV file describing the register file layout.
        accessor (RegisterAccess): The object to use to perform register access.
    """
    # if a file name was passed in, open it and close later
    # otherwise we assume that 'csvfile' is something file-like
    # which we can pass directly to the csvreader.
    if isinstance(csvfile, six.string_types):
        with open(csvfile, "r") as file:  # pylint: disable=unspecified-encoding
            regs = list(csv.DictReader(file))
    else:
        regs = list(csv.DictReader(csvfile))

    root = RootNode(array_offset)

    may_insert = True
    for r in regs:
        fullname = r["name"]
        basename = fullname.split("/")[-1]
        pathparts = fullname.split("/")[:-1]

        node = walk_nodes(root, pathparts, may_insert, array_offset)

        register = Register(accessor, node, **r)
        # sets global and instance attributes
        RegisterDescriptor(node, basename, register)

        root._all_registers[fullname] = register  # pylint: disable=protected-access
        node._registers[basename] = (  # pylint: disable=protected-access
            fullname,
            register,
        )
    # Now scan through and add properties for "compound" registers,
    # i.e 64bit values that span 2 registers, or strings which may span many
    may_insert = False
    for r in regs:
        fullname = r["name"]
        basename = fullname.split("/")[-1]
        pathparts = fullname.split("/")[:-1]

        if basename.endswith("_low"):
            highname = "{}_high".format(basename[:-4])
            node = walk_nodes(root, pathparts, may_insert, array_offset)
            cls = node.__class__

            if highname in cls.__dict__:
                add_64(node, basename[:-4])
            else:
                print("Warning: have {} register, but no _high".format(basename))

        if basename.endswith("_0_3"):
            node = walk_nodes(root, pathparts, may_insert, array_offset)
            add_str(node, basename[:-4])

    return root


__all__ = (
    "Node",
    "Register",
    "RegisterFile",
    "RootNode",
)
