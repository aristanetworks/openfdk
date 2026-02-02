--------------------------------------------------------------------------------
-- Copyright (c) 2013 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Maintainers:
--   fdk-support@arista.com
--
-- Description:
--   Metamako proprietary types, constants, functions and procedures.
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

package metamako_pkg is

  ------------------------------------------------------------------------------
  -- Constants -----------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- This constant is used to make simulations more clear.
  -- This is used to represent the propagation delay through a circuit.
  constant t_prop : time := 1 ps;

  constant IN_SIMULATION_C : boolean := false
                                        -- synthesis translate_off
                                        or true
                                        -- synthesis translate_on
                                      ; -- <- here is the semicolon

  constant IN_SYNTHESIS_C : boolean := not IN_SIMULATION_C;

  function bool_to_str_caps (constant i : boolean) return string;

  ------------------------------------------------------------------------------
  -- I2C address specification
  -- This is the most significant 7 bits of the "address" byte which excludes r/wn in bit 0.
  -- The standard practice tends to be to quote the address as the whole address byte with bit 0 set to 0.
  subtype i2c_addr_t is std_logic_vector(7 downto 1);
  type i2c_addr_array_t is array (natural range <>) of i2c_addr_t;

  -- SFP and SFP+ modules have two i2c addresses, 0xa0 and 0xa2.
  constant SFP_I2C_ADDR_C  : i2c_addr_t := "101000-";
  constant SFP0_I2C_ADDR_C : i2c_addr_t := "1010000";
  constant SFP1_I2C_ADDR_C : i2c_addr_t := "1010001";
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Types ---------------------------------------------------------------------
  ------------------------------------------------------------------------------

  subtype byte_t is std_logic_vector(7 downto 0);
  type byte_array_t is array (natural range <>) of byte_t;
  type byte_array_ptr_t is access byte_array_t;

  subtype nibble_t is std_logic_vector(3 downto 0);
  type nibble_array_t is array (natural range <>) of nibble_t;

  subtype octet_t is std_logic_vector(7 downto 0);
  type octet_array_t is array (natural range <>) of octet_t;
  type octet_array_ptr_t is access octet_array_t;

  subtype slv1_t is std_logic_vector(0 downto 0);
  type slv1_array_t is array (natural range <>) of slv1_t;

  subtype slv2_t is std_logic_vector(1 downto 0);
  type slv2_array_t is array (natural range <>) of slv2_t;

  subtype slv3_t is std_logic_vector(2 downto 0);
  type slv3_array_t is array (natural range <>) of slv3_t;
  type slv3_array_2d_t is array (natural range <>, natural range<>) of slv3_t;

  subtype slv4_t is std_logic_vector(3 downto 0);
  type slv4_array_t is array (natural range <>) of slv4_t;

  subtype slv5_t is std_logic_vector(4 downto 0);
  type slv5_array_t is array (natural range <>) of slv5_t;

  subtype slv6_t is std_logic_vector(5 downto 0);
  type slv6_array_t is array (natural range <>) of slv6_t;

  subtype slv7_t is std_logic_vector(6 downto 0);
  type slv7_array_t is array (natural range <>) of slv7_t;

  subtype slv8_t is std_logic_vector(7 downto 0);
  type slv8_array_t is array (natural range <>) of slv8_t;
  type slv8_array_ptr_t is access slv8_array_t;

  subtype slv9_t is std_logic_vector(8 downto 0);
  type slv9_array_t is array (natural range <>) of slv9_t;

  subtype slv10_t is std_logic_vector(9 downto 0);
  type slv10_array_t is array (natural range <>) of slv10_t;

  type slv11_array_t is array (natural range <>) of std_logic_vector(10 downto 0);

  subtype slv12_t is std_logic_vector(11 downto 0);
  type slv12_array_t is array (natural range <>) of slv12_t;

  subtype slv13_t is std_logic_vector(12 downto 0);
  type slv13_array_t is array (natural range <>) of slv13_t;

  subtype slv14_t is std_logic_vector(13 downto 0);
  type slv14_array_t is array (natural range <>) of slv14_t;

  subtype slv15_t is std_logic_vector(14 downto 0);
  type slv15_array_t is array (natural range <>) of slv15_t;

  subtype slv16_t is std_logic_vector(15 downto 0);
  type slv16_array_t is array (natural range <>) of slv16_t;
  type slv16_array_ptr_t is access slv16_array_t;

  subtype slv17_t is std_logic_vector(16 downto 0);
  type slv17_array_t is array (natural range <>) of slv17_t;

  subtype slv18_t is std_logic_vector(17 downto 0);
  type slv18_array_t is array (natural range <>) of slv18_t;

  subtype slv20_t is std_logic_vector(19 downto 0);
  type slv20_array_t is array (natural range <>) of slv20_t;
  type slv20_array_ptr_t is access slv20_array_t;

  subtype slv21_t is std_logic_vector(20 downto 0);
  type slv21_array_t is array (natural range <>) of slv21_t;
  type slv21_array_ptr_t is access slv21_array_t;

  subtype slv22_t is std_logic_vector(21 downto 0);
  type slv22_array_t is array (natural range <>) of slv22_t;
  type slv22_array_ptr_t is access slv22_array_t;

  subtype slv24_t is std_logic_vector(23 downto 0);
  type slv24_array_t is array (natural range <>) of slv24_t;
  type slv24_array_ptr_t is access slv24_array_t;

  subtype slv26_t is std_logic_vector(25 downto 0);
  type slv26_array_t is array (natural range <>) of slv26_t;

  subtype slv27_t is std_logic_vector(26 downto 0);
  type slv27_array_t is array (natural range <>) of slv27_t;

  subtype slv28_t is std_logic_vector(27 downto 0);
  type slv28_array_t is array (natural range <>) of slv28_t;

  subtype slv30_t is std_logic_vector(29 downto 0);
  type slv30_array_t is array (natural range <>) of slv30_t;

  subtype slv32_t is std_logic_vector(31 downto 0);
  type slv32_array_t is array (natural range <>) of slv32_t;
  type slv32_array_ptr_t is access slv32_array_t;

  subtype slv36_t is std_logic_vector(35 downto 0);
  type slv36_array_t is array (natural range <>) of slv36_t;

  subtype slv40_t is std_logic_vector(39 downto 0);
  type slv40_array_t is array (natural range <>) of slv40_t;

  subtype slv48_t is std_logic_vector(47 downto 0);
  type slv48_array_t is array (natural range <>) of slv48_t;
  type slv48_array_ptr_t is access slv48_array_t;

  subtype slv49_t is std_logic_vector(48 downto 0);
  type slv49_array_t is array (natural range <>) of slv49_t;

  subtype slv50_t is std_logic_vector(49 downto 0);
  type slv50_array_t is array (natural range <>) of slv50_t;

  subtype slv52_t is std_logic_vector(51 downto 0);
  type slv52_array_t is array (natural range <>) of slv52_t;

  subtype slv53_t is std_logic_vector(52 downto 0);
  type slv53_array_t is array (natural range <>) of slv53_t;

  subtype slv56_t is std_logic_vector(55 downto 0);
  type slv56_array_t is array (natural range <>) of slv56_t;

  subtype slv60_t is std_logic_vector(59 downto 0);
  type slv60_array_t is array (natural range <>) of slv60_t;

  subtype slv64_t is std_logic_vector(63 downto 0);
  type slv64_array_t is array (natural range <>) of slv64_t;
  type slv64_array_ptr_t is access slv64_array_t;

  subtype slv65_t is std_logic_vector(64 downto 0);
  type slv65_array_t is array (natural range <>) of slv65_t;

  subtype slv66_t is std_logic_vector(65 downto 0);
  type slv66_array_t is array (natural range <>) of slv66_t;

  subtype slv72_t is std_logic_vector(71 downto 0);
  type slv72_array_t is array (natural range <>) of slv72_t;

  subtype slv80_t is std_logic_vector(79 downto 0);
  type slv80_array_t is array (natural range <>) of slv80_t;

  subtype slv88_t is std_logic_vector(87 downto 0);
  type slv88_array_t is array (natural range <>) of slv88_t;

  subtype slv128_t is std_logic_vector(127 downto 0);
  type slv128_array_t is array (natural range <>) of slv128_t;

  subtype slv160_t is std_logic_vector(159 downto 0);
  type slv160_array_t is array (natural range <>) of slv160_t;

  subtype slv204_t is std_logic_vector(203 downto 0);
  type slv204_array_t is array (natural range <>) of slv204_t;

  subtype slv256_t is std_logic_vector(255 downto 0);
  type slv256_array_t is array (natural range <>) of slv256_t;

  subtype slv512_t is std_logic_vector(511 downto 0);
  type slv512_array_t is array (natural range <>) of slv512_t;

  subtype slv1024_t is std_logic_vector(1023 downto 0);
  type slv1024_array_t is array (natural range <>) of slv1024_t;

  subtype u2_t is unsigned(1 downto 0);
  type u2_array_t is array (natural range <>) of u2_t;

  subtype u3_t is unsigned(2 downto 0);
  type u3_array_t is array (natural range <>) of u3_t;

  subtype u4_t is unsigned(3 downto 0);
  type u4_array_t is array (natural range <>) of u4_t;

  subtype u5_t is unsigned(4 downto 0);
  type u5_array_t is array (natural range <>) of u5_t;

  subtype u6_t is unsigned(5 downto 0);
  type u6_array_t is array (natural range <>) of u6_t;

  subtype u7_t is unsigned(6 downto 0);
  type u7_array_t is array (natural range <>) of u7_t;

  subtype u8_t is unsigned(7 downto 0);
  type u8_array_t is array (natural range <>) of u8_t;

  subtype u9_t is unsigned(8 downto 0);
  type u9_array_t is array (natural range <>) of u9_t;

  subtype u10_t is unsigned(9 downto 0);
  type u10_array_t is array (natural range <>) of u10_t;

  subtype u12_t is unsigned(11 downto 0);
  type u12_array_t is array (natural range <>) of u12_t;

  subtype u14_t is unsigned(13 downto 0);
  type u14_array_t is array (natural range <>) of u14_t;

  subtype u16_t is unsigned(15 downto 0);
  type u16_array_t is array (natural range <>) of u16_t;

  subtype u24_t is unsigned(23 downto 0);
  type u24_array_t is array (natural range <>) of u24_t;

  subtype u32_t is unsigned(31 downto 0);
  type u32_array_t is array (natural range <>) of u32_t;

  subtype u33_t is unsigned(32 downto 0);
  type u33_array_t is array (natural range <>) of u33_t;

  subtype u38_t is unsigned(37 downto 0);
  type u38_array_t is array (natural range <>) of u38_t;

  subtype u64_t is unsigned(63 downto 0);
  type u64_array_t is array (natural range <>) of u64_t;

  subtype s8_t is signed(7 downto 0);
  type s8_array_t is array (natural range <>) of s8_t;

  subtype s16_t is signed(15 downto 0);
  type s16_array_t is array (natural range <>) of s16_t;

  subtype s24_t is signed(23 downto 0);
  type s24_array_t is array (natural range <>) of s24_t;

  subtype s32_t is signed(31 downto 0);
  type s32_array_t is array (natural range <>) of s32_t;
  type s32_array_ptr_t is access s32_array_t;

  type s33_array_t is array (natural range <>) of signed(32 downto 0);
  type s34_array_t is array (natural range <>) of signed(33 downto 0);

  subtype s64_t is signed(63 downto 0);
  type s64_array_t is array (natural range <>) of s64_t;

  type real_array_t is array (natural range <>) of real;
  type boolean_array_t is array (natural range <>) of boolean;
  type boolean_array_2d_t is array (natural range <>, natural range <>) of boolean;
  type natural_array_t is array (natural range <>) of natural;
  type positive_array_t is array (natural range <>) of positive;
  type integer_array_t is array (natural range <>) of integer;
  type integer_array_2d_t is array (natural range <>, natural range <>) of integer;

  type std_logic_2d is array (integer range <>, integer range <>) of std_logic;

  -- std_logic differential pair
  type diffpair_t is record
    p : std_logic;
    n : std_logic;
  end record;

  constant diffpair_dflt_c : diffpair_t := (p => '0',
                                            n => '1');

  type diffpair_vector_t is array (natural range <>) of diffpair_t;
  type diffpair_array_t is array (natural range <>) of diffpair_t;

  -- ddr3 signals: fpga outputs
  type ddr3_host2mem_t is
  record
    addr    : std_logic_vector(15 downto 0);
    ba      : std_logic_vector(2 downto 0);
    ras_n   : std_logic;
    cas_n   : std_logic;
    we_n    : std_logic;
    reset_n : std_logic;
    ck      : diffpair_vector_t(1 downto 0);
    cke     : std_logic_vector(1 downto 0);
    cs_n    : std_logic_vector(1 downto 0);
    odt     : std_logic_vector(1 downto 0);
    dm      : std_logic_vector(8 downto 0);
  end record;
  type ddr3_host2mem_array_t is array (natural range <>) of ddr3_host2mem_t;

  type ddr3_inout_t is
  record
    dqs : diffpair_vector_t(8 downto 0);
    dq  : std_logic_vector(71 downto 0);
  end record;
  type ddr3_inout_array_t is array (natural range <>) of ddr3_inout_t;

  -- ddr4 signals: fpga outputs
  type ddr4_host2mem_t is
  record
    addr    : std_logic_vector(17 downto 0);
    ba      : std_logic_vector(1 downto 0);
    bg      : std_logic_vector(1 downto 0);
    reset_n : std_logic;
    ck      : diffpair_vector_t(1 downto 0);
    cke     : std_logic_vector(1 downto 0);
    cs_n    : std_logic_vector(3 downto 0);
    odt     : std_logic_vector(1 downto 0);
    act_n   : std_logic;
    parity  : std_logic;
  end record;
  type ddr4_host2mem_array_t is array (natural range <>) of ddr4_host2mem_t;

  type ddr4_inout_t is
  record
    dqs : diffpair_vector_t(17 downto 0);
    dq  : std_logic_vector(71 downto 0);
    dm  : std_logic_vector(8 downto 0);
  end record;
  type ddr4_inout_array_t is array (natural range <>) of ddr4_inout_t;

  -- QDR signals: FPGA outputs
  type qdr2_x18_host2mem_t is
  record
    k      : std_logic;
    k_n    : std_logic;
    d      : std_logic_vector(17 downto 0);
    a      : std_logic_vector(20 downto 0);
    bws_n  : std_logic_vector(1 downto 0);
    wps_n  : std_logic;
    rps_n  : std_logic;
    doff_n : std_logic;
  end record;

  -- QDRII+ Memory: FPGA inputs
  type qdr2_x18_mem2host_t is
  record
    cq          : std_logic;
    cq_n        : std_logic;
    q           : std_logic_vector(17 downto 0);
    oct_rzqin   : std_logic;
    pll_ref_clk : std_logic;
  end record;

  -- QDR signals: FPGA outputs
  type qdr2_x36_host2mem_t is
  record
    k      : std_logic_vector(1 downto 0);
    k_n    : std_logic_vector(1 downto 0);
    d      : std_logic_vector(35 downto 0);
    a      : std_logic_vector(20 downto 0);
    bws_n  : std_logic_vector(3 downto 0);
    wps_n  : std_logic;
    rps_n  : std_logic;
    doff_n : std_logic;
  end record;

  -- QDRII+ Memory: FPGA inputs
  type qdr2_x36_mem2host_t is
  record
    cq          : std_logic_vector(1 downto 0);
    cq_n        : std_logic_vector(1 downto 0);
    q           : std_logic_vector(35 downto 0);
    oct_rzqin   : std_logic;
    pll_ref_clk : std_logic;
  end record;

  type i2c_type_t is
  record
    scl : std_logic;
    sda : std_logic;
  end record;

  type i2c_type_vector_t is array (natural range <>) of i2c_type_t;

  ------------------------------------------------------------------------------
  -- Functions & procedures ----------------------------------------------------
  ------------------------------------------------------------------------------

  function str_chunk (constant instr : string; constant start : integer; constant bytes : integer) return std_logic_vector;
  -- calculate ceiling(log2(arg1))
  function log2c (arg1               : natural) return natural;
  function log2c (arg1               : real) return natural;
  -- calculate floor(log2(arg1))
  function log2f (arg1               : positive) return natural;
  -- Given an integer number of states, determine the width of a vector required for representation.
  function slv_width (num_states     : natural) return positive;
  function slv_high  (num_states     : natural) return natural;
  function divc (numerator   : natural;
                 denominator : natural) return natural;

  function reverse (arg1 : std_logic_vector) return std_logic_vector;
  function reverse (arg1 : diffpair_vector_t) return diffpair_vector_t;
  function reverse (arg1 : integer_array_t) return integer_array_t;
  function reverse (arg1 : std_logic_vector;
                    grp  : natural) return std_logic_vector;
  function reverse_bytes (arg1 : std_logic_vector) return std_logic_vector;
  function to_bytes (arg1      : std_logic_vector) return byte_array_t;
  function reverse_each_slice(arg1        : std_logic_vector;
                              slice_width : integer) return std_logic_vector;
  function reverse_each_byte (arg1 : std_logic_vector) return std_logic_vector;

  function and_reduce (arg1   : std_logic_vector) return std_logic;
  function or_reduce (arg1    : std_logic_vector) return std_logic;
  function xor_reduce (arg1   : std_logic_vector) return std_logic;

  function and_reduce (arg1   : unsigned) return std_logic;
  function or_reduce (arg1    : unsigned) return std_logic;
  function xor_reduce (arg1   : unsigned) return std_logic;

  -- boolean reduction functions, not optimised for synthesis structure.
  function or_reduce (arg1    : boolean_array_t) return boolean;
  function and_reduce (arg1   : boolean_array_t) return boolean;

  -- Vivado 2023.1 does not seem to or/and reduce a boolean_array with a boolean
  -- correctly (seems to only reduce it with 1 bit of the array), so these
  -- functions perform that operation.
  function or_reduce (arg1    : boolean_array_t; arg2 : boolean) return boolean_array_t;
  function and_reduce (arg1   : boolean_array_t; arg2 : boolean) return boolean_array_t;

  function resize_slv (arg1       : std_logic_vector; arg2 : natural) return std_logic_vector;
  function to_sl (arg1            : boolean) return std_logic;
  function to_slv (arg1           : natural; arg2 : natural) return std_logic_vector;
  function to_slv (a              : boolean_array_t) return std_logic_vector;
  function to_boolean (arg1       : std_logic) return boolean;
  function to_boolean_array (arg1 : std_logic_vector) return boolean_array_t;
  function to_boolean (arg1       : integer) return boolean;
  function to_int (arg1           : boolean) return natural;
  function to_int (arg1           : std_logic) return natural;
  function imin (arg1             : integer; arg2 : integer) return integer;
  function imax (arg1             : integer; arg2 : integer) return integer;
  function imin (arg1             : integer_array_t) return integer;
  function imax (arg1             : integer_array_t) return integer;
  function imax (arg1             : positive_array_t) return positive;
  function imax (arg1             : integer_array_t; arg2 : integer_array_t) return integer_array_t;
  function rmin (arg1             : real; arg2 : real) return real;
  function rmax (arg1             : real; arg2 : real) return real;
  function sum (arg1              : boolean_array_t) return natural;
  function sum (arg1              : integer_array_t) return integer;
  function sum (arg1              : natural_array_t) return natural;
  function in_array (arg1         : integer; arg2 : integer_array_t) return boolean;
  function pos_in_array (arg1     : integer; arg2 : integer_array_t) return integer;

  function extend (arg  : std_ulogic;
                   size : natural) return std_logic_vector;
  -- Result is a std_logic_vector of length size with every element set to arg.

  function extend (arg  : string;
                   size : natural) return string;

  function extend (arg  : std_logic_vector;
                   size : natural) return std_logic_vector;
  -- Result is a std_logic_vector of length size with zero padding in the msbits

  function extend (a    : boolean_array_t;
                   size : natural;
                   fill : boolean := false) return boolean_array_t;
  -- Result is a boolean_array_t of length size with 'fill' padding in the ms entries

  function normalise (a : std_logic_vector) return std_logic_vector;
  function normalise (a : unsigned) return unsigned;

  -- Compare two octet arrays over len bytes
  function compare_buffers (
    buf1 : octet_array_t;
    buf2 : octet_array_t;
    len  : natural)
    return boolean;

  function bin_decode_simple (a  : std_logic_vector;
                              en : std_logic) return std_logic_vector;
  function bin_decode_tree (a  : std_logic_vector;
                            en : std_logic) return std_logic_vector;
  function bin_decode_chu (a  : std_logic_vector;
                           en : std_logic) return std_logic_vector;

  function pack(a : octet_array_t) return std_logic_vector;
  function pack(a : slv8_array_t) return std_logic_vector;

  function unpack(a : std_logic_vector) return octet_array_t;
  function unpack(a : std_logic_vector) return slv8_array_t;

  function count_ones(slv  : std_logic_vector) return integer;
  function count_zeros(slv : std_logic_vector) return integer;

  function count_true(a  : boolean_array_t) return integer;
  function count_false(a : boolean_array_t) return integer;

  -- priority encoder with active low input vector, msb has higher priority
  procedure priority_encode_n(vec_n        : in  std_logic_vector;
                              signal match : out std_logic;
                              signal value : out unsigned);

  -- priority encoder with active high input vector, msb has higher priority
  procedure priority_encode(vec          : in  std_logic_vector;
                            signal match : out std_logic;
                            signal value : out unsigned);

  -- priority encoder with active high input vector, lsb has higher priority
  procedure priority_encode_rev(vec          : in  std_logic_vector;
                                signal match : out std_logic;
                                signal value : out unsigned);

  function find_first(a         : std_logic_vector) return std_logic_vector;
  function encode_one_hot_slv(input_signal : std_logic_vector) return std_logic_vector;

  -- left shifts a vector by the specified number of bits
  function shift_data_left (arg1     : std_logic_vector;
                            numshift : integer
                            ) return std_logic_vector;

  -- right shifts a vector by the specified number of bits
  function shift_data_right (arg1     : std_logic_vector;
                             numshift : integer
                             ) return std_logic_vector;

  function get_incrementing (base : natural;
                            count : positive
                            ) return integer_array_t;

  function iif(test                    : boolean;
               true_value, false_value : integer)
    return integer;

  function iif(test                    : boolean;
               true_value, false_value : real)
    return real;

  function iif(test                    : boolean;
               true_value, false_value : boolean)
    return boolean;

  function iif(test                    : boolean;
               true_value, false_value : std_logic_vector)
    return std_logic_vector;

  function iif(test                    : boolean;
               true_value, false_value : unsigned)
    return unsigned;

  function iif(test                    : boolean;
               true_value, false_value : i2c_addr_array_t)
               return i2c_addr_array_t;

  function iif(test                    : boolean;
               true_value, false_value : std_logic)
    return std_logic;

  function iif(test                    : boolean;
               true_value, false_value : string)
    return string;

  function iif(test : boolean;
               true_value, false_value : integer_array_t)
               return integer_array_t;

  function iif(test                    : boolean;
               true_value, false_value : severity_level)
    return severity_level;

  function iif(test                    : boolean;
               true_value, false_value : slv64_array_t)
    return slv64_array_t;

  function iif(test                    : boolean;
               true_value, false_value : boolean_array_t)
    return boolean_array_t;

  function "-" (a, b : integer_array_t) return integer_array_t;
  function "-" (a: integer_array_t; b: integer) return integer_array_t;
  function "-" (a: integer; b: integer_array_t) return integer_array_t;

  function "**" (a: integer; b: integer_array_t) return integer_array_t;

