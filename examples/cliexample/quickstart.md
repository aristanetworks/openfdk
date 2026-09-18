# Using the `cliexample` Example

## Contents

- [`Installation`](#installation)
  - [`EOS Installation`](#eos-installation)

- [Using the cliexample Example on a Device](#usage)
  - [`Using the Example on a Device Running EOS`](#using-the-example-on-a-device-running-eos)



---

## Installation


### EOS Installation

To load the example app onto a device running EOS, first copy the SWIX to the
switch:

```bash
scp cliexample-VERSION-RELEASE.swix admin@hostname:
```

Then log into the device and run:

```console
hostname> enable
hostname# configure
hostname(config)# copy flash:cliexample-VERSION-RELEASE.swix extension:
hostname(config)# extension cliexample-VERSION-RELEASE.swix
```

You can show the state of the currently installed extension by running
`show extensions`. For example:

```console
hostname# show extensions
Name                                       Version/Release      Status      Extension
------------------------------------------ -------------------- ----------- ---------
cliexample-VERSION-RELEASE.swix          0.0.0/28             A, I        1

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

## <a id="usage"></a>Using the `cliexample` Example on a Device


### Using the Example on a Device Running EOS

To run the installed application, enter the _cliexample_ configuration mode,
enable the daemon, and configure the example addresses. For example:

```console
hostname> en
hostname# conf
hostname(config)# cliexample
hostname(config-cliexample)# ip address 192.0.2.1
hostname(config-cliexample)# ip address 192.0.2.2 secondary
hostname(config-cliexample)# no disabled
hostname(config-cliexample)# end
```

The status command is available from any CLI mode. After the daemon starts, it
reports the configured primary and secondary addresses:

```console
hostname# show cliexample status
Enabled: Yes
Running: Yes
CliExample status store:
  ip address	192.0.2.1
  ip address secondary	192.0.2.2
```

The same settings appear under `cliexample` in the running configuration:

```console
hostname# show running-config section cliexample
cliexample
   ip address 192.0.2.1
   ip address 192.0.2.2 secondary
   no disabled
```

With no address argument, `no ip address` removes both the primary and
secondary addresses. The status entries then show `None`:

```console
hostname# configure
hostname(config)# cliexample
hostname(config-cliexample)# no ip address
hostname(config-cliexample)# end
hostname# show cliexample status
Enabled: Yes
Running: Yes
CliExample status store:
  ip address	None
  ip address secondary	None
```

Use `disabled` in `config-cliexample` mode to stop the daemon. After shutdown,
the status command reports `Running: No`.

```console
hostname# configure
hostname(config)# cliexample
hostname(config-cliexample)# disabled
```
