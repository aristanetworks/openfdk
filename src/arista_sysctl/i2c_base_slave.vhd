--------------------------------------------------------------------------------
-- Copyright (c) 2017-2020 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Author:
--   fdk-support@arista.com
--
-- Description:
--   Protocol agnostic I2C slave
--   Note - Does not support slave initiated clock stretching
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

entity i2c_base_slave is
  generic (
    STABLE_PULSE_CLKS_G : natural := 50;
    DEGLITCH_EN_G       : boolean := false
    );
  port (
    sample_clk : in  std_logic;
    base_addr  : in  std_logic_vector(6 downto 0);

    ----------------------------------------------------------------------
    -- I2C Bus interface
    ----------------------------------------------------------------------
    scl_in     : in  std_logic;
    scl_low_n  : out std_logic;
    sda_in     : in  std_logic;
    sda_low_n  : out std_logic;

    ----------------------------------------------------------------------
    -- Parallel Bus interface
    ----------------------------------------------------------------------
    start      : out std_logic;                    -- Start Received
    stop       : out std_logic;                    -- Stop Received
    ack        : out std_logic;                    -- Acknowledge (end of byte transaction)
    rx_data    : out std_logic_vector(7 downto 0); -- Data from Master (Valid @ ack)
    tx_data    : in  std_logic_vector(7 downto 0)  -- Data to Master (Must be valid @ ack prior to transaction)
    );
end i2c_base_slave;

architecture rtl of i2c_base_slave is

  ----------------------------------------------------------------------
  -- Definitions and Declarations
  ----------------------------------------------------------------------
  type i2c_state_t is (RX_ADDR_s,
                       RX_BYTE_s,
                       SEND_ACK_s,
                       SEND_NACK_s,
                       TX_BYTE_s,
                       WAIT_ACK_s,
                       IDLE_s);

  ----------------------------------------------------------------------
  -- Signal Declarations
  ----------------------------------------------------------------------
  signal scl_m        : std_logic := '1';
  signal sda_m        : std_logic := '1';
  signal scl_i        : std_logic := '1';
  signal sda_i        : std_logic := '1';

  signal scl_d        : std_logic;
  signal scl_re       : std_logic;
  signal scl_fe       : std_logic;
  signal sda_d        : std_logic;
  signal sda_re       : std_logic;
  signal sda_fe       : std_logic;
  signal sm           : std_logic := '0';
  signal pm           : std_logic := '0';

  signal i2c_rwn      : std_logic;
  signal i2c_state    : i2c_state_t := IDLE_s;
  signal bit_cnt      : unsigned(2 downto 0);

  signal sda_low_n_i  : std_logic := '1';
  signal rx_dat       : std_logic_vector(7 downto 0);
  signal tx_dat       : std_logic_vector(7 downto 0);

  signal glitch_scl   : std_logic  := '0';
  signal glitch_sda   : std_logic  := '0';
  signal deglitch_scl : std_logic  := '1';
  signal deglitch_sda : std_logic  := '1';

