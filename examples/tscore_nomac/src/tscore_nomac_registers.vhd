--------------------------------------------------------------------------------
-- Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Author:
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
    PROJECT_NAME_G : string;
    NUM_PORTS_G    : natural := 1
    );
  port (
    reg_clk   : in  std_logic;
    reg_avld  : in  std_logic;
    reg_addr  : in  std_logic_vector(15 downto 0);
    reg_rvld  : out std_logic;
    reg_rdata : out std_logic_vector(31 downto 0);
    reg_wvld  : in  std_logic;
    reg_wdata : in  std_logic_vector(31 downto 0);

    -- Status
    fpga_id                : in  std_logic_vector(2 downto 0);

    -- Time Stamp Control & Results
    ts_clk_sel             : out std_logic;
    ts_clk_active          : in  std_logic;

    ts_ctl_apply_init      : out std_logic;
    ts_ctl_apply_init_src  : out std_logic_vector(2 downto 0);
    ts_ctl_init_val_ns     : out std_logic_vector(63 downto 0);
    ts_ctl_init_val_ts     : out std_logic_vector(63 downto 0);
    ts_ctl_apply_add_skip  : out std_logic;
    ts_ctl_add_skipn       : out std_logic;
    ts_ctl_add_skip_period : out std_logic_vector(31 downto 0);

    ts_add_skip_inc        : in  std_logic_vector(1 downto 0);
    ts_result_vld          : in  std_logic_vector(1 downto 0);
    ts_result              : in  slv64_array_t(1 downto 0);

    trigger                : out std_logic_vector(0 downto 0);
    trig_timestamp_vld     : in  std_logic_vector(NUM_PORTS_G-1 downto 0);
    trig_timestamp         : in  slv64_array_t(NUM_PORTS_G-1 downto 0)
    );
end entity tscore_nomac_registers;

architecture rtl of tscore_nomac_registers is

  --------------------------------------------------------------------------------
  -- Address Decode
  --------------------------------------------------------------------------------
  constant TRIGGER_C       : integer := 5;
  constant GENERAL_CFG_C   : integer := TRIGGER_C+1;
  constant TS_CTLLOW_C     : integer := GENERAL_CFG_C+1;
  constant TS_CTLHGH_C     : integer := TS_CTLLOW_C+9-1;
  constant TS_STS_C        : integer := TS_CTLHGH_C+1;
  constant TS_RSLTLOW_C    : integer := TS_STS_C+1;
  constant TS_RSLTHGH_C    : integer := TS_RSLTLOW_C-1+
                                      3*(2+NUM_PORTS_G);

  --------------------------------------------------------------------------------
  -- Signal Declarations
  --------------------------------------------------------------------------------
  signal reg_address       : unsigned(15 downto 0);
  signal reg_wvld_r        : std_logic;
  signal reg_wdata_r       : std_logic_vector(31 downto 0);

  signal general_cfg       : std_logic_vector(31 downto 0) := (others => '0');

  signal ts_ctl            : slv32_array_t(TS_CTLHGH_C downto TS_CTLLOW_C) := (TS_CTLLOW_C => x"00000001", others => (others => '0'));
  signal ts_sts            : std_logic_vector(31 downto 0) := (others => '0');
  signal ts_rslts          : slv32_array_t(TS_RSLTHGH_C downto TS_RSLTLOW_C) := (others => (others => '0'));

  signal ts_add_skip_cnt   : u32_array_t(1 downto 0) := (others => (others => '0'));
  signal ts_rslt           : slv64_array_t(1 downto 0) := (others => (others => '0'));
  signal ts_trig_timestamp : slv64_array_t(NUM_PORTS_G-1 downto 0) := (others => (others => '0'));

