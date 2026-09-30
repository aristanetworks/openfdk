# Developer Guide

The Arista FDK allows you to create extensions that run on your Arista switch.
It is particularly focussed on the development of applications targeting the
application FPGAs of Arista 7130 switches.

## Application Components

Most applications contain three core software components:

1. CLI definition YAML
2. CLI plugin python
3. App daemon

### YAML Definition File

The YAML file defines:

- any CLI modes and commands implemented by the application
- daemons used in the implementation
- as well as some metadata associated with the application.

[YAML Definition Documentation](https://eos.arista.com/eos-4-25-2f/cli-extensions-for-customers/#YAML_definition_file)

### CLI Plugin

The CLI Plugin is a Python module that gets loaded into ConfigAgent at startup
time which defines command handlers corresponding to the definitions in the YAML
file. ConfigAgent will invoke the appropriate handler when the user executes a
command.

[CLI Extension Documentation](https://eos.arista.com/eos-4-25-2f/cli-extensions-for-customers/)

### Daemon

The daemon is generally an EosSdk agent with two main responsiblities:

1. Responding to config changes made by the CLI commands above.
2. Publishing status updates that can be queried by the CLI or other APIs.

[Lifecycle of an SDK agent](https://github.com/aristanetworks/EosSdk/wiki/Lifecycle-of-an-SDK-agent)

## Developing with the FDK

### EOS Overview

[Understanding EOS and Sysdb](https://github.com/aristanetworks/EosSdk/wiki/Understanding-EOS-and-Sysdb)

### EosSdk

[EosSdk Wiki](https://github.com/aristanetworks/EosSdk/wiki)
[API Documentation](http://aristanetworks.github.io/EosSdk/docs/2.16.0/ref/index.html)

### LibApp

[API Reference](../resources/libapp/README.md)

For platform-specific FPGA transceiver tuning values and the corresponding
LibApp API, see [FPGA Transceiver Tuning](../resources/libapp/README.md#fpga-transceiver-tuning).

### EOS Extensions

EOS extensions may be either a single RPM or a SWIX (SWI eXtention). A SWIX is
an uncompressed Zip file containing a manifest, one or more RPMs, zero or more
squashfs filesystems, and an optional list of EOS agents to be restarted when
the extension is installed or uninstalled. SWIX files also support cryptographic
signatures.

The manifest controls which of the included RPMs are installed and which of the
included squashfs filesystems are mounted (and where) in each supported version
of EOS. This allows multiple versions of an application to be included in a SWIX
if necessary to support multiple versions of EOS.

Squashfs filesystems are mounted read-only directly from the SWIX file without
extracting into RAM or flash. This allows large files to be included in an
extension without consuming RAM. This is typically used for large numbers of
large FPGA bitfiles.

The Arista swi-tools are used to generate SWIX files. These tools are
[publicly available on github](https://github.com/aristanetworks/swi-tools).

Example Makefiles produce both a standalone RPM and a SWIX by default. The
`APP_RPM` and `APP_SWIX` variables name these outputs; set either variable to an
empty value to disable that output.

Setting `APP_BUILD_SQUASHFS=1` moves selected files from the RPM embedded in the
SWIX into a squashfs filesystem.

## Building and Copying Examples

Each example contains a generated `Makefile` that builds its application and
FPGA images. From the example directory, run:

```console
make
```

This builds all Board Standards configured by the example. To select one Board
Standard, set `BOARDSTD`, for example:

```console
make BOARDSTD=lb2
```

Run `make targets` to list the available targets and resolved project settings.

To create a derivative application, copy an example directory outside the FDK
tree. In the copied `Makefile`, update `PROJECT`, `VERSION_ID`, and `BUILD_ID`.
If the relative location of the FDK changes, also update `ARISTA_FDK_DIR` or
`ARISTA_FDK_VERSION`. Keep application-specific source files in `src`; the
generated `*-cfg.json` files define the FPGA source and constraint compile
order.
