# Using the `tscore_nomac` Example

## Contents

                                                                                                
- [`Installation`](#installation)
    - [`EOS Installation`](#eos-installation)
    - [`MOS Installation`](#mos-installation)
    
- [`Using the `tscore_nomac` Example on a Device`](#usage)
    - [`Using the Example on a Device Running EOS`](#using-the-example-on-a-device-running-eos)
    - [`Using the Example on a Device Running MOS`](#using-the-example-on-a-device-running-mos)
    

- [`eAPI`](#eapi)

---

## Installation


### EOS Installation

To load the example app onto a device running EOS, first copy the SWIX to the switch:

```bash
scp tscore_nomac-XXX.swix admin@hostname:
```

Then log into the device and run:

```console
hostname> en
hostname# conf
hostname(config)# copy flash:tscore_nomac-XXX.swix extensions:
hostname(config)# extension tscore_nomac-XXX.swix
```

You can show the state of the currently installed extension by running ``show extensions``.
For example:

```console
hostname#show extensions
Name                                       Version/Release      Status      Extension
------------------------------------------ -------------------- ----------- ---------
tscore_nomac-XXX.x86_64.swix              0.0.0/28             A, I        1

A: available | NA: not available | I: installed | NI: not installed | F: forced
S: valid signature | NS: invalid signature
The extensions are stored on internal flash (flash:)
```

Please note, because of the EOS CliPlugin framework your current CLI session will terminate, so you'll have to log back into the switch.
If you reboot the switch and the SWIX is also in boot-extensions, the CLI Extension will be automatically registered after a reboot.



### MOS Installation

In order to start the TscoreNomac example application it must be installed. To do so, copy the generated RPM to your device and install:

```bash
scp tscore_nomac-XXX.rpm admin@hostname:
```

Log into the device and run:

```console
hostname> en
hostname# conf
hostname(config)# install app tscore_nomac-XXX.rpm
hostname(config)# exit
hostname# exit
```

Log out of the device and then back in to refresh the CLI.

You can see the apps installed on your device using the `show application` command.


---

## <a id="usage"></a>Using the `tscore_nomac` Example on a Device


### Using the Example on a Device Running EOS

The application can be started via the ``no disabled`` command:

```
test_dut#config
test_dut(config)#tscode_nomac
test_dut(config-tscode_nomac)#no disabled
```

at which point the FPGA will take some small amount of time to program, and following
that, the application will show as `Enabled` and `Running`:

```
test_dut(config-tscore_nomac)#show tscore_nomac status
Enabled: Yes
Running: Yes
Last timestamp raw: 0
test_dut(config-tscore_nomac)#
```

The `trigger` CLI command will write a value to the trigger register.
This in turn triggers the tscore to issue a timestamp e.g.

```
test_dut(config-tscore_nomac)#trigger
test_dut(config-tscore_nomac)#show tscore_nomac status
Enabled: Yes
Running: Yes
Last timestamp raw: 7226366790233529172
test_dut(config-tscore_nomac)#trigger
test_dut(config-tscore_nomac)#show tscore_nomac status
Enabled: Yes
Running: Yes
Last timestamp raw: 7226366820893175444
```



### Using the Example on a Device Running MOS

The application can be started via the ``no shutdown`` command:

```
test_dut#config
test_dut(config)#tscode_nomac
test_dut(config-tscode_nomac)#no shutdown
```

at which point the FPGA will take some small amount of time to program, and following
that, the application will show as `Enabled` and `Running`:

```
test_dut(config-tscore_nomac)#show tscore_nomac status
Enabled: Yes
Running: Yes
Last timestamp raw: 0
test_dut(config-tscore_nomac)#
```

The `trigger` CLI command will write a value to the trigger register.
This in turn triggers the tscore to issue a timestamp e.g.

```
test_dut(config-tscore_nomac)#trigger
test_dut(config-tscore_nomac)#show tscore_nomac status
Enabled: Yes
Running: Yes
Last timestamp raw: 7226366790233529172
test_dut(config-tscore_nomac)#trigger
test_dut(config-tscore_nomac)#show tscore_nomac status
Enabled: Yes
Running: Yes
Last timestamp raw: 7226366820893175444
```



---

## eAPI

Building commands using EOSSDK also gives access via eAPI. For example, after enabling the eAPI, CURL commands return structured json output.

To enable eAPI in EOS:

```console
management api http-commands
no shutdown
```

Enabling eAPI is slightly differrent in MOS:

```console
configure
management http
no protocol secure
management api
no shutdown
end
```



and then run this command on an external or local host:
(The curl command is the same for MOS/EOS.)

```bash
curl --insecure -u admin -H "Content-Type: application/json" -X POST \
     -d '{"jsonrpc":"2.0",
          "method":"runCmds",
          "params":{ "version":1,
                     "cmds":["show tscore_nomac status"],
                     "format":"json"}, "id":""}' \
      https://hostname/command-api/ | json_pp
```

and, if the app is `no disabled`, the output will be along the lines of:

```
{
    "enabled": true,
    "running": true,
    "lastTimestampRaw": 7226366820893175444
}
```