begin

  --------------------------------------------------------------------------------
  -- Register Controller
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
      trigger <= "0";

      reg_rvld  <= '1';
      reg_rdata <= (others => '0');
      case to_integer(reg_address) is
        when 0 => reg_rdata <= str_chunk(PROJECT_NAME_G, 1, 4);
        when 1 => reg_rdata <= str_chunk(PROJECT_NAME_G, 5, 4);
        when 2 => reg_rdata <= str_chunk(PROJECT_NAME_G, 9, 4);
        when 3 => reg_rdata <= str_chunk(PROJECT_NAME_G, 13, 4);
        when 4 => reg_rdata(2 downto 0) <= fpga_id;

        when TRIGGER_C =>                                             -- Trigger
          if reg_wvld_r = '1' then
            trigger <= "1";
          end if;

        when GENERAL_CFG_C =>                                       -- General Configuration
          reg_rdata <= general_cfg;
          if reg_wvld_r = '1' then
            general_cfg <= reg_wdata_r;
          end if;

        when TS_CTLLOW_C to TS_CTLHGH_C =>                          -- Timestamp Control
          reg_rdata <= ts_ctl(to_integer(reg_address));
          if reg_wvld_r = '1' then
            ts_ctl(to_integer(reg_address)) <= reg_wdata_r;
          end if;

        when TS_STS_C =>                                            -- Timestamp Status
          reg_rdata <= ts_sts;

        when TS_RSLTLOW_C to TS_RSLTHGH_C =>                        -- Timestamp Results
          reg_rdata <= ts_rslts(to_integer(reg_address));

        when others => null;
      end case;
    end if;
  end process;

  --------------------------------------------------------------------------------
  -- Register Decode

  -- TS Registers
  ts_clk_sel                       <= ts_ctl(TS_CTLLOW_C)(0);                --ts/time_sync/control,ctl,1
  ts_ctl_apply_init                <= ts_ctl(TS_CTLLOW_C+1)(0);              --ts/chron/apply_initval,ctl,1
  ts_ctl_apply_init_src            <= ts_ctl(TS_CTLLOW_C+1)(3 downto 1);     --ts/chron/apply_initval,ctl,3
  ts_ctl_init_val_ns(31 downto 0)  <= ts_ctl(TS_CTLLOW_C+2);                 --ts/chron/initval_low,ctl,32
  ts_ctl_init_val_ns(63 downto 32) <= ts_ctl(TS_CTLLOW_C+3);                 --ts/chron/initval_high,ctl,32
  ts_ctl_init_val_ts(31 downto 0)  <= ts_ctl(TS_CTLLOW_C+4);                 --ts/chron/initval_ns,ctl,32
  ts_ctl_init_val_ts(63 downto 32) <= ts_ctl(TS_CTLLOW_C+5);                 --ts/chron/initval_s,ctl,32
  ts_ctl_apply_add_skip            <= ts_ctl(TS_CTLLOW_C+6)(0);              --ts/chron/apply_add_skip_period,ctl,1
  ts_ctl_add_skipn                 <= ts_ctl(TS_CTLLOW_C+7)(0);              --ts/chron/add_skipn,ctl,1
  ts_ctl_add_skip_period           <= ts_ctl(TS_CTLLOW_C+8);                 --ts/chron/add_skip_period,ctl,32

  ts_sts(0)                        <= ts_clk_active;                         --ts/time_sync/status,sts,false,1

  ts_rslts(TS_RSLTLOW_C)           <= std_logic_vector(ts_add_skip_cnt(0));  --ts/host_gpio/add_skip_count,counter,32
  ts_rslts(TS_RSLTLOW_C+1)         <= ts_rslt(0)(31 downto 0);               --ts/host_gpio/timestamp_low/high,sts,32
  ts_rslts(TS_RSLTLOW_C+2)         <= ts_rslt(0)(63 downto 32);
  
  ts_rslts(TS_RSLTLOW_C+3)         <= std_logic_vector(ts_add_skip_cnt(1));  --ts/spartan_pps/add_skip_count,counter,32
  ts_rslts(TS_RSLTLOW_C+4)         <= ts_rslt(1)(31 downto 0);               --ts/spartan_pps/timestamp_low/high,sts,32
  ts_rslts(TS_RSLTLOW_C+5)         <= ts_rslt(1)(63 downto 32);

  ts_rslts(TS_RSLTLOW_C+3)         <= std_logic_vector(ts_add_skip_cnt(1));  --ts/spartan_pps/add_skip_count,counter,32
  ts_rslts(TS_RSLTLOW_C+4)         <= ts_rslt(1)(31 downto 0);               --ts/spartan_pps/timestamp_low/high,sts,32
  ts_rslts(TS_RSLTLOW_C+5)         <= ts_rslt(1)(63 downto 32);

  ts_rslts(TS_RSLTLOW_C+6)         <= (others => '0');
  ts_rslts(TS_RSLTLOW_C+7)         <= ts_trig_timestamp(0)(31 downto 0);     --example_ts_0/high,sts,32 x NUM_PORTS_G
  ts_rslts(TS_RSLTLOW_C+8)         <= ts_trig_timestamp(0)(63 downto 32);

  --------------------------------------------------------------------------------
  -- Timestamp Registers
  gen_timestamp            : for i in 0 to 1 generate
    process (reg_clk)
    begin
      if rising_edge(reg_clk) then
        if ts_add_skip_inc(i) = '1' then
          ts_add_skip_cnt(i) <= ts_add_skip_cnt(i) + 1;
        end if;
        if ts_result_vld(i) = '1' then
          ts_rslt(i) <= ts_result(i);
        end if;
      end if;
    end process;
  end generate;

  gen_timestamp_rxsof : for i in 0 to NUM_PORTS_G-1 generate
    process (reg_clk)
    begin
      if rising_edge(reg_clk) then
        if trig_timestamp_vld(i) = '1' then
          ts_trig_timestamp(i) <= trig_timestamp(i);
        end if;
      end if;
    end process;
  end generate;

end architecture rtl;
