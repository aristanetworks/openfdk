--------------------------------------------------------------------------------
-- Copyright (c) 2020 Arista Networks, Inc. All rights reserved.
--------------------------------------------------------------------------------
-- Maintainers:
--   fdk-support@arista.com
--
-- Description:
--   Various definitions for PCIe implementations
--
-- Tags:
--   noencrypt
--   license-arista-fdk-agreement
--   license-bsd-3-clause
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.metamako_pkg.all;

package pcie_pkg is

  ------------------------------------------------------------------------------
  -- Type Declarations
  ------------------------------------------------------------------------------
  -- pcie signals: root complex to endpoint direction when the fpga is the endpoint (fpga inputs)
  type pcie_16lane_root2ep_t is
  record
    data    : diffpair_vector_t(15 downto 0);
    perst_n : std_logic;
    refclk  : diffpair_t;
  end record;
  type pcie_16lane_root2ep_array_t is array (natural range <>) of pcie_16lane_root2ep_t;

  type pcie_8lane_root2ep_t is
  record
    data    : diffpair_vector_t(7 downto 0);
    perst_n : std_logic;
    refclk  : diffpair_t;
  end record;
  type pcie_8lane_root2ep_array_t is array (natural range <>) of pcie_8lane_root2ep_t;

  type pcie_4lane_root2ep_t is
  record
    data    : diffpair_vector_t(3 downto 0);
    perst_n : std_logic;
    refclk  : diffpair_t;
  end record;
  type pcie_4lane_root2ep_array_t is array (natural range <>) of pcie_4lane_root2ep_t;

  type pcie_1lane_root2ep_t is
  record
    data    : diffpair_vector_t(0 downto 0);
    perst_n : std_logic;
    refclk  : diffpair_t;
  end record;
  type pcie_1lane_root2ep_array_t is array (natural range <>) of pcie_1lane_root2ep_t;

  -- pcie signals: endpoint to root complex direction when the fpga is the endpoint (fpga outputs)
  type pcie_16lane_ep2root_t is
  record
    data : diffpair_vector_t(15 downto 0);
  end record;
  type pcie_16lane_ep2root_array_t is array (natural range <>) of pcie_16lane_ep2root_t;

  type pcie_8lane_ep2root_t is
  record
    data : diffpair_vector_t(7 downto 0);
  end record;
  type pcie_8lane_ep2root_array_t is array (natural range <>) of pcie_8lane_ep2root_t;

  type pcie_4lane_ep2root_t is
  record
    data : diffpair_vector_t(3 downto 0);
  end record;
  type pcie_4lane_ep2root_array_t is array (natural range <>) of pcie_4lane_ep2root_t;

  type pcie_1lane_ep2root_t is
  record
    data : diffpair_vector_t(0 downto 0);
  end record;
  type pcie_1lane_ep2root_array_t is array (natural range <>) of pcie_1lane_ep2root_t;

  -- pcie signals: root complex to endpoint direction when the fpga is the root complex (fpga outputs)
  type pcie_4lane_rc_root2ep_t is
  record
    data    : diffpair_vector_t(3 downto 0);
    perst_n : std_logic;
  end record;
  type pcie_4lane_rc_root2ep_array_t is array (natural range <>) of pcie_4lane_rc_root2ep_t;

  -- pcie signals: endpoint to root complex direction when the fpga is the root complex (fpga inputs)
  type pcie_4lane_rc_ep2root_t is
  record
    data   : diffpair_vector_t(3 downto 0);
    refclk : diffpair_t;
  end record;
  type pcie_4lane_rc_ep2root_array_t is array (natural range <>) of pcie_4lane_rc_ep2root_t;

  --------------------------------------------------------------------------------
  -- Function Declarations
  --------------------------------------------------------------------------------
  -- convert X lane root to 8 lane endpoint
  function pcie_root2ep_tox8 (r2ep : pcie_4lane_root2ep_t) return pcie_8lane_root2ep_t;
  function pcie_root2ep_tox8 (r2ep : pcie_8lane_root2ep_t) return pcie_8lane_root2ep_t;

  -- convert 8 lane endpoint to X lane root
  function pcie_ep2root_frmx8 (ep2r : pcie_8lane_ep2root_t) return pcie_4lane_ep2root_t;
  function pcie_ep2root_frmx8 (ep2r : pcie_8lane_ep2root_t) return pcie_8lane_ep2root_t;

end pcie_pkg;

package body pcie_pkg is

  --------------------------------------------------------------------------------
  -- Function bodies
  --------------------------------------------------------------------------------
  -- convert 4 lane root to 8 lane endpoint
  function pcie_root2ep_tox8 (r2ep : pcie_4lane_root2ep_t) return pcie_8lane_root2ep_t is
    variable r2ep_v : pcie_8lane_root2ep_t;
  begin
    r2ep_v.data(3 downto 0) := r2ep.data;
    r2ep_v.perst_n          := r2ep.perst_n;
    r2ep_v.refclk           := r2ep.refclk;
    return r2ep_v;
  end;
  -- overload 8 lane root to 8 lane endpoint
  function pcie_root2ep_tox8 (r2ep : pcie_8lane_root2ep_t) return pcie_8lane_root2ep_t is
  begin
    return r2ep;
  end;

  -- convert 8 lane endpoint to 4 lane root
  function pcie_ep2root_frmx8 (ep2r : pcie_8lane_ep2root_t) return pcie_4lane_ep2root_t is
    variable ep2r_v : pcie_4lane_ep2root_t;
  begin
    ep2r_v.data := ep2r.data(3 downto 0);
    return ep2r_v;
  end;
  -- overload 8 lane endpoint to 8 lane root
  function pcie_ep2root_frmx8 (ep2r : pcie_8lane_ep2root_t) return pcie_8lane_ep2root_t is
  begin
    return ep2r;
  end;

end pcie_pkg;

