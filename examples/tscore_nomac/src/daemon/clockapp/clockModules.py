# ------------------------------------------------------------------------------
#  Copyright (c) 2022-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
#    fdk-support@arista.com
#
#  Description:
#    Clock synchronisation daemon for ts_ipcore.
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

from __future__ import absolute_import

import logging
import hal
import portio

from clocks import ClockBase
from six.moves import range


class OCXOControl(object):
    # The OCXO controller has an I2C target node 7-bit device address of 0x65.
    I2C_TARGET_ADDR = 0x65
    # The `ts_clk_sel` address.
    TS_CLK_SEL_ADDR = 0xF0
    # The `trim_value` address.
    TRIM_VALUE_ADDR = 0xF1
    # The OCXO ID register address.
    OCXO_ID_ADDR = 0xF2
    # The OCXO ID register value.
    OCXO_ID_VAL = 0xCAFE

    def __init__(self):
        # On L and LB devices, the FPGA resides on a mezzanine card which also
        # has an OCXO. To control the OCXO, you have to communicate with the
        # FPGA via the `sysmon` I2C bus. All FPGA apps have the `arista_sysctl_v2`
        # entity included at the top of the hierarchy. The `arista_sysctl_v2`
        # entity implements (amongst a number of things) an I2C-to-SPI bridge
        # so that commands from the CPU can be translated to SPI commands that
        # are sent to the DAC that controls the OCXO frequency (the trim value).

        # The I2C bus from the CPU to the FPGA is called the `sysmon` bus which
        # lies behind an I2C bridge/MUX which changes based on the EOS and the
        # MOS version. Therefore, to find the correct I2C bus, we ask `hal` to
        # lookup the bus by the label "main_sys".

        busnum = hal.i2c.label_to_bus("main_sys")
        self.i2c_accessor = hal.i2c.Device(bus=busnum, addr=OCXOControl.I2C_TARGET_ADDR)
        magic = self.i2c_accessor.read_word_data(OCXOControl.OCXO_ID_ADDR)
        if magic != OCXOControl.OCXO_ID_VAL:
            raise Exception("FPGA image does not implement OCXO bridge. Built against recent board_top?")

    def trim(self, val):
        self.i2c_accessor.write_word_data(OCXOControl.TRIM_VALUE_ADDR, val)

    def route_to_fpga(self, v):
        return self.i2c_accessor.write_word_data(OCXOControl.TS_CLK_SEL_ADDR, 0 if v else 1)

    def is_routed_to_fpga(self):
        # On L and LB, the `ts_clk_sel` register has values:
        #    0x0000 -> clockmux routes the clk from the on-board OCXO to the FPGA.
        #    0x0001 -> clockmux routes the clk from the platform to the FPGA.
        return self.i2c_accessor.read_word_data(OCXOControl.TS_CLK_SEL_ADDR) == 0x0000


class OCXO(ClockBase):
    #####
    # Notes:
    #  * Given DAC: 0xffff -> 5v range (assume fully linear)
    #                65535 -> 5000mv
    #               65.535 -> 5mv
    #
    #  * And clock: 0.2ppm -> 1V control (assume midrange from datasheet, could be 0.1-0.3)
    #                 1ppb -> 5mv adjustment
    #
    #  * Thus :
    #          65.535 -> 1ppb
    #           1 LSB -> 15.259 ppt (approx)
    #
    # So:
    #    adjusting DAC control by x*65.535 will trim frequency by approx x ppb
    #    Some quantization since we can only write the nearest integer to DAC
    #####
    LSB = 65536
    LSB_PER_PPB = 65.536
    MAX_OFFS = 250  # ppb
    MIN_OFFS = -250  # ppb
    MAX_SCALER = 1.25
    MIN_SCALER = 0.75
    PPB_ADJ = 1.0

    @property
    def CLAMP(self):
        return (self.LSB / (self.LSB_PER_PPB * self.PPB_ADJ)) / 2

    def __init__(self, regfile):  # pylint: disable=unused-argument
        self.adjust(0)

    def adjust(self, ppb):
        ppb = self.clamp(ppb)
        raw = 0x00008000 + int(ppb * self.LSB_PER_PPB * self.PPB_ADJ)

        # clamp to 16bit values
        if raw < 0:
            raw = 0
        elif raw > 0xFFFF:
            raw = 0xFFFF

        self.apply_dac(raw)
        self.raw = raw
        return ppb


