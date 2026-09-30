# `cliexample` Example Design



> **Note:** Arista supports the compilation and execution of this example in
> its original form, following the instructions provided. Arista makes no
> commitment or obligation to support modifications to the example, support
> questions relating to the Xilinx Vivado toolchain, or other customisations to
> the example design.

## LICENSE

Licensed under the [BSD 3-clause license](LICENSE.md)

## Contents

- [`Introduction`](#introduction)
- [`Building from Source`](#building-from-source)
- [`Copying the Example`](#copying-the-example)
- [`Description`](#description)
  - [`Software Components`](#software-components)
    - [`EOS`](#eos)


---

## Introduction


`cliexample` is an example designed primarily to demonstrate the instantiation
and use of the Cli Extension mechanism in EOS.

It is compatible with all devices and cloud instances running EOS.





---

## Building from Source

Run `make` in the `cliexample` example directory:

```console
arista_fdk/examples/cliexample> make
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
`arista_fdk/examples/cliexample/src`. Shared APIs are documented in the
[LibApp API reference](../../resources/libapp/README.md).



#### *EOS*

The EOS integration has three application-specific components:



| File                  | Description                                                                                                                                                                                                 |
|-----------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `CliExample.yaml`     | A YAML file which describes the CLI commands and daemon.                                                                                                                                                    |
| `CliExampleCli.py`    | A Python file which is loaded by the CLI processor in EOS. It implements classes which are called by EOS when CLI commands are entered. This may read from the status store, and write to the config store. |
| `CliExampleDaemon.py` | A Python file which implements a daemon which responds to configuration updates, and publishes status.                                                                                                      |


See the [Developer Guide](../../doc/developer-guide.md) for the common EOS SDK,
CLI extension, packaging, and installation model.
