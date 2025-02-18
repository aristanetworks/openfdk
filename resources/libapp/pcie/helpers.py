# ------------------------------------------------------------------------------
#  Copyright (c) 2019 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    A collection of various helper functions
#
#    This code is part of a proof of concept of PCIe on Arista's 7130E and 7130L
#    Series platforms. This application provides a means to verify that PCIe is
#    functional on these platforms and should not be used as a guideline for PCIe
#    designs on these platforms. This method of interfacing to PCIe will become
#    unsupported once MOS API adds official support for PCIe.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

import binascii


def hex(*args, **kwargs):  # pylint: disable=redefined-builtin
    return _hex(*args, **kwargs)


def _hex(intval, pad=0, leading=False):
    """Same as hex() but without the leading 0x by default"""

    prefix = "0x" if leading else ""
    return "{}{:0{}x}".format(prefix, intval, pad)


def _mask(flags):
    """
    Return a mask with bits set as described in flags.
    Param flags: List of integer bit positions to be set
    """

    mask = 0x0
    for pos in flags:
        mask |= 1 << pos
    return mask


def mask_lower(pos):
    return _mask_lower(pos)


def _mask_lower(pos):
    """
    Return a mask with all bits lower than pos set
    """

    return (1 << pos) - 1


def _not(value, nbits):
    """Bitwise NOT of value of size nbits"""

    return ~value & _mask_lower(nbits)


def to_binary_prefix(*args, **kwargs):
    return _to_binary_prefix(*args, **kwargs)


def _to_binary_prefix(intval, precision=3):
    """
    Represent an integer using the largest possible binary prefix such that its significand is at least 1.
    Formatting of the significand is done using the python string format 'g', e.g. with precision=3,
        256         -> 256,
        2*1024      -> 2K,
        2049        -> 2K (with precision=4 this will be 2.001K),
        4*1024*1024 -> 4M,
        10e6        -> 9.54M,
        100e6       -> 95.4M
    """

    units = {0: "", 10: "Ki", 20: "Mi", 30: "Gi", 40: "Ti"}

    magnitude = (intval.bit_length() - 1) / 10 * 10
    return "{:.{}g} {}B".format(float(intval) / (1 << magnitude), precision, units[magnitude])


def _to_decimal_prefix(val, precision=3):
    """
    Represent a non-negative number using the largest possible decimal prefix such that its significand is at least 1.
    Formatting of the significand is done using the python string format 'g', e.g. with precision=3,
        25.6     -> 25.6,
        2e3      -> 2K,
        4e6      -> 4M,
        10.436e9 -> 10.4G
    """

    units = {0: "", 3: "K", 6: "M", 9: "G", 12: "T"}

    for exp in range(0, 12, 3):
        if val < 10 ** (exp + 3):
            return "{:.{}g} {}B".format(float(val) / 10**exp, precision, units[exp])

    raise ValueError("Could not interpret value")


def _roundup_pow2(intval):
    """Round a non-negative integer up to the nearest power of two"""

    if intval == 0:
        return 0

    if intval > 0:
        return 1 << (intval - 1).bit_length()

    raise ValueError("Input integer must be non-negative")


def _to_bytes(hexstr, endian="little"):
    """
    Convert a hexadecimal string into a string of bytes, e.g. 0x000abcde to '\xde\xbc\x0a\x00' if little endian
    and '\x00\x0a\xbc\xde' if big endian. Leading zeroes are maintained, and added to pad to the next byte.
    """

    # Pad to byte align
    if len(hexstr) % 2:
        hexstr = "0" + hexstr

    if endian == "big":
        return binascii.a2b_hex(hexstr)

    if endian == "little":
        hexstr = "".join([hexstr[i - 2 : i] for i in range(len(hexstr), 0, -2)])
        return binascii.a2b_hex(hexstr)

    raise ValueError("Endianness must be big or little")


# Export bytes_to_int as public
def bytes_to_int(*args, **kwargs):
    return _bytes_to_int(*args, **kwargs)


def _bytes_to_int(ba, endian="little"):
    """
    Convert a bytearray into an integer, e.g. '\x34\x12' into 0x1234.
    """

    if endian == "little":
        ba = reversed(ba)

    ret = 0
    for b in ba:
        ret = (ret << 8) + ord(b)
    return ret
