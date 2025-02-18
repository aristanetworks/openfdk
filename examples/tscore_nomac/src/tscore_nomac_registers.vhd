--------------------------------------------------------------------------------
-- Copyright (c) 2021 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Maintainers:
--   fdk-support@arista.com
--
-- Description:
--   Example register file for TS Core.
--
--   Licensed under BSD 3-clause license:
--     https://opensource.org/licenses/BSD-3-Clause
--
-- Tags:
--   noencrypt
--   license-bsd-3-clause
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.metamako_pkg.all;

entity tscore_nomac_registers is
  generic (
    PROJECT_NAME_G          : string;
    NUM_USER_TIMESTAMPERS_G : positive := 1
    );
  port (
    -- Register interface
    reg_clk                : in  std_logic;
    reg_avld               : in  std_logic;
    reg_addr               : in  std_logic_vector(15 downto 0);
    reg_rvld               : out std_logic;
    reg_rdata              : out std_logic_vector(31 downto 0);
    reg_wvld               : in  std_logic;
    reg_wdata              : in  std_logic_vector(31 downto 0);
    --
    -- FPGA ID
    fpga_id                : in  std_logic_vector(2 downto 0);
    --
    -- Timestamp clock selection
    ts_clk_sel             : out std_logic;
    ts_clk_active          : in  std_logic;
    --
    -- Timestamp control interface
    ts_ctl_apply_init      : out std_logic;
    ts_ctl_apply_init_src  : out std_logic_vector(2 downto 0);
    ts_ctl_init_val_ts     : out std_logic_vector(63 downto 0);
    ts_ctl_init_val_ns     : out std_logic_vector(63 downto 0);
    ts_ctl_apply_add_skip  : out std_logic;
    ts_ctl_add_skipn       : out std_logic;
    ts_ctl_add_skip_period : out std_logic_vector(31 downto 0);
    --
    -- PPS timestamp interface
    pps_ts_result_vlds     : in  std_logic_vector(1 downto 0);
    pps_ts_results         : in  slv64_array_t(1 downto 0);
    pps_ts_add_skip_incs   : in  std_logic_vector(1 downto 0);
    --
    -- User's timestamp trigger
    user_ts_triggers       : out std_logic_vector(NUM_USER_TIMESTAMPERS_G - 1 downto 0) := (others => '0');
    --
    -- User-triggered timestamp result interface
    user_ts_result_vlds    : in  std_logic_vector(NUM_USER_TIMESTAMPERS_G - 1 downto 0);
    user_ts_results        : in  slv64_array_t(NUM_USER_TIMESTAMPERS_G - 1 downto 0)
    );
end entity tscore_nomac_registers;

architecture rtl of tscore_nomac_registers is

  --------------------------------------------------------------------------------
  -- Address Decode
  --------------------------------------------------------------------------------

  constant TRIGGER_C     : natural := 5;
  constant GENERAL_CFG_C : natural := TRIGGER_C + 1;

  -- Timestamp control
  constant TS_CTL_NUM_REGS_C : natural := 9;
  constant TS_CTL_LO_C       : natural := GENERAL_CFG_C + 1;
  constant TS_CTL_HI_C       : natural := TS_CTL_LO_C + TS_CTL_NUM_REGS_C - 1;

  -- Time sync status
  constant TIME_SYNC_STATUS_C : natural := TS_CTL_HI_C + 1;

  -- Timestamp results
  -- Number of timestampers is 2 (for PPS) plus NUM_USER_TIMESTAMPERS_G
  constant TS_RESULTS_NUM_REGS_C : natural := 3;
  constant TS_RESULTS_LO_C       : natural := TIME_SYNC_STATUS_C + 1;
  constant TS_RESULTS_HI_C       : natural := TS_RESULTS_LO_C + TS_RESULTS_NUM_REGS_C * (2 + NUM_USER_TIMESTAMPERS_G) - 1;

  --------------------------------------------------------------------------------
  -- Signal Declarations
  --------------------------------------------------------------------------------

  -- Register interface
  signal reg_address : unsigned(15 downto 0);
  signal reg_wvld_r  : std_logic;
  signal reg_wdata_r : std_logic_vector(31 downto 0);

  -- General configuration register
  signal general_cfg : std_logic_vector(31 downto 0) := (others => '0');

  -- Timestamp control and status registers
  signal ts_ctl : slv32_array_t(TS_CTL_HI_C downto TS_CTL_LO_C) := (TS_CTL_LO_C => x"00000001", others => (others => '0'));

  -- Time sync status register
  signal ts_stat : std_logic_vector(31 downto 0) := (others => '0');

  -- PPS timestamp results and status
  signal pps_ts_result_regs    : slv64_array_t(1 downto 0) := (others => (others => '0'));
  signal pps_ts_add_skip_cntrs : u32_array_t(1 downto 0)   := (others => (others => '0'));

  -- User timestamp results
  signal user_ts_result_regs : slv64_array_t(NUM_USER_TIMESTAMPERS_G - 1 downto 0) := (others => (others => '0'));

  -- Linear mapping of the timestamp result registers for ease of access
  signal ts_result_regs : slv32_array_t(TS_RESULTS_HI_C downto TS_RESULTS_LO_C) := (others => (others => '0'));

