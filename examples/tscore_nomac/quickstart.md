# Using the `tscore_nomac` Example

## Contents

- [`Installation`](#installation)
  - [`EOS Installation`](#eos-installation)

- [Using the tscore_nomac Example on a Device](#usage)
  - [`Using the Example on a Device Running EOS`](#using-the-example-on-a-device-running-eos)


- [`eAPI`](#eapi)

---

## Installation


### EOS Installation

To load the example app onto a device running EOS, first copy the SWIX to the
switch:

```bash
scp tscore_nomac-VERSION-RELEASE.swix admin@hostname:
```

Then log into the device and run:

```console
hostname> enable
hostname# configure
hostname(config)# copy flash:tscore_nomac-VERSION-RELEASE.swix extension:
hostname(config)# extension tscore_nomac-VERSION-RELEASE.swix
```

You can show the state of the currently installed extension by running
`show extensions`. For example:

```console
hostname# show extensions
Name                                       Version/Release      Status      Extension
------------------------------------------ -------------------- ----------- ---------
tscore_nomac-VERSION-RELEASE.swix          0.0.0/28             A, I        1

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

## <a id="usage"></a>Using the `tscore_nomac` Example on a Device


### Using the Example on a Device Running EOS

The application is disabled by default:

```console
hostname> show tscore_nomac status
Enabled: No
Running: No
Last timestamp raw: None
Last timestamp: None
```

Enter `tscore_nomac` configuration mode and use `no disabled` to start the
daemon and program the first available FPGA:

```console
hostname> enable
hostname# configure
hostname(config)# tscore_nomac
hostname(config-tscore_nomac)# no disabled
hostname(config-tscore_nomac)# show tscore_nomac status
Enabled: Yes
Running: Yes
Last timestamp raw: 0
Last timestamp: 1970-01-01 00:00:00.000000000
```

`Running: Yes` confirms that FPGA programming and daemon initialization
completed. The initial raw timestamp is zero. The `trigger` command writes the
trigger register, captures a timestamp, and updates both status fields:

```console
hostname(config-tscore_nomac)# trigger
hostname(config-tscore_nomac)# show tscore_nomac status
Enabled: Yes
Running: Yes
Last timestamp raw: 7226366790233529172
Last timestamp: 2023-04-26 14:33:51.210541396
```

The values are examples; each trigger should produce a nonzero raw timestamp
and a corresponding UTC timestamp. Use `disabled` for a normal shutdown. It
stops the daemon, unloads the FPGA image, and clears runtime status:

```console
hostname(config-tscore_nomac)# disabled
hostname(config-tscore_nomac)# show tscore_nomac status
Enabled: No
Running: No
Last timestamp raw: None
Last timestamp: None
```

Starting the app again with `no disabled` reprograms the FPGA and initializes
the timestamp fields again.

### Configuring time synchronization

EOS provides free-running and PPS synchronization from version 4.32.1. This
example package supports EOS 4.34.1F and later.

After `show tscore_nomac status` reports `Running: Yes`, select a
hardware-clocking reference. Free-running mode requires no external reference:

```console
hostname# configure
hostname(config)# hardware clocking
hostname(config-hw-clk)# time-sync
hostname(config-hw-clk-time-sync)# reference free-running
hostname(config-hw-clk-time-sync)# end
hostname# show hardware clocking time-sync
```

Confirm that the displayed reference is `free-running`. For PPS, configure the
input and verify that EOS reports it as up before selecting it:

```console
hostname# configure
hostname(config)# hardware clocking
hostname(config-hw-clk)# port pps-in1
hostname(config-hw-clk-port-pps-in1)# signal pps
hostname(config-hw-clk-port-pps-in1)# exit
hostname(config-hw-clk)# time-sync
hostname(config-hw-clk-time-sync)# reference pps
hostname(config-hw-clk-time-sync)# end
hostname# show hardware clocking
hostname# show hardware clocking time-sync
```

If `pps-in1` is not `up`, check the external PPS connection. With a valid
reference, `show hardware clocking time-sync` should report reference `pps`
and synchronization status `synced`.

The system-clock reference is supported on DCS-7130 platforms running EOS
4.36.1 or later. Synchronize EOS with NTP before selecting it:

```console
hostname# configure
hostname(config)# ntp server time.aristanetworks.com
hostname(config)# end
hostname# show ntp status
hostname# configure
hostname(config)# hardware clocking
hostname(config-hw-clk)# time-sync
hostname(config-hw-clk-time-sync)# reference system-clock
hostname(config-hw-clk-time-sync)# end
hostname# show hardware clocking time-sync
```

Wait for `show ntp status` to report `synchronised`; hardware-clocking status
should then show reference `system-clock` and synchronization status `synced`.
For PPS and system-clock synchronization, inspect the sample count, average
offset, and standard deviation in the minute statistics:

```console
hostname# show hardware clocking time-sync offset statistics
```

Reset all hardware-clocking configuration, or remove only the PPS input and
NTP configuration, as follows:

```console
hostname(config)# no hardware clocking
hostname(config)# hardware clocking
hostname(config-hw-clk)# no port pps-in1
hostname(config-hw-clk)# exit
hostname(config)# no ntp
```




---

## eAPI

Building commands using EOSSDK also gives access via eAPI. For example, after
enabling the eAPI, CURL commands return structured json output.

To enable eAPI in EOS:

```console
management api http-commands
no shutdown
```



and then run this command on an external or local host:

```console
curl --insecure -u admin -H "Content-Type: application/json" -X POST \
     -d '{"jsonrpc":"2.0",
          "method":"runCmds",
          "params":{ "version":1,
                     "cmds":["show tscore_nomac status"],
                     "format":"json"}, "id":""}' \
      https://hostname/command-api/ | json_pp
```

If the app is enabled, the structured status is similar to:

```console
{
    "enabled": true,
    "running": true,
    "lastTimestampRaw": 7226366820893175444,
    "lastTimestamp": "2023-04-26 14:33:58.805416596"
}
```
