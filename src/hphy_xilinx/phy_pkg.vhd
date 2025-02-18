--------------------------------------------------------------------------------
-- Copyright (c) 2021 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Maintainers:
--   fdk-support@arista.com
--
-- Description:
--   This package provides definitions and utilities for the PHY.
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

package phy_pkg is

  ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Constant and Type Definitions
  ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- constant CPLL_SEL_C          : std_logic_vector := 8x"00"; -- Not yet supported
  constant QPLL0_SEL_C         : std_logic_vector := 2x"3";
  constant QPLL1_SEL_C         : std_logic_vector := 2x"2";
  constant QPLL_REFCLK0_C      : std_logic        := '0';
  constant QPLL_REFCLK1_C      : std_logic        := '1';
  constant QPLLMODE_INV_C      : std_logic_vector := 8x"00"; -- No Valid Configuration programmed
  constant QPLLMODE_10G_156R_C : std_logic_vector := 8x"01";
  constant QPLLMODE_25G_156R_C : std_logic_vector := 8x"02";
  constant QPLLMODE_10G_161R_C : std_logic_vector := 8x"03";
  constant QPLLMODE_25G_161R_C : std_logic_vector := 8x"04";
  constant QPLLMODE_2G5_156R_C : std_logic_vector := 8x"05";

  constant GTMODE_10G32_C : std_logic_vector := 8x"00";
  constant GTMODE_1G32_C  : std_logic_vector := 8x"01";
  constant GTMODE_10G16_C : std_logic_vector := 8x"02";
  constant GTMODE_1G16_C  : std_logic_vector := 8x"03";
  constant GTMODE_10G20_C : std_logic_vector := 8x"04";
  constant GTMODE_25G64_C : std_logic_vector := 8x"05";
  constant GTMODE_25G80_C : std_logic_vector := 8x"06";
  constant GTMODE_1G8_C   : std_logic_vector := 8x"07";

  -- Define a GT configuration type for all
  type qpll_cfg_t is
  record
    ref0_idx   : natural;
    ref0_route : string(1 to 5);
    ref0_sel   : std_logic_vector(2 downto 0);
    ref1_idx   : natural;
    ref1_route : string(1 to 5);
    ref1_sel   : std_logic_vector(2 downto 0);
  end record;

  type gt_cfg_subt is
  record
    txdiffctrl   : std_logic_vector(6 downto 0); -- AKA Main Cursor
    txpostcursor : std_logic_vector(5 downto 0);
    txprecursor  : slv6_array_t(2 downto 0);
    txpolarity   : std_logic;
    txinhibit    : std_logic;
    rxdfeen      : std_logic;
    rxpolarity   : std_logic;
    rxinhibit    : std_logic;
    rxreset      : std_logic;
    eyescanreset : std_logic;
  end record;
  type gt_cfg_t is array (natural range <>) of gt_cfg_subt;
  constant GT_CFG_DFLT_C : gt_cfg_subt := (txdiffctrl   => (others => '0'),
                                           txpostcursor => (others => '0'),
                                           txprecursor  => (others => (others => '0')),
                                           txpolarity   => '0',
                                           txinhibit    => '0',
                                           rxdfeen      => '0',
                                           rxpolarity   => '0',
                                           rxinhibit    => '0',
                                           rxreset      => '0',
                                           eyescanreset => '0');

  -- Define a GT status type for all
  type gt_sts_t is
  record
    qpllmode  : slv8_array_t(1 downto 0);
    txmode    : std_logic_vector(7 downto 0);
    txinhibit : std_logic;
    txprbs    : std_logic_vector(3 downto 0);
    txber     : std_logic_vector(31 downto 0);
    txser     : std_logic_vector(31 downto 0);
    rxmode    : std_logic_vector(7 downto 0);
    rxinhibit : std_logic;
    rxprbs    : std_logic_vector(3 downto 0);
    rxprbslck : std_logic;
    rxprbserr : std_logic;
    loopback  : std_logic_vector(2 downto 0);
  end record;
  type gt_sts_array_t is array (natural range <>) of gt_sts_t;

  ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- Component Definitions
  ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  component gty_quad_gtye4_common_wrapper
    port (
      GTYE4_COMMON_BGBYPASSB         : in  std_logic_vector(0 downto 0)  := 1x"1";
      GTYE4_COMMON_BGMONITORENB      : in  std_logic_vector(0 downto 0)  := 1x"1";
      GTYE4_COMMON_BGPDB             : in  std_logic_vector(0 downto 0)  := 1x"1";
      GTYE4_COMMON_BGRCALOVRD        : in  std_logic_vector(4 downto 0)  := 5x"10";
      GTYE4_COMMON_BGRCALOVRDENB     : in  std_logic_vector(0 downto 0)  := 1x"1";
      GTYE4_COMMON_DRPADDR           : in  std_logic_vector(15 downto 0);
      GTYE4_COMMON_DRPCLK            : in  std_logic_vector(0 downto 0);
      GTYE4_COMMON_DRPDI             : in  std_logic_vector(15 downto 0);
      GTYE4_COMMON_DRPEN             : in  std_logic_vector(0 downto 0);
      GTYE4_COMMON_DRPWE             : in  std_logic_vector(0 downto 0);
      GTYE4_COMMON_GTGREFCLK0        : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_GTGREFCLK1        : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_GTNORTHREFCLK00   : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_GTNORTHREFCLK01   : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_GTNORTHREFCLK10   : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_GTNORTHREFCLK11   : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_GTREFCLK00        : in  std_logic_vector(0 downto 0);
      GTYE4_COMMON_GTREFCLK01        : in  std_logic_vector(0 downto 0);
      GTYE4_COMMON_GTREFCLK10        : in  std_logic_vector(0 downto 0);
      GTYE4_COMMON_GTREFCLK11        : in  std_logic_vector(0 downto 0);
      GTYE4_COMMON_GTSOUTHREFCLK00   : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_GTSOUTHREFCLK01   : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_GTSOUTHREFCLK10   : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_GTSOUTHREFCLK11   : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_PCIERATEQPLL0     : in  std_logic_vector(2 downto 0)  := (others => '0');
      GTYE4_COMMON_PCIERATEQPLL1     : in  std_logic_vector(2 downto 0)  := (others => '0');
      GTYE4_COMMON_PMARSVD0          : in  std_logic_vector(7 downto 0)  := (others => '0');
      GTYE4_COMMON_PMARSVD1          : in  std_logic_vector(7 downto 0)  := (others => '0');
      GTYE4_COMMON_QPLL0CLKRSVD0     : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_QPLL0CLKRSVD1     : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_QPLL0FBDIV        : in  std_logic_vector(7 downto 0)  := (others => '0');
      GTYE4_COMMON_QPLL0LOCKDETCLK   : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_QPLL0LOCKEN       : in  std_logic_vector(0 downto 0)  := 1x"1";
      GTYE4_COMMON_QPLL0PD           : in  std_logic_vector(0 downto 0);
      GTYE4_COMMON_QPLL0REFCLKSEL    : in  std_logic_vector(2 downto 0);
      GTYE4_COMMON_QPLL0RESET        : in  std_logic_vector(0 downto 0);
      GTYE4_COMMON_QPLL1CLKRSVD0     : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_QPLL1CLKRSVD1     : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_QPLL1FBDIV        : in  std_logic_vector(7 downto 0)  := (others => '0');
      GTYE4_COMMON_QPLL1LOCKDETCLK   : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_QPLL1LOCKEN       : in  std_logic_vector(0 downto 0)  := 1x"1";
      GTYE4_COMMON_QPLL1PD           : in  std_logic_vector(0 downto 0);
      GTYE4_COMMON_QPLL1REFCLKSEL    : in  std_logic_vector(2 downto 0);
      GTYE4_COMMON_QPLL1RESET        : in  std_logic_vector(0 downto 0);
      GTYE4_COMMON_QPLLRSVD1         : in  std_logic_vector(7 downto 0)  := (others => '0');
      GTYE4_COMMON_QPLLRSVD2         : in  std_logic_vector(4 downto 0)  := (others => '0');
      GTYE4_COMMON_QPLLRSVD3         : in  std_logic_vector(4 downto 0)  := (others => '0');
      GTYE4_COMMON_QPLLRSVD4         : in  std_logic_vector(7 downto 0)  := (others => '0');
      GTYE4_COMMON_RCALENB           : in  std_logic_vector(0 downto 0)  := 1x"1";
      GTYE4_COMMON_SDM0DATA          : in  std_logic_vector(24 downto 0) := (others => '0');
      GTYE4_COMMON_SDM0RESET         : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_SDM0TOGGLE        : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_SDM0WIDTH         : in  std_logic_vector(1 downto 0)  := (others => '0');
      GTYE4_COMMON_SDM1DATA          : in  std_logic_vector(24 downto 0) := (others => '0');
      GTYE4_COMMON_SDM1RESET         : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_SDM1TOGGLE        : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_SDM1WIDTH         : in  std_logic_vector(1 downto 0)  := (others => '0');
      GTYE4_COMMON_UBCFGSTREAMEN     : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_UBDO              : in  std_logic_vector(15 downto 0) := (others => '0');
      GTYE4_COMMON_UBDRDY            : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_UBENABLE          : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_UBGPI             : in  std_logic_vector(1 downto 0)  := (others => '0');
      GTYE4_COMMON_UBINTR            : in  std_logic_vector(1 downto 0)  := (others => '0');
      GTYE4_COMMON_UBIOLMBRST        : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_UBMBRST           : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_UBMDMCAPTURE      : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_UBMDMDBGRST       : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_UBMDMDBGUPDATE    : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_UBMDMREGEN        : in  std_logic_vector(3 downto 0)  := (others => '0');
      GTYE4_COMMON_UBMDMSHIFT        : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_UBMDMSYSRST       : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_UBMDMTCK          : in  std_logic_vector(0 downto 0)  := (others => '0');
      GTYE4_COMMON_UBMDMTDI          : in  std_logic_vector(0 downto 0)  := (others => '0');

      GTYE4_COMMON_DRPDO             : out std_logic_vector(15 downto 0);
      GTYE4_COMMON_DRPRDY            : out std_logic_vector(0 downto 0);
      GTYE4_COMMON_PMARSVDOUT0       : out std_logic_vector(7 downto 0);
      GTYE4_COMMON_PMARSVDOUT1       : out std_logic_vector(7 downto 0);
      GTYE4_COMMON_QPLL0FBCLKLOST    : out std_logic_vector(0 downto 0);
      GTYE4_COMMON_QPLL0LOCK         : out std_logic_vector(0 downto 0);
      GTYE4_COMMON_QPLL0OUTCLK       : out std_logic_vector(0 downto 0);
      GTYE4_COMMON_QPLL0OUTREFCLK    : out std_logic_vector(0 downto 0);
      GTYE4_COMMON_QPLL0REFCLKLOST   : out std_logic_vector(0 downto 0);
      GTYE4_COMMON_QPLL1FBCLKLOST    : out std_logic_vector(0 downto 0);
      GTYE4_COMMON_QPLL1LOCK         : out std_logic_vector(0 downto 0);
      GTYE4_COMMON_QPLL1OUTCLK       : out std_logic_vector(0 downto 0);
      GTYE4_COMMON_QPLL1OUTREFCLK    : out std_logic_vector(0 downto 0);
      GTYE4_COMMON_QPLL1REFCLKLOST   : out std_logic_vector(0 downto 0);
      GTYE4_COMMON_QPLLDMONITOR0     : out std_logic_vector(7 downto 0);
      GTYE4_COMMON_QPLLDMONITOR1     : out std_logic_vector(7 downto 0);
      GTYE4_COMMON_REFCLKOUTMONITOR0 : out std_logic_vector(0 downto 0);
      GTYE4_COMMON_REFCLKOUTMONITOR1 : out std_logic_vector(0 downto 0);
      GTYE4_COMMON_RXRECCLK0SEL      : out std_logic_vector(1 downto 0);
      GTYE4_COMMON_RXRECCLK1SEL      : out std_logic_vector(1 downto 0);
      GTYE4_COMMON_SDM0FINALOUT      : out std_logic_vector(3 downto 0);
      GTYE4_COMMON_SDM0TESTDATA      : out std_logic_vector(14 downto 0);
      GTYE4_COMMON_SDM1FINALOUT      : out std_logic_vector(3 downto 0);
      GTYE4_COMMON_SDM1TESTDATA      : out std_logic_vector(14 downto 0);
      GTYE4_COMMON_UBDADDR           : out std_logic_vector(15 downto 0);
      GTYE4_COMMON_UBDEN             : out std_logic_vector(0 downto 0);
      GTYE4_COMMON_UBDI              : out std_logic_vector(15 downto 0);
      GTYE4_COMMON_UBDWE             : out std_logic_vector(0 downto 0);
      GTYE4_COMMON_UBMDMTDO          : out std_logic_vector(0 downto 0);
      GTYE4_COMMON_UBRSVDOUT         : out std_logic_vector(0 downto 0);
      GTYE4_COMMON_UBTXUART          : out std_logic_vector(0 downto 0)
      );
  end component;

  COMPONENT gty_quad
    PORT (
      gtwiz_userclk_tx_active_in : IN  STD_LOGIC_VECTOR(0 DOWNTO 0) := 1x"1";
      gtwiz_userclk_rx_active_in : IN  STD_LOGIC_VECTOR(0 DOWNTO 0) := 1x"1";
      gtwiz_reset_tx_done_in     : IN  STD_LOGIC_VECTOR(0 DOWNTO 0) := 1x"1";
      gtwiz_reset_rx_done_in     : IN  STD_LOGIC_VECTOR(0 DOWNTO 0) := 1x"1";

      drpaddr_in            : IN  STD_LOGIC_VECTOR(39 DOWNTO 0);
      drpclk_in             : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      drpdi_in              : IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
      drpen_in              : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      drpwe_in              : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      gtrxreset_in          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      gttxreset_in          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      gtyrxn_in             : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      gtyrxp_in             : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      qpll0clk_in           : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      qpll0refclk_in        : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      qpll1clk_in           : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      qpll1refclk_in        : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      loopback_in           : IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
      txprbssel_in          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
      txprbsforceerr_in     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxprbssel_in          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
      rxprbscntreset_in     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxcdrhold_in          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxdlybypass_in        : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      rxdlyen_in            : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      rxdlyovrden_in        : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      rxdlysreset_in        : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxelecidlemode_in     : IN  STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0');
      rxlpmen_in            : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxlpmgcovrden_in      : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxlpmhfovrden_in      : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxlpmlfklovrden_in    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxlpmosovrden_in      : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxosovrden_in         : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxphalign_in          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      rxphalignen_in        : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      rxphdlypd_in          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      rxphdlyreset_in       : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      rxpllclksel_in        : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      rxsysclksel_in        : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      rxpolarity_in         : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxprogdivreset_in     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxsyncallin_in        : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxsyncin_in           : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      rxsyncmode_in         : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '1');
      rxuserrdy_in          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxusrclk_in           : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxusrclk2_in          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      txctrl0_in            : IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
      txctrl1_in            : IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
      txdata_in             : IN  STD_LOGIC_VECTOR(511 DOWNTO 0);
      txdiffctrl_in         : IN  STD_LOGIC_VECTOR(19 DOWNTO 0);
      txdlybypass_in        : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      txdlyen_in            : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      txdlyhold_in          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      txdlyovrden_in        : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      txdlysreset_in        : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      txdlyupdown_in        : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      txinhibit_in          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      txphalign_in          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      txphalignen_in        : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      txphdlypd_in          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      txphdlyreset_in       : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      txphdlytstclk_in      : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      txphinit_in           : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      txphovrden_in         : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      txpippmen_in          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      txpippmovrden_in      : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      txpippmpd_in          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '1');
      txpippmsel_in         : IN  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
      txpippmstepsize_in    : IN  STD_LOGIC_VECTOR(19 DOWNTO 0) := (others => '0');
      txpllclksel_in        : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      txsysclksel_in        : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      txoutclksel_in        : IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
      txpolarity_in         : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      txpostcursor_in       : IN  STD_LOGIC_VECTOR(19 DOWNTO 0);
      txprecursor_in        : IN  STD_LOGIC_VECTOR(19 DOWNTO 0);
      txprogdivreset_in     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      txsyncallin_in        : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      txsyncin_in           : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      txsyncmode_in         : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      txuserrdy_in          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      txusrclk_in           : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      txusrclk2_in          : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);

      drpdo_out             : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      drprdy_out            : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      gtpowergood_out       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      gtytxn_out            : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      gtytxp_out            : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxprbslocked_out      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxprbserr_out         : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxcdrlock_out         : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxctrl0_out           : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      rxctrl1_out           : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      rxdata_out            : OUT STD_LOGIC_VECTOR(511 DOWNTO 0);
      rxdlysresetdone_out   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxelecidle_out        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxoutclk_out          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxphaligndone_out     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxpmaresetdone_out    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxrecclkout_out       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxresetdone_out       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxsyncdone_out        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      rxsyncout_out         : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      txdlysresetdone_out   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      txoutclk_out          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      txphaligndone_out     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      txphinitdone_out      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      txpmaresetdone_out    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      txprgdivresetdone_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      txresetdone_out       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      txsyncdone_out        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      txsyncout_out         : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
      );
  END COMPONENT;

  COMPONENT picxo
    PORT (
      RESET_I     : IN  STD_LOGIC;
      REF_CLK_I   : IN  STD_LOGIC;
      TXOUTCLK_I  : IN  STD_LOGIC;
      RSIGCE_I    : IN  STD_LOGIC;
      VSIGCE_I    : IN  STD_LOGIC;
      VSIGCE_O    : OUT STD_LOGIC;
      ACC_STEP    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
      G1          : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
      G2          : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
      R           : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
      V           : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
      CE_DSP_RATE : IN  STD_LOGIC_VECTOR(23 DOWNTO 0);
      C_I         : IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
      P_I         : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
      N_I         : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
      OFFSET_PPM  : IN  STD_LOGIC_VECTOR(21 DOWNTO 0);
      OFFSET_EN   : IN  STD_LOGIC;
      HOLD        : IN  STD_LOGIC;
      DON_I       : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
      ACC_DATA    : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      ERROR_O     : OUT STD_LOGIC_VECTOR(20 DOWNTO 0);
      VOLT_O      : OUT STD_LOGIC_VECTOR(21 DOWNTO 0);
      CE_PI_O     : OUT STD_LOGIC;
      CE_PI2_O    : OUT STD_LOGIC;
      CE_DSP_O    : OUT STD_LOGIC;
      OVF_PD      : OUT STD_LOGIC;
      OVF_AB      : OUT STD_LOGIC;
      OVF_VOLT    : OUT STD_LOGIC;
      OVF_INT     : OUT STD_LOGIC
      );
  END COMPONENT;

  ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end phy_pkg;

package body phy_pkg is
end package body phy_pkg;
