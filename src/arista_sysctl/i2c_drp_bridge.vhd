--------------------------------------------------------------------------------
-- Copyright (c) 2017-2022 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Author:
--   fdk-support@arista.com
--
-- Description:
--   This translates I2C to DRP
--   Add parameter for I2C DEGLITCH
--
--   21 Dec 2022 - Added internal temperature monitoring
--   This module is tested by tb_arista_sysctl_v2
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
use work.fpga_spec_pkg.all;

entity i2c_drp_bridge is
    generic (
      STABLE_PULSE_CLKS_G : natural := 50;
      DEGLITCH_EN_G       : boolean := false;
      FPGA_POSITION_G     : mm_fpga_position_t := MM_FPGA_POSITION_CENTRAL;
      I2C_BASE_ADDR_0_G   : std_logic_vector(6 downto 0) := "1010101";
      I2C_BASE_ADDR_1_G   : std_logic_vector(6 downto 0) := "1010110";
      ENABLE_TEMPRD_G     : boolean := false
      );
    port (
      clk           : in  std_logic;
      rst           : in  std_logic;

      fpga_id       : out std_logic_vector(2 downto 0);
      init_complete : out std_logic;
      temperature   : out std_logic_vector(9 downto 0);

      -- I2C Bus interface
      scl_in        : in  std_logic;
      scl_low_n     : out std_logic;
      sda_in        : in  std_logic;
      sda_low_n     : out std_logic;

      -- DRP Interface
      sysmon_eos    : in  std_logic;
      drp_en        : out std_logic;
      drp_wen       : out std_logic;
      drp_addr      : out std_logic_vector(7 downto 0);
      drp_di        : out std_logic_vector(15 downto 0);
      drp_drdy      : in  std_logic;
      drp_do        : in  std_logic_vector(15 downto 0)
      );
end entity i2c_drp_bridge;

architecture rtl of i2c_drp_bridge is

  ------------------------------------------------------------------------------
  -- Definitions and Declarations
  ------------------------------------------------------------------------------
  type protocol_state_t is (RX_REG_s,
                            RX_LOW_s,
                            RX_HIGH_s,
                            TX_LOW_s,
                            TX_HIGH_s,
                            IDLE_s);

  type drp_state_t is (RD_TEMP_s,
                       RD_DRP_s,
                       IDLE_s,
                       INIT_s);

  -- Temperature Sampling Reference
  constant TEMP_TIMER_C     : integer := integer(25.0*1.0E6 * 2.0); -- 2s
  constant TEMP_CNT_WIDTH_C : integer := log2c(TEMP_TIMER_C)+1;

  ------------------------------------------------------------------------------
  -- Signal Declarations
  ------------------------------------------------------------------------------
  signal start          : std_logic;
  signal stop           : std_logic;
  signal ack            : std_logic;
  signal rx_byte        : std_logic_vector(7 downto 0);

  signal start_d        : std_logic;
  signal stop_d         : std_logic;
  signal ack_d          : std_logic;
  signal start_re       : std_logic;
  signal stop_re        : std_logic;
  signal ack_re         : std_logic;
  signal ack_fe         : std_logic;

  signal protocol_state : protocol_state_t := IDLE_s;
  signal rwn            : std_logic;
  signal reg_val        : std_logic;
  signal reg            : std_logic_vector(7 downto 0);
  signal rxd_val        : std_logic_vector(1 downto 0);
  signal rx_data        : std_logic_vector(15 downto 0);
  signal tx_data        : std_logic_vector(15 downto 0) := "1001011010100111";
  signal tx_byte        : std_logic_vector(7 downto 0);

  signal drp_rd_req     : std_logic := '0';
  signal drp_s          : drp_state_t;
  signal drp_s_d        : drp_state_t;
  signal fpga_ab        : std_logic := '0';
  signal i2c_base_addr  : i2c_addr_t;
  signal temp_stb       : std_logic := '0';
  signal temp_count     : unsigned(TEMP_CNT_WIDTH_C-1 downto 0) := (others => '0');





