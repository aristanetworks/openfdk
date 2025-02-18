Arista FDK Upgrade Guide
========================

API Compatibility
---------------------------------

It is important that developers are able to easily upgrade their Arista FDK release.
To do this, we are explicit about API compatibility.

The Arista FDK versions follow \<major\>.\<minor\>.\<patch\>. Apps are expected to compile
against releases within the same major version. Breaking changes are introduced
in major releases, non-breaking features are introduced in minor versions. Patch 
releases contain bug fixes only.

> **Note**
> Breaking changes were introduced between v2.1.0 and v2.4.0. These are outlined below.
> Arista have added features in v2.4.0 to avoid future breaking changes, and expect to
> be able to strictly adhere to the API compatibility from v3 onward.

Changes between v2.1.0 and v2.4.0
---------------------------------

Version 2.2.0 introduced several changes which stopped customers upgrading FDK versions.
Version 2.3.0 was internal-only. For version 2.4.0 Arista have attempted to:

  1. minimise changes to the API for version 2.1.0;
  2. make those changes in a way that reduces the need for further changes to the API.

Changes to the top entity are:
  * The `reserved_in` and `reserved_out` signals were added to the top entity, to allow
    unsupported, or changeable, signals to be added in future FDK revisions.

Additionally, two signals were deprecated for all board standards:
  * The `mac_addr` signal in the top entity was deprecated in preparation for a new format
    MAC address signal which uses less resources.
  * The `fpga_dna` signal was deprecated. You can now instantiate the FPGA's DNA primitives
    directly to use the FPGA DNA.

Other changes include:
  * `arista_sysctl.vhd` was changed to `arista_sysctl_v2.vhd`.
  * This change requires several new dependent files and packages.

These changes apply across all board standards.

### To upgrade:

In the `-cfg.json` file, the files required by the base board support package
need to be updated to support the new `arista_sysctl_v2`.

For the `lb2` the changes are:
```diff
-        "${ARISTA_FDK_DIR}/src/arista_sysctl/arista_sysctl.vhd",
-        "${ARISTA_FDK_DIR}/src/arista_sysctl/arista_sysctl_registers.vhd",
-        "${ARISTA_FDK_DIR}/src/primitive_xilinx/dna_porte2_wrapper.vhd",
+        "${ARISTA_FDK_DIR}/src/arista_sysctl/arista_sysctl_v2.vhd",
+        "${ARISTA_FDK_DIR}/src/board_common/board_common_pkg.vhd",
+        "${ARISTA_FDK_DIR}/src/hermes/hermes_pkg.vhd",
+        "${ARISTA_FDK_DIR}/src/regfile/i2c_slave_deglitch.vhd",
+        "${ARISTA_FDK_DIR}/src/regfile/reg_file_pkg.vhd",
+        "${ARISTA_FDK_DIR}/src/regfile/reg_flexi_pkg.vhd",
+        "${ARISTA_FDK_DIR}/src/yart/yart_i2c.vhd",
+        "${ARISTA_FDK_DIR}/src/yart/yart_leaf_decode.vhd",
+        "${ARISTA_FDK_DIR}/src/yart/yart_pkg.vhd",
+        "${ARISTA_FDK_DIR}/src/yart/yart_reg.vhd",
+        "${ARISTA_FDK_DIR}/src/yart/yart_tl.vhd",
+        "${ARISTA_FDK_DIR}/src/yart/ytl_bridge.vhd",
```

In the `top.vhd` file (for an `lb2` top level entity), `fpga_dna` and `mac_addr` are deprecated,
and indicated as such in the `top.vhd` instantiation. The `reserved_in` and
`reserved_out` signals are also added (which should eliminate future, similar
changes). It is not necessary to connect these signals.

The required changes to the top entity are:
```diff
69,71d68
-     crc_error        : out   std_logic := '0'
---
+     crc_error        : out   std_logic := '0';
+
+     -- Signals below are reserved and subject to change.
+     reserved_in      : in    top_reserved_in_t;
+     reserved_out     : out   top_reserved_out_t := TOP_RESERVED_OUT_DFLT_C
 end entity top;
```

All apps will need to include new files in libapp, since the clock generator module
was replaced. In `src/app-cfg.json`:

```diff
-         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/Exx-Default-Config.txt",
-         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/Exx-GTREFCLK0_161-Config.txt",
-         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/LBR-GTREFCLK0_161-SecRevB-Config.txt",
-         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/Lxx-Default-Config.txt",
-         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/Lxx-Default-SRCOCXO-Config.txt",
-         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/Lxx-GTREFCLK0_161-Config.txt",
-         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/Lxx-NTSC14835-SRCOCXO-Config.txt",
-         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/Lxx-NTSC29670-SRCOCXO-Config.txt",
-         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/Lxx-PAL1485-SRCOCXO-Config.txt",
-         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/Lxx-PAL297-SRCOCXO-Config.txt",
---
+         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/clkgen_profiles.json",
+         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/default_eh_emu_si5345.txt",
+         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/default_lb2_lyrebird_si5345.txt",
+         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/default_lb2_malabar_lmk05318b.txt",
+         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/default_lb2_tamarama_lmk05318.txt",
+         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/eth156OCXO_lb2_lyrebird_si5345.txt",
+         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/eth161_eh_emu_si5345.txt",
+         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/eth161_lb2_lyrebird_si5345.txt",
+         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/eth161_lb2_malabar_lmk05318b.txt",
+         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/eth161_lb2_tamarama_lmk05318.txt",
+         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/ntsc148OCXO_lb2_lyrebird_si5345.txt",
+         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/ntsc297OCXO_lb2_lyrebird_si5345.txt",
+         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/pal148OCXO_lb2_lyrebird_si5345.txt",
+         "${ARISTA_FDK_DIR}/resources/libapp/clkgen_profiles/pal297OCXO_lb2_lyrebird_si5345.txt",
+         "${ARISTA_FDK_DIR}/resources/libapp/clock_generator.py",
```

Each app's `Makefile` needs an update to `parse_app_cfg`:

```diff
 define parse_app_cfg
-    $(foreach src, $(1),\
-      $(if $(findstring json,$(src)),\
-        $(shell sed -re '/app_sources/d; \
-                         s/\"/ /g; s/,/ /g; s/]/ /g; \
-                         /^\}/d; /^\{/d; \
-                         s/\$$\{PROJECT_DIR\}/$(subst /,\/,$(PROJECT_DIR))/g; \
-                         s/\$$\{ARISTA_FDK_DIR\}/$(subst /,\/,$(ARISTA_FDK_DIR))/g' $(src)), \
-        $(src)))
+$(foreach src, $1, \
+  $(if $(findstring json,$(src)), \
+    $(shell cat $(src) | \
+      jq -r '. \
+        | with_entries( \
+          select( \
+            .key|contains("sources") or contains("constrs") \
+          ) \
+        ) \
+        | flatten \
+        | .[] \
```

For apps based on the `tscore` IP core, an additional file must be added:

```diff
+        "${ARISTA_FDK_DIR}/src/ts_ipcore/tscore.vhd",
```

Determining which files to add
------------------------------

The `null` example provides a minimal example using no dependencies. Comparing
the files required for the `null` example in any new version of the FDK, with
a previous version indicates which files to add. 

The need to add new dependencies due to new Arista FDK versions is a known issue, 
and will be rectified in a future version of the FDK.
