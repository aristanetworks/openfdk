--------------------------------------------------------------------------------
-- Copyright (c) 2016-2022 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Author:
--   fdk-support@arista.com
--
-- Description:
--   Definitions for AXI4-Stream protocol interfaces
--   These records have been defined to assist with Stream/Styx interoperability.
--   For Stream/Styx specifications, see AID/8878 and AID/8879 respectively.
--   The AXI4-S 'tuser' field has been used with the following mapping:
--     tuser(0) => tfirst    (used like Stream/Styx .sof)
--     tuser(1) => tbadframe (used like Stream/Styx .badframe)
--   Note: AXi4-S suffers from the same limitations as Stream - if you need a certain
--         data bus width, you will have to define an explicit record that supports it.
--
-- Tags:
--   noencrypt
--   license-arista-fdk-agreement
--   license-bsd-3-clause
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.metamako_pkg.all;

package amba_pkg is

  type axi4s8_std_t is record
    tvalid    : std_logic;
    tdata     : std_logic_vector(7 downto 0);
    tkeep     : std_logic_vector(0 downto 0);
    tstrb     : std_logic_vector(0 downto 0);
    tlast     : std_logic;
    tfirst    : std_logic;              -- tuser(0)
    tbadframe : std_logic;              -- tuser(1)
  end record;
  type axi4s8_std_array_t is array (natural range <>) of axi4s8_std_t;

  type axi4s8_dts_t is record
    tready : std_logic;
  end record;
  type axi4s8_dts_array_t is array (natural range <>) of axi4s8_dts_t;

  --! Default values so that we can initialise them
  constant AXI4S8_STD_DFLT_C : axi4s8_std_t := (tvalid    => '0',
                                                tdata     => (others => '0'),
                                                tkeep     => (others => '1'),
                                                tstrb     => (others => '1'),
                                                tlast     => '0',
                                                tfirst    => '0',
                                                tbadframe => '0');

  constant AXI4S8_DTS_DFLT_C : axi4s8_dts_t := (tready => '1');

  type axi4s32_std_t is record
    tvalid    : std_logic;
    tdata     : std_logic_vector(31 downto 0);
    tkeep     : std_logic_vector(3 downto 0);
    tstrb     : std_logic_vector(3 downto 0);
    tlast     : std_logic;
    tfirst    : std_logic;              -- tuser(0)
    tbadframe : std_logic;              -- tuser(1)
  end record;
  type axi4s32_std_array_t is array (natural range <>) of axi4s32_std_t;

  type axi4s32_dts_t is record
    tready : std_logic;
  end record;
  type axi4s32_dts_array_t is array (natural range <>) of axi4s32_dts_t;

  --! Default values so that we can initialise them
  constant AXI4S32_STD_DFLT_C : axi4s32_std_t := (tvalid    => '0',
                                                  tdata     => (others => '0'),
                                                  tkeep     => (others => '1'),
                                                  tstrb     => (others => '1'),
                                                  tlast     => '0',
                                                  tfirst    => '0',
                                                  tbadframe => '0');

  constant AXI4S32_DTS_DFLT_C : axi4s32_dts_t := (tready => '1');

  type axi4s64_std_t is record
    tvalid    : std_logic;
    tdata     : std_logic_vector(63 downto 0);
    tkeep     : std_logic_vector(7 downto 0);
    tstrb     : std_logic_vector(7 downto 0);
    tlast     : std_logic;
    tfirst    : std_logic;              -- tuser(0)
    tbadframe : std_logic;              -- tuser(1)
  end record;
  type axi4s64_std_array_t is array (natural range <>) of axi4s64_std_t;

  type axi4s64_dts_t is record
    tready : std_logic;
  end record;
  type axi4s64_dts_array_t is array (natural range <>) of axi4s64_dts_t;

  --! Default values so that we can initialise them
  constant AXI4S64_STD_DFLT_C : axi4s64_std_t := (tvalid    => '0',
                                                  tdata     => (others => '0'),
                                                  tkeep     => (others => '1'),
                                                  tstrb     => (others => '1'),
                                                  tlast     => '0',
                                                  tfirst    => '0',
                                                  tbadframe => '0');

  constant AXI4S64_DTS_DFLT_C : axi4s64_dts_t := (tready => '1');

  type axi4s128_std_t is record
    tvalid    : std_logic;
    tdata     : std_logic_vector(127 downto 0);
    tkeep     : std_logic_vector(15 downto 0);
    tstrb     : std_logic_vector(15 downto 0);
    tlast     : std_logic;
    tfirst    : std_logic;              -- tuser(0)
    tbadframe : std_logic;              -- tuser(1)
  end record;
  type axi4s128_std_array_t is array (natural range <>) of axi4s128_std_t;

  type axi4s128_dts_t is record
    tready : std_logic;
  end record;
  type axi4s128_dts_array_t is array (natural range <>) of axi4s128_dts_t;

  --! Default values so that we can initialise them
  constant AXI4S128_STD_DFLT_C : axi4s128_std_t := (tvalid    => '0',
                                                    tdata     => (others => '0'),
                                                    tkeep     => (others => '1'),
                                                    tstrb     => (others => '1'),
                                                    tlast     => '0',
                                                    tfirst    => '0',
                                                    tbadframe => '0');

  constant AXI4S128_DTS_DFLT_C : axi4s128_dts_t := (tready => '1');

  type axi4s512_std_t is record
    tvalid    : std_logic;
    tdata     : std_logic_vector(511 downto 0);
    tkeep     : std_logic_vector(63 downto 0);
    tstrb     : std_logic_vector(63 downto 0);
    tlast     : std_logic;
    tfirst    : std_logic;              -- tuser(0)
    tbadframe : std_logic;              -- tuser(1)
  end record;
  type axi4s512_std_array_t is array (natural range <>) of axi4s512_std_t;

  type axi4s512_dts_t is record
    tready : std_logic;
  end record;
  type axi4s512_dts_array_t is array (natural range <>) of axi4s512_dts_t;

  --! Default values so that we can initialise them
  constant AXI4S512_STD_DFLT_C : axi4s512_std_t := (tvalid    => '0',
                                                    tdata     => (others => '0'),
                                                    tkeep     => (others => '1'),
                                                    tstrb     => (others => '1'),
                                                    tlast     => '0',
                                                    tfirst    => '0',
                                                    tbadframe => '0');

  constant AXI4S512_DTS_DFLT_C : axi4s512_dts_t := (tready => '1');

  ------------------------------------------------------------------------
  --Define records for AXI4-Lite interfaces
  type axi4l_mts_t is record
    awvalid : std_logic;
    awaddr  : std_logic_vector(31 downto 0);
    awprot  : std_logic_vector(2 downto 0);
    wvalid  : std_logic;
    wdata   : std_logic_vector(31 downto 0);
    wstrb   : std_logic_vector(3 downto 0);
    bready  : std_logic;
    arvalid : std_logic;
    araddr  : std_logic_vector(31 downto 0);
    arprot  : std_logic_vector(2 downto 0);
    rready  : std_logic;
  end record;

  type axi4l_stm_t is record
    awready : std_logic;
    wready  : std_logic;
    bvalid  : std_logic;
    bresp   : std_logic_vector(1 downto 0);
    arready : std_logic;
    rvalid  : std_logic;
    rdata   : std_logic_vector(31 downto 0);
    rresp   : std_logic_vector(1 downto 0);
  end record;

end package amba_pkg;

package body amba_pkg is
end package body amba_pkg;
