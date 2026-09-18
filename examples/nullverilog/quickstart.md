# Using the `nullverilog` Example

## Contents

- [`Installation`](#installation)
  - [`EOS Installation`](#eos-installation)

- [Using the nullverilog Example on a Device](#usage)
  - [`Using the Example on a Device Running EOS`](#using-the-example-on-a-device-running-eos)


- [`eAPI`](#eapi)

---

## Installation


### EOS Installation

To load the example app onto a device running EOS, first copy the SWIX to the
switch:

```bash
scp nullverilog-VERSION-RELEASE.swix admin@hostname:
```

Then log into the device and run:

```console
hostname> enable
hostname# configure
hostname(config)# copy flash:nullverilog-VERSION-RELEASE.swix extension:
hostname(config)# extension nullverilog-VERSION-RELEASE.swix
```

You can show the state of the currently installed extension by running
`show extensions`. For example:

```console
hostname# show extensions
Name                                       Version/Release      Status      Extension
------------------------------------------ -------------------- ----------- ---------
nullverilog-VERSION-RELEASE.swix          0.0.0/28             A, I        1

A: available | NA: not available | I: installed | NI: not installed | F: forced
S: valid signature | NS: invalid signature
The extensions are stored on internal flash (flash:)
```

To persist the installed extension across reboots, copy it to boot-extensions:

```console
hostname# copy installed-extensions boot-extensions
```

Please note, because of the EOS CliPlugin framework your current CLI session
will terminate, so you'll have to log back into the switch. If you reboot the
switch and the SWIX is also in boot-extensions, the CLI Extension will be
automatically registered after a reboot.


---

## <a id="usage"></a>Using the `nullverilog` Example on a Device


### Using the Example on a Device Running EOS

Enter the `nullverilog` configuration mode and use `no disabled` to start the
daemon and program each supported FPGA:

```console
hostname> enable
hostname# configure
hostname(config)# nullverilog
hostname(config-nullverilog)# no disabled
hostname(config-nullverilog)# end
```

FPGA programming can take a short time. The unprivileged
`show nullverilog status` command reports when the daemon is enabled and
running:

```console
hostname> show nullverilog status
Enabled: Yes
Running: Yes
<Fpga> appName: <value-containing-null_v>
```

There is one `appName` line for each programmed FPGA. The register uses
`null_v`, rather than the longer `nullverilog` name. When requested through
eAPI, the same command returns `enabled: true`, `running: true`, and a non-empty
`fpgas` object whose values contain `null_v`.

To unload the FPGA image and stop the daemon, use `disabled` in the application
mode:

```console
hostname> enable
hostname# configure
hostname(config)# nullverilog
hostname(config-nullverilog)# disabled
hostname(config-nullverilog)# end
hostname# show nullverilog status
Enabled: No
Running: No
```

No FPGA `appName` lines are shown while the application is disabled; eAPI
returns an empty `fpgas` object. Return to the application mode and issue
`no disabled` to program the FPGAs and start the daemon again.




---

## eAPI

Building commands using EOSSDK also gives access via eAPI. For example, after
enabling the eAPI, CURL commands return structured json output.

To enable eAPI in EOS:

```console
management api http-commands
no shutdown
```
