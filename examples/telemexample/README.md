# `telemexample` Example Design


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
        

---

## Introduction


`TelemExample` is an example designed primarily to demonstrate the use of the
time-series telemetry module within libapp. This is designed to send telemetry
via EOS, to an off-box device using [Influx line format](https://docs.influxdata.com/influxdb/v1.8/write_protocols/line_protocol_tutorial/).

This example implements a few different outputs:

* A sinusoid function, once per second, controlled by CLI.
* A system monitor.



---

## Usage information

Information about how to use the example design is contained in the [Quickstart Guide](quickstart.md).



---

## Supported Board Standards and Operating Systems


| Board Standard     | FPGA                 | EOS              | MOS             | Devices                                                                     |
|--------------------|----------------------|------------------|-----------------|-----------------------------------------------------------------------------|
| `eh_central      ` | XCVU9P-FLGB2104-3-E  | 4.26.2 or later | No         | DCS-7130-32EB, DCS-7130-48EB, DCS-7130-48EH, DCS-7130-96EB, DCS-7130-96EH   |
| `eh_leaf         ` | XCVU9P-FLGB2104-3-E  | 4.26.2 or later | No         | DCS-7130-48EH, DCS-7130-96EH                                                |
| `l               ` | XCVU7P-FLVB2104-2-E  | 4.26.2 or later | No         | DCS-7130-48L, DCS-7130-96L                                                  |
| `lb2             ` | XCVU9P-FLGB2104-3-E  | 4.26.2 or later | No         | DCS-7130-32LB, DCS-7130-48LB, DCS-7130-96LB, DCS-7130LBR-48S6QD             |

> **_Note:_** While this example does not support MOS, the libapp Telemetry
module is expected to work on MOS also.



---

## Building from Source

`telemexample` can be built from source, using the supplied `Makefile`. This
includes all software and gateware components (i.e. building the application
will run the tools to build the FPGA image for each supported Board Standard).

To build the example, simply type `make` within the `telemexample` example directory:

```console
arista_fdk/examples/telemexample> make
```

The result is a versioned RPM file, in the same directory as the `Makefile`.
The RPM file (e.g. `telemexample-XXX.x86_64.rpm`) can be copied to an Arista
switch running EOS or MOS, where it can be installed and enabled. The RPM will
install a set of files on the target switch in `/opt/apps/telemexample`.

Some other useful features are available in the build system provided with the
FDK. The available targets can be listed using:

```console
arista_fdk/examples/telemexample> make targets
```

A simple `make` invocation will build for all available Board Standards. To
limit to a particular one (e.g. `lb2`) use:

```console
arista_fdk/examples/telemexample> make BOARDSTD=lb2
```

For further details, refer to the Arista FPGA Development Kit User Guide.



---

## Copying the Example

This example is designed to be copied as the basis for derivative applications,
and so is licensed under a [BSD 3-clause license](LICENSE.md) to allow copying, modification and
redistribution under those terms.

To copy and use the example from the Arista FDK, copy the `telemexample` directory
outside the FDK tree (probably to a new version control repository):

```bash
cp -r arista_fdk-3.0.0.openfdk/examples/telemexample mynewproject/
```
Update the `Makefile` to change:

| Variable         | Description              |
|------------------|--------------------------|
| `ARISTA_FDK_DIR` | The location of the FDK. |
| `PROJECT`        | The project name.        |
| `VERSION_ID`     | The project version.     |
| `BUILD_ID`       | The build ID.            |

For example, for a new project, based on `telemexample` called `mynewproject`:

```diff
--- mynewproject/Makefile
+++ mynewproject/Makefile
@@ -21,12 +21,12 @@

 .SECONDEXPANSION:

-PROJECT    ?= telemexample
-VERSION_ID ?= 3.1.0alpha1
-BUILD_ID   ?= 5
+PROJECT    ?= mynewproject
+VERSION_ID ?= 0.0.1
+BUILD_ID   ?= 1

 PROJECT_DIR     = $(CURDIR)
-ARISTA_FDK_DIR ?= $(PROJECT_DIR)/../../../arista_fdk-3.0.0.openfdk
+ARISTA_FDK_DIR ?= $(PROJECT_DIR)/../arista_fdk-3.0.0.openfdk
 ARISTA_SRC_DIR  = $(ARISTA_FDK_DIR)/src

 SOURCE_FILES = $(PROJECT_DIR)/src_files.json
```



---

## Description

This example project is comprised of *FPGA* and *software* components. Each of
these is described in the following sections.



### FPGA Components





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

The software which implements the `telemexample` example in EOS is located in the
`arista_fdk/examples/telemexample/src/eos` directory of the Arista FDK.

The integration with EOS has 3 main components:


| File                    | Description                                                                                                                                                                                                         |
|-------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `TelemExample.yaml`     | A YAML file which describes the CLI commands and daemon.                                                                                                                                                            |
| `TelemExampleCli.py`    | A Python file which is loaded by the CLI processor in EOS. It implements classes which are called by EOS when CLI commands are entered. This may read from the status store, and write to the config store.         |
| `TelemExampleDaemon.py` | A Python file which implements a daemon which responds to configuration updates, and publishes status. In the case of `telemexample`, it responds to `no disable` commands by programming and configuring the FPGA. |


It would be appropriate to use these as the basis for EOS support for an application.

When creating the RPM several symbolic links are added to these files, which helps
EOS locate and load the application.

EOS can use two file formats for extensions: `.rpm` and `.swix`. The `telemexample` example
currently builds a `.rpm` file - the same RPM can be used as a MOS application or
an EOS extension.


