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

  ------------------------------------------------------------------------------
  -- Functions
  ------------------------------------------------------------------------------

  function mm_get_fpga_manufacturer (constant i : mm_fpga_target_t) return mm_fpga_manufacturer_t;
  function mm_get_fpga_manufacturer (constant i : mm_fpga_target_t) return string;                            -- Overload
  function mm_get_fpga_family       (constant i : mm_fpga_target_t) return mm_fpga_family_t;
  function mm_get_fpga_family       (constant i : string) return mm_fpga_family_t;                            -- Overload
  function mm_get_fpga_target       (constant i : string) return mm_fpga_target_t;
  function mm_get_fpga_gt_type      (constant i : string) return mm_fpga_gt_type_t;
  function mm_get_fpga_gt_type      (constant i : mm_fpga_target_t; qidx : natural) return mm_fpga_gt_type_t; -- Overload
  function mm_get_fpga_num_slr      (constant i : mm_fpga_target_t) return natural;
  function mm_get_fpga_num_hbmstk   (constant i : mm_fpga_target_t) return natural;

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------


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

  function mm_get_fpga_target (constant i : string) return mm_fpga_target_t is
  begin
    if i = "E_CENTRAL" or i = "E_LEAF" then
      return MM_FPGA_XILINX_XCKU095_22;
    elsif i = "ED_CENTRAL" or i = "ED_LEAF" then
      return MM_FPGA_XILINX_XCVU9P_22L;
    elsif i = "L" then
      return MM_FPGA_XILINX_XCVU7P_22;
    elsif i = "EH_CENTRAL" or i = "EH_LEAF" or i = "LB2" then
      return MM_FPGA_XILINX_XCVU9P_33;
    elsif i = "BVL" then
      return MM_FPGA_XILINX_XCVH1542_33;
    else
      assert false report "Unknown FPGA target specified in mm_get_fpga_target" severity failure;
      return MM_FPGA_XILINX_XCVU9P_33;
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

end package body fpga_spec_pkg;
