# ------------------------------------------------------------------------------
#  Copyright (c) 2022 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    Functions to serialize/deserialize data for agent config/status.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

"""Functions to serialize/deserialize data for agent config/status."""
import collections
import json


def dumps(obj):
    """Returns a string containing a serialized representation of an object.

    Args:
        obj (any): The object to serialize.
    """
    return json.dumps(obj)


def loads(data):
    """Returns a deserialized Python object.

    Args:
        data (str): A serialized represensation of an object.
    """
    try:
        return json.loads(data, object_pairs_hook=collections.OrderedDict)
    except (TypeError, ValueError):
        # FIXME: do we need this fallback?
        return data
