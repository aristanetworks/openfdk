Arista FDK
===============================================================================

## Introduction

This is an open-source version of the Arista FPGA Development Kit (FDK). For more
comprehensive documentation, and a Development Kit including closed-source code
visit the 7130 download portal on the [Arista web site](https://www.arista.com/en/support/software-download).

This kit provides the tools and information required to
build applications for Arista products, including the Arista 7130 series of
programmable switches. Applications are extensions to EOS that can be
installed as part of a production environment. They're generally packaged
as .rpm (an industry standard) or .swix (Arista's software extension format).

Building applications for Arista devices dramatically eases the problem of
*deploying* professional-quality FPGA applications (but does not necessarily
make writing FPGA code easier).

Open-source examples that use the FDK include:
* [Netnod's FPGA NTP Server](https://github.com/Netnod/FPGA_NTP_SERVER/tree/devel/FPGA/targets/ntps_arista) -- provides an encrypted NTP server (NTPS), leveraging the FDK's Timesync core to run Sweden's NTP service.
* [Arista's Promtail Extension](https://github.com/netnod/FPGA_NTP_SERVER) -- packages and runs Promtail on Arista Switches to
  collect logs and send them to Grafana Loki.

The intention of the FDK is twofold -- to provide:

* the information required by developers to build applications, including: the information about hardware required by FPGA engineers to build FPGA configs; API details for interfacing with Arista's software platform (EOS).
* libraries, examples, documents, IP cores, build systems, and any other material that will ease development.

> Note: this FDK does not include all of the logic required to build financial
> trading applications. Notable examples of logic that might be required are
> a TCP offload engine, a UDP stack, order book building logic, etc. If you
> would like third-party logic for these components the Arista team can
> recommend our partners.

This open source version of the FDK includes:

* Documentation
    * API documentation
    * FAQ
* Board support packages for all supported board standards and
  devices;
* LibApp -- a Python module for interacting with EOS, providing
  version independence, and convenient user APIs.
* IP Cores (RTL libraries) provided by Arista, providing commonly
  required modules used in FPGA designs;
* An example build system which can either be used as a working example
  of how to build applications, or as the basis for customer build systems;
* Examples applications demonstrating APIs, IP cores, build libraries,
  or other.

## Getting Started

To get started, unpack the FDK, and build one of the example applications.
We recommend the `telemexample` or `null` example.

All examples can be built by executing `make` in the example directory.
This produces a .swix file which you can install on a supported switch.

## Licensing

The file LICENSE.md, in the root of the FDK directory, contains information
relating to licensing the files within the FDK. Please see the
[LICENSE.md](LICENSE.md) for details.

## Documentation

Detailed documents regarding specific topics are available:

* Developer's guide -- [doc/developer-guide.md](doc/developer-guide.md)
    * A guide and information on how to build applications using the FDK. This focusses on software, packaging, operations and other non-FPGA aspects of the  applications.
* LibApp User's Guide - [doc/libapp/index.html](doc/libapp/index.html)
    * API information for LibApp, which provides user-friendly methods for writing EOS and MOS based applications.

In addition, each example is documented with a `README.md` and a `quickstart.md`.
These describe the application from a developer's point of view, and a
user's point of view, respectively.

## Structure of the FDK

The FDK directory structure is as follows:

 * `doc` -- Documentation about software APIs, FAQ.
 * `devkit`    -- Information and source code relating to Board Standards and
   the specific SKUs/platforms that support them.
 * `resources` -- Contains resources used to create applications for Arista
   Devices, as well as build system and software resources (e.g. libapp)
 * `examples`  -- A set of examples, including Application files, FPGA source
   files, daemons, documentation, etc.
 * `ipcores`   -- Contains documentation and requirements for IP Cores. The
   source for IP cores is contained within the `src` directory.
 * `src`       -- All source files including Python, FPGA RTL, TCL, XCI, etc.