class CMO(OCXO):
    # Addresses we use for clock control are taken from the `sys_com_ctl` register map.
    RBC_STS_ADDR = 0xF0E
    RBC_CTL_ADDR = 0xF2A
    TRIM_LOW_ADDR = 0xF28
    TRIM_HIGH_ADDR = 0xF29

    quality = 80

    def __init__(self, regfile):
        # if we're using CMO, then set clockmux appropriately
        OCXOControl().route_to_fpga(False)

        # Give ourself permission
        portio.ioperm(CMO.TRIM_LOW_ADDR, 3, True)
        # And take control of the output pins
        portio.outb(0x1, CMO.RBC_CTL_ADDR)
        OCXO.__init__(self, regfile)

    def apply_dac(self, raw):
        lo = (raw >> 0) & 0xFF
        hi = (raw >> 8) & 0xFF

        portio.outb(hi, CMO.TRIM_HIGH_ADDR)
        portio.outb(lo, CMO.TRIM_LOW_ADDR)


class lbCMO(OCXO):
    quality = 90

    def __init__(self, regfile):
        self._val = None
        self.ocxo = OCXOControl()

        self.ocxo.route_to_fpga(True)
        OCXO.__init__(self, regfile)

    def apply_dac(self, raw):
        # avoid multiply writing duplicate values
        if raw != self._val:
            self.ocxo.trim(raw)
            self._val = raw


def clamp(n, minmax):
    return max(-minmax, min(n, minmax))


class CMAsa3xm(ClockBase):
    # CMAv1 (CMA) modules carry a Microchip SA3Xm atomic clock
    quality = 100
    CLAMP = 1000  # 1ppm?
    raw = 0

    def __init__(self, regfile):  # pylint: disable=unused-argument
        import hal.sa3xm  # pylint: disable=import-outside-toplevel,redefined-outer-name

        cma = hal.clock_module.detect()  # pylint: disable=unused-variable
        self.sa3xm = hal.sa3xm.SA3Xm()
        self.sa3xm.analog_tuning = False
        OCXOControl().route_to_fpga(False)

        self._pp12 = self.get_current_pp12()
        self.adjust_all(0)
        self._first = True

    def parse_error(self, command, response, exception):
        # re-init the cma object. This reopens the UART and may flush away any bad buffer state
        self.sa3xm = None
        self.sa3xm = hal.sa3xm.SA3Xm()
        self.sa3xm.analog_tuning = False
        logging.error(
            "Unable to parse CMA response: {}: '{}' : {}".format(  # pylint: disable=logging-format-interpolation
                command, response, exception
            )
        )

    def get_current_pp12(self):
        response = "<none>"
        try:
            response = self.sa3xm.trim_digital_addjustment_pp12(0)
            valueStr = response.split("=")[1]
            try:
                value = int(valueStr)
                return value
            except ValueError as ex:
                self.parse_error("get_pp12", response, ex)
        except IndexError as ex:
            self.parse_error("get_pp12", response, ex)
        return None

    def get_current_ppb(self):
        pp12 = self.get_current_pp12()
        if pp12 is not None:
            return pp12 / 1000.0
        return None

    def adjust_step(self, ppb):
        """Takes a single step towards the desired ppb setpoint
        May not get all the way there and returns the current ppb as achieved
        Returns the current ppb value.
        May also return None in case of sustained problems, ppb may or may not be stepped
        and we no longer know the hw current status.
        """

        ppb = self.clamp(ppb)
        target_pp12 = ppb * 1000  # convert to parts-per 10^12
        stepsize = target_pp12 - self._pp12
        stepsize = clamp(stepsize, self.sa3xm.pp12_limit)
        self.raw = stepsize

        response = "<none>"
        try:
            response = self.sa3xm.trim_digital_addjustment_pp12(stepsize)
            valueStr = response.split("=")[1]
            try:
                self._pp12 = int(valueStr)
                return self._pp12 / 1000.0  # convert back to ppb
            except ValueError as ex:
                self.parse_error("trim_pp12", response, ex)
        except IndexError as ex:
            self.parse_error("trim_pp12", response, ex)
        return self.get_current_ppb()

    def adjust_all(self, ppb):
        # even if we're railing edge-to-edge, should never take more than
        # this many steps
        max_iters = (self.CLAMP * 1000) / self.sa3xm.pp12_limit

        for _ in range(max_iters):
            current = self.adjust_step(ppb)
            delta = current - ppb
            if abs(delta) < 0.001:
                return current

        raise TimeoutError("Too many iterations to adjust sa3xm clock module")

    def adjust(self, ppb):
        if self._first:
            self._first = False
            return self.adjust_all(ppb)
        return self.adjust_step(ppb)


