--------------------------------------------------------------------------------
-- Copyright (c) 2019-2023 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Author:
--   fdk-support@arista.com
--
-- Description:
--   Wraps the Xilinx PLLEn_BASE primative for ultrascale devices
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

library UNISIM;
use UNISIM.VCOMPONENTS.all;

library work;
use work.fpga_spec_pkg.all;

entity xil_pllbase is
  generic (
    FPGA_TYPE_G : mm_fpga_target_t := MM_FPGA_XILINX_XCKU095_22;

    -- Read the Xilinx documentation on how to set these...
    CLKIN_PERIOD_G   : real    := 2.0000;  -- "ns"
    CLKFBOUT_MULT_G  : natural := 1;
    DIVCLK_DIVIDE_G  : natural := 1;
    CLKOUT0_DIVIDE_G : natural := 1;
    CLKOUT1_DIVIDE_G : natural := 1;

    SIM_SPEEDUP_G : boolean := false
    );
  port (
    src_clk  : in  std_logic;
    src_rst  : in  std_logic;
    dst0_clk : out std_logic;
    dst0_rst : out std_logic;
    dst1_clk : out std_logic;
    dst1_rst : out std_logic;


    drp_addr : in  std_logic_vector(6 downto 0)  := (others => '0');
    drp_clk  : in  std_logic                     := '0';
    drp_en   : in  std_logic                     := '0';
    drp_di   : in  std_logic_vector(15 downto 0) := (others => '0');
    drp_do   : out std_logic_vector(15 downto 0) := (others => '0');
    drp_rdy  : out std_logic                     := '0';
    drp_we   : in  std_logic                     := '0'
    );
end entity xil_pllbase;

architecture rtl of xil_pllbase is

  ------------------------------------------------------------------------------
  -- Local Procedure
  ------------------------------------------------------------------------------
  -- pragma synthesis_off
  procedure clk_gen_from_freq(signal clk : out std_logic; constant FREQ : real) is
    constant PERIOD    : time := 1 sec / FREQ;        -- Full period
    constant HIGH_TIME : time := PERIOD / 2;          -- High time
    constant LOW_TIME  : time := PERIOD - HIGH_TIME;  -- Low time; always >= HIGH_TIME
  begin
    assert (HIGH_TIME /= 0 fs)
      report "clk_gen_from_freq: High time is zero; time resolution to large for frequency" severity failure;
    loop
      clk <= '0';
      wait for LOW_TIME;
      clk <= '1';
      wait for HIGH_TIME;
    end loop;
  end procedure;
  -- pragma synthesis_on

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant FPGA_FAMILY_C : mm_fpga_family_t := mm_get_fpga_family(FPGA_TYPE_G);

  --------------------------------------------------------------------------------
  -- Signal Declarations
  --------------------------------------------------------------------------------
  signal dst_clk_fbout : std_logic;
  signal dst_clk_fbin  : std_logic;
  signal dst_clk_lck   : std_logic := '0';
  signal dst_clk_lck_n : std_logic;
  signal dst0_clk_ubuf : std_logic;
  signal dst1_clk_ubuf : std_logic;
  signal dst0_clk_i    : std_logic;
  signal dst0_rst_i    : std_logic;
  signal dst1_clk_i    : std_logic;
  signal dst1_rst_i    : std_logic;

