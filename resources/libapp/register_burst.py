# ------------------------------------------------------------------------------
#  Copyright (c) 2025 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    Register Burst class - allows a burst of registers to be read / written
#      in a single transaction. Only supported in EOS.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

from __future__ import absolute_import


class _RegisterBurst(object):
    def __init__(self, regfile):
        self._reg_addr_list = []
        self._reg_val_list = []
        self._reg_read_list = []
        self._regfile = regfile
        self._regaccess = None

    def __get__(self, parent, cls=None):
        return self.submit()

    def _add_register(self, register, read, value=0):
        addr = None
        if hasattr(self._regfile, "_all_registers"):
            if self._regaccess is None:
                self._regaccess = self._regfile._all_registers[register].regaccess  # pylint: disable=protected-access
            addr = self._regfile._all_registers[register].addr  # pylint: disable=protected-access
        else:
            reg = [r for name, r in self._regfile.register_list() if name.split("/")[-1] == register]
            assert len(reg), "Error, register not found {}".format(register)
            if self._regaccess is None:
                self._regaccess = reg[0].regaccess  # pylint: disable=protected-access
            addr = reg[0].addr

        # check for consecutive register accesses and join together into single transactions
        if (
            self._reg_read_list
            and read
            and self._reg_read_list[-1]
            and self._reg_addr_list[-1] + self._reg_read_list[-1] == addr
        ):
            self._reg_read_list[-1] = self._reg_read_list[-1] + 1
        elif (
            self._reg_read_list
            and not read
            and not self._reg_read_list[-1]
            and self._reg_addr_list[-1] + len(self._reg_val_list[-1]) == addr
        ):
            self._reg_val_list[-1].append(value)
        else:
            self._reg_addr_list.append(addr)
            self._reg_val_list.append(None if read else value)
            self._reg_read_list.append(1 if read else 0)

    def _clear(self):
        self._reg_addr_list = []
        self._reg_val_list = []
        self._reg_read_list = []

    def _submit(self):
        if self._reg_addr_list:
            return self._regaccess.internal._submit_burst(  # pylint: disable=protected-access
                self._reg_addr_list, self._reg_val_list, self._reg_read_list
            )
        return None