end package metamako_pkg;

package body metamako_pkg is

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  function bool_to_str_caps (constant i : boolean) return string is
  begin
    if i then
      return "TRUE";
    else
      return "FALSE";
    end if;
  end function;

  -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  function str_chunk (
    constant instr : string;
    constant start : integer;
    constant bytes : integer)
    return std_logic_vector is
    variable retval : std_logic_vector(((bytes * 8) - 1) downto 0) := (others => '0');
  begin  -- str_chunk
    for i in 0 to (bytes-1) loop
      if start+i <= instr'high then
        retval(i*8 + 7 downto i*8) := std_logic_vector(to_unsigned(character'pos(instr(start+i)), 8));
      end if;
    end loop;  -- i
    return retval;
  end str_chunk;

  function log2c (arg1 : real) return natural is
    variable e   : real    := 1.0;
    variable res : natural := 0;
  begin
    while e < arg1 loop
      e   := e * 2.0;
      res := res + 1;
    end loop;
    return res;
  end function log2c;

  function log2c (arg1 : natural) return natural is
  begin
    return log2c(real(arg1));
  end function log2c;

  function log2f (arg1 : positive) return natural is
  begin
    return log2c(arg1 + 1) - 1;
  end function log2f;

  function slv_width (num_states : natural) return positive is
  begin
    return imax(log2c(num_states), 1);
  end function slv_width;

  function slv_high (num_states : natural) return natural is
  begin
    return slv_width(num_states) - 1;
  end function slv_high;

  --
  -- integer division with ceiling
  --
  function divc (numerator   : natural;
                 denominator : natural) return natural is
  begin
    if numerator mod denominator = 0 then
      return numerator / denominator;
    else
      return numerator / denominator + 1;
    end if;
  end function divc;

  function reverse (arg1 : std_logic_vector) return std_logic_vector is
    -- Want this to work for all slv ranges
    -- normalise the range of the input slv as x downto 0
    variable arg1_norm : std_logic_vector(arg1'length-1 downto 0) := arg1;
    -- normalised result in reverse bit order
    variable res_norm  : std_logic_vector(arg1'length-1 downto 0);
    -- result converted back to arg1 range
    variable res       : std_logic_vector(arg1'range);
  begin
    for i in arg1_norm'range loop
      res_norm(arg1_norm'high - i) := arg1_norm(i);
    end loop;
    res := res_norm;
    return res;
  end function reverse;

  function reverse (arg1 : diffpair_vector_t) return diffpair_vector_t is
    -- Want this to work for all slv ranges
    -- normalise the range of the input slv as x downto 0
    variable arg1_norm : diffpair_vector_t(arg1'length-1 downto 0) := arg1;
    -- normalised result in reverse bit order
    variable res_norm  : diffpair_vector_t(arg1'length-1 downto 0);
    -- result converted back to arg1 range
    variable res       : diffpair_vector_t(arg1'range);
  begin
    for i in arg1_norm'range loop
      res_norm(arg1_norm'high - i) := arg1_norm(i);
    end loop;
    res := res_norm;
    return res;
  end function reverse;

  function reverse (arg1 : integer_array_t) return integer_array_t is
    -- Want this to work for all ranges
    -- normalise the range of the input array as x downto 0
    variable arg1_norm : integer_array_t(arg1'length-1 downto 0) := arg1;
    -- normalised result in reverse order
    variable res_norm  : integer_array_t(arg1'length-1 downto 0);
    -- result converted back to arg1 range
    variable res       : integer_array_t(arg1'range);
  begin
    for i in arg1_norm'range loop
      res_norm(arg1_norm'high - i) := arg1_norm(i);
    end loop;
    res := res_norm;
    return res;
  end function reverse;

  function reverse_bytes(arg1 : std_logic_vector) return std_logic_vector is
    constant NUM_OCTETS_IN_ARG_C : natural                                  := arg1'length/byte_t'length;
    variable arg_downto          : std_logic_vector(arg1'length-1 downto 0) := arg1;
    variable result_norm         : std_logic_vector(arg1'length-1 downto 0);
    variable result              : std_logic_vector(arg1'range);
  begin
    -- synthesis translate_off
    assert arg1'length mod byte_t'length = 0
      report "reverse_bytes: argument must be an integer multiple of byte_t'length bits"
      severity error;
    -- synthesis translate_on
    for i in 0 to NUM_OCTETS_IN_ARG_C - 1 loop
      result_norm((i+1)*byte_t'length-1 downto i*byte_t'length)
        := arg_downto((NUM_OCTETS_IN_ARG_C-i)*byte_t'length-1 downto (NUM_OCTETS_IN_ARG_C-1-i)*byte_t'length);
    end loop;  -- i
    result := result_norm;
    return result;
  end function reverse_bytes;

  function to_bytes(arg1 : std_logic_vector) return byte_array_t is
    constant NUM_OCTETS_IN_ARG_C : natural                                  := arg1'length/byte_t'length;
    variable arg_downto          : std_logic_vector(arg1'length-1 downto 0) := arg1;
    variable result              : byte_array_t(NUM_OCTETS_IN_ARG_C-1 downto 0);
  begin
    -- synthesis translate_off
    assert arg1'length mod byte_t'length = 0
      report "to_bytes: argument must be an integer multiple of byte_t'length bits"
      severity error;
    -- synthesis translate_on
    for i in 0 to NUM_OCTETS_IN_ARG_C-1 loop
      result(i) := arg_downto((i+1)*byte_t'length-1 downto i*byte_t'length);
    end loop;  -- i
    return result;
  end function to_bytes;

  function reverse_each_slice(arg1        : std_logic_vector;
                              slice_width : integer)
    return std_logic_vector is
    constant NUM_SLICES_C : positive := arg1'length/slice_width;
    variable ret_val      : std_logic_vector(arg1'range);
  begin
    for i in 0 to NUM_SLICES_C-1 loop
      for j in 0 to slice_width-1 loop
        ret_val((i*slice_width)+j) := arg1((i+1)*slice_width-j-1);
      end loop;
    end loop;
    return ret_val;
  end function reverse_each_slice;

  -- Reverse the order of the bits within each byte but maintain the order of bytes within the word.
  -- E.g. 0x12_34 becomes 0x48_2C
  function reverse_each_byte(arg1 : std_logic_vector) return std_logic_vector is
  begin
    return reverse_each_slice(arg1, 8);
  end function reverse_each_byte;

  --! Reverses a std_logic_vector in groups.
  --! @param[in]  arg1 Vector to reverse.
  --! @param[in]  grp  Grouping. Eg. 8 gives byte reversal.
  --! @returns    Group reversed arg1 data.
  function reverse (arg1 : std_logic_vector;
                    grp  : natural) return std_logic_vector
  is
    variable arg1_norm : std_logic_vector(arg1'length-1 downto 0) := arg1;
    variable res       : std_logic_vector(arg1_norm'range);
    variable j         : natural;
  begin
    for i in 0 to arg1'length/grp-1 loop
      j                             := arg1'length/grp-1 - i;
      res((i+1)*grp-1 downto i*grp) := arg1_norm((j+1)*grp-1 downto j*grp);
    end loop;

    return res;
  end function reverse;

  --
  -- The aim is to minimise delay by creating a balanced tree of gates.
  -- Uses recursion to implement the reduce operation.
  --
  function and_reduce (arg1 : std_logic_vector) return std_logic is
    -- normalise the vector indexes
    variable norm_arg1 : std_logic_vector(arg1'length-1 downto 0) := arg1;
  begin
    case arg1'length is
      when 0 =>
        -- pragma synthesis_off
        assert false report "and_reduce : error arg1 has zero length" severity error;
        -- pragma synthesis_on
        return 'X';
      when 1 =>
        return norm_arg1(0);
      when 2 =>
        return norm_arg1(1) and norm_arg1(0);
      when others =>
        return and_reduce(norm_arg1(norm_arg1'high downto norm_arg1'length/2)) and
          and_reduce(norm_arg1(norm_arg1'length/2-1 downto 0));
    end case;  -- arg1'length
  end function and_reduce;

  function or_reduce (arg1 : std_logic_vector) return std_logic is
    -- normalise the vector indexes
    variable norm_arg1 : std_logic_vector(arg1'length-1 downto 0) := arg1;
  begin
    case arg1'length is
      when 0 =>
        -- pragma synthesis_off
        assert false report "or_reduce : error arg1 has zero length" severity error;
        -- pragma synthesis_on
        return 'X';
      when 1 =>
        return norm_arg1(0);
      when 2 =>
        return norm_arg1(1) or norm_arg1(0);
      when others =>
        return or_reduce(norm_arg1(norm_arg1'high downto norm_arg1'length/2)) or
          or_reduce(norm_arg1(norm_arg1'length/2-1 downto 0));
    end case;  -- arg1'length
  end function or_reduce;

  function xor_reduce (arg1 : std_logic_vector) return std_logic is
    -- normalise the vector indexes
    variable norm_arg1 : std_logic_vector(arg1'length-1 downto 0) := arg1;
  begin
    case arg1'length is
      when 0 =>
        -- pragma synthesis_off
        assert false report "xor_reduce : error arg1 has zero length" severity error;
        -- pragma synthesis_on
        return 'X';
      when 1 =>
        return norm_arg1(0);
      when 2 =>
        return norm_arg1(1) xor norm_arg1(0);
      when others =>
        return xor_reduce(norm_arg1(norm_arg1'high downto norm_arg1'length/2)) xor
          xor_reduce(norm_arg1(norm_arg1'length/2-1 downto 0));
    end case;  -- arg1'length
  end function xor_reduce;

  function and_reduce (arg1 : unsigned) return std_logic is
  begin
    return and_reduce(std_logic_vector(arg1));
  end function and_reduce;

  function or_reduce (arg1 : unsigned) return std_logic is
  begin
    return or_reduce(std_logic_vector(arg1));
  end function or_reduce;

  function xor_reduce (arg1 : unsigned) return std_logic is
  begin
    return xor_reduce(std_logic_vector(arg1));
  end function xor_reduce;

  ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  -- boolean reduction functions, not optimised for synthesis structure.
  ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  function or_reduce (arg1 : boolean_array_t) return boolean is
    variable r : boolean := false;
  begin
    for i in arg1'range loop
      r := r or arg1(i);
    end loop;
    --
    return r;
  end function;

  function and_reduce (arg1 : boolean_array_t) return boolean is
    variable rslt : boolean := true;
  begin
    for idx in arg1'range loop
      rslt := rslt and arg1(idx);
    end loop;
    return rslt;
  end function and_reduce;

  function or_reduce (arg1 : boolean_array_t; arg2 : boolean) return boolean_array_t is
    variable r : boolean_array_t(arg1'range);
  begin
    for i in arg1'range loop
      r(i) := arg1(i) or arg2;
    end loop;
    return r;
  end function;

  function and_reduce (arg1 : boolean_array_t; arg2 : boolean) return boolean_array_t is
    variable r : boolean_array_t(arg1'range);
  begin
    for i in arg1'range loop
      r(i) := arg1(i) and arg2;
    end loop;
    return r;
  end function;

  ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  function resize_slv (arg1 : std_logic_vector; arg2 : natural) return std_logic_vector is
  begin
    return std_logic_vector(resize(unsigned(arg1), arg2));
  end function resize_slv;

  function to_sl (arg1 : boolean) return std_logic is
  begin
    if arg1 then
      return '1';
    else
      return '0';
    end if;
  end function to_sl;

  function to_int (arg1 : boolean) return natural is
  begin
    if arg1 then
      return 1;
    else
      return 0;
    end if;
  end function to_int;

  function to_int (arg1 : std_logic) return natural is
  begin
    if arg1 = '1' then
      return 1;
    else
      return 0;
    end if;
  end function to_int;

  function to_boolean (arg1 : std_logic) return boolean is
  begin
    if arg1 = '1' or arg1 = 'H' then
      return true;
    else
      return false;
    end if;
  end function to_boolean;

  function to_boolean_array (arg1 : std_logic_vector) return boolean_array_t is
    variable r : boolean_array_t(arg1'range);
  begin
    for i in r'range loop
      r(i) := to_boolean(arg1(i));
    end loop;
    return r;
  end function to_boolean_array;

  function to_boolean (arg1 : integer) return boolean is
  begin
    if arg1 = 0 then
      return false;
    else
      return true;
    end if;
  end function to_boolean;

  function to_slv (arg1 : natural;
                   arg2 : natural) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(arg1, arg2));
  end function to_slv;

  function to_slv (a : boolean_array_t) return std_logic_vector is
    variable r : std_logic_vector(a'range);
  begin
    for i in a'range loop
      r(i) := to_sl(a(i));
    end loop;
    return r;
  end to_slv;

  function imin (arg1 : integer; arg2 : integer) return integer is
  begin
    if arg1 < arg2 then
      return arg1;
    else
      return arg2;
    end if;
  end function imin;

  function imax (arg1 : integer; arg2 : integer) return integer is
  begin
    if arg1 < arg2 then
      return arg2;
    else
      return arg1;
    end if;
  end function imax;

  function imin (arg1 : integer_array_t) return integer is
    variable tmp_res : integer;
  begin
    tmp_res := arg1(arg1'low);
    for i in arg1'low+1 to arg1'high loop
      if arg1(i) < tmp_res then
        tmp_res := arg1(i);
      end if;
    end loop;
    return tmp_res;
  end function imin;

  function imax (arg1 : integer_array_t) return integer is
    variable tmp_res : integer;
  begin
    tmp_res := arg1(arg1'low);
    for i in arg1'low+1 to arg1'high loop
      if arg1(i) > tmp_res then
        tmp_res := arg1(i);
      end if;
    end loop;
    return tmp_res;
  end function imax;

  function imax (arg1 : positive_array_t) return positive is
    variable tmp_res : positive;
  begin
    tmp_res := arg1(arg1'low);
    for i in arg1'low+1 to arg1'high loop
      if arg1(i) > tmp_res then
        tmp_res := arg1(i);
      end if;
    end loop;
    return tmp_res;
  end function imax;

  function imax (arg1 : integer_array_t; arg2 : integer_array_t) return integer_array_t is
    variable retval : integer_array_t(arg1'range);
  begin
    for i in arg1'range loop
      retval(i) := imax(arg1(i), arg2(i));
    end loop;
    return retval;
  end function imax;

  function rmin (arg1 : real; arg2 : real) return real is
  begin
    if arg1 < arg2 then
      return arg1;
    else
      return arg2;
    end if;
  end function rmin;

  function rmax (arg1 : real; arg2 : real) return real is
  begin
    if arg1 < arg2 then
      return arg2;
    else
      return arg1;
    end if;
  end function rmax;

  function sum(arg1 : integer_array_t) return integer is
    variable ret_val : integer := 0;
  begin
    for i in arg1'range loop
      ret_val := ret_val + arg1(i);
    end loop;
    return ret_val;
  end function sum;

  function sum(arg1 : natural_array_t) return natural is
    variable ret_val : natural := 0;
  begin
    for i in arg1'range loop
      ret_val := ret_val + arg1(i);
    end loop;
    return ret_val;
  end function sum;

  function sum(arg1 : boolean_array_t) return natural is
    variable ret : natural := 0;
  begin
    for i in arg1'range loop
      if arg1(i) then
        ret := ret + 1;
      end if;
    end loop;
    return ret;
  end function;

  function in_array(arg1 : integer; arg2 : integer_array_t) return boolean is
    variable ret_val : boolean := false;
  begin
    for i in arg2'range loop
      if arg1 = arg2(i) then
        ret_val := true;
      end if;
    end loop;
    return ret_val;
  end function in_array;

  function pos_in_array(arg1 : integer; arg2 : integer_array_t) return integer is
    variable ret_val : integer := -1;
  begin
    for i in arg2'range loop
      if arg1 = arg2(i) then
        ret_val := i;
        exit;
      end if;
    end loop;
    return ret_val;
  end function pos_in_array;

  function extend (arg  : std_ulogic;
                   size : natural) return std_logic_vector is
    variable res : std_logic_vector(size-1 downto 0);
  begin
    res := (others => arg);
    return res;
  end function extend;

  function extend (arg  : string;
                   size : natural) return string is
    variable res : string(1 to size) := (others => ' ');
  begin
    for i in 1 to arg'length loop
      res(i) := arg(i);
      exit when i >= size;
    end loop;
    return res;
  end function extend;

  function extend (arg  : std_logic_vector;
                   size : natural) return std_logic_vector is
    variable res : std_logic_vector(size-1 downto 0);
  begin
    -- pragma synthesis_off
    assert size >= arg'length
      report "size is smaller than arg"
      severity error;
    -- pragma synthesis_on
    res := std_logic_vector(resize(unsigned(arg), size));
    return res;
  end function extend;

  function extend (a    : boolean_array_t;
                   size : natural;
                   fill : boolean := false) return boolean_array_t is
    variable r : boolean_array_t(size-1 downto 0) := (others => fill);
  begin
    r(a'length-1 downto 0) := a;
    return r;
  end extend;

  function normalise (a : std_logic_vector) return std_logic_vector is
    variable a_norm : std_logic_vector(a'length-1 downto 0) := a;
  begin
    return a_norm;
  end function normalise;

  function normalise (a : unsigned) return unsigned is
    variable a_norm : unsigned(a'length-1 downto 0) := a;
  begin
    return a_norm;
  end function normalise;

  function compare_buffers (
    buf1 : octet_array_t;
    buf2 : octet_array_t;
    len  : natural)
    return boolean is
  begin  -- compare_buffers
    for i in 0 to (len-1) loop
      if buf1(i + buf1'left) /= buf2(i + buf2'left) then
        return false;
      end if;
    end loop;  -- i
    return true;
  end compare_buffers;

  function bin_decode_simple (a  : std_logic_vector;
                              en : std_logic) return std_logic_vector is
    variable result : std_logic_vector(2**a'length-1 downto 0) := (others => '0');
  begin
    result(to_integer(unsigned(a))) := en;
    return result;
  end function bin_decode_simple;

  function bin_decode_tree (a  : std_logic_vector;
                            en : std_logic) return std_logic_vector is
    variable norm_a : std_logic_vector(a'length-1 downto 0) := a;
    variable result : std_logic_vector(2**a'length-1 downto 0);
  begin
    case a'length is
      when 0 =>
        return result;
      when 1 =>
        -- put lsbit on left and msbit on the right since the others clause seems to assume the bits are returned this way round
        result := (1 => (not norm_a(0) and en), 0 => (norm_a(0) and en));
        return result;
      when others =>
        result := bin_decode_tree(norm_a(norm_a'high-1 downto 0), norm_a(norm_a'high) and en) &
                  bin_decode_tree(norm_a(norm_a'high-1 downto 0), not norm_a(norm_a'high) and en);
        return result;
    end case;  -- arg1'length
  end function bin_decode_tree;

  --
  -- From Pong P Chu
  -- RTL Hardware Design Using VHDL : Coding for Efficiency, Portability and Scalability,
  -- 2006, John Wiley and Sons,
  -- Listing 15.7 Parameterised tree-shaped binary decoder
  --
  function bin_decode_chu (a  : std_logic_vector;
                           en : std_logic) return std_logic_vector is
    constant STAGE_C : natural := a'length;
    variable p       : std_logic_2d(STAGE_C downto 0, 2**STAGE_C-1 downto 0);
    variable result  : std_logic_vector(2**a'length-1 downto 0);
  begin
    p(STAGE_C, 0) := en;

    for s in STAGE_C downto 1 loop
      for r in 0 to natural(2**(STAGE_C-1)-1) loop
        p(s-1, 2*r)   := (not a(s-1)) and p(s, r);
        p(s-1, 2*r+1) := a(s-1) and p(s, r);
      end loop;
    end loop;

    for i in 0 to natural(2**STAGE_C-1) loop
      result(i) := p(0, i);
    end loop;

    return result;
  end function bin_decode_chu;

  function pack(a : octet_array_t) return std_logic_vector is
    variable r : std_logic_vector(a'length * 8 - 1 downto 0);
    alias a_a  : octet_array_t(a'length - 1 downto 0) is a;
  begin
    for i in a_a'range loop
      r(8 * (i + 1) - 1 downto 8 * i) := a_a(i);
    end loop;
    --
    return r;
  end function;

  function pack(a : slv8_array_t) return std_logic_vector is
    variable r : std_logic_vector(a'length * 8 - 1 downto 0);
    alias a_a  : slv8_array_t(a'length - 1 downto 0) is a;
  begin
    for i in a_a'range loop
      r(8 * (i + 1) - 1 downto 8 * i) := a_a(i);
    end loop;
    --
    return r;
  end function;

  function unpack(a : std_logic_vector) return octet_array_t is
    variable r : octet_array_t(a'length / 8 - 1 downto 0);
    alias a_a  : std_logic_vector(a'length - 1 downto 0) is a;
  begin
    for i in r'range loop
      r(i) := a_a(8 * (i + 1) - 1 downto 8 * i);
    end loop;
    return r;
  end function;

  function unpack(a : std_logic_vector) return slv8_array_t is
    variable r : slv8_array_t(a'length / 8 - 1 downto 0);
    alias a_a  : std_logic_vector(a'length - 1 downto 0) is a;
  begin
    for i in r'range loop
      r(i) := a_a(8 * (i + 1) - 1 downto 8 * i);
    end loop;
    return r;
  end function;

  procedure priority_encode_n(vec_n        : in  std_logic_vector;
                              signal match : out std_logic;
                              signal value : out unsigned) is
    variable normalised_vec_n : std_logic_vector(vec_n'length-1 downto 0);
    variable ret_dont_care    : unsigned(log2c(vec_n'length)-1 downto 0) := (others => '-');
  begin
    normalised_vec_n := vec_n;
    for i in natural(vec_n'length-1) downto 0 loop
      value <= to_unsigned(i, value'length);
      if normalised_vec_n(i) = '0' then
        match <= '1';
        return;
      end if;
    end loop;
    match <= '0';
    value <= ret_dont_care;
  end procedure priority_encode_n;

  -- This function counts the number of ones in a std_logic_vector
  function count_ones(slv : std_logic_vector) return integer is
    variable count : natural := 0;
  begin
    for i in slv'range loop
      if slv(i) = '1' then count := count + 1;
      end if;
    end loop;
    return count;
  end function count_ones;

  -- This function counts the number of zeros in a std_logic_vector
  function count_zeros(slv : std_logic_vector) return integer is
    variable count : natural := 0;
  begin
    for i in slv'range loop
      if slv(i) = '0' then count := count + 1;
      end if;
    end loop;
    return count;
  end function count_zeros;

  -- This function counts the number of trues in a std_logic_vector
  function count_true(a : boolean_array_t) return integer is
    variable count : natural := 0;
  begin
    for i in a'range loop
      if a(i) then
        count := count + 1;
      end if;
    end loop;
    return count;
  end function count_true;

  -- This function counts the number of falses in a std_logic_vector
  function count_false(a : boolean_array_t) return integer is
    variable count : natural := 0;
  begin
    for i in a'range loop
      if not a(i) then
        count := count + 1;
      end if;
    end loop;
    return count;
  end function count_false;

  procedure priority_encode(vec          : in  std_logic_vector;
                            signal match : out std_logic;
                            signal value : out unsigned) is
    variable normalised_vec : std_logic_vector(vec'length-1 downto 0);
    variable ret_dont_care  : unsigned(log2c(vec'length)-1 downto 0) := (others => '-');
  begin
    normalised_vec := vec;
    for i in natural(vec'length-1) downto 0 loop
      value <= to_unsigned(i, value'length);
      if normalised_vec(i) = '1' then
        match <= '1';
        return;
      end if;
    end loop;
    match <= '0';
    value <= ret_dont_care;
  end procedure priority_encode;

  procedure priority_encode_rev(vec          : in  std_logic_vector;
                                signal match : out std_logic;
                                signal value : out unsigned) is
    variable normalised_vec : std_logic_vector(vec'length-1 downto 0);
    variable ret_dont_care  : unsigned(log2c(vec'length)-1 downto 0) := (others => '-');
  begin
    normalised_vec := vec;
    match <= '0';
    for i in 0 to natural(vec'length-1) loop
      value <= to_unsigned(i, value'length);
      if normalised_vec(i) = '1' then
        match <= '1';
        return;
      end if;
    end loop;
    value <= ret_dont_care;
  end procedure priority_encode_rev;

  function find_first(a : std_logic_vector)
    return std_logic_vector is
    variable r : std_logic_vector(a'range);
  begin
    r(a'right) := a(a'right);
    for i in a'right+1 to a'left loop
      r(i) := a(i) and not or_reduce(a(i-1 downto a'right));
    end loop;
    return r;
  end;

  ---- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  function encode_one_hot_slv(input_signal : std_logic_vector)
    return std_logic_vector is
    variable result_vector   : std_logic_vector(log2c(input_signal'length)-1 downto 0);
    variable extended_signal : std_logic_vector(2*input_signal'length-1 downto 0);
    variable temp_vector     : std_logic_vector(input_signal'range);
    variable start_position  : integer := 0;
    variable window_size     : integer := 0;
    variable step_size       : integer := 0;
    variable current_index   : integer := 0;
    variable bit_index       : integer := 0;
  begin
    -- steps are:
    --  * start at 1, 1 bit window, 2 bit step
    --  * start at 2, 2 bit window, 4 bit step
    --  * start at 4, 4 bit window, 8 bit step
    --  * start at 8, 8 bit window, 16 bit step

    extended_signal                     := (others => '0');
    extended_signal(input_signal'range) := input_signal;
    start_position                      := 1;
    for loop_index in result_vector'range loop
      start_position := 2**loop_index;
      window_size    := start_position - 1;
      step_size      := 2**(loop_index+1);
      current_index  := start_position;
      temp_vector    := (others => '0');
      bit_index      := 0;
      while current_index + window_size < extended_signal'length loop
        temp_vector(bit_index)  := or_reduce(extended_signal(current_index + window_size downto current_index));
        bit_index               := bit_index + 1;
        current_index           := current_index + step_size;
      end loop;
      result_vector(loop_index) := or_reduce(temp_vector(bit_index-1 downto 0));
    end loop; -- loop_index
    return result_vector;
  end;

  function shift_data_left(arg1 : std_logic_vector; numshift : integer) return std_logic_vector is
    variable zero_c : std_logic_vector(numshift-1 downto 0) := (others => '0');
    variable result : std_logic_vector(arg1'range);
  begin
    result := arg1(arg1'length-(numshift+1) downto 0) & zero_c;
    return result;
  end function shift_data_left;

  function shift_data_right(arg1 : std_logic_vector; numshift : integer) return std_logic_vector is
    variable zero_c : std_logic_vector(numshift-1 downto 0) := (others => '0');
    variable result : std_logic_vector(arg1'range);
  begin
    result := zero_c & arg1(arg1'length-1 downto numshift);
    return result;
  end function shift_data_right;

  function get_incrementing (base : natural; count : positive) return integer_array_t is
    variable r : integer_array_t(0 to count - 1);
  begin
    for i in r'range loop
      r(i) := base + i;
    end loop;
    return r;
  end function;

  function iif(test                    : boolean;
               true_value, false_value : boolean)
    return boolean is
  begin
    if test then
      return true_value;
    else
      return false_value;
    end if;
  end function;

  function iif(test                    : boolean;
               true_value, false_value : integer)
    return integer is
  begin
    if test then
      return true_value;
    else
      return false_value;
    end if;
  end function;

  function iif(test                    : boolean;
               true_value, false_value : real)
    return real is
  begin
    if test then
      return true_value;
    else
      return false_value;
    end if;
  end function;

  function iif(test                    : boolean;
               true_value, false_value : std_logic_vector)
    return std_logic_vector is
  begin
    if test then
      return true_value;
    else
      return false_value;
    end if;
  end function;

  function iif(test                    : boolean;
               true_value, false_value : unsigned)
    return unsigned is
  begin
    if test then
      return true_value;
    else
      return false_value;
    end if;
  end function;

  function iif(test                    : boolean;
               true_value, false_value : i2c_addr_array_t)
    return i2c_addr_array_t is
  begin
    if test then
      return true_value;
    else
      return false_value;
    end if;
  end function;

  function iif(test                    : boolean;
               true_value, false_value : std_logic)
    return std_logic is
  begin
    if test then
      return true_value;
    else
      return false_value;
    end if;
  end function;

  function iif(test                    : boolean;
               true_value, false_value : string)
    return string is
  begin
    if test then
      return true_value;
    else
      return false_value;
    end if;
  end function;

  function iif(test                    : boolean;
               true_value, false_value : integer_array_t)
    return integer_array_t is
  begin
    if test then
      return true_value;
    else
      return false_value;
    end if;
  end function;

  function iif(test                    : boolean;
               true_value, false_value : severity_level)
    return severity_level is
  begin
    if test then
      return true_value;
    else
      return false_value;
    end if;
  end function;

  function iif(test                    : boolean;
               true_value, false_value : slv64_array_t)
    return slv64_array_t is
  begin
    if test then
      return true_value;
    else
      return false_value;
    end if;
  end function;

  function iif(test                    : boolean;
               true_value, false_value : boolean_array_t)
    return boolean_array_t is
  begin
    if test then
      return true_value;
    else
      return false_value;
    end if;
  end function;

  function "-" (a, b : integer_array_t)
    return integer_array_t is
    variable retval : integer_array_t(a'range);
  begin
    assert a'length = b'length report "can't subtract different length vectors" severity error;
    for i in a'range loop
      retval(i) := a(i) - b(i);
    end loop;
    return retval;
  end function;

  function "-" (a: integer_array_t; b: integer)
    return integer_array_t is
    variable retval : integer_array_t(a'range);
  begin
    for i in a'range loop
      retval(i) := a(i) - b;
    end loop;
    return retval;
  end function;

  function "-" (a: integer; b: integer_array_t)
    return integer_array_t is
    variable retval : integer_array_t(b'range);
  begin
    for i in b'range loop
      retval(i) := a - b(i);
    end loop;
    return retval;
  end function;

  function "**" (a: integer; b: integer_array_t) return integer_array_t is
    variable retval : integer_array_t(b'range);
  begin
    for i in b'range loop
      retval(i) := a ** b(i);
    end loop;
    return retval;
  end function;

end package body metamako_pkg;

--