class CMA(CMAsa3xm):
    pass


class CMAmro50(ClockBase):
    # This CMA module carries a Spectratime mRO-50 atomic clock
    #####
    # Notes:
    # * Adjustment range of fine tuning reg seems to be 0x0000 to 0x12C0 (which does not
    #      agree with the datasheet, but this is what was found experimentally on a device)
    #
    # * From the datasheet, adjustment rate of fine tuning reg is approx 30 uHz/step@10 MHz
    #
    # * It's not clear from the datasheet, but experimentally it can also be seen that
    #      writing smaller values to the reg produces a faster clock.
    #
    # * Thus:
    #        1 LSB         -> 0.003 ppb (3 ppt)
    #        333.333 steps -> 1 ppb
    #
    # So:
    #      Adjusting the fine tuning register from it's centre by -333.33*x will trim the
    #      frequency by approx x ppb
    #####
    quality = 100
    # The min and max offset values, in ppb, need to be calculated based on the
    # range of the trim values.
    # From the user guide, the nominal trim value is 0x0960 (2400), with a range
    # of 0x0640 (1600) to 0x0C80 (3200).
    # Experimentally, the nominal trim value is 0x0960 (2400), with a range of
    # 0x0000 (0) to 0x12C0 (4800).
    # Referring to `mro50.py`, we are using the experimental values.
    MAX_OFFS = 7  # ppb - for a max value of 0x0C80, this would be 2
    MIN_OFFS = -7  # ppb - for a min value of 0x0640, this would be -2
    MAX_SCALER = 2.0
    MIN_SCALER = 0.5
    PPB_ADJ = 1.0

    def __init__(self, regfile):  # pylint: disable=unused-argument
        import hal.mro50  # pylint: disable=import-outside-toplevel,redefined-outer-name

        cma = hal.clock_module.detect()  # pylint: disable=unused-variable
        self.mro50 = hal.mro50.mRO50()
        OCXOControl().route_to_fpga(False)

        self.NUM_LSB = self.mro50.max_fine_trim - self.mro50.min_fine_trim
        self.LSB_PER_PPB = 1 / self.mro50.ppb_per_bit_fine
        self.NOMINAL_PPB = (self.mro50.max_fine_trim + self.mro50.min_fine_trim) / 2  # Assume centre of range is 0 ppb
        self.adjust(0)

    @property
    def CLAMP(self):
        # We assume that the NOMINAL_PPB has been set to lie exactly halfway
        # within the allowable range of values. Then the general formula
        # for limiting is:
        #     limit = (self.NUM_LSB  / 2) / (self.LSB_PER_PPB * self.PPB_ADJ)
        # i.e. we only allow excursions from the nominal value that are equal
        # to half the full range.
        # Note that the scaling factor to convert from LSB to PPB has an
        # "adjustment" factor called `self.PPB_ADJ` that is determined
        # experimentally on device startup for calibration purposes.

        # There are 2 ways to clamp the ppb setting:

        # 1. Limiting the ppb value by using the general formula above.
        STEP_LIMIT = self.NUM_LSB / 2

        # 2. Limiting the ppb value to +/- 500 steps from the nominal value, as
        #    recommended by the Evaluation Kit document. In this case, the
        #    limit is just hard-coded so there appears to be only 500 steps.
        # STEP_LIMIT = 500

        return STEP_LIMIT / (self.LSB_PER_PPB * self.PPB_ADJ)

    def adjust(self, ppb):
        ppb = self.clamp(ppb)

        # Subtract from nominal since smaller values are faster
        val = self.NOMINAL_PPB - int(ppb * self.LSB_PER_PPB * self.PPB_ADJ)

        self.mro50.set_digital_adjustment_fine(val)
        self.raw = val

        return ppb