begin

  ----------------------------------------------------------------------
  -- Continuous Assignment
  ----------------------------------------------------------------------
  scl_low_n <= '1'; -- Clock stretching is not required so scl_low_n always driven...
  sda_low_n <= sda_low_n_i;

  start     <= sm;
  stop      <= pm;
  rx_data   <= rx_dat;

  ----------------------------------------------------------------------
  -- Synchronise I2C
  ----------------------------------------------------------------------
  process (sample_clk)
  begin
    if rising_edge(sample_clk) then
      scl_m <= scl_in;
      sda_m <= sda_in;
      scl_i <= scl_m;
      sda_i <= sda_m;
    end if;
  end process;

  -----------------------------------------------------------------------
  -- Due to glitches happening on scl and sda for CSeries platforms, need
  -- to implement a deglitch counter
  -----------------------------------------------------------------------
  g_deglitch : if DEGLITCH_EN_G generate
    p_deglitch : process (sample_clk) is
      variable v_scl_pulse_count : natural range 0 to STABLE_PULSE_CLKS_G-1;
      variable v_sda_pulse_count : natural range 0 to STABLE_PULSE_CLKS_G-1;
    begin
      if rising_edge(sample_clk) then
        glitch_scl     <= '0';
        glitch_sda     <= '0';

        if scl_i = deglitch_scl then
          if v_scl_pulse_count /= STABLE_PULSE_CLKS_G-1 then
            glitch_scl <= '1';
          end if;
          v_scl_pulse_count := STABLE_PULSE_CLKS_G-1;
        else
          if v_scl_pulse_count = 0 then
            -- the have been STABLE_PULSE_CLKS_G contiguous clock cycles with a new value for scl so assume it is stable
            v_scl_pulse_count := STABLE_PULSE_CLKS_G-1;
            deglitch_scl       <= not deglitch_scl;
          else
            v_scl_pulse_count := v_scl_pulse_count - 1;
          end if;
        end if;

        if sda_i = deglitch_sda then
          if v_sda_pulse_count /= STABLE_PULSE_CLKS_G-1 then
            glitch_sda <= '1';
          end if;
          v_sda_pulse_count := STABLE_PULSE_CLKS_G-1;
        else
          if v_sda_pulse_count = 0 then
            -- the have been STABLE_PULSE_CLKS_G contiguous clock cycles with a new value for scl so assume it is stable
            v_sda_pulse_count := STABLE_PULSE_CLKS_G-1;
            deglitch_sda       <= not deglitch_sda;
          else
            v_sda_pulse_count := v_sda_pulse_count - 1;
          end if;
        end if;
      end if;
    end process p_deglitch;
  end generate g_deglitch;

  g_nodeglitch : if not DEGLITCH_EN_G generate
    deglitch_scl <= scl_i;
    deglitch_sda <= sda_i;
    glitch_scl  <= '0';
    glitch_sda  <= '0';
  end generate g_nodeglitch;

  ----------------------------------------------------------------------
  -- Generate I2C Conditions
  ----------------------------------------------------------------------
  process (sample_clk) is
  begin
    if rising_edge(sample_clk) then
      scl_d  <= deglitch_scl;
      scl_re <= deglitch_scl and not scl_d;
      scl_fe <= not deglitch_scl and scl_d;
      sda_d  <= deglitch_sda;
      sda_re <= deglitch_sda and not sda_d;
      sda_fe <= not deglitch_sda and sda_d;

      if deglitch_scl = '0' then -- Standard sda transitions are on scl low
        sm <= '0';
      elsif sda_fe = '1' then
        if deglitch_scl /= '0' then
          sm <= '1';
        end if;
      end if;

      if deglitch_scl = '0' then -- Standard sda transitions are on scl low
        pm <= '0';
      elsif sda_re = '1' then
        if deglitch_scl /= '0' then
          pm <= '1';
        end if;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------------
  -- I2C State Machine
  ----------------------------------------------------------------------
  process (sample_clk)
  begin
    if rising_edge(sample_clk) then
      if (sm = '1') or (pm = '1') then
        ack     <= '0';
        bit_cnt <= to_unsigned(7, 3);

        if sm = '1' then -- sm & pm are mutually exclusive
          i2c_state <= RX_ADDR_s;
        else -- pm = '1'
          i2c_state <= IDLE_s;
        end if;
      elsif scl_re = '1' then
        ack <= '0';

        case i2c_state is
          when RX_ADDR_s =>
            rx_dat <= rx_dat(6 downto 0) & deglitch_sda;
            if bit_cnt = to_unsigned(0, 3) then
              if rx_dat(6 downto 0) = base_addr then
                i2c_rwn   <= deglitch_sda;
                i2c_state <= SEND_ACK_s;
              else
                i2c_state <= SEND_NACK_s;
              end if;
            end if;
            bit_cnt <= bit_cnt - to_unsigned(1, 3);

          when RX_BYTE_s =>
            rx_dat <= rx_dat(6 downto 0) & deglitch_sda;
            if bit_cnt = to_unsigned(0, 3) then
              i2c_state <= SEND_ACK_s;
            end if;
            bit_cnt <= bit_cnt - to_unsigned(1, 3);

          when SEND_ACK_s =>
            ack     <= '1';
            bit_cnt <= to_unsigned(7, 3);
            if i2c_rwn = '1' then
              tx_dat    <= tx_data;
              i2c_state <= TX_BYTE_s;
            else
              i2c_state <= RX_BYTE_s; -- Keep receiving bytes until stop seen...
            end if;

          when SEND_NACK_s =>
            ack       <= '1';
            bit_cnt   <= to_unsigned(7, 3);
            i2c_state <= IDLE_s;

          when TX_BYTE_s =>
            tx_dat <= tx_dat(6 downto 0) & '1';
            if bit_cnt = to_unsigned(0, 3) then
              i2c_state <= WAIT_ACK_s;
            end if;
            bit_cnt <= bit_cnt - to_unsigned(1, 3);

          when WAIT_ACK_s =>
            ack     <= '1';
            bit_cnt <= to_unsigned(7, 3);
            tx_dat  <= tx_data;
            if deglitch_sda = '1' then  -- NACKm so break...
              i2c_state <= IDLE_s;
            else
              i2c_state <= TX_BYTE_s;
            end if;

          when others =>  -- IDLE_s....wait for next start...
            null;
        end case;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------------
  -- Drive the SDA (falling edge SCL)
  ----------------------------------------------------------------------
  process (sample_clk)
  begin
    if rising_edge(sample_clk) then
      if scl_fe = '1'then
        sda_low_n_i <= '1';
        if i2c_state = SEND_ACK_s then
          sda_low_n_i <= '0';
        elsif i2c_state = TX_BYTE_s then
          sda_low_n_i <= tx_dat(7);
        end if;
      end if;
    end if;
  end process;

end rtl;
