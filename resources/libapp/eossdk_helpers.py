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

import json

from . import IS_EOS


class EapiInterface(object):
    """A wrapper around EOSSDK EAPI Interface."""

    def __init__(self, eapi_mgr):
        self.eapi_mgr = eapi_mgr

    def get_l1_source(self, intf_id):
        if IS_EOS:
            intf_s = intf_id.to_string()
            cmd = "show l1 source interface {}".format(intf_s)
            result = self.eapi_mgr.run_show_cmd(cmd)
            if result.success():
                response = result.responses()[0]
                json_ = json.loads(response)
                intf_name = json_["interfaces"][intf_s].get("sourceInterface", None)
                # return Et25-MAC by default but not on Tama
                if intf_name and "MAC" not in intf_name:
                    return intf_name
        return None

    def set_l1_source(self, intf_id, src_id):
        if IS_EOS:
            cmd_0 = "interface {}".format(intf_id.to_string())
            cmd_1 = "l1 source interface {}".format(src_id.to_string())
            result = self.eapi_mgr.run_config_cmds((cmd_0, cmd_1))
            if not result.success():
                raise AttributeError