begin

  dst0_clk <= dst0_clk_i;
  dst0_rst <= dst0_rst_i;
  dst1_clk <= dst1_clk_i;
  dst1_rst <= dst1_rst_i;

  --------------------------------------------------------------------------------
  -- Clock for simulation purposes

  -- pragma synthesis_off
  gen_sim_plls : if SIM_SPEEDUP_G generate
    constant CLK0_FREQ_C : real := ((CLKFBOUT_MULT_G * 1.0E9) / (CLKIN_PERIOD_G * DIVCLK_DIVIDE_G) / CLKOUT0_DIVIDE_G);
    constant CLK1_FREQ_C : real := ((CLKFBOUT_MULT_G * 1.0E9) / (CLKIN_PERIOD_G * DIVCLK_DIVIDE_G) / CLKOUT1_DIVIDE_G);
  begin
    clk_gen_from_freq(dst0_clk_ubuf, CLK0_FREQ_C);
    clk_gen_from_freq(dst1_clk_ubuf, CLK1_FREQ_C);

    process
    begin
      wait for 100 ns;
      while src_rst = '1' loop
        wait until rising_edge(src_clk);
      end loop;
      wait for 100 ns;
      wait until rising_edge(dst0_clk_ubuf);
      dst_clk_lck <= '1';
    end process;
  end generate;
  -- pragma synthesis_on

  --------------------------------------------------------------------------------
  -- PLL Instances

  gen_synth_plls : if not SIM_SPEEDUP_G generate
    gen_pll_us : if FPGA_FAMILY_C = MM_FPGA_ULTRASCALE generate
      pll_clk_i : unisim.vcomponents.PLLE3_ADV
        generic map(
          CLKFBOUT_MULT       => CLKFBOUT_MULT_G,
          CLKFBOUT_PHASE      => 0.000000,
          CLKIN_PERIOD        => CLKIN_PERIOD_G,
          CLKOUT0_DIVIDE      => CLKOUT0_DIVIDE_G,
          CLKOUT0_DUTY_CYCLE  => 0.500000,
          CLKOUT0_PHASE       => 0.000000,
          CLKOUT1_DIVIDE      => CLKOUT1_DIVIDE_G,
          CLKOUT1_DUTY_CYCLE  => 0.500000,
          CLKOUT1_PHASE       => 0.000000,
          CLKOUTPHY_MODE      => "VCO_2X",
          DIVCLK_DIVIDE       => DIVCLK_DIVIDE_G,
          IS_CLKFBIN_INVERTED => '0',
          IS_CLKIN_INVERTED   => '0',
          IS_PWRDWN_INVERTED  => '0',
          IS_RST_INVERTED     => '0',
          REF_JITTER          => 0.010000,
          STARTUP_WAIT        => "FALSE"
          )
        port map (
          PWRDWN => '0',
          RST    => src_rst,
          CLKIN  => src_clk,

          CLKFBIN     => dst_clk_fbin,
          CLKFBOUT    => dst_clk_fbout,
          CLKOUT0     => dst0_clk_ubuf,
          CLKOUT1     => dst1_clk_ubuf,
          CLKOUTPHYEN => '0',
          LOCKED      => dst_clk_lck,

          DADDR => drp_addr,
          DCLK  => drp_clk,
          DEN   => drp_en,
          DI    => drp_di,
          DO    => drp_do,
          DRDY  => drp_rdy,
          DWE   => drp_we
          );
    end generate;
    gen_pll_usp : if FPGA_FAMILY_C = MM_FPGA_ULTRASCALEP generate
      pll_clk_i : unisim.vcomponents.PLLE4_ADV
        generic map(
          CLKFBOUT_MULT       => CLKFBOUT_MULT_G,
          CLKFBOUT_PHASE      => 0.000000,
          CLKIN_PERIOD        => CLKIN_PERIOD_G,
          CLKOUT0_DIVIDE      => CLKOUT0_DIVIDE_G,
          CLKOUT0_DUTY_CYCLE  => 0.500000,
          CLKOUT0_PHASE       => 0.000000,
          CLKOUT1_DIVIDE      => CLKOUT1_DIVIDE_G,
          CLKOUT1_DUTY_CYCLE  => 0.500000,
          CLKOUT1_PHASE       => 0.000000,
          CLKOUTPHY_MODE      => "VCO_2X",
          DIVCLK_DIVIDE       => DIVCLK_DIVIDE_G,
          IS_CLKFBIN_INVERTED => '0',
          IS_CLKIN_INVERTED   => '0',
          IS_PWRDWN_INVERTED  => '0',
          IS_RST_INVERTED     => '0',
          REF_JITTER          => 0.010000,
          STARTUP_WAIT        => "FALSE"
          )
        port map (
          PWRDWN => '0',
          RST    => src_rst,
          CLKIN  => src_clk,

          CLKFBIN     => dst_clk_fbin,
          CLKFBOUT    => dst_clk_fbout,
          CLKOUT0     => dst0_clk_ubuf,
          CLKOUT1     => dst1_clk_ubuf,
          CLKOUTPHYEN => '0',
          LOCKED      => dst_clk_lck,

          DADDR => drp_addr,
          DCLK  => drp_clk,
          DEN   => drp_en,
          DI    => drp_di,
          DO    => drp_do,
          DRDY  => drp_rdy,
          DWE   => drp_we
          );
    end generate;
  end generate;

  --------------------------------------------------------------------------------
  -- Clock Buffers

  dstclk_fb_bufg_i : BUFG port map (O => dst_clk_fbin, I => dst_clk_fbout);
  dstclk0_bufg_i   : BUFG port map (O => dst0_clk_i, I => dst0_clk_ubuf);
  dstclk1_bufg_i   : BUFG port map (O => dst1_clk_i, I => dst1_clk_ubuf);

  --------------------------------------------------------------------------------
  -- Reset generation

  dst_clk_lck_n <= not dst_clk_lck;

  dst0rst_sync_i : entity work.synchroniser
    generic map (INIT_G => '1')
    port map (
      clk    => dst0_clk_i,
      rst    => dst_clk_lck_n,
      a      => '0',
      a_sync => dst0_rst_i
      );

  dst1rst_sync_i : entity work.synchroniser
    generic map (INIT_G => '1')
    port map (
      clk    => dst1_clk_i,
      rst    => dst_clk_lck_n,
      a      => '0',
      a_sync => dst1_rst_i
      );

end architecture rtl;
