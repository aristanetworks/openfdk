# `null` Example Design


> **_Note:_**  Arista supports the compilation and execution of
        this example in its original form, following the instructions
        provided. Arista makes no commitment or obligation to support
        modifications to the example, or support questions relating to the
        Xilinx Vivado toolchain, or other customisations to the example
        design.

## LICENSE

Licensed under the [BSD 3-clause license](LICENSE.md)

## Contents                                                                                                                                                                                                                                                                                                                
- [`Introduction`](#introduction)
    - [`Usage information`](#usage-information)
    - [`Supported Board Standards and Operating Systems`](#supported-board-standards-and-operating-systems)
    
- [`Building from Source`](#building-from-source)

- [`Copying the Example`](#copying-the-example)

- [`Description`](#description)
    - [`FPGA Components`](#fpga-components)
        - [`Common FPGA Files`](#common-fpga-files)
        - [`Specific FPGA Files`](#specific-fpga-files)
    - [`Software Components`](#software-components)
        - [`EOS`](#eos)
        - [`MOS`](#mos)
        

---

## Introduction

The Null example design demonstrates how to build and program FPGA images into all FPGAs on all board standards.



---

## Supported Board Standards and Operating Systems


| Board Standard     | FPGA                 | EOS              | MOS             | Devices                                                                     |
|--------------------|----------------------|------------------|-----------------|-----------------------------------------------------------------------------|
| `e_central       ` | XCKU095-FFVB2104-2-E | 4.28.0f or later | 0.37.0 or later | DCS-7130-48E, DCS-7130-48EP, DCS-7130-96E, DCS-7130-96EP                    |
| `e_leaf          ` | XCKU095-FFVB2104-2-E | 4.28.0f or later | 0.37.0 or later | DCS-7130-48EP, DCS-7130-96EP                                                |
| `eh_central      ` | XCVU9P-FLGB2104-3-E  | 4.28.0f or later | 0.37.0 or later | DCS-7130-32EB, DCS-7130-48EB, DCS-7130-48EH, DCS-7130-96EB, DCS-7130-96EH   |
| `eh_leaf         ` | XCVU9P-FLGB2104-3-E  | 4.28.0f or later | 0.37.0 or later | DCS-7130-48EH, DCS-7130-96EH                                                |
| `l               ` | XCVU7P-FLVB2104-2-E  | 4.28.0f or later | 0.37.0 or later | DCS-7130-48L, DCS-7130-96L                                                  |
| `lb2             ` | XCVU9P-FLGB2104-3-E  | 4.28.0f or later | 0.37.0 or later | DCS-7130-32LB, DCS-7130-48LB, DCS-7130-96LB, DCS-7130LBR-48S6QD             |



---

## Building from Source

`null` can be built from source, using the supplied `Makefile`. This
includes all software and gateware components (i.e. building the application
will run the tools to build the FPGA image for each supported Board Standard).

To build the example, simply type `make` within the `null` example directory:

```console
arista_fdk/examples/null> make
```

The result is a versioned RPM file, in the same directory as the `Makefile`.
The RPM file (e.g. `null-XXX.x86_64.rpm`) can be copied to an Arista
switch running EOS or MOS, where it can be installed and enabled. The RPM will
install a set of files on the target switch in `/opt/apps/null`.

Some other useful features are available in the build system provided with the
FDK. The available targets can be listed using:

```console
arista_fdk/examples/null> make targets
```

A simple `make` invocation will build for all available Board Standards. To
limit to a particular one (e.g. `lb2`) use:

```console
arista_fdk/examples/null> make BOARDSTD=lb2
```

For further details, refer to the Arista FPGA Developer's Kit User Guide.



---

## Copying the Example

This example is designed to be copied as the basis for derivative applications,
and so is licensed under a [BSD 3-clause license](LICENSE.md) to allow copying, modification and
redistribution under those terms.

To copy and use the example from the Arista FDK, copy the `null` directory
outside the FDK tree (probably to a new version control repository):

```bash
cp -r arista_fdk-2.6.0beta1.openfdk/examples/null mynewproject/
```
Update the `Makefile` to change:

| Variable         | Description              |
|------------------|--------------------------|
| `ARISTA_FDK_DIR` | The location of the FDK. |
| `PROJECT`        | The project name.        |
| `VERSION_ID`     | The project version.     |
| `BUILD_ID`       | The build ID.            |

For example, for a new project, based on `null` called `mynewproject`:

```diff
--- mynewproject/Makefile
+++ mynewproject/Makefile
@@ -21,12 +21,12 @@

 .SECONDEXPANSION:

-PROJECT    ?= null
-VERSION_ID ?= 3.1.0alpha1
-BUILD_ID   ?= 5
+PROJECT    ?= mynewproject
+VERSION_ID ?= 0.0.1
+BUILD_ID   ?= 1

 PROJECT_DIR     = $(CURDIR)
-ARISTA_FDK_DIR ?= $(PROJECT_DIR)/../../../arista_fdk-2.6.0beta1.openfdk
+ARISTA_FDK_DIR ?= $(PROJECT_DIR)/../arista_fdk-2.6.0beta1.openfdk
 ARISTA_SRC_DIR  = $(ARISTA_FDK_DIR)/src

 SOURCE_FILES = $(PROJECT_DIR)/src_files.json
```



---

## Description

This example project is comprised of *FPGA* and *software* components. Each of
these is described in the following sections.



### FPGA Components




Xilinx project creation can be performed by using the provided `Makefile`
environment within the Arista FDK. This automatically creates an appropriately
configured Xilinx Vivado project and imports all required files for the
particular variant, from the associated `null-<boardstandard>-cfg.json` file.

#### *Common FPGA Files*

Regardless of the specific project, there are a set of files that are common to
all Xilinx projects which are automatically imported by the `Makefile`
environment. These files include:

| File                    | Description                                                                         |
|-------------------------|-------------------------------------------------------------------------------------|
| `board_conf.json`       | Defines important details about the Board Standard, including the type of FPGA.     |
| `board_top.vhd`         | Defines the standardised interfaces, and instantiates system level functionality required for the correct operation and management by the 7130 Device. This also instantiates the `top` entity which is the application top-level file. |
| `board_constraints.xdc` | Defines the interface pinouts, electrical definitions and timing.                   |
| `board_pkg.vhd`         | Defines board-specific functions and constants that are/can be used within designs. |

In addition to the above files, Arista IP cores and all required dependencies
are imported. All of these files can be found within the `arista_fdk/src`
directory of the Arista FDK.

#### *Specific FPGA Files*

Each Xilinx project, including this example, require a set of files that are
project-specific. The following files are provided as an example `null`
implementation:


| File                           | Description                                                                        |
|--------------------------------|------------------------------------------------------------------------------------|
| `null-<boardstandard>-top.vhd` | The top-level HDL file that defines the `top` entity.                              |
| `null-<boardstandard>-top.xdc` | The top-level HDL constraints for the project.                                     |
| `null-registers.vhd`           | An example register implementation.                                                |
| `null-registers.csv`           | An example register CSV file for mapping the HDL implementation into the software. |


These can be found within the `arista_fdk/examples/null/src` directory of
the Arista FDK.



### Software Components

The software components provided in this example have been designed to interact
with the installed OS.

There is a library of Python files that implement classes for available
features of a particular Board Standard. These can be found in
`arista_fdk/resources/libapp`.



#### *MOS*

The example application `example.py` can be found in the `arista_fdk/examples/null/src`
directory of the Arista FDK. This Python code provides the basic essentials that
are required to start the application and program the FPGAs with the appropriate
images.

For more details, please review the Python source file and refer to the MOSAPI
User Guide which can be downloaded from https://www.arista.com/support.

