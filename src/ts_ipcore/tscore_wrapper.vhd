--------------------------------------------------------------------------------
-- Copyright (c) 2020 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Maintainers:
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
    -- The FPGA family.
    FPGA_FAMILY_G      : mm_fpga_family_t := MM_FPGA_ULTRASCALEP;
    -- The system clock frequency.
    SYS_CLK_FREQ_G     : natural := 156;
    -- Whether the PPS input is inverted.
    PPS_IN_INVERTED_G  : boolean := true;
    -- Whether the GPIO input is inverted.
    GPIO_IN_INVERTED_G : boolean := true;
    -- Number of user-triggered timestampers.
    NUM_TS_TRIGGERS_G  : integer := 1
    );
  port (
    -- Timing Reference Sources
    refclk_user            : in  std_logic;
    refclk_ts              : in  std_logic;
    pps_in_gpio            : in  std_logic;
    pps_in                 : in  std_logic;
    --
    -- Timestamp Clock Selection
    -- '0' = from internal 156.25 MHz source
    -- '1' = from external 100 MHz source
    ts_clk_sel             : in  std_logic;
    --
    -- External Timestamp Clock Satus
    -- '1' = externally-derived timestamp clock is active
    ts_clk_active          : out std_logic;
    --
    -- Timestamp Control Register Interface
    reg_clk                : in  std_logic;
    reg_rst                : in  std_logic;
    ts_ctl_apply_init      : in  std_logic;
    ts_ctl_apply_init_src  : in  std_logic_vector(2 downto 0);
    ts_ctl_init_val_ts     : in  std_logic_vector(63 downto 0);
    ts_ctl_init_val_ns     : in  std_logic_vector(63 downto 0);
    ts_ctl_apply_add_skip  : in  std_logic;
    ts_ctl_add_skipn       : in  std_logic;
    ts_ctl_add_skip_period : in  std_logic_vector(31 downto 0);
    --
    -- PPS Timestamp Results Register Interface
    -- bit 0 = pps_in_gpio
    -- bit 1 = pps_in
    -- Results will be synchonised into `reg_clk` domain.
    ts_result_vld          : out std_logic_vector(1 downto 0);
    ts_result              : out slv64_array_t(1 downto 0);
    ts_add_skip_inc        : out std_logic_vector(1 downto 0);
    --
    -- User Timestamp Trigger
    -- User's trigger will be synchronised into the `ts_clk` domain.
    trigger                : in  std_logic_vector(NUM_TS_TRIGGERS_G-1 downto 0);
    --
    -- User Timestamp Results Interface
    -- User timestamp results will be synchronised into the `reg_clk` domain.
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
      FPGA_FAMILY_G           => FPGA_FAMILY_G,
      SYS_CLK_FREQ_G          => SYS_CLK_FREQ_G,
      PPS_IN_INVERTED_G       => PPS_IN_INVERTED_G,
      GPIO_IN_INVERTED_G      => GPIO_IN_INVERTED_G,
      NUM_USER_TIMESTAMPERS_G => NUM_TS_TRIGGERS_G
      )
    port map (
      refclk_user            => refclk_user,
      refclk_ts              => refclk_ts,
      pps_in_gpio            => pps_in_gpio,
      pps_in                 => pps_in,
      --
      ts_clk_sel             => ts_clk_sel,
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
      pps_ts_result_vlds     => ts_result_vld,
      pps_ts_results         => ts_result,
      pps_ts_add_skip_incs   => ts_add_skip_inc,
      --
      user_ts_triggers       => trigger,
      user_ts_result_clks    => (others => reg_clk),
      user_ts_result_vlds    => trig_timestamp_vld,
      user_ts_results        => trig_timestamp
      );

end architecture structural;
