--------------------------------------------------------------------------------
-- Copyright (c) 2021 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Author:
--   fdk-support@arista.com
--
-- Description:
--   This package provides definitions and utilities for the Hermes interface.
--
-- Tags:
--   noencrypt
--   license-arista-fdk-agreement
--   license-bsd-3-clause
--
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.metamako_pkg.all;

------------------------------------------------------------------------------

package hermes_pkg is

  ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Constant Definitions
  ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  constant HERMES_VER_MAJ_C    : std_logic_vector := 8x"00";
  constant HERMES_VER_MIN_C    : std_logic_vector := 8x"01";

  -- Hermes Pre-Defined (Common) Commands
  constant NACK_COMMAND_C      : std_logic_vector := 15x"0000"; -- No Ack Required (e.g. Push)
  constant RST_COMMAND_C       : std_logic_vector := 15x"0002"; -- Reset Command
  constant RST_RESPONSE_C      : std_logic_vector := 15x"0003";
  constant RDBYTE_COMMAND_C    : std_logic_vector := 15x"0004"; -- Read BYTE(s)      -- Addr = Byte Addressing
  constant RDBYTE_RESPONSE_C   : std_logic_vector := 15x"0005";
  constant WRBYTE_COMMAND_C    : std_logic_vector := 15x"0006"; -- Write BYTE(s)
  constant WRBYTE_RESPONSE_C   : std_logic_vector := 15x"0007";
  constant RDWORD_COMMAND_C    : std_logic_vector := 15x"0008"; -- Read 32b WORD(s)  -- Addr = Word Addressing
  constant RDWORD_RESPONSE_C   : std_logic_vector := 15x"0009";
  constant WRWORD_COMMAND_C    : std_logic_vector := 15x"000A"; -- Write 32b WORD(s)
  constant WRWORD_RESPONSE_C   : std_logic_vector := 15x"000B";

  -- HeartBeat Configuration
  constant HEARTBEAT_VERSION_C : std_logic_vector := 6x"01";
  constant HEARTBEAT_PORT_C    : std_logic_vector := std_logic_vector(to_unsigned(15364, 16)); -- Reserved in AID7730
  -- Heartbeat Type/Length Constants
  constant HEARTBEAT_TL1_C     : std_logic_vector := 8x"01" & 8x"10"; -- Project Name
  constant HEARTBEAT_TL2_C     : std_logic_vector := 8x"02" & 8x"04"; -- BitStream ID
  constant HEARTBEAT_TL3_C     : std_logic_vector := 8x"03" & 8x"02"; -- Platform ID
  constant HEARTBEAT_TL4_C     : std_logic_vector := 8x"04" & 8x"02"; -- Board Standard ID
  constant HEARTBEAT_TL5_C     : std_logic_vector := 8x"05" & 8x"01"; -- FPGA ID
  constant HEARTBEAT_TL6_C     : std_logic_vector := 8x"06" & 8x"01"; -- EEPROM Status
  constant HEARTBEAT_TL7_C     : std_logic_vector := 8x"07" & 8x"02"; -- SEM Status
  constant HEARTBEAT_TL8_C     : std_logic_vector := 8x"08" & 8x"04"; -- UP Time Counter
  constant HEARTBEAT_TL9_C     : std_logic_vector := 8x"09" & 8x"02"; -- Sysmon Temperature

  -- RegFile Configuration
  constant REGFILE_VERSION_C   : std_logic_vector := 6x"01";
  constant REGFILE_PORT_C      : std_logic_vector := std_logic_vector(to_unsigned(15365, 16)); -- Reserved in AID7730
  constant CLRCNT_COMMMAND_C   : std_logic_vector := 15x"000C";
  constant CLRCNT_RESPONSE_C   : std_logic_vector := 15x"000D";

  -- Hermes GT PHY Configuration
  constant HPHY_VERSION_C      : std_logic_vector := 6x"01";
  constant HPHY_PORT_C         : std_logic_vector := std_logic_vector(to_unsigned(15366, 16)); -- Reserved in AID7730

  -- makoStream Configuration
  constant MAKOSTRM_VERSION_C  : std_logic_vector := 6x"03";
  constant MAKOSTRM_PORT_C     : std_logic_vector := std_logic_vector(to_unsigned(15360, 16)); -- Reserved in AID7730


  ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Type Definitions
  ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  type hermes_cfg_t is record
    vld      : std_logic;
    fpga_mac : std_logic_vector(47 downto 0);
    fpga_ip  : std_logic_vector(31 downto 0);
    host_mac : std_logic_vector(47 downto 0);
    host_ip  : std_logic_vector(31 downto 0);
  end record;

  constant HERMES_CFG_DFLT_C : hermes_cfg_t := (
    vld => '0',
    fpga_mac => (others => '0'),
    fpga_ip  => (others => '0'),
    host_mac => (others => '0'),
    host_ip  => (others => '0')
  );

  type hermes_std_t is record
    vld   : std_logic;                    -- Byte Valid
    sof   : std_logic;                    -- Start of Frame
    eof   : std_logic;                    -- End of Frame
    data  : std_logic_vector(7 downto 0); -- Data
    abort : std_logic;                    -- Hard Abort (Re-init Node)
    link  : std_logic;                    -- Link Validation
  end record;
  type hermes_std_array_t is array (natural range <>) of hermes_std_t;

  constant HERMES_STD_DFLT_C : hermes_std_t := (vld   => '0',
                                                sof   => '0',
                                                eof   => '0',
                                                data  => (others => '0'),
                                                abort => '0',
                                                link  => '0');

  type hermes_dts_t is record
    rdy : std_logic;
  end record;
  type hermes_dts_array_t is array (natural range <>) of hermes_dts_t;

  constant HERMES_DTS_DFLT_C : hermes_dts_t := (rdy => '1');

  type hermes_cmd_t is record
    ena  : std_logic;
    cmd  : std_logic_vector(14 downto 0);
    len  : std_logic_vector(15 downto 0);
    addr : std_logic_vector(31 downto 0);
  end record;
  constant HERMES_CMD_DFLT_C : hermes_cmd_t := (ena  => '0',
                                                cmd  => (others => '0'),
                                                len  => (others => '0'),
                                                addr => (others => '0')
                                                );

  ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Function and procedure prototypes
  ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  procedure HERMES_LINK_ASSERT (std : in hermes_std_t);

  ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end hermes_pkg;

package body hermes_pkg is

  ------------------------------------------------------------------------------
  -- Validation
  ------------------------------------------------------------------------------
  procedure HERMES_LINK_ASSERT (std : in hermes_std_t) is
  begin
    -- pragma synthesis_off
    wait for 10 ns;
    assert std.link = '1'
      report "Hermes Ring Establishment Failed - Check Connections"
      severity failure;
    wait;
    -- pragma synthesis_on
  end procedure;

end package body hermes_pkg;
