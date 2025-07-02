--------------------------------------------------------------------------------
-- Copyright (c) 2017 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Maintainers:
--   fdk-support@arista.com
--
-- Description:
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
use std.textio.all;

use work.metamako_pkg.all;

package fpga_spec_pkg is

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------

  -- Cls : Class (FPGA, CPLD, etc)
  -- Mfg : Manufacture
  -- Dev : Device Name
  -- Spd : Speed Grade (where 32(L) = XCVR Speed 3; Fabric Speed 2; Other Info (LowVoltage, etc))
  --                           Cls  Mfg    Dev    Spd
  type mm_fpga_target_t is (MM_FPGA_XILINX_XC7VX415T_22,
                            MM_FPGA_ALTERA_10AX115_32,
                            MM_FPGA_XILINX_XCVU9P_22L,
                            MM_FPGA_XILINX_XCVU190_22,
                            MM_FPGA_XILINX_XCKU095_22,
                            MM_FPGA_XILINX_XCVU9P_22I,
                            MM_FPGA_XILINX_XCKU060_22,
                            MM_FPGA_XILINX_XCVU9P_33,
                            MM_FPGA_XILINX_XCVU7P_22,
                            MM_FPGA_XILINX_XCVH1582_22,
                            MM_FPGA_XILINX_XCVH1542_33,
                            MM_FPGA_XILINX_XC7K70T_22,
                            MM_FPGA_XILINX_XC7A50T_11,
                            MM_FPGA_XILINX_XC7A50T_22,
                            MM_FPGA_MICROSEMI_M2GL005,
                            MM_FPGA_MICROSEMI_M2GL025T
                            );

  type mm_fpga_family_t is (MM_FPGA_7SERIES,
                            MM_FPGA_ARRIA10,
                            MM_FPGA_ULTRASCALEP,
                            MM_FPGA_ULTRASCALE,
                            MM_FPGA_VERSALHBM,
                            MM_FPGA_IGLOO2);

  type mm_fpga_manufacturer_t is (MM_FPGA_XILINX,
                                  MM_FPGA_ALTERA,
                                  MM_FPGA_MICROSEMI);

  type mm_fpga_gt_type_t is (MM_GTX,
                             MM_GTH,
                             MM_GTY,
                             MM_GTYP,
                             MM_GTM,
                             MM_GTP);


  -- Currently this is relevant for EMU only...
  type mm_fpga_position_t is (MM_FPGA_POSITION_LEAF,
                              MM_FPGA_POSITION_CENTRAL);

  type mm_fpga_hbm_info_t is record
    base_addr     : slv64_t;
    devices       : integer;
    stacks        : integer;
    axi_freq_mhz  : real;
    size_log2     : integer;
  end record;

  type mm_fpga_hbm_bus_alloc_t is record
    axi_freq_mhz  : real;
    base_addr     : slv64_array_t(63 downto 0);
    size_log2     : integer_array_t(63 downto 0);
  end record;

  ------------------------------------------------------------------------------
  -- Functions
  ------------------------------------------------------------------------------

  function mm_get_fpga_manufacturer (constant i : mm_fpga_target_t) return mm_fpga_manufacturer_t;
  function mm_get_fpga_manufacturer (constant i : mm_fpga_target_t) return string;                            -- Overload
  function mm_get_fpga_family       (constant i : mm_fpga_target_t) return mm_fpga_family_t;
  function mm_get_fpga_family       (constant i : string) return mm_fpga_family_t;                            -- Overload
  function mm_get_fpga_gt_type      (constant i : string) return mm_fpga_gt_type_t;
  function mm_get_fpga_gt_type      (constant i : mm_fpga_target_t; qidx : natural) return mm_fpga_gt_type_t; -- Overload
  function mm_get_fpga_num_slr      (constant i : mm_fpga_target_t) return natural;
  function mm_get_fpga_num_hbmstk   (constant i : mm_fpga_target_t) return natural;
  function mm_get_fpga_hbm_info     (constant i : mm_fpga_target_t) return mm_fpga_hbm_info_t;
  function mm_get_fpga_hbm_bus_alloc(constant i : mm_fpga_target_t; wr_loc: integer_array_t; rd_loc: integer_array_t; bus_weights_log2: integer_array_t) return mm_fpga_hbm_bus_alloc_t;

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------

  constant MM_FPGA_HBM_INFO_DFLT_C : mm_fpga_hbm_info_t := (
    base_addr    => (others => '0'),
    devices      => 0,
    stacks       => 0,
    axi_freq_mhz => 0.0,
    size_log2    => 0
  );

  constant MM_FPGA_HBM_BUS_ALLOC_DFLT_C : mm_fpga_hbm_bus_alloc_t := (
    axi_freq_mhz => 0.0,
    size_log2    => (others => 0),
    base_addr    => (others => (others => '0'))
  );

