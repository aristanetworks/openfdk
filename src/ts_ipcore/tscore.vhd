--------------------------------------------------------------------------------
-- Copyright (c) 2023 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Author:
--   fdk-support@arista.com
--
-- Description:
--   This entity is the FDK Timestamping IP Core.
--   It instantiates all the necessary entities to provide:
--   - timestamp clock (500 MHz) generation
--   - PPS timestamps (available from the register file)
--   - any number of user-triggered timestamps, the results of which are
--     available to the user in a user-provided clock domain
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

library work;
use work.metamako_pkg.all;
use work.fpga_spec_pkg.all;
use work.metachron_pkg.all;

entity tscore is
  generic (
    -- The FPGA family.
    FPGA_FAMILY_G      : mm_fpga_family_t := MM_FPGA_ULTRASCALEP;
    -- The system clock frequency.
    SYS_CLK_FREQ_G     : natural          := 156;
    -- Whether the PPS input is inverted.
    PPS_IN_INVERTED_G  : boolean          := true;
    -- Whether the GPIO input is inverted.
    GPIO_IN_INVERTED_G : boolean          := true;
    -- Number of user-triggered timestampers.
    NUM_TS_TRIGGERS_G  : natural          := 1
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
    trigger                : in std_logic_vector(NUM_TS_TRIGGERS_G - 1 downto 0) := (others => '0');
    -- User Timestamp Results Interface
    -- User timestamp results will be synchronised into the `trig_timestamp_clks` domain.
    trig_timestamp_clks    : in std_logic_vector(NUM_TS_TRIGGERS_G - 1 downto 0) := (others => '0');
    trig_timestamp_vld     : out std_logic_vector(NUM_TS_TRIGGERS_G - 1 downto 0);
    trig_timestamp         : out slv64_array_t(NUM_TS_TRIGGERS_G - 1 downto 0)
    );
end entity tscore;

architecture rtl of tscore is

  signal timestamp_clk : std_logic;
  signal cntr_signals  : metachron_counter_control_t;

begin

  --------------------------------------------------------------------------------
  -- Time Synchronisation
  --------------------------------------------------------------------------------

  timing_controller_i : entity work.timing_controller
    generic map (
      FPGA_FAMILY_G      => FPGA_FAMILY_G,
      SYS_CLK_FREQ_G     => SYS_CLK_FREQ_G,
      PPS_IN_INVERTED_G  => PPS_IN_INVERTED_G,
      GPIO_IN_INVERTED_G => GPIO_IN_INVERTED_G
      )
    port map (
      sys_clk              => refclk_user,
      ts_ref_clk           => refclk_ts,
      pps_in_gpio          => pps_in_gpio,
      pps_in               => pps_in,
      --
      ts_clk_sel           => ts_clk_sel,
      ts_clk_active        => ts_clk_active,
      --
      -- Timestamp clock output
      ts_clk               => timestamp_clk,
      --
      reg_clk              => reg_clk,
      reg_rst              => reg_rst,
      ctlr_apply_init      => ts_ctl_apply_init,
      ctlr_apply_init_src  => ts_ctl_apply_init_src,
      ctlr_init_val_ts     => ts_ctl_init_val_ts,
      ctlr_init_val_ns     => ts_ctl_init_val_ns,
      ctlr_apply_add_skip  => ts_ctl_apply_add_skip,
      ctlr_add_skipn       => ts_ctl_add_skipn,
      ctlr_add_skip_period => ts_ctl_add_skip_period,
      --
      ts_result_vld        => ts_result_vld,
      ts_result            => ts_result,
      ts_add_skip_inc      => ts_add_skip_inc,
      -- Counter control output
      cntr_signals         => cntr_signals
      );

  --------------------------------------------------------------------------------
  -- Timestamp Generation
  --------------------------------------------------------------------------------

  gen_timestampers : for i in 0 to NUM_TS_TRIGGERS_G - 1 generate

    timestamper_i : entity work.timestamper
      port map (
        reg_clk      => reg_clk,
        reg_rst      => reg_rst,
        -- Timestamp clock input
        ts_clk       => timestamp_clk,
        -- Counter control input - uses `reg_clk` and `ts_clk`
        cntr_signals => cntr_signals,
        -- Trigger will be synchronised into `ts_clk` domain.
        trigger      => trigger(i),
        trigger_out  => open,
        -- Timestamp results will be synchronised into the `trig_timestamp_clks` domain.
        result_vld   => trig_timestamp_vld(i),
        result       => trig_timestamp(i),
        --
        result_clk   => trig_timestamp_clks(i)
        );

  end generate;

end architecture rtl;
