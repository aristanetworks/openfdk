--------------------------------------------------------------------------------
-- Copyright (c) 2013-2023 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Author:
--   fdk-support@arista.com
--
-- Description:
--   Types, definitions, etc, that are re-used in board_pkg.vhd files.
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

-- Packages used for types
library work;
use work.hermes_pkg.all;

package board_common_pkg is
      -- Signals in top_reserved_in_t are Arista-internal, and may be removed,
  -- changed, or updated, in any new FDK release.
  type top_reserved_in_common_t is
    record
      hermes_cfg       : hermes_cfg_t;

      mac_baseaddr     : std_logic_vector(47 downto 0);
      mac_total        : std_logic_vector(7 downto 0);

      bitstream_id     : std_logic_vector(31 downto 0);
      platform_id      : std_logic_vector(15 downto 0);
      boardstd_id      : std_logic_vector(15 downto 0);

      eeprom_sts       : std_logic_vector(2 downto 0);
      sysmon_temp      : std_logic_vector(9 downto 0);
      sem_status       : std_logic_vector(13 downto 0);
    end record;

    constant TOP_RESERVED_IN_COMMON_DFLT_C : top_reserved_in_common_t := (
      hermes_cfg => HERMES_CFG_DFLT_C,

      mac_baseaddr => (others => '0'),
      mac_total    => (others => '0'),

      bitstream_id => (others => '0'),
      platform_id  => (others => '0'),
      boardstd_id  => (others => '0'),

      eeprom_sts   => (others => '0'),
      sysmon_temp  => (others => '0'),
      sem_status   => (others => '0')
    );

    type top_reserved_out_common_t is
    record
      dummy            : std_logic; -- No current reserved output signals.
    end record;

    constant TOP_RESERVED_OUT_COMMON_DFLT_C : top_reserved_out_common_t := (
      dummy => '0'
    );
end package board_common_pkg;

package body board_common_pkg is

end package body board_common_pkg;
