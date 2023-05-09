--------------------------------------------------------------------------------
-- Copyright (c) 2020 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Author:
--   fdk-support@arista.com
--
-- Description:
--   This is the Timestamping IP Core Wrapper
--
-- Tags:
--   noencrypt
--   license-arista-fdk-agreement
--   license-bsd-3-clause
--
--------------------------------------------------------------------------------

library ieee;                    --NODOCS
use ieee.std_logic_1164.all;     --NODOCS
use ieee.numeric_std.all;        --NODOCS

library work;
use work.metamako_pkg.all;
use work.fpga_spec_pkg.all;
use work.metachron_pkg.all;

entity tscore_wrapper is
  generic (
    FPGA_FAMILY_G      : mm_fpga_family_t := MM_FPGA_ULTRASCALEP;
    SYS_CLK_FREQ_G     : natural := 156;
    PPS_IN_INVERTED_G  : boolean := true;
    GPIO_IN_INVERTED_G : boolean := true;

    NUM_TS_TRIGGERS_G  : integer := 1
    );
  port (
    -- Timing Reference Sources
    refclk_user            : in  std_logic;
    refclk_ts              : in  std_logic;
    pps_in_gpio            : in  std_logic;
    pps_in                 : in  std_logic;

    -- Register interface
    reg_clk                : in  std_logic;
    reg_rst                : in  std_logic;
    ts_clk_sel             : in  std_logic;
    ts_clk_active          : out std_logic;
    ts_ctl_apply_init      : in  std_logic;
    ts_ctl_apply_init_src  : in  std_logic_vector(2 downto 0);
    ts_ctl_init_val_ns     : in  std_logic_vector(63 downto 0);
    ts_ctl_init_val_ts     : in  std_logic_vector(63 downto 0);
    ts_ctl_apply_add_skip  : in  std_logic;
    ts_ctl_add_skipn       : in  std_logic;
    ts_ctl_add_skip_period : in  std_logic_vector(31 downto 0);
    ts_add_skip_inc        : out std_logic_vector(1 downto 0);
    ts_result_vld          : out std_logic_vector(1 downto 0);
    ts_result              : out slv64_array_t(1 downto 0);

    -- TS Trigger Interface
    trigger                : in  std_logic_vector(NUM_TS_TRIGGERS_G-1 downto 0);
    trig_timestamp_vld     : out std_logic_vector(NUM_TS_TRIGGERS_G-1 downto 0);
    trig_timestamp         : out slv64_array_t(NUM_TS_TRIGGERS_G-1 downto 0)
    );
end entity tscore_wrapper;

architecture structural of tscore_wrapper is
begin

  --------------------------------------------------------------------------------
  -- Instantiate the `tscore` IP core with the results made available to the
  -- register file.
  --------------------------------------------------------------------------------

  tscore_i : entity work.tscore
    generic map (
      FPGA_FAMILY_G      => FPGA_FAMILY_G,
      SYS_CLK_FREQ_G     => SYS_CLK_FREQ_G,
      PPS_IN_INVERTED_G  => PPS_IN_INVERTED_G,
      GPIO_IN_INVERTED_G => GPIO_IN_INVERTED_G,
      NUM_TS_TRIGGERS_G  => NUM_TS_TRIGGERS_G
      )
    port map (
      refclk_user            => refclk_user,
      refclk_ts              => refclk_ts,
      pps_in_gpio            => pps_in_gpio,
      pps_in                 => pps_in,
      --
      ts_clk_sel             => ts_clk_sel,
      --
      ts_clk_active          => ts_clk_active,
      --
      reg_clk                => reg_clk,
      reg_rst                => reg_rst,
      ts_ctl_apply_init      => ts_ctl_apply_init,
      ts_ctl_apply_init_src  => ts_ctl_apply_init_src,
      ts_ctl_init_val_ts     => ts_ctl_init_val_ts,
      ts_ctl_init_val_ns     => ts_ctl_init_val_ns,
      ts_ctl_apply_add_skip  => ts_ctl_apply_add_skip,
      ts_ctl_add_skipn       => ts_ctl_add_skipn,
      ts_ctl_add_skip_period => ts_ctl_add_skip_period,
      --
      ts_result_vld          => ts_result_vld,
      ts_result              => ts_result,
      ts_add_skip_inc        => ts_add_skip_inc,
      --
      trigger                => trigger,
      --
      trig_timestamp_clks    => (others => reg_clk),
      trig_timestamp_vld     => trig_timestamp_vld,
      trig_timestamp         => trig_timestamp
      );

end architecture structural;
