# Arista FDK Upgrade Guide

## API Compatibility

It is important that developers are able to easily upgrade their Arista FDK
release. To do this, we are explicit about API compatibility.

The Arista FDK versions follow \<major\>.\<minor\>.\<patch\>. Apps are expected
to compile against releases within the same major version. Breaking changes are
introduced in major releases, non-breaking features are introduced in minor
versions. Patch releases contain bug fixes only.

## Changes between v3.x and v4.0

Version 4.0 removes support for MOS and Python 2. It also removes obsolete board
standards. Review the application software, target device and EOS configuration
before rebuilding an application with v4.0.

### MOS support

The v4.0 FDK supports EOS only. It no longer builds or packages MOS application
software. An application which must continue to run on MOS must remain on a
v3.x FDK release. Migrating a MOS application to v4.0 is effectively a full
rewrite of its software component. Rewrite it as an EOS SDK daemon and CLI
extension before adopting the v4.0 FDK.

Applications which provided both MOS and EOS implementations in v3.x should
remove the MOS implementation and adopt the EOS-only source layout used by the
v4.0 examples:

```diff
 src/
-  example.py                       # MOS implementation
-  eos/Example.yaml
-  eos/ExampleCli.py
-  eos/ExampleDaemon.py
+  Example.yaml
+  ExampleCli.py
+  ExampleDaemon.py
```

Update the application Makefile variables and the daemon path in the CLI YAML
to remove the `eos/` directory component. For example,
`/opt/apps/example/eos/ExampleDaemon.py` becomes
`/opt/apps/example/ExampleDaemon.py`. Remove any remaining MOS-only imports,
dependencies, configuration and tests. Build and install the resulting SWIX as
an EOS extension.

### Python 3

The v4.0 FDK uses Python 3 only. EOS example software has already been Python 3
only since FDK v3.0, so an EOS-only v3.x application may require no source
changes. Software shared with MOS, however, may still contain Python 2
compatibility or dependencies.

Before rebuilding, port Python 2 code and rebuild third-party dependencies for
Python 3. Use `#!/usr/bin/env arista-python` for software which runs on EOS and
`#!/usr/bin/env python3` for host-side build and utility scripts. Supported EOS
releases select the appropriate Python 3 interpreter through `arista-python`.

### FPGA function interfaces

Generic FPGA function interfaces were introduced during the v3.x series and
are not new in v4.0. By default, the FDK creates one
`FpgaFunction<fpga>/<port>` interface for each application-facing (AP)
interface exposed by the FPGA. These interfaces allow the port speed to be
configured, can be used for L1 sourcing, and can expose application-provided
link status and interface counters through EOS.

The `FpgaFunction` interfaces do not rename or replace the corresponding
`Application<fpga>/<port>` interfaces. The `Application` interfaces remain
visible, but must not be used for configuration. Apply all configuration,
including speed and L1 source settings, to the `FpgaFunction` interfaces for
correct behaviour. Product-specific names such as `WatchIn5/4/11` are not
created for FDK applications.

Applications can react to configuration and state changes on these interfaces
through [EOS SDK `eth_phy_intf` handlers][eos-sdk-eth-phy-intf], such as
`on_eth_phy_intf_link_speed`. The `libapp.tuning.TuningMixin` used by the
[MacPhy example](../examples/macphy/README.md) provides an implementation of
these handlers using the matching `arista_sysctl_v2` PHY configuration records.
The MacPhy core's `gt_cfg` interface is compatible with this path. See
[FPGA Transceiver Tuning](../resources/libapp/README.md#fpga-transceiver-tuning)
in the generated LibApp guide.

EOS does not receive success or failure feedback when an FDK daemon attempts to
apply interface configuration. Configuration status can therefore be
misleading. For example, EOS can show a requested speed as configured even when
the daemon or hardware does not accept or apply it.

EOS does not infer link status or counters from the gateware. Applications
which provide these values must publish them for each `FpgaFunction` interface
through the FDK handler interface. When publishing counters, pass
`counters_supported=True` to `load_image`. See
`src/macphy/driver/macphy.py` in the MacPhy example for a reference
implementation.

Audit the application's saved EOS configuration, CLI YAML, Python code, eAPI
clients, tests and documentation for `Application` interface references. Move
all configuration to the corresponding `FpgaFunction` interfaces, and use
those names when publishing link status and counters.

### Supported board standards

FDK v4.0 supports the `lb2` and `bvl` board standards. The `l`, `eh_central`
and `eh_leaf` board standards present in v3.x are no longer included. Designs
for one of the removed standards must remain on v3.x or be ported to a supported
device and board standard.

### To upgrade

1. Confirm that the target device uses a board standard supported by v4.0.
2. Rewrite any MOS application software as an EOS SDK daemon and CLI extension,
   then remove the MOS-only files.
3. Port shared application code and dependencies to Python 3.
4. Move the EOS application files out of `src/eos`, and update their installed
   paths in the Makefile and CLI YAML.
5. Move all configuration from `Application` interfaces to the corresponding
   `FpgaFunction` interfaces, handle the relevant configuration and state
   changes, and publish any application-provided link status and counters
   against those interfaces.
6. Rebuild the application against v4.0, install its SWIX on a supported EOS
   release, and verify FPGA loading, CLI registration, interface speeds, L1
   source configuration, link status and counters.

[eos-sdk-eth-phy-intf]: https://aristanetworks.github.io/EosSdk/docs/2.16.0/ref/eth_phy_intf.html