begin

  --------------------------------------------------------------------------------
  -- Register Controller
  --------------------------------------------------------------------------------

  process (reg_clk)
  begin
    if rising_edge(reg_clk) then
      if reg_avld = '1' then -- update local register address
        reg_address <= unsigned(reg_addr);
      end if;

      -- Delay one cycle to match reg_address...
      reg_wvld_r  <= reg_wvld;
      reg_wdata_r <= reg_wdata;

      -- Defaults...
      user_ts_triggers <= (others => '0');

      reg_rvld  <= '1';
      reg_rdata <= (others => '0');
      case to_integer(reg_address) is
        when 0 => reg_rdata <= str_chunk(PROJECT_NAME_G,  1, 4);
        when 1 => reg_rdata <= str_chunk(PROJECT_NAME_G,  5, 4);
        when 2 => reg_rdata <= str_chunk(PROJECT_NAME_G,  9, 4);
        when 3 => reg_rdata <= str_chunk(PROJECT_NAME_G, 13, 4);
        when 4 => reg_rdata(2 downto 0) <= fpga_id;

        -- User triggers
        -- Note: We have only implemented 1 trigger here, regardless of
        -- the value of `NUM_USER_TIMESTAMPERS_G` with the expectation
        -- that a user will know how to expand to more triggers depending
        -- on their application requirements.
        when TRIGGER_C =>
          if reg_wvld_r = '1' then
            user_ts_triggers(0) <= '1';
          end if;

        -- General Configuration
        when GENERAL_CFG_C =>
          reg_rdata <= general_cfg;
          if reg_wvld_r = '1' then
            general_cfg <= reg_wdata_r;
          end if;

        -- Timestamp Control
        when TS_CTL_LO_C to TS_CTL_HI_C =>
          reg_rdata <= ts_ctl(to_integer(reg_address));
          if reg_wvld_r = '1' then
            ts_ctl(to_integer(reg_address)) <= reg_wdata_r;
          end if;

        -- Times Sync Status
        when TIME_SYNC_STATUS_C =>
          reg_rdata <= ts_stat;

        -- Timestamp Results
        when TS_RESULTS_LO_C to TS_RESULTS_HI_C =>
          reg_rdata <= ts_result_regs(to_integer(reg_address));

        when others =>
          null;
      end case;
    end if;
  end process;

  --------------------------------------------------------------------------------
  -- Register Decode
  --------------------------------------------------------------------------------

  -- Timestamp Control Registers
  ts_clk_sel                       <= ts_ctl(TS_CTL_LO_C + 0)(0);          -- ts/time_sync/control,ctl,1
  ts_ctl_apply_init                <= ts_ctl(TS_CTL_LO_C + 1)(0);          -- ts/chron/apply_initval,ctl,1
  ts_ctl_apply_init_src            <= ts_ctl(TS_CTL_LO_C + 1)(3 downto 1); -- ts/chron/apply_initval,ctl,3
  ts_ctl_init_val_ns(31 downto 0)  <= ts_ctl(TS_CTL_LO_C + 2);             -- ts/chron/initval_low,ctl,32
  ts_ctl_init_val_ns(63 downto 32) <= ts_ctl(TS_CTL_LO_C + 3);             -- ts/chron/initval_high,ctl,32
  ts_ctl_init_val_ts(31 downto 0)  <= ts_ctl(TS_CTL_LO_C + 4);             -- ts/chron/initval_ns,ctl,32
  ts_ctl_init_val_ts(63 downto 32) <= ts_ctl(TS_CTL_LO_C + 5);             -- ts/chron/initval_s,ctl,32
  ts_ctl_apply_add_skip            <= ts_ctl(TS_CTL_LO_C + 6)(0);          -- ts/chron/apply_add_skip_period,ctl,1
  ts_ctl_add_skipn                 <= ts_ctl(TS_CTL_LO_C + 7)(0);          -- ts/chron/add_skipn,ctl,1
  ts_ctl_add_skip_period           <= ts_ctl(TS_CTL_LO_C + 8);             -- ts/chron/add_skip_period,ctl,32

  -- Timestamp Status Register
  ts_stat(0) <= ts_clk_active;                                             -- ts/time_sync/status,sts,false,1

  -- PPS Timestamp results
  ts_result_regs(TS_RESULTS_LO_C)     <= std_logic_vector(pps_ts_add_skip_cntrs(0)); -- ts/host_gpio/add_skip_count,counter,32
  ts_result_regs(TS_RESULTS_LO_C + 1) <= pps_ts_result_regs(0)(31 downto 0);         -- ts/host_gpio/timestamp_low,sts,32
  ts_result_regs(TS_RESULTS_LO_C + 2) <= pps_ts_result_regs(0)(63 downto 32);        -- ts/host_gpio/timestamp_high,sts,32

  ts_result_regs(TS_RESULTS_LO_C + 3) <= std_logic_vector(pps_ts_add_skip_cntrs(1)); -- ts/spartan_pps/add_skip_count,counter,32
  ts_result_regs(TS_RESULTS_LO_C + 4) <= pps_ts_result_regs(1)(31 downto 0);         -- ts/spartan_pps/timestamp_low,sts,32
  ts_result_regs(TS_RESULTS_LO_C + 5) <= pps_ts_result_regs(1)(63 downto 32);        -- ts/spartan_pps/timestamp_high,sts,32

  -- User Timestamp results
  g_user_results : for i in 0 to NUM_USER_TIMESTAMPERS_G - 1 generate
    -- example_ts_i/add_skip_count,counter,32
    ts_result_regs(TS_RESULTS_LO_C + 6 + TS_RESULTS_NUM_REGS_C * i) <= (others => '0');
    -- example_ts_i/timestamp_low,sts,32
    ts_result_regs(TS_RESULTS_LO_C + 7 + TS_RESULTS_NUM_REGS_C * i) <= user_ts_results(i)(31 downto 0);
    -- example_ts_i/timestamp_high,sts,32
    ts_result_regs(TS_RESULTS_LO_C + 8 + TS_RESULTS_NUM_REGS_C * i) <= user_ts_results(i)(63 downto 32);
  end generate g_user_results;

  --------------------------------------------------------------------------------
  -- Timestamp Registers
  --------------------------------------------------------------------------------

  -- PPS timestampers
  g_pps_regs : for i in 0 to 1 generate

    process (reg_clk)
    begin
      if rising_edge(reg_clk) then
        if pps_ts_add_skip_incs(i) = '1' then
          pps_ts_add_skip_cntrs(i) <= pps_ts_add_skip_cntrs(i) + 1;
        end if;
        if pps_ts_result_vlds(i) = '1' then
          pps_ts_result_regs(i) <= pps_ts_results(i);
        end if;
      end if;
    end process;

  end generate g_pps_regs;

  -- User-triggered timestampers
  g_user_regs : for i in 0 to NUM_USER_TIMESTAMPERS_G - 1 generate

    process (reg_clk)
    begin
      if rising_edge(reg_clk) then
        if user_ts_result_vlds(i) = '1' then
          user_ts_result_regs(i) <= user_ts_results(i);
        end if;
      end if;
    end process;

  end generate g_user_regs;

end architecture rtl;
