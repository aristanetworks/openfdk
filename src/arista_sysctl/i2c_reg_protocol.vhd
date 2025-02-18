--------------------------------------------------------------------------------
-- Copyright (c) 2020 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Maintainers:
--   fdk-support@arista.com
--
-- Description:
--   This translates I2C to Register Access Protocol (Simple 16b/32b)
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

entity i2c_reg_protocol is
  generic (
    STABLE_PULSE_CLKS_G : natural := 50;
    DEGLITCH_EN_G       : boolean := false
    );
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    base_addr : in  std_logic_vector(6 downto 0);

    -- I2C Bus interface
    scl_in    : in  std_logic;
    scl_low_n : out std_logic;
    sda_in    : in  std_logic;
    sda_low_n : out std_logic;

    -- Register Interface
    reg_avld  : out std_logic;
    reg_addr  : out std_logic_vector(15 downto 0);
    reg_rvld  : in  std_logic;
    reg_rdata : in  std_logic_vector(31 downto 0);
    reg_wvld  : out std_logic;
    reg_wdata : out std_logic_vector(31 downto 0)
    );
end entity i2c_reg_protocol;

architecture rtl of i2c_reg_protocol is

  --------------------------------------------------------------------------------
  -- Definitions and Declarations
  --------------------------------------------------------------------------------
  type protocol_state_t is (RX_REG_s,
                            RX_DATA_s,
                            TX_DATA_s,
                            IDLE_s);

  --------------------------------------------------------------------------------
  -- Signal Declarations
  --------------------------------------------------------------------------------
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
  signal reg_val        : std_logic_vector(1 downto 0);
  signal reg            : std_logic_vector(15 downto 0);
  signal rxd_val        : std_logic_vector(3 downto 0);
  signal rx_data        : std_logic_vector(31 downto 0);
  signal tx_data        : std_logic_vector(31 downto 0);
  signal tx_hold        : std_logic_vector(23 downto 0);
  signal tx_byte        : std_logic_vector(7 downto 0);

begin

  --------------------------------------------------------------------------------
  -- I2C Slave
  i2c_slave : entity work.i2c_base_slave
    generic map(
      STABLE_PULSE_CLKS_G => STABLE_PULSE_CLKS_G,
      DEGLITCH_EN_G       => DEGLITCH_EN_G
      )
    port map (
      sample_clk => clk,
      base_addr  => base_addr,

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

  --------------------------------------------------------------------------------
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
        when RX_REG_s => -- 16b address
          if ack_re = '1' then
            reg_val <= reg_val(0) & '1';
            reg     <= reg(7 downto 0) & rx_byte;
            if reg_val(0) = '1' then
              protocol_state <= RX_DATA_s;
            end if;
          end if;

        when RX_DATA_s => -- 32b data
          if ack_re = '1' then
            rxd_val <= rxd_val(2 downto 0) & '1';
            rx_data <= rx_data(23 downto 0) & rx_byte;
          end if;

        when TX_DATA_s => -- 32b data
          if ack_fe = '1' then
            tx_byte <= tx_hold(23 downto 16);
            tx_hold <= tx_hold(15 downto 0) & x"00";
          end if;

        when others => -- IDLE_s
          tx_byte <= tx_data(31 downto 24); -- Always ready to send....
          tx_hold <= tx_data(23 downto 0);
          if ack_re = '1' then
            rwn <= rx_byte(0);
            if rx_byte(0) = '1' then
              protocol_state <= TX_DATA_s;
            else
              protocol_state <= RX_REG_s;
            end if;
          end if;
      end case;

      if rst = '1' or start_d = '1' or stop_d = '1' then -- Reset
        protocol_state <= IDLE_s;
        reg_val <= (others => '0');
        rxd_val <= (others => '0');
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------------
  -- Register Interface
  process (clk)
  begin
    if rising_edge(clk) then
      -- Capture Register Address
      reg_avld <= '0';
      if ((start_re = '1') or (stop_re = '1')) and (reg_val = "11") then
        reg_avld <= '1';
        reg_addr <= reg;
      end if;

      -- Update Register with Data
      reg_wvld <= '0';
      if (stop_re = '1') and (rxd_val = "1111") then
        reg_wvld  <= '1';
        reg_wdata <= rx_data;
      end if;

      -- Capture Register Data for Read
      if reg_rvld = '1' then
        tx_data <= reg_rdata;
      end if;
    end if;
  end process;

end architecture rtl;
