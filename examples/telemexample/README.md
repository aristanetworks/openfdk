# `telemexample` Example Design



> **Note:** Arista supports the compilation and execution of this example in
> its original form, following the instructions provided. Arista makes no
> commitment or obligation to support modifications to the example, support
> questions relating to the Xilinx Vivado toolchain, or other customisations to
> the example design.

## LICENSE

Licensed under the [BSD 3-clause license](LICENSE.md)

## Contents

- [`Introduction`](#introduction)
- [`Usage information`](#usage-information)
- [`Building from Source`](#building-from-source)
- [`Copying the Example`](#copying-the-example)
- [`Description`](#description)
  - [`Software Components`](#software-components)
    - [`EOS`](#eos)


---

## Introduction


`TelemExample` is an example designed primarily to demonstrate the use of the
time-series telemetry module within libapp. This is designed to send telemetry
via EOS, to an off-box device using
[Influx line format](https://docs.influxdata.com/influxdb/v1.8/write_protocols/line_protocol_tutorial/).

This example implements a few different outputs:

- A sinusoid function, once per second, controlled by CLI.
- A system monitor.



---

## Usage information

Information about how to use the example design is contained in the [Quickstart
Guide](quickstart.md).




---

## Building from Source

Run `make` in the `telemexample` example directory:

```console
arista_fdk/examples/telemexample> make
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

This example project is comprised of *software* components.






### Software Components

The example-specific EOS software is in
`arista_fdk/examples/telemexample/src`. Shared APIs are documented in the
[LibApp API reference](../../resources/libapp/README.md).



#### *EOS*

The EOS integration has three application-specific components:



| File                    | Description                                                                                                                                                                                                 |
|-------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `TelemExample.yaml`     | A YAML file which describes the CLI commands and daemon.                                                                                                                                                    |
| `TelemExampleCli.py`    | A Python file which is loaded by the CLI processor in EOS. It implements classes which are called by EOS when CLI commands are entered. This may read from the status store, and write to the config store. |
| `TelemExampleDaemon.py` | A Python file which implements a daemon which responds to configuration updates, and publishes status.                                                                                                      |


See the [Developer Guide](../../doc/developer-guide.md) for the common EOS SDK,
CLI extension, packaging, and installation model.
