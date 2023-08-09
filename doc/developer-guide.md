# Developer Guide

The Arista FDK allows you to create extensions that run on your Arista switch. It is particularly focussed on the development of applications targeting the application FPGAs of Arista 7130 switches.

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

The CLI Plugin is a Python module that gets loaded into ConfigAgent at startup time which defines command handlers corresponding to the definitions in the YAML file. ConfigAgent will invoke the appropriate handler when the user executes a command.

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

[API Reference](libapp/index.html)

### EOS Extensions

EOS extensions may be either a single RPM or a SWIX (SWI eXtention).  A SWIX
is an uncompressed Zip file containing a manifest, one or more RPMs, zero
or more squashfs filesystems, and an optional list of EOS agents to be
restarted when the extension is installed or uninstalled.  SWIX files also
support cryptographic signatures.

The manifest controls which of the included RPMs are installed and which of
the included squashfs filesystems are mounted (and where) in each supported
version of EOS.  This allows multiple versions of an application to be
included in a SWIX if necessary to support multiple versions of EOS.

Squashfs filesystems are mounted read-only directly from the SWIX file without
extracting into RAM or flash.  This allows large files to be included in an
extension without consuming RAM.  This is typically used for large numbers of
large FPGA bitfiles.

The Arista swi-tools are used to generate SWIX files.  These tools are
[publicly available on github](https://github.com/aristanetworks/swi-tools).

The FDK examples are built in both RPM and SWIX formats by default, without a
squashfs filesystem, except for the muxcore example which generates a squashfs
filesystem as an example of how this is done.  When generating a squashfs, the
RPM extension includes all files, but the RPM within the SWIX excludes
everything that is in the squashfs.

The `APP_BUILD_SQUASHFS` variable controls whether a squashfs filesystem is
generated.  By default, this variable is unset and disables squashfs.  Setting
it to '1' enables squashfs.

The variables `APP_SWIX` and `APP_RPM` control whether the example is built as a
SWIX or a standalone RPM.  If neither are set (the default) or if both are set,
both SWIX and RPM will be built.  If only one is set, then only that one will
be built.  The variables should be set to the name of the output file.
