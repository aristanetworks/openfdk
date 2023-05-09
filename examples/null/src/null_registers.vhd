--------------------------------------------------------------------------------
-- Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Author:
--   fdk-support@arista.com
--
-- Description:
--   Example register interface for the Null example design.
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

entity null_registers is
  generic (
    PROJECT_NAME_G : string
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
    fpga_id   : in  std_logic_vector(2 downto 0)
    );
end entity null_registers;

architecture rtl of null_registers is

  --------------------------------------------------------------------------------
  -- Signal Declarations
  --------------------------------------------------------------------------------
  signal reg_address : unsigned(15 downto 0);
  signal reg_wvld_r  : std_logic;
  signal reg_wdata_r : std_logic_vector(31 downto 0);

  signal scratch     : slv32_array_t(8 downto 5) := (others => (others => '0'));

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
      reg_rvld  <= '1';
      reg_rdata <= (others => '0');

      case to_integer(reg_address) is
        when 0 => reg_rdata <= str_chunk(PROJECT_NAME_G, 1, 4);
        when 1 => reg_rdata <= str_chunk(PROJECT_NAME_G, 5, 4);
        when 2 => reg_rdata <= str_chunk(PROJECT_NAME_G, 9, 4);
        when 3 => reg_rdata <= str_chunk(PROJECT_NAME_G, 13, 4);
        when 4 => reg_rdata(2 downto 0) <= fpga_id;

        when 5 to 8 =>
          reg_rdata <= scratch(to_integer(reg_address));
          if reg_wvld_r = '1' then
            scratch(to_integer(reg_address)) <= reg_wdata_r;
          end if;

        when others => null;
      end case;
    end if;
  end process;

end architecture rtl;
