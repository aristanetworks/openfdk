# `cliexample` Example Design


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


`cliexample` is an example designed primarily to demonstrate the instantiation
and use of the Cli Extension mechanism in EOS.

It is compatible with all devices and cloud instances running MOS or EOS.




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

`cliexample` can be built from source, using the supplied `Makefile`. This
includes all software and gateware components (i.e. building the application
will run the tools to build the FPGA image for each supported Board Standard).

To build the example, simply type `make` within the `cliexample` example directory:

```console
arista_fdk/examples/cliexample> make
```

The result is a versioned RPM file, in the same directory as the `Makefile`.
The RPM file (e.g. `cliexample-XXX.x86_64.rpm`) can be copied to an Arista
switch running EOS or MOS, where it can be installed and enabled. The RPM will
install a set of files on the target switch in `/opt/apps/cliexample`.

Some other useful features are available in the build system provided with the
FDK. The available targets can be listed using:

```console
arista_fdk/examples/cliexample> make targets
```

A simple `make` invocation will build for all available Board Standards. To
limit to a particular one (e.g. `lb2`) use:

```console
arista_fdk/examples/cliexample> make BOARDSTD=lb2
```

For further details, refer to the Arista FPGA Developer's Kit User Guide.



---

## Copying the Example

This example is designed to be copied as the basis for derivative applications,
and so is licensed under a [BSD 3-clause license](LICENSE.md) to allow copying, modification and
redistribution under those terms.

To copy and use the example from the Arista FDK, copy the `cliexample` directory
outside the FDK tree (probably to a new version control repository):

```bash
cp -r arista_fdk-2.6.0beta1.openfdk/examples/cliexample mynewproject/
```
Update the `Makefile` to change:

| Variable         | Description              |
|------------------|--------------------------|
| `ARISTA_FDK_DIR` | The location of the FDK. |
| `PROJECT`        | The project name.        |
| `VERSION_ID`     | The project version.     |
| `BUILD_ID`       | The build ID.            |

For example, for a new project, based on `cliexample` called `mynewproject`:

```diff
--- mynewproject/Makefile
+++ mynewproject/Makefile
@@ -21,12 +21,12 @@

 .SECONDEXPANSION:

-PROJECT    ?= cliexample
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






### Software Components

The software components provided in this example have been designed to interact
with the installed OS.

There is a library of Python files that implement classes for available
features of a particular Board Standard. These can be found in
`arista_fdk/resources/libapp`.



#### *EOS*

Applications on EOS are implemented as EOSSDK extensions. EOSSDK is a powerful
API which enables third parties to integrate with Arista's OS. The EOS software
can co-exist with the MOS software but uses an orthogonal set of interfaces.
Detailed documentation for EOSSDK and examples can be found on github:
https://github.com/aristanetworks/EosSdk

The software which implements the `cliexample` example in EOS is located in the
`arista_fdk/examples/cliexample/src/eos` directory of the Arista FDK.

The integration with EOS has 3 main components:


| File                  | Description                                                                                                                                                                                                       |
|-----------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `CliExample.yaml`     | A YAML file which describes the CLI commands and daemon.                                                                                                                                                          |
| `CliExampleCli.py`    | A Python file which is loaded by the CLI processor in EOS. It implements classes which are called by EOS when CLI commands are entered. This may read from the status store, and write to the config store.       |
| `CliExampleDaemon.py` | A Python file which implements a daemon which responds to configuration updates, and publishes status. In the case of `cliexample`, it responds to `no disable` commands by programming and configuring the FPGA. |


It would be appropriate to use these as the basis for EOS support for an application.

When creating the RPM several symbolic links are added to these files, which helps
EOS locate and load the application.

EOS can use two file formats for extensions: `.rpm` and `.swix`. The `cliexample` example
currently builds a `.rpm` file - the same RPM can be used as a MOS application or
an EOS extension.


#### *MOS*

The example application `example.py` can be found in the `arista_fdk/examples/cliexample/src`
directory of the Arista FDK. This Python code provides the basic essentials that
are required to start the application and program the FPGAs with the appropriate
images.

For more details, please review the Python source file and refer to the MOSAPI
User Guide which can be downloaded from https://www.arista.com/support.

