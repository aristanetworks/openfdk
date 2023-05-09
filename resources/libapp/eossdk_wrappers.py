#!/usr/bin/env python
# ------------------------------------------------------------------------------
#  Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
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

try:
    import eossdk
except ImportError:
    eossdk = None

from types import MethodType

from . import device

try:
    _available_devices = device.get_fpga_devices()
except Exception as e:  # pylint: disable=broad-except
    _available_devices = []

_id_to_device = {fpga.identifier: fpga for fpga in _available_devices}


if hasattr(eossdk, "Fpga"):
    # Just use the pre-existing stuff if it already exists
    Fpga = eossdk.Fpga
    # Add PCIe information from libapp. This isn't in eossdk so add
    # it in if it doesn't exist
    if not hasattr(Fpga, "pcie"):
        Fpga.pcie = property(lambda self: _id_to_device[self.name()].pcie)
        eossdk.Fpga.pcie = property(lambda self: _id_to_device[self.name()].pcie)
    FpgaMgr = eossdk.FpgaMgr
    # Add a function to get communicators. This doesn't always exist in eossdk
    if not hasattr(FpgaMgr, "ham"):

        def ham(mgr, fpga, address):  # pylint: disable=unused-argument
            # type: (FpgaMgr, Fpga, int) -> object
            maybe_comm = _id_to_device[fpga.name()].communicator
            # Happens to be that the communicator class uses addr for the
            # internal address regardless of context
            maybe_comm.internal.addr = address
            return maybe_comm

        FpgaMgr.ham = MethodType(ham, None, FpgaMgr)
        eossdk.FpgaMgr.ham = MethodType(ham, None, eossdk.FpgaMgr)
    FpgaHandler = eossdk.FpgaHandler
    FpgaIter = eossdk.FpgaIter
    FpgaReservation = eossdk.FpgaReservation
    FpgaReservationIter = eossdk.FpgaReservationIter
    FpgaReservationStatus = eossdk.FpgaReservationStatus
    FpgaReservationStatusIter = eossdk.FpgaReservationStatusIter

    # fpga_reservation_result_t enum
    FRR_INVALID = eossdk.FRR_INVALID
    FRR_PENDING = eossdk.FRR_PENDING
    FRR_SUCCESS = eossdk.FRR_SUCCESS
    FRR_FAILED_TO_MATCH_FPGA = eossdk.FRR_FAILED_TO_MATCH_FPGA
    FRR_FAILED_TO_RESERVE = eossdk.FRR_FAILED_TO_RESERVE
    FRR_FAILED_TO_PROGRAM = eossdk.FRR_FAILED_TO_PROGRAM
    FRR_FAILED_TO_CLEAR = eossdk.FRR_FAILED_TO_CLEAR

    # Helper function to get the FpgaMgr
    def get_fpga_mgr(sdk):
        # type: (eossdk.Sdk) -> eossdk.FpgaMgr
        return sdk.get_fpga_mgr()
