--------------------------------------------------------------------------------
-- Copyright (c) 2022 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Maintainers:
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
  -- Signals in `top_reserved_<dir>_common_t` are Arista-internal, and may be removed,
  -- changed, or updated, in any new FDK release.
  type top_reserved_in_common_t is
    record
      hermes_cfg   : hermes_cfg_t;

      bitstream_id : std_logic_vector(31 downto 0);

      eeprom_sts   : std_logic_vector(2 downto 0);
      sysmon_alm   : std_logic_vector(15 downto 0);
      sem_status   : std_logic_vector(13 downto 0);
    end record;

  constant TOP_RESERVED_IN_COMMON_DFLT_C : top_reserved_in_common_t := (
    hermes_cfg   => HERMES_CFG_DFLT_C,

    bitstream_id => (others => '0'),

    eeprom_sts   => (others => '0'),
    sysmon_alm   => (others => '0'),
    sem_status   => (others => '0')
    );

  type top_reserved_out_common_t is
  record
    sem_enable : std_logic;
  end record;

  constant TOP_RESERVED_OUT_COMMON_DFLT_C : top_reserved_out_common_t := (
    sem_enable => '1'
    );

end package board_common_pkg;

package body board_common_pkg is

end package body board_common_pkg;