begin

  ------------------------------------------------------------------------------
  -- I2C Slave
  i2c_slave : entity work.i2c_base_slave
    generic map(
      STABLE_PULSE_CLKS_G => STABLE_PULSE_CLKS_G,
      DEGLITCH_EN_G       => DEGLITCH_EN_G
      )
    port map (
      sample_clk => clk,
      base_addr  => i2c_base_addr,

      scl_in     => scl_in,
      scl_low_n  => scl_low_n,
      sda_in     => sda_in,
      sda_low_n  => sda_low_n,

      start      => start,
      stop       => stop,
      ack        => ack,
      rx_data    => rx_byte,
      tx_data    => tx_byte
      );

  ------------------------------------------------------------------------------
  -- Protocol State Machine
  process (clk)
  begin
    if rising_edge(clk) then
      start_d  <= start;
      stop_d   <= stop;
      ack_d    <= ack;
      start_re <= start and not start_d;
      stop_re  <= stop and not stop_d;
      ack_re   <= ack and not ack_d;
      ack_fe   <= not ack and ack_d;

      case protocol_state is
        when RX_REG_s =>
          if ack_re = '1' then
            reg_val <= '1';
            reg     <= rx_byte;
            protocol_state <= RX_LOW_s;
          end if;

        when RX_LOW_s =>
          if ack_re = '1' then
            rxd_val(0) <= '1';
            rx_data(7 downto 0) <= rx_byte;
            protocol_state <= RX_HIGH_s;
          end if;

        when RX_HIGH_s =>
          if ack_re = '1' then
            rxd_val(1) <= '1';
            rx_data(15 downto 8) <= rx_byte;
            protocol_state <= IDLE_s;
          end if;

        when TX_LOW_s =>
          if ack_fe = '1' then
            tx_byte <= tx_data(15 downto 8);
          end if;
          if ack_re = '1' then
            protocol_state <= TX_HIGH_s;
          end if;

        when TX_HIGH_s =>
          if ack_re = '1' then
            protocol_state <= IDLE_s;
          end if;

        when others => -- IDLE_s
          tx_byte <= tx_data(7 downto 0); -- Always ready to send....
          if ack_re = '1' then
            rwn <= rx_byte(0);
            if rx_byte(0) = '1' then
              protocol_state <= TX_LOW_s;
            else
              protocol_state <= RX_REG_s;
            end if;
          end if;
      end case;

      if (init_complete = '0') or (start_d = '1') or (stop_d = '1') then -- Reset
        protocol_state <= IDLE_s;
        reg_val <= '0';
        rxd_val <= "00";
      end if;
    end if;
  end process;


  ------------------------------------------------------------------------------
  -- Timing Reference
  process (clk)
  begin
    if rising_edge(clk) then
      temp_count <= temp_count + 1;

      temp_stb <= '0';
      if temp_count = to_unsigned(TEMP_TIMER_C, TEMP_CNT_WIDTH_C) then
        temp_stb   <= '1';
        temp_count <= (others => '0');
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- DRP Interface
  process (clk)
  begin
    if rising_edge(clk) then
      drp_en  <= '0';
      drp_wen <= '0';

      if ((start_re = '1') or (stop_re = '1')) and (reg_val = '1') then
        drp_rd_req <= '1';
      end if;

      drp_s_d <= drp_s;
      case drp_s is

        when IDLE_s =>
          if drp_rd_req = '1' then
            drp_rd_req <= '0'; -- serviced
            drp_s      <= RD_DRP_s;
--        elsif NOT IMPLEMENTED YET!! then
--          drp_s <= WR_DRP_s;
          elsif temp_stb = '1' then
            drp_s <= RD_TEMP_s;
          end if;

        when RD_TEMP_s =>
          if drp_s /= drp_s_d then
            drp_en   <= '1';
            drp_addr <= x"00";
          end if;
          if drp_drdy = '1' then
            temperature(9 downto 0) <= drp_do(15 downto 6);
            drp_s <= IDLE_s;
          end if;

        when RD_DRP_s =>
          if drp_s /= drp_s_d then
            drp_en   <= '1';
            drp_addr <= reg;
          end if;
          if drp_drdy = '1' then
            tx_data <= drp_do;
            drp_s   <= IDLE_s;
          end if;

--      when WR_DRP_s =>
--        if ((start_re = '1') or (stop_re = '1')) and (reg_val = '1') then
--          drp_en   <= '1';
--          drp_addr <= reg;
--        end if;
--        if (stop_re = '1') and (rxd_val = "11") then
--          drp_wen <= '1';
--          drp_di  <= rx_data;
--        end if;
--        if drp_drdy = '1' then
--          tx_data <= drp_do;
--        end if;

        when others => -- INIT_s : Read VP/VN to determine FPGA AB (E-Series)
          if sysmon_eos = '1' then
            drp_en   <= '1';
            drp_addr <= x"03";
          elsif drp_drdy = '1' then
            if drp_do(15 downto 12) = x"F" then
              i2c_base_addr <= I2C_BASE_ADDR_1_G;
              fpga_ab       <= '1';
            else
              i2c_base_addr <= I2C_BASE_ADDR_0_G;
            end if;
            drp_s         <= RD_TEMP_s;
            init_complete <= '1';
          end if;
      end case;

      if rst = '1' then
        drp_s         <= INIT_s;
        fpga_ab       <= '0';
        init_complete <= '0';
        temperature   <= (others => '0');
      end if;
    end if;
  end process;

  fpga_id <= "01" & fpga_ab when FPGA_POSITION_G = MM_FPGA_POSITION_LEAF else "000";

end architecture rtl;
