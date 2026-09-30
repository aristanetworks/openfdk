# ------------------------------------------------------------------------------
#  Copyright (c) 2025 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Maintainers:
#    fdk-support@arista.com
#
#  Description:
#    Burst access for PLSmbusUtils - allows transactions to be submitted in
#    single bursts, rather than separate transactions.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

import PLSmbusUtil
import Smbus_pb2

# Submit a burst of transactions
def _submit_burst(  # pylint: disable=too-many-arguments,too-many-locals
    sock,
    pci,
    accelId,
    bus,
    deviceId,
    registers,
    datas,
    reads,
    readCurrent=False,
    backend=None,
    pec=None,
    writeType=Smbus_pb2.WRITE,
    readType=Smbus_pb2.READ,
    delay=Smbus_pb2.ZERO,
    extraDelay=0,
):

    assert sock and backend != Smbus_pb2.IOPORT

    # Create transaction request
    tr = Smbus_pb2.TransactionRequest()

    # Create transactions for each register (1 for write, 2 for read)
    for i, register in enumerate(registers):
        read = reads[i]

        # Create the request
        request = tr.request.add()

        # For non-SCD 8-bit address is only supported so put the remaining register bytes into
        # the data as a separate write operation.
        if not accelId:
            register = PLSmbusUtil.toBytes(registers[i][0])
            data = bytes(registers[i][1:] + datas[i])
            writeNoStopReadCurrent = 0
            request.type = writeType
            masterType = Smbus_pb2.KERNEL_DEV if backend is None else backend
            request.count = len(data)
        else:
            register = PLSmbusUtil.toBytes(registers[i])
            data = bytes(datas[i])
            writeNoStopReadCurrent = readCurrent if read else 0
            request.type = readType if read else writeType
            masterType = Smbus_pb2.SCD if backend is None else backend
            request.count = read or len(data)

        accelIdVal = accelId or 0

        request.masterType = masterType
        request.address = PLSmbusUtil.encodeAddress(
            bus,
            deviceId,
            register,
            accelId=accelIdVal,
            writeNoStopReadCurrent=writeNoStopReadCurrent,
            delay=delay,
            extraDelay=extraDelay,
        )
        request.pci = pci
        request.data = data
        if pec:
            request.pec = True

        if not accelId and read:
            # Create the read transaction for non-SCD devices
            request = tr.request.add()
            request.address = PLSmbusUtil.encodeAddress(
                bus,
                deviceId,
                PLSmbusUtil.toBytes(0xFF),
                accelId=accelIdVal,
                writeNoStopReadCurrent=readCurrent,
                delay=delay,
                extraDelay=extraDelay,
            )
            request.pci = pci
            request.type = readType
            request.masterType = masterType
            request.count = read

    # Submit the TransactionRequest
    tr = PLSmbusUtil.sendAndRecv(sock, tr)

    # pull out any read data that has been requested
    j = 0
    ret = []
    for read in reads:
        if read:
            if not accelId:
                j += 1
            ret.append(tr.response[j].data)
        j += 1
    return ret
