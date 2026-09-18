# `tscore_nomac` Example Design



> **Note:** Arista supports the compilation and execution of this example in
> its original form, following the instructions provided. Arista makes no
> commitment or obligation to support modifications to the example, support
> questions relating to the Xilinx Vivado toolchain, or other customisations to
> the example design.

## LICENSE

Licensed under the [BSD 3-clause license](LICENSE.md)

## Contents

- [`Introduction`](#introduction)
- [`Supported Board Standards and EOS Versions`](#supported-board-standards-and-eos-versions)
- [`Building from Source`](#building-from-source)
- [`Copying the Example`](#copying-the-example)
- [`Description`](#description)
  - [`FPGA Components`](#fpga-components)
  - [`Software Components`](#software-components)
    - [`EOS`](#eos)


---

## Introduction


The `tscore` example design demonstrates how to use the time synchronisation IP
core. It allows the device's on-board oscillators to be synchronised to an
external PPS source.




---

## Supported Board Standards and EOS Versions


| Board Standard     | FPGA                 | EOS              | Devices                                                                     |
|--------------------|----------------------|------------------|-----------------------------------------------------------------------------|
| `lb2` | XCVU9P-FLGB2104-3-E | 4.34.1f or later | DCS-7130-32LB, DCS-7130-48LB, DCS-7130-96LB, DCS-7130LBR-48S6QD, DCS-7132LB-48Y4C, DCS-7135LB-48Y4C-R |

**Limitations**

- System-clock synchronization requires EOS 4.36.1 or later.



---

## Building from Source

Run `make` in the `tscore_nomac` example directory:

```console
arista_fdk/examples/tscore_nomac> make
```

A simple `make` invocation will build for all available Board Standards. To
limit to a particular one (e.g. `lb2`) use:

```console
arista_fdk/examples/tscore_nomac> make BOARDSTD=lb2
```

The build produces a versioned RPM and SWIX. See [Building and Copying
Examples](../../doc/developer-guide.md#building-and-copying-examples) for build
targets, packaging details, and project configuration.




---

## Copying the Example

This example is licensed under the [BSD 3-clause license](LICENSE.md) and may be used as the basis for
a derivative application. See [Building and Copying
Examples](../../doc/developer-guide.md#building-and-copying-examples) for the
variables and paths that must be updated after copying it.



---

## Description

This example project is comprised of *FPGA* and *software*
components. Each of these is described in the following sections.



### FPGA Components




The example-specific gateware and constraints are in
`arista_fdk/examples/tscore_nomac/src`. Its generated configuration file defines
the complete source and constraint compile order. See the [Arista FDK User
Guide](../../README.md) for the shared Board Standard files and build flow.



### Software Components

The example-specific EOS software is in
`arista_fdk/examples/tscore_nomac/src`. Shared APIs are documented in the
[LibApp API reference](../../resources/libapp/README.md).



#### *EOS*

The EOS integration has three application-specific components:



| File                          | Description                                                                                                                                                                                                        |
|-------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `TsCoreNoMacExample.yaml`     | A YAML file which describes the CLI commands and daemon.                                                                                                                                                           |
| `TsCoreNoMacExampleCli.py`    | A Python file which is loaded by the CLI processor in EOS. It implements classes which are called by EOS when CLI commands are entered. This may read from the status store, and write to the config store.        |
| `TsCoreNoMacExampleDaemon.py` | A Python file which implements a daemon which responds to configuration updates, and publishes status. In the case of tscore_nomac, it responds to `no disabled` commands by programming and configuring the FPGA. |


See the [Developer Guide](../../doc/developer-guide.md) for the common EOS SDK,
CLI extension, packaging, and installation model.