end package fpga_spec_pkg;

package body fpga_spec_pkg is

  function mm_get_fpga_manufacturer (constant i : mm_fpga_target_t) return mm_fpga_manufacturer_t is
  begin
    case i is
      when MM_FPGA_ALTERA_10AX115_32  => return MM_FPGA_ALTERA;
      when MM_FPGA_MICROSEMI_M2GL005  => return MM_FPGA_MICROSEMI;
      when MM_FPGA_MICROSEMI_M2GL025T => return MM_FPGA_MICROSEMI;
      when others                     => return MM_FPGA_XILINX;
    end case;
  end function;

  function mm_get_fpga_manufacturer (constant i : mm_fpga_target_t) return string is
  begin
    case i is
      when MM_FPGA_ALTERA_10AX115_32  => return "ALTERA";
      when MM_FPGA_MICROSEMI_M2GL005  => return "MICROSEMI";
      when MM_FPGA_MICROSEMI_M2GL025T => return "MICROSEMI";
      when others                     => return "XILINX";
    end case;
  end function;

  function mm_get_fpga_family (constant i : mm_fpga_target_t) return mm_fpga_family_t is
  begin
    case i is
      when MM_FPGA_XILINX_XCVU7P_22    => return MM_FPGA_ULTRASCALEP;
      when MM_FPGA_XILINX_XCVU9P_33    => return MM_FPGA_ULTRASCALEP;
      when MM_FPGA_XILINX_XCVU9P_22L   => return MM_FPGA_ULTRASCALEP;
      when MM_FPGA_XILINX_XCVU9P_22I   => return MM_FPGA_ULTRASCALEP;
      when MM_FPGA_XILINX_XCVU190_22   => return MM_FPGA_ULTRASCALE;
      when MM_FPGA_XILINX_XCKU095_22   => return MM_FPGA_ULTRASCALE;
      when MM_FPGA_XILINX_XCVH1582_22  => return MM_FPGA_VERSALHBM;
      when MM_FPGA_XILINX_XCVH1542_33  => return MM_FPGA_VERSALHBM;
      when MM_FPGA_XILINX_XC7VX415T_22 => return MM_FPGA_7SERIES;
      when MM_FPGA_XILINX_XC7K70T_22   => return MM_FPGA_7SERIES;
      when MM_FPGA_XILINX_XC7A50T_11   => return MM_FPGA_7SERIES;
      when MM_FPGA_XILINX_XC7A50T_22   => return MM_FPGA_7SERIES;
      when MM_FPGA_ALTERA_10AX115_32   => return MM_FPGA_ARRIA10;
      when MM_FPGA_MICROSEMI_M2GL005   => return MM_FPGA_IGLOO2;
      when MM_FPGA_MICROSEMI_M2GL025T  => return MM_FPGA_IGLOO2;
      when others                      => assert false report "Unknown FPGA target specified in mm_get_fpga_family" severity failure;
                     return MM_FPGA_7SERIES;  -- Return should never be used, but this keeps the tools happy
    end case;
  end function;

  function mm_get_fpga_family (constant i : string) return mm_fpga_family_t is
  begin
    if i = "E_CENTRAL" or i = "E_LEAF" then
      return MM_FPGA_ULTRASCALE;
    elsif i = "EH_CENTRAL" or i = "EH_LEAF" or i = "L" or i = "LB2" then
      return MM_FPGA_ULTRASCALEP;
    elsif i = "BVL" then
      return MM_FPGA_VERSALHBM;
    else
      assert false report "Unknown FPGA target specified in mm_get_fpga_family" severity failure;
      return MM_FPGA_ULTRASCALEP;
    end if;
  end function;

  function mm_get_fpga_gt_type (constant i : string) return mm_fpga_gt_type_t is
    variable gt_type : mm_fpga_gt_type_t;
  begin
    if i = "GTH" then
      gt_type := MM_GTH;
    elsif i = "GTY" then
      gt_type := MM_GTY;
    elsif i = "GTX" then
      gt_type := MM_GTX;
    elsif i = "GTP" then
      gt_type := MM_GTP;
    elsif i = "GTYP" then
      gt_type := MM_GTYP;
    elsif i = "GTM" then
      gt_type := MM_GTM;
    else
      -- pragma synthesis_off
      assert false report "In-correct value for GT_TYPE";
    -- pragma synthesis_on
    end if;
    return gt_type;
  end function;

  function mm_get_fpga_gt_type (constant i : mm_fpga_target_t; qidx : natural) return mm_fpga_gt_type_t is
  begin
    case i is
      when MM_FPGA_XILINX_XCVU7P_22    => return MM_GTY;
      when MM_FPGA_XILINX_XCVU9P_33    => return MM_GTY;
      when MM_FPGA_XILINX_XCVU9P_22L   => return MM_GTY;
      when MM_FPGA_XILINX_XCVU9P_22I   => return MM_GTY;
      when MM_FPGA_XILINX_XCVU190_22   => if qidx >= 24/4 then
                                            return MM_GTY;
                                          else
                                            return MM_GTH;
                                          end if;
      when MM_FPGA_XILINX_XCKU095_22   => if qidx >= 24/4 then
                                            return MM_GTY;
                                          else
                                            return MM_GTH;
                                          end if;
      when MM_FPGA_XILINX_XCVH1542_33  => if qidx >= 13 then
                                            return MM_GTM;
                                          else
                                            return MM_GTYP;
                                          end if;
      when MM_FPGA_XILINX_XCVH1582_22  => return MM_GTYP;
      when MM_FPGA_XILINX_XC7K70T_22   => return MM_GTX;
      when MM_FPGA_XILINX_XC7A50T_11   => return MM_GTP;
      when MM_FPGA_XILINX_XC7A50T_22   => return MM_GTP;
      when others                      => assert false report "Unsupported FPGA target specified in mm_get_fpga_gt_type" severity failure;
                                          return MM_GTY;  -- Return should never be used, but this keeps the tools happy
    end case;
  end function;

  function mm_get_fpga_num_slr (constant i : mm_fpga_target_t) return natural is
  begin
    case i is
      when MM_FPGA_XILINX_XCVU7P_22    => return 2;
      when MM_FPGA_XILINX_XCVU9P_33    => return 3;
      when MM_FPGA_XILINX_XCVU9P_22L   => return 3;
      when MM_FPGA_XILINX_XCVU9P_22I   => return 3;
      when MM_FPGA_XILINX_XCVU190_22   => return 3;
      when MM_FPGA_XILINX_XCKU095_22   => return 1;
      when MM_FPGA_XILINX_XCVH1582_22  => return 2;
      when MM_FPGA_XILINX_XCVH1542_33  => return 2;
      when MM_FPGA_XILINX_XC7VX415T_22 => return 1;
      when MM_FPGA_XILINX_XC7K70T_22   => return 1;
      when MM_FPGA_XILINX_XC7A50T_11   => return 1;
      when MM_FPGA_XILINX_XC7A50T_22   => return 1;
      when MM_FPGA_ALTERA_10AX115_32   => return 1;
      when MM_FPGA_MICROSEMI_M2GL005   => return 1;
      when MM_FPGA_MICROSEMI_M2GL025T  => return 1;
      when others                      => assert false report "Unsupported FPGA target specified in mm_get_fpga_num_slr" severity failure;
                                          return 1;  -- Return should never be used, but this keeps the tools happy
    end case;
  end function;

  function mm_get_fpga_num_hbmstk (constant i : mm_fpga_target_t) return natural is
  begin
    case i is
      when MM_FPGA_XILINX_XCVH1582_22  => return 2;
      when MM_FPGA_XILINX_XCVH1542_33  => return 2;
      when others                      => return 0;
    end case;
  end function;

  function mm_get_fpga_hbm_info     (constant i : mm_fpga_target_t) return mm_fpga_hbm_info_t is
    variable ret: mm_fpga_hbm_info_t := MM_FPGA_HBM_INFO_DFLT_C;
  begin
    case i is
      when MM_FPGA_XILINX_XCVH1582_22 =>
        -- 32 GB
        ret.base_addr     := x"0000_0040_0000_0000";
        ret.devices       := 16;
        ret.stacks        := 2;
        ret.axi_freq_mhz  := 425.0;
        ret.size_log2     := 35;
      when MM_FPGA_XILINX_XCVH1542_33 =>
        -- 16 GB
        ret.base_addr     := x"0000_0040_0000_0000";
        ret.devices       := 16;
        ret.stacks        := 2;
        ret.axi_freq_mhz  := 450.0;
        ret.size_log2     := 34;
      when others =>
    end case;
    return ret;
  end function;

  function find_lowest(a: integer_array_t) return integer is
    constant min_val: integer := imin(a);
  begin
    for i in a'range loop
      if a(i) = min_val then
        return i;
      end if;
    end loop;
    return -1;
  end function;

  function sort_hbm_buses(bus_weights: integer_array_t) return integer_array_t is
    constant bus_weights_max : integer := imax(bus_weights);
    variable bus_weights_v   : integer_array_t(bus_weights'range) := bus_weights;
    variable ret: integer_array_t(bus_weights'range) := (others => 0);
    variable idx: integer := 0;
  begin
    for i in bus_weights'range loop
      idx := find_lowest(bus_weights_v);
      bus_weights_v(idx) := bus_weights_max + 1;
      ret(i) := idx;
    end loop;
    return ret;
  end function;

  -- The HBM memory mapping is based upon the Versal structure where the device is
  -- grouped with 8 AXI ports with full access to every 2 HBM devices.
  -- The CIPS block diagram needs to be set up appropriately to do this (bvl_cips_ph)
  -- has this configuration set up as an example.
  -- This function divides the memory up evenly based upon the assignments (after
  -- checking if it is valid).
  function mm_get_fpga_hbm_bus_alloc(constant i : mm_fpga_target_t; wr_loc: integer_array_t; rd_loc: integer_array_t; bus_weights_log2: integer_array_t) return mm_fpga_hbm_bus_alloc_t is
    constant sev: severity_level := iif(IN_SIMULATION_C, WARNING, FAILURE);
    constant hbm_info: mm_fpga_hbm_info_t := mm_get_fpga_hbm_info(i);
    constant num_buses: integer := wr_loc'length;
    constant bus_weights: integer_array_t := 2 ** (bus_weights_log2 - imin(bus_weights_log2));
    constant bus_weights_sum : integer := 2 ** log2c(sum(bus_weights));
    constant sort : integer_array_t(bus_weights_log2'range) := sort_hbm_buses(bus_weights_log2);
    constant max_num_buses: integer := hbm_info.devices * 4;
    -- max allocation available in each 8 bus array
    constant max_share : integer := bus_weights_sum / 8;
    variable max_bus_size: integer := imax(20, hbm_info.size_log2 - log2c(hbm_info.devices) + 1);
    constant addr_share : integer :=  2**(max_bus_size - 20) / (bus_weights_sum / 8);
    constant bus_size: integer := 2**(max_bus_size - 20);
    constant split_size: integer := 2**(max_bus_size - log2c(bus_weights_sum / 8) - 20);
    variable wr_bus_used: boolean_array_t(0 to 63) := (others => false);
    variable rd_bus_used: boolean_array_t(0 to 63) := (others => false);
    variable share: integer_array_t(0 to 7) := (others => 0);
    variable base_addr: u64_t;
    variable failed : boolean := false;
    variable max_num_buses_core: integer;
    variable wr_loc_i     : integer;
    variable rd_loc_i     : integer;
    variable bus_weight_i : integer;
    variable ret: mm_fpga_hbm_bus_alloc_t;
  begin
    -- if there are no devices, just return the structure
    if hbm_info.devices = 0 then
      return MM_FPGA_HBM_BUS_ALLOC_DFLT_C;
    end if;

    ret.axi_freq_mhz := hbm_info.axi_freq_mhz;
--    report "HBM Bus: Size " & integer'image(ret.size_log2) & " (" & integer'image(2 ** (ret.size_log2 - 20)) & " MB) " & integer'image(log2c(num_buses / 8)) severity NOTE;
    assert false report "HBM Bus: Device Offset - " & integer'image(max_bus_size) & " Split Offset - " & integer'image(max_bus_size - log2c(num_buses / 8)) severity NOTE;

    assert wr_loc'left = bus_weights_log2'left and wr_loc'left = rd_loc'left report "HBM Bus Error: Weight, Write and Read bus lengths are not the same" severity sev;
    assert wr_loc'right = bus_weights_log2'right and wr_loc'right = rd_loc'right report "HBM Bus Error: Weight, Write and Read bus lengths are not the same" severity sev;

    for i in wr_loc'range loop
      wr_loc_i := wr_loc(sort(i));
      rd_loc_i := rd_loc(sort(i));
      bus_weight_i := bus_weights(sort(i));

      assert wr_loc_i < max_num_buses report "HBM Bus Error: write bus outside range (0 - " & integer'image(max_num_buses - 1) & ")" severity FAILURE;
      assert rd_loc_i < max_num_buses report "HBM Bus Error: read bus outside range (0 - " & integer'image(max_num_buses - 1) & ")" severity FAILURE;

      if wr_bus_used(wr_loc_i) then
        assert false report "HBM Bus Error: write bus & " & integer'image(wr_loc_i) & " is used multiple times" severity WARNING;
        failed := true;
      end if;
      -- check to make sure read bus is unique
      if rd_bus_used(rd_loc_i) then
        assert false report "HBM Bus Error: read bus & " & integer'image(rd_loc_i) & " is used multiple times" severity WARNING;
        failed := true;
      end if;

      -- check to make sure of overlapping memory access
      if (wr_loc_i / 8) /= (rd_loc_i / 8) then
        assert false report "HBM Bus Error: write and read bus not in corresponding memory area, cannot operate. Index: " & integer'image(i) severity WARNING;
        failed := true;
      else
        base_addr := unsigned(hbm_info.base_addr);
        base_addr(63 downto 20) := base_addr(63 downto 20) + bus_size * (wr_loc_i / 8);
        base_addr(63 downto 20) := base_addr(63 downto 20) + split_size * share(wr_loc_i / 8);
        ret.base_addr(sort(i)) := std_logic_vector(base_addr);
        ret.size_log2(sort(i)) := log2c(split_size) + 20 + log2c(bus_weight_i);
        assert false report "HBM Bus Index: " & integer'image(i) & " (WR_LOC: " & integer'image(wr_loc_i) & " RD_LOC: " & integer'image(rd_loc_i) & ") Base Address: " & to_hstring(ret.base_addr(sort(i))) severity NOTE;
        share(wr_loc_i / 8) := share(wr_loc_i / 8) + bus_weight_i;
        if share(wr_loc_i / 8) > max_share then
          assert false report "HBM Bus Error: too many buses in the same area at index: " & integer'image(i) severity WARNING;
          failed := true;
        end if;
      end if;
    end loop;

    assert not failed report "HBM Bus Error: Failed (see previous messages for details)" severity FAILURE;
    if IN_SIMULATION_C and failed then
      return MM_FPGA_HBM_BUS_ALLOC_DFLT_C;
    end if;
    return ret;
  end function;


end package body fpga_spec_pkg;
