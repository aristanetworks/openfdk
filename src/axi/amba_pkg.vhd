--------------------------------------------------------------------------------
-- Copyright (c) 2016 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Maintainers:
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

  type axi4l_mts_array_t is array(integer range <>) of axi4l_mts_t;

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

  type axi4l_stm_array_t is array(integer range <>) of axi4l_stm_t;

  constant AXI4MML_MTS_DFLT_C : axi4l_mts_t := (awvalid => '0',
                                                awaddr  => (others => '0'),
                                                awprot  => (others => '0'),
                                                wvalid  => '0',
                                                wdata   => (others => '0'),
                                                wstrb   => (others => '0'),
                                                bready  => '0',
                                                arvalid => '0',
                                                araddr  => (others => '0'),
                                                arprot  => (others => '0'),
                                                rready  => '0');

  constant AXI4MML_STM_DFLT_C : axi4l_stm_t := (awready => '0',
                                                wready  => '0',
                                                bvalid  => '0',
                                                bresp   => (others => '0'),
                                                arready => '0',
                                                rvalid  => '0',
                                                rdata   => (others => '0'),
                                                rresp   => (others => '0'));

  ------------------------------------------------------------------------
  -- Define constants for AXI4MM interfaces
  constant AXI4MM_MDWIDTH_C: integer := 256;
  constant AXI4MM_MIWIDTH_C: integer := 16;
  constant AXI4MM_MUWIDTH_C: integer := 64;
  constant AXI4MM_MAWIDTH_C: integer := 64;

  ------------------------------------------------------------------------
  -- Define types for AXI4MM interfaces
  subtype axi4mm_id_t     is std_logic_vector(AXI4MM_MIWIDTH_C-1 downto 0);
  subtype axi4mm_data_t   is std_logic_vector(AXI4MM_MDWIDTH_C-1 downto 0);
  subtype axi4mm_wstrb_t  is std_logic_vector(AXI4MM_MDWIDTH_C/8-1 downto 0);
  subtype axi4mm_addr_t   is std_logic_vector(AXI4MM_MAWIDTH_C-1 downto 0);
  subtype axi4mm_user_t   is std_logic_vector(AXI4MM_MUWIDTH_C-1 downto 0);
  subtype axi4mm_prot_t   is std_logic_vector(2 downto 0);
  subtype axi4mm_cache_t  is std_logic_vector(3 downto 0);
  subtype axi4mm_region_t is std_logic_vector(3 downto 0);
  subtype axi4mm_resp_t   is std_logic_vector(1 downto 0);
  subtype axi4mm_size_t   is std_logic_vector(2 downto 0);
  subtype axi4mm_burst_t  is std_logic_vector(1 downto 0);
  subtype axi4mm_len_t    is std_logic_vector(7 downto 0);
  subtype axi4mm_lock_t   is std_logic;
  subtype axi4mm_qos_t    is std_logic_vector(3 downto 0);

  type axi4mm_id_array_t     is array (integer range <>) of axi4mm_id_t;
  type axi4mm_data_array_t   is array (integer range <>) of axi4mm_data_t;
  type axi4mm_wstrb_array_t  is array (integer range <>) of axi4mm_wstrb_t;
  type axi4mm_addr_array_t   is array (integer range <>) of axi4mm_addr_t;
  type axi4mm_user_array_t   is array (integer range <>) of axi4mm_user_t;
  type axi4mm_prot_array_t   is array (integer range <>) of axi4mm_prot_t;
  type axi4mm_cache_array_t  is array (integer range <>) of axi4mm_cache_t;
  type axi4mm_region_array_t is array (integer range <>) of axi4mm_region_t;
  type axi4mm_resp_array_t   is array (integer range <>) of axi4mm_resp_t;
  type axi4mm_size_array_t   is array (integer range <>) of axi4mm_size_t;
  type axi4mm_burst_array_t  is array (integer range <>) of axi4mm_burst_t;
  type axi4mm_len_array_t    is array (integer range <>) of axi4mm_len_t;
  type axi4mm_lock_array_t   is array (integer range <>) of axi4mm_lock_t;
  type axi4mm_qos_array_t    is array (integer range <>) of axi4mm_qos_t;

  ------------------------------------------------------------------------
  -- Define records for AXI4-MM interfaces
  -- NOTE: mts => manager to subordinate, stm -> subordinate to manager
  type axi4mm_mts_addr_channel_t is record
    addr   : axi4mm_addr_t;
    user   : axi4mm_user_t;
    burst  : axi4mm_burst_t;
    cache  : axi4mm_cache_t;
    region : axi4mm_region_t;
    id     : axi4mm_id_t;
    qos    : axi4mm_qos_t;
    len    : axi4mm_len_t;
    lock   : axi4mm_lock_t;
    prot   : axi4mm_prot_t;
    size   : axi4mm_size_t;
    valid  : std_logic;
  end record;

  constant AXI4MM_MTS_ADDR_CHANNEL_DFLT_C : axi4mm_mts_addr_channel_t := (
    addr   => (others  => '0'),
    user   => (others  => '0'),
    burst  => "01",
    cache  => (others  => '0'),
    region => (others  => '0'),
    id     => (others  => '0'),
    qos    => (others  => '0'),
    len    => (others  => '0'),
    lock   => '0',
    prot   => (others  => '0'),
    size   => (others  => '0'),
    valid  => '0'
    );

  type axi4mm_stm_addr_channel_t is record
    ready: std_logic;
  end record;

  constant AXI4MM_STM_ADDR_CHANNEL_DFLT_C : axi4mm_stm_addr_channel_t := (
    ready => '0'
    );

  type axi4mm_mts_read_data_channel_t is record
    ready: std_logic;
  end record;

  constant AXI4MM_MTS_READ_DATA_CHANNEL_DFLT_C: axi4mm_mts_read_data_channel_t := (
    ready => '0'
    );

  type axi4mm_stm_read_data_channel_t is record
    data  : axi4mm_data_t;
    resp  : axi4mm_resp_t;
    id    : axi4mm_id_t;
    valid : std_logic;
    last  : std_logic;
  end record;

  constant AXI4MM_STM_READ_DATA_CHANNEL_DFLT_C: axi4mm_stm_read_data_channel_t := (
    data  => (others => '0'),
    resp  => (others => '0'),
    id    => (others => '0'),
    valid => '0',
    last  => '0'
    );

  type axi4mm_mts_write_data_channel_t is record
    data  : axi4mm_data_t;
    strb  : axi4mm_wstrb_t;
    last  : std_logic;
    valid : std_logic;
  end record;

  constant AXI4MM_MTS_WRITE_DATA_CHANNEL_DFLT_C: axi4mm_mts_write_data_channel_t := (
    data  => (others => '0'),
    strb  => (others => '1'),
    last  => '1',
    valid => '0'
    );

  type axi4mm_stm_write_data_channel_t is record
    ready: std_logic;
  end record;

  constant AXI4MM_STM_WRITE_DATA_CHANNEL_DFLT_C: axi4mm_stm_write_data_channel_t := (
    ready => '0'
    );

  type axi4mm_mts_bresp_channel_t is record
    ready: std_logic;
  end record;

  constant AXI4MM_MTS_BRESP_CHANNEL_DFLT_C: axi4mm_mts_bresp_channel_t := (
    ready => '0'
    );

  type axi4mm_stm_bresp_channel_t is record
    id    : axi4mm_id_t;
    resp  : axi4mm_resp_t;
    user  : axi4mm_user_t;
    valid : std_logic;
  end record;

  constant AXI4MM_STM_BRESP_CHANNEL_DFLT_C: axi4mm_stm_bresp_channel_t := (
    id    => (others => '0'),
    resp  => (others => '0'),
    user  => (others => '0'),
    valid => '0'
    );

  type axi4mm_mts_t is record
    r_addr : axi4mm_mts_addr_channel_t;
    r_data : axi4mm_mts_read_data_channel_t;
    w_addr : axi4mm_mts_addr_channel_t;
    w_data : axi4mm_mts_write_data_channel_t;
    b_resp : axi4mm_mts_bresp_channel_t;
  end record;
  type axi4mm_mts_array_t is array(integer range <>) of axi4mm_mts_t;

  constant AXI4MM_MTS_DFLT_C: axi4mm_mts_t := (
    r_addr => AXI4MM_MTS_ADDR_CHANNEL_DFLT_C,
    r_data => AXI4MM_MTS_READ_DATA_CHANNEL_DFLT_C,
    w_addr => AXI4MM_MTS_ADDR_CHANNEL_DFLT_C,
    w_data => AXI4MM_MTS_WRITE_DATA_CHANNEL_DFLT_C,
    b_resp => AXI4MM_MTS_BRESP_CHANNEL_DFLT_C
    );

  type axi4mm_stm_t is record
    r_addr: axi4mm_stm_addr_channel_t;
    r_data: axi4mm_stm_read_data_channel_t;
    w_addr: axi4mm_stm_addr_channel_t;
    w_data: axi4mm_stm_write_data_channel_t;
    b_resp: axi4mm_stm_bresp_channel_t;
  end record;
  type axi4mm_stm_array_t is array(integer range <>) of axi4mm_stm_t;

  constant AXI4MM_STM_DFLT_C: axi4mm_stm_t := (
    r_addr => AXI4MM_STM_ADDR_CHANNEL_DFLT_C,
    r_data => AXI4MM_STM_READ_DATA_CHANNEL_DFLT_C,
    w_addr => AXI4MM_STM_ADDR_CHANNEL_DFLT_C,
    w_data => AXI4MM_STM_WRITE_DATA_CHANNEL_DFLT_C,
    b_resp => AXI4MM_STM_BRESP_CHANNEL_DFLT_C
    );

  type axi4mm_bus_params_t is record
    awidth    : integer range 0 to AXI4MM_MAWIDTH_C;
    aruwidth  : integer range 0 to AXI4MM_MUWIDTH_C;
    awuwidth  : integer range 0 to AXI4MM_MUWIDTH_C;
    dwidth    : integer range 0 to AXI4MM_MDWIDTH_C;
    idwidth   : integer range 0 to AXI4MM_MIWIDTH_C;
  end record;

  constant AXI4MM_BUS_PARAMS_DFLT_C: axi4mm_bus_params_t := (
    awidth    => AXI4MM_MAWIDTH_C,
    aruwidth  => AXI4MM_MUWIDTH_C,
    awuwidth  => AXI4MM_MUWIDTH_C,
    dwidth    => AXI4MM_MDWIDTH_C,
    idwidth   => AXI4MM_MIWIDTH_C
  );

  function to_axi4mm_size_t(bwidth: integer) return axi4mm_size_t;

end package amba_pkg;

package body amba_pkg is

  function to_axi4mm_size_t(bwidth: integer) return axi4mm_size_t is
    constant l2c_bw: natural := log2c(bwidth);
  begin
    assert 2**l2c_bw = bwidth report "Error, AXI Bus Width must be a power of 2." severity FAILURE;
    return std_logic_vector(to_unsigned(l2c_bw-3, 3));
  end function;

end package body amba_pkg;
