# libApp API reference

This reference is generated from the documented Python APIs in LibApp.

## FPGA Transceiver Tuning

LibApp provides Arista-recommended FPGA transceiver tuning values for
corresponding platform FPGAs. Some applications may only need to read these
values. Retrieve them from an application's `Fpga` object rather than
hard-coding platform names or electrical values:

```python
fpga = libapp.device.get_fpga_devices()[0]
settings = fpga.tuning_data[(speed, medium)][ap]
```

The outer key is a supported speed and medium combination, such as
`("25G", "copper")`; the inner key is the one-based application-port (AP)
number. Available combinations and setting fields are determined by the
corresponding FPGA. The values are data only: an application must apply the
fields that its FPGA transceiver implementation exposes.

# Table of Contents

* [libapp](#libapp)
* [libapp.cli](#libapp.cli)
  * [StatusAccessor](#libapp.cli.StatusAccessor)
  * [status\_as\_dict](#libapp.cli.status_as_dict)
  * [ShowEnabledBaseCmd](#libapp.cli.ShowEnabledBaseCmd)
* [libapp.clkgen\_ctl](#libapp.clkgen_ctl)
  * [ClkGenDevice](#libapp.clkgen_ctl.ClkGenDevice)
    * [set\_clkgenconfig](#libapp.clkgen_ctl.ClkGenDevice.set_clkgenconfig)
    * [rst\_clkgenconfig](#libapp.clkgen_ctl.ClkGenDevice.rst_clkgenconfig)
* [libapp.clock\_generator](#libapp.clock_generator)
  * [ClockGenerator](#libapp.clock_generator.ClockGenerator)
    * [check\_profile](#libapp.clock_generator.ClockGenerator.check_profile)
    * [load\_profile](#libapp.clock_generator.ClockGenerator.load_profile)
* [libapp.daemon](#libapp.daemon)
  * [StatusMixin](#libapp.daemon.StatusMixin)
    * [status](#libapp.daemon.StatusMixin.status)
* [libapp.device](#libapp.device)
  * [Fpga](#libapp.device.Fpga)
    * [load\_image](#libapp.device.Fpga.load_image)
    * [profile\_key](#libapp.device.Fpga.profile_key)
    * [profile\_state](#libapp.device.Fpga.profile_state)
    * [is\_loaded](#libapp.device.Fpga.is_loaded)
    * [unload\_image](#libapp.device.Fpga.unload_image)
    * [tuning\_data](#libapp.device.Fpga.tuning_data)
  * [get\_fpga\_devices](#libapp.device.get_fpga_devices)
  * [get\_fpga\_identifiers](#libapp.device.get_fpga_identifiers)
  * [get\_interface\_macaddr](#libapp.device.get_interface_macaddr)
* [libapp.eossdk\_helpers](#libapp.eossdk_helpers)
  * [EapiInterface](#libapp.eossdk_helpers.EapiInterface)
* [libapp.eossdk\_utils](#libapp.eossdk_utils)
  * [debug\_fn](#libapp.eossdk_utils.debug_fn)
  * [SdkAgentMetaClass](#libapp.eossdk_utils.SdkAgentMetaClass)
    * [\_\_new\_\_](#libapp.eossdk_utils.SdkAgentMetaClass.__new__)
  * [EosSdkAgent](#libapp.eossdk_utils.EosSdkAgent)
* [libapp.fphy](#libapp.fphy)
  * [FPhy](#libapp.fphy.FPhy)
    * [initialise](#libapp.fphy.FPhy.initialise)
    * [set\_speed](#libapp.fphy.FPhy.set_speed)
* [libapp.loghandler](#libapp.loghandler)
  * [EOSTraceHandler](#libapp.loghandler.EOSTraceHandler)
* [libapp.network](#libapp.network)
* [libapp.pcie](#libapp.pcie)
* [libapp.pcie.device](#libapp.pcie.device)
* [libapp.pcie.fpga\_pcie](#libapp.pcie.fpga_pcie)
  * [FpgaPCIeDeviceManager](#libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager)
    * [check\_pcie\_bifurcation](#libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.check_pcie_bifurcation)
    * [enable\_access\_pci\_devices](#libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.enable_access_pci_devices)
    * [check\_access\_pci\_devices](#libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.check_access_pci_devices)
    * [rescan\_pci\_devices](#libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.rescan_pci_devices)
    * [remove\_pci\_devices](#libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.remove_pci_devices)
    * [lspci\_devices](#libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.lspci_devices)
    * [list\_devices](#libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.list_devices)
    * [list\_regions](#libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.list_regions)
    * [read\_region](#libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.read_region)
    * [write\_region](#libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.write_region)
* [libapp.pcie.helpers](#libapp.pcie.helpers)
* [libapp.pcie.pci](#libapp.pcie.pci)
  * [PCIDeviceManager](#libapp.pcie.pci.PCIDeviceManager)
    * [detect\_pci\_devices](#libapp.pcie.pci.PCIDeviceManager.detect_pci_devices)
    * [rescan\_pci\_devices](#libapp.pcie.pci.PCIDeviceManager.rescan_pci_devices)
    * [lspci\_devices](#libapp.pcie.pci.PCIDeviceManager.lspci_devices)
    * [get\_pci\_devices\_by\_id](#libapp.pcie.pci.PCIDeviceManager.get_pci_devices_by_id)
    * [get\_pci\_devices\_by\_bdf\_re](#libapp.pcie.pci.PCIDeviceManager.get_pci_devices_by_bdf_re)
  * [PCIMemoryRegion](#libapp.pcie.pci.PCIMemoryRegion)
    * [is\_mapped](#libapp.pcie.pci.PCIMemoryRegion.is_mapped)
    * [read\_aligned\_once](#libapp.pcie.pci.PCIMemoryRegion.read_aligned_once)
    * [read](#libapp.pcie.pci.PCIMemoryRegion.read)
    * [write\_aligned\_once](#libapp.pcie.pci.PCIMemoryRegion.write_aligned_once)
    * [write](#libapp.pcie.pci.PCIMemoryRegion.write)
  * [PCICapability](#libapp.pcie.pci.PCICapability)
  * [PCIExpressCapability](#libapp.pcie.pci.PCIExpressCapability)
    * [\_\_init\_\_](#libapp.pcie.pci.PCIExpressCapability.__init__)
  * [PCIDevice](#libapp.pcie.pci.PCIDevice)
    * [\_\_init\_\_](#libapp.pcie.pci.PCIDevice.__init__)
    * [iospace\_regions](#libapp.pcie.pci.PCIDevice.iospace_regions)
    * [memspace\_regions](#libapp.pcie.pci.PCIDevice.memspace_regions)
    * [memspace\_access\_enabled](#libapp.pcie.pci.PCIDevice.memspace_access_enabled)
    * [memspace\_access\_enabled](#libapp.pcie.pci.PCIDevice.memspace_access_enabled)
    * [rescan](#libapp.pcie.pci.PCIDevice.rescan)
    * [remove](#libapp.pcie.pci.PCIDevice.remove)
    * [config\_read\_setpci](#libapp.pcie.pci.PCIDevice.config_read_setpci)
    * [config\_write\_setpci](#libapp.pcie.pci.PCIDevice.config_write_setpci)
  * [PCIEndpoint](#libapp.pcie.pci.PCIEndpoint)
  * [PCIBridge](#libapp.pcie.pci.PCIBridge)
  * [PCIeDevice](#libapp.pcie.pci.PCIeDevice)
  * [PCIeEndpoint](#libapp.pcie.pci.PCIeEndpoint)
  * [PCIeBridge](#libapp.pcie.pci.PCIeBridge)
* [libapp.pcie.pci\_ids](#libapp.pcie.pci_ids)
  * [Base](#libapp.pcie.pci_ids.Base)
    * [class\_by\_name](#libapp.pcie.pci_ids.Base.class_by_name)
    * [vendor\_by\_name](#libapp.pcie.pci_ids.Base.vendor_by_name)
  * [PCI\_IDs](#libapp.pcie.pci_ids.PCI_IDs)
    * [vendor\_id\_inttokey](#libapp.pcie.pci_ids.PCI_IDs.vendor_id_inttokey)
    * [device\_id\_inttokey](#libapp.pcie.pci_ids.PCI_IDs.device_id_inttokey)
    * [class\_id\_inttokey](#libapp.pcie.pci_ids.PCI_IDs.class_id_inttokey)
    * [subclass\_id\_inttokey](#libapp.pcie.pci_ids.PCI_IDs.subclass_id_inttokey)
    * [get\_unique\_id](#libapp.pcie.pci_ids.PCI_IDs.get_unique_id)
    * [get\_vendor\_name](#libapp.pcie.pci_ids.PCI_IDs.get_vendor_name)
    * [get\_vendor\_id](#libapp.pcie.pci_ids.PCI_IDs.get_vendor_id)
    * [get\_device\_name](#libapp.pcie.pci_ids.PCI_IDs.get_device_name)
    * [get\_device\_id](#libapp.pcie.pci_ids.PCI_IDs.get_device_id)
    * [get\_class\_id](#libapp.pcie.pci_ids.PCI_IDs.get_class_id)
    * [get\_subclass\_name](#libapp.pcie.pci_ids.PCI_IDs.get_subclass_name)
    * [get\_subclass\_id](#libapp.pcie.pci_ids.PCI_IDs.get_subclass_id)
* [libapp.pcie.shell](#libapp.pcie.shell)
  * [shellcmd](#libapp.pcie.shell.shellcmd)
  * [echo](#libapp.pcie.shell.echo)
* [libapp.pl\_smbus\_burst](#libapp.pl_smbus_burst)
* [libapp.profiles](#libapp.profiles)
* [libapp.register\_accessor](#libapp.register_accessor)
* [libapp.register\_burst](#libapp.register_burst)
* [libapp.register\_file](#libapp.register_file)
  * [Retryable](#libapp.register_file.Retryable)
  * [RegisterFile](#libapp.register_file.RegisterFile)
* [libapp.serial](#libapp.serial)
  * [dumps](#libapp.serial.dumps)
  * [loads](#libapp.serial.loads)
* [libapp.subprocess](#libapp.subprocess)
  * [SubprocessHandler](#libapp.subprocess.SubprocessHandler)
    * [on\_process\_exit](#libapp.subprocess.SubprocessHandler.on_process_exit)
  * [ChildProcess](#libapp.subprocess.ChildProcess)
    * [\_\_init\_\_](#libapp.subprocess.ChildProcess.__init__)
  * [SubprocessMgr](#libapp.subprocess.SubprocessMgr)
    * [SubprocessReactor](#libapp.subprocess.SubprocessMgr.SubprocessReactor)
    * [run](#libapp.subprocess.SubprocessMgr.run)
* [libapp.sysctl](#libapp.sysctl)
  * [PhyConfig](#libapp.sysctl.PhyConfig)
  * [AristaSysctlV2](#libapp.sysctl.AristaSysctlV2)
    * [\_\_init\_\_](#libapp.sysctl.AristaSysctlV2.__init__)
* [libapp.system](#libapp.system)
  * [eos\_version](#libapp.system.eos_version)
* [libapp.telemetry](#libapp.telemetry)
  * [Telemetry](#libapp.telemetry.Telemetry)
    * [ready](#libapp.telemetry.Telemetry.ready)
    * [connect](#libapp.telemetry.Telemetry.connect)
    * [disconnect](#libapp.telemetry.Telemetry.disconnect)
    * [add\_default\_tags](#libapp.telemetry.Telemetry.add_default_tags)
    * [send\_metrics](#libapp.telemetry.Telemetry.send_metrics)
* [libapp.tuning](#libapp.tuning)
  * [TuningMixin](#libapp.tuning.TuningMixin)

<a id="libapp"></a>

# libapp

The libapp package.

<a id="libapp.cli"></a>

# libapp.cli

Utilities for writing CliPlugins.

<a id="libapp.cli.StatusAccessor"></a>

## StatusAccessor Objects

```python
class StatusAccessor(Mapping, dict)
```

A wrapper around statuses in Sysdb that provides python objects.

This mapping handles the translation between python objects and serialized
representations stored in Sysdb under daemon/agent/status.  Those values
are always strings which this class assumes are JSON encoded.  Strings
which are not correctly encoded will result in ValueError/JsonDecodeError
exceptions.

<a id="libapp.cli.status_as_dict"></a>

#### status\_as\_dict

```python
def status_as_dict(ctx)
```

Returns current status in Sysdb deserialized as a dict.

<a id="libapp.cli.ShowEnabledBaseCmd"></a>

## ShowEnabledBaseCmd Objects

```python
class ShowEnabledBaseCmd(CliExtension.ShowCommandClass)
```

Subclassing me will provide enabled/running status.

**Attributes**:

- `daemon` _str_ - Name of the daemon.
  
  The derived class must initialize the data object with a call to
  super(<DerivedClass>, self).handler(ctx) which will return a dict with the
  <enabled> and <running> keys.
  
  Furthermore, the same must be done in the render function:
  e.g. super(<DerivedClass>, self).render(data)
  which will print the enabled/running status.

<a id="libapp.clkgen_ctl"></a>

# libapp.clkgen\_ctl

Clock generator controller for applications running on Arista 7130 switches.

Deprecated: Use the `clock_generator` module instead.

<a id="libapp.clkgen_ctl.ClkGenDevice"></a>

## ClkGenDevice Objects

```python
class ClkGenDevice(object)
```

Clock generator (clkgen) controller.

<a id="libapp.clkgen_ctl.ClkGenDevice.set_clkgenconfig"></a>

#### set\_clkgenconfig

```python
def set_clkgenconfig(profile)
```

Sets clkgen profile.

Configures clkgen with the specified profile and waits for the device
to be ready.

**Arguments**:

- `profile` _str_ - Name of profile to apply. Possible values are:
  "eth", "eth161", "pal", "ntsc", "palx2", "ntscx2".

<a id="libapp.clkgen_ctl.ClkGenDevice.rst_clkgenconfig"></a>

#### rst\_clkgenconfig

```python
def rst_clkgenconfig()
```

Resets clkgen profile to the default value.

<a id="libapp.clock_generator"></a>

# libapp.clock\_generator

Clock generator controller for applications running on Arista 7130 switches.

<a id="libapp.clock_generator.ClockGenerator"></a>

## ClockGenerator Objects

```python
class ClockGenerator(object)
```

Clock generator (clkgen) controller.

<a id="libapp.clock_generator.ClockGenerator.check_profile"></a>

#### check\_profile

```python
def check_profile(profile)
```

Verifies that the profile exists for the platform.

<a id="libapp.clock_generator.ClockGenerator.load_profile"></a>

#### load\_profile

```python
def load_profile(profile, verify=False, quiet=False, timeout=None)
```

Loads a clock generator profile.

Configures clkgen with the specified profile and waits for the device
to return ready.

**Arguments**:

- `profile` _str_ - Name of profile to apply.

<a id="libapp.daemon"></a>

# libapp.daemon

Helpers for writing EosSdk daemons.

<a id="libapp.daemon.StatusMixin"></a>

## StatusMixin Objects

```python
class StatusMixin(object)
```

A mixin that exposes daemon status through the `status` property.

<a id="libapp.daemon.StatusMixin.status"></a>

#### status

```python
@property
def status()
```

A mutable mapping that provides access to daemon status.

<a id="libapp.device"></a>

# libapp.device

Wrappers for accessing FPGAs and other devices on 7130 switches.

<a id="libapp.device.Fpga"></a>

## Fpga Objects

```python
class Fpga(object)
```

An FPGA in the system.

Typically accessed via get_fpga_devices().

**Attributes**:

- `label` _str_ - Label used to identify the FPGA.
- `identifier` _str_ - The name of the FPGA on EOS.
- `id` _int_ - Numeric FPGA identifier.
- `board_standard` _str_ - The FPGA bitstream compatibility standard.
- `communicator` _RegisterAccessor_ - The interface to use to access
  registers via the i2c_app bus.
- `sys_communicator` _RegisterAccessor_ - The interface to use to access
  registers via the i2c_sys bus.
- `port_list` _List[int]_ - List of ap interfaces on this FPGA.
- `macaddr_list` _List[netaddr.EUI]_ - List of MAC addresses allocated to this FPGA.
- `part` _str_ - Part number of the FPGA.
- `jtag` _JTAG_ - JTAG interface to the FPGA.
- `pcie` _Pcie_ - PCIe interface to the FPGA.
- `clkgen` _ClockGenerator_ - ClockGenerator device interface for FPGA reference clocks.
- `tuning_data` _dict_ - Mapping of supported (speed, medium) combinations
  to one-based AP numbers and tuning-setting dictionaries.

<a id="libapp.device.Fpga.load_image"></a>

#### load\_image

```python
def load_image(bitstream,
               clock_profile="default",
               blocking=True,
               timeout=None,
               ipcores=None,
               register_file=None,
               port_def=None,
               load_from_flash=False,
               allow_device_restart=False,
               counters_supported=False)
```

Programs the FPGA with a specified bitstream.

On EOS, the `timeout` and `blocking` flags are supported.

If `blocking` is False, this function returns immediately after beginning
programming. On EOS, use `fpga.is_loaded()` or `fpga.profile_state()` to
check the result.

If `timeout` is not None, this function will raise a TimeoutError if the programming takes longer than
`timeout` seconds. As EosSdk daemons may be killed if they do not yield back to the main event loop within 30
seconds, this may be useful to gracefully handle programming taking too long instead of having the entire
daemon killed.

**Arguments**:

- `bitstream` _str_ - Path to the bitstream file.
- `clock_profile` _str_ - Clock-generator profile to load. Defaults to
  `"default"`.
- `blocking` _bool_ - Whether to wait for programming to finish. On EOS,
  `False` returns after programming starts.
- `timeout` _Optional[float]_ - Maximum time in seconds to wait for
  programming on EOS.
- `ipcores` _Optional[Dict[str, str]]_ - IP-core configuration to include
  in the EOS profile.
- `register_file` _Optional[str]_ - Path to the register file to use.
- `load_from_flash` _bool_ - Whether to load the image from FPGA flash.
- `allow_device_restart` _bool_ - Whether the image should remain loaded
  when the device restarts.
- `counters_supported` _bool_ - Whether the daemon publishes interface
  counters.

<a id="libapp.device.Fpga.profile_key"></a>

#### profile\_key

```python
def profile_key()
```

Return the profile that has been applied to this FPGA. If no profile is loaded, this function returns `None`

<a id="libapp.device.Fpga.profile_state"></a>

#### profile\_state

```python
def profile_state()
```

Returns the state of the profile that has been applied to the FPGA from this program

<a id="libapp.device.Fpga.is_loaded"></a>

#### is\_loaded

```python
def is_loaded()
```

Returns true if the FPGA is loaded with an image from this program

<a id="libapp.device.Fpga.unload_image"></a>

#### unload\_image

```python
def unload_image()
```

Clears FPGA configuration.

<a id="libapp.device.Fpga.tuning_data"></a>

#### tuning\_data

```python
@property
def tuning_data()
```

Returns platform-specific recommended FPGA transceiver tuning values.

The mapping contains only the speed and medium combinations supplied
for the detected platform, keyed by one-based AP number. Reading this
property returns data only and does not configure FPGA hardware.

<a id="libapp.device.get_fpga_devices"></a>

#### get\_fpga\_devices

```python
def get_fpga_devices(board_standard=None, identifier=None, _i2c_awidth=None)
```

Returns a list of application FPGAs in the system.

By default get_fpga_devices will return all application FPGAs in the system
but the result can be filtered by specifying a board standard or identifier
for a particular FPGA.

**Arguments**:

- `board_standard` _Optional[str]_ - The board standard to restrict the
  resulting FPGA list to, if any.
- `identifier` _Optional[str]_ - The name of a particular FPGA to limit the
  result to.

<a id="libapp.device.get_fpga_identifiers"></a>

#### get\_fpga\_identifiers

```python
def get_fpga_identifiers()
```

Return a mapping from each application FPGA identifier to its board standard.

On EOS, keys are FPGA identifiers such as `Fpga1`. On other platforms,
keys are the corresponding platform labels.

<a id="libapp.device.get_interface_macaddr"></a>

#### get\_interface\_macaddr

```python
def get_interface_macaddr(interface=None)
```

Returns the mac address of a particular port.

**Arguments**:

  interface [str]: The name of a particular port.

<a id="libapp.eossdk_helpers"></a>

# libapp.eossdk\_helpers

<a id="libapp.eossdk_helpers.EapiInterface"></a>

## EapiInterface Objects

```python
class EapiInterface(object)
```

A wrapper around EOSSDK EAPI Interface.

<a id="libapp.eossdk_utils"></a>

# libapp.eossdk\_utils

<a id="libapp.eossdk_utils.debug_fn"></a>

#### debug\_fn

```python
def debug_fn(func)
```

This wrapper tries to run the wrapped function. If the function
raises an Exception, print the traceback, and, if the user is at a
TTY, drop the user into an interactive debug session.

<a id="libapp.eossdk_utils.SdkAgentMetaClass"></a>

## SdkAgentMetaClass Objects

```python
class SdkAgentMetaClass(type)
```

<a id="libapp.eossdk_utils.SdkAgentMetaClass.__new__"></a>

#### \_\_new\_\_

```python
def __new__(mcs, classname, bases, classDict)
```

Wraps all functions in this class that start with "on_" with
the above debug_fn

<a id="libapp.eossdk_utils.EosSdkAgent"></a>

## EosSdkAgent Objects

```python
class EosSdkAgent(six.with_metaclass(SdkAgentMetaClass, object))
```

To add debgging capabilities to your agent, subclass this EosSdkAgent.

<a id="libapp.fphy"></a>

# libapp.fphy

<a id="libapp.fphy.FPhy"></a>

## FPhy Objects

```python
class FPhy(object)
```

Transceiver tuning driver for a matching PHY configuration interface.

Uses `arista_sysctl_v2` PHY configuration records to apply values from
`Fpga.tuning_data`. The register names and layout must match the PHY
interface used by the application.

<a id="libapp.fphy.FPhy.initialise"></a>

#### initialise

```python
def initialise(fpga, sysctl, tuning_data)
```

Initialise the transceiver tuning path.

**Arguments**:

- `fpga` - FPGA identifier used when reporting tuning activity.
- `sysctl` - `AristaSysctlV2` instance exposing PHY configuration
  records.
- `tuning_data` - Mapping returned by `Fpga.tuning_data`.
  
  This configures the inputs used by `set_speed`.

<a id="libapp.fphy.FPhy.set_speed"></a>

#### set\_speed

```python
def set_speed(port, speed, medium=None, multichannel=False)
```

Apply tuning for a port speed and medium.

**Arguments**:

- `port` _int_ - One-based AP number.
- `speed` _str_ - Requested link speed.
- `medium` _str_ - Supported medium for the requested speed.
- `multichannel` _bool_ - Multichannel operation, which is unsupported.
  
  The values are written through the matching `arista_sysctl_v2` PHY
  configuration record. The requested speed and medium must be supplied
  by the platform's `Fpga.tuning_data`.

<a id="libapp.loghandler"></a>

# libapp.loghandler

Python logging for EOS apps.

<a id="libapp.loghandler.EOSTraceHandler"></a>

## EOSTraceHandler Objects

```python
class EOSTraceHandler(logging.Handler)
```

A handler class which uses EOS tracing.

<a id="libapp.network"></a>

# libapp.network

Network Utility Functions for applications running on Arista 7130 switches.

<a id="libapp.pcie"></a>

# libapp.pcie

<a id="libapp.pcie.device"></a>

# libapp.pcie.device

<a id="libapp.pcie.fpga_pcie"></a>

# libapp.pcie.fpga\_pcie

<a id="libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager"></a>

## FpgaPCIeDeviceManager Objects

```python
class FpgaPCIeDeviceManager(object)
```

Class to manage PCIe devices on FPGAs in the system

<a id="libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.check_pcie_bifurcation"></a>

#### check\_pcie\_bifurcation

```python
def check_pcie_bifurcation()
```

Check that the PCIe bifurcation set in the BIOS is correct and prompt a reboot if it is not

<a id="libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.enable_access_pci_devices"></a>

#### enable\_access\_pci\_devices

```python
def enable_access_pci_devices(memory=False)
```

Enable memory (and I/O - unimplemented) access to managed PCI devices

<a id="libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.check_access_pci_devices"></a>

#### check\_access\_pci\_devices

```python
def check_access_pci_devices(trxn_size=4)
```

Check the PCI devices to make sure that they are mapped correctly and there is read/write access.
Param trxn_size: Maximum size in bytes for each access-check transaction,
                 or None to use one transaction. It must be a multiple of
                 the region's word size.

<a id="libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.rescan_pci_devices"></a>

#### rescan\_pci\_devices

```python
def rescan_pci_devices(remove=False, remove_bridge=False)
```

Rescan for PCI devices on the FPGAs

<a id="libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.remove_pci_devices"></a>

#### remove\_pci\_devices

```python
def remove_pci_devices(remove_bridge=False)
```

Remove all PCI devices on the FPGAs. Return a list of BDFs of the removed devices.

<a id="libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.lspci_devices"></a>

#### lspci\_devices

```python
def lspci_devices(bdf=None, verbose=False, root=False)
```

Return `lspci` output for the PCI devices on the FPGAs.

<a id="libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.list_devices"></a>

#### list\_devices

```python
def list_devices(verbose=False)
```

Return PCIe device information as a list of dictionaries. Link values
contain both the current and maximum capability values.

If `verbose` is true, each dictionary also includes subclass, vendor,
and device identifiers and names.

Returns (list[dict]): One dictionary for each managed PCIe device.

<a id="libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.list_regions"></a>

#### list\_regions

```python
def list_regions(verbose=False)
```

Return memory-region information as a list of dictionaries.

If `verbose` is true, each dictionary also includes whether the region
is prefetchable.

Returns (list[dict]): One dictionary for each region of each managed
    PCIe device.

<a id="libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.read_region"></a>

#### read\_region

```python
def read_region(bdf, region_num, offset, nbytes, align=True, trxn_size=4)
```

Read the values at address range [offset:offset+nbytes-1] (inclusive) of the specified region.
Param bdf: [Domain:]Bus:Device.Function identifier, Domain defaults to 0x0000
Param nbytes: Number of bytes to read. A value of 0 reads the entire region starting from offset.
Param align: Align accesses to word boundaries, defaults to True
Param trxn_size: Maximum size in bytes for each read transaction, or None
                 to use one transaction. It must be a multiple of the
                 region's word size.
Returns (bytes): The requested bytes in device memory order.

<a id="libapp.pcie.fpga_pcie.FpgaPCIeDeviceManager.write_region"></a>

#### write\_region

```python
def write_region(bdf,
                 region_num,
                 value,
                 offset,
                 nbytes=None,
                 align=True,
                 trxn_size=4)
```

Write bytes at an offset from the base address of the specified region. If
`nbytes` is greater than the length of `value`, the value is repeated.
Param bdf: [Domain:]Bus:Device.Function identifier, Domain defaults to 0x0000
Param value: Bytes to write, repeated as needed to fill `nbytes`.
Param offset: Offset in bytes from the start of the region.
Param nbytes: Number of bytes to write. A value of 0 fills the entire region starting from offset.
              Must be a multiple of the length of value. Defaults to the length of value.
Param align: Align accesses to word boundaries, defaults to True
Param trxn_size: Maximum size in bytes for each write transaction, or None
                 to use one transaction. It must be a multiple of the
                 region's word size.

<a id="libapp.pcie.helpers"></a>

# libapp.pcie.helpers

<a id="libapp.pcie.pci"></a>

# libapp.pcie.pci

<a id="libapp.pcie.pci.PCIDeviceManager"></a>

## PCIDeviceManager Objects

```python
class PCIDeviceManager(object)
```

Class to manage all the PCI devices in the system

<a id="libapp.pcie.pci.PCIDeviceManager.detect_pci_devices"></a>

#### detect\_pci\_devices

```python
def detect_pci_devices(bdfs=None)
```

Create a list of PCI devices in the system. Invalidates all existing references to detected devices.
Param bdfs: List of BDFs of devices to detect, includes all devices in the system by default

<a id="libapp.pcie.pci.PCIDeviceManager.rescan_pci_devices"></a>

#### rescan\_pci\_devices

```python
def rescan_pci_devices()
```

Rescan all PCI devices in the system.

<a id="libapp.pcie.pci.PCIDeviceManager.lspci_devices"></a>

#### lspci\_devices

```python
@staticmethod
def lspci_devices(bdf="::.",
                  vendor_id="",
                  device_id="",
                  class_id="",
                  verbose=False,
                  root=False)
```

Return the `lspci` output for devices matching the supplied filters.

<a id="libapp.pcie.pci.PCIDeviceManager.get_pci_devices_by_id"></a>

#### get\_pci\_devices\_by\_id

```python
def get_pci_devices_by_id(vendor_id, device_id)
```

Return a list of PCI devices which match the given vendor and device IDs

<a id="libapp.pcie.pci.PCIDeviceManager.get_pci_devices_by_bdf_re"></a>

#### get\_pci\_devices\_by\_bdf\_re

```python
def get_pci_devices_by_bdf_re(regexp)
```

Return a list of PCI devices whose BDF matches the given regular expression

<a id="libapp.pcie.pci.PCIMemoryRegion"></a>

## PCIMemoryRegion Objects

```python
class PCIMemoryRegion(object)
```

Class representing a memory region of a PCI device

<a id="libapp.pcie.pci.PCIMemoryRegion.is_mapped"></a>

#### is\_mapped

```python
@property
def is_mapped()
```

Whether or not the operating system has mapped the region

<a id="libapp.pcie.pci.PCIMemoryRegion.read_aligned_once"></a>

#### read\_aligned\_once

```python
def read_aligned_once(nbytes)
```

mmap.read has a bug where it may result in multiple reads for a single call. This breaks clear-on-read
registers. This function implements a workaround to read only once at the current address.

<a id="libapp.pcie.pci.PCIMemoryRegion.read"></a>

#### read

```python
def read(offset, nbytes, align=True, trxn_size=4)
```

Return bytes read from the memory region starting at offset.
Beware of concurrency issues if other processes are also accessing the memory region.
Param align: Align accesses to word boundaries, defaults to True
Param trxn_size: Maximum size of each read transaction in bytes. If None,
                 the read is issued as one transaction. It must be a
                 multiple of the region's word size.
Returns (bytes): The requested bytes in device memory order.

<a id="libapp.pcie.pci.PCIMemoryRegion.write_aligned_once"></a>

#### write\_aligned\_once

```python
def write_aligned_once(data)
```

mmap.write has a bug where it may result in multiple writes for a single call. This function implements a
workaround to write only once at the current address.

<a id="libapp.pcie.pci.PCIMemoryRegion.write"></a>

#### write

```python
def write(offset, value, align=True, trxn_size=4)
```

Write bytes to the memory region starting at offset.
Beware of concurrency issues if other processes are also accessing the memory region.
Param offset: Offset in bytes from the start of the region.
Param value: Bytes to write.
Param align: Align accesses to word boundaries, defaults to True
Param trxn_size: Maximum size of each write transaction in bytes. If None,
                 the write is issued as one transaction. It must be a
                 multiple of the region's word size.

<a id="libapp.pcie.pci.PCICapability"></a>

## PCICapability Objects

```python
class PCICapability(object)
```

Class representing a PCI capability

<a id="libapp.pcie.pci.PCIExpressCapability"></a>

## PCIExpressCapability Objects

```python
class PCIExpressCapability(PCICapability)
```

Class representing the PCI Express capability

<a id="libapp.pcie.pci.PCIExpressCapability.__init__"></a>

#### \_\_init\_\_

```python
def __init__(cap)
```

Param capability: bytearray containing the capability

<a id="libapp.pcie.pci.PCIDevice"></a>

## PCIDevice Objects

```python
class PCIDevice(object)
```

Class representing a PCI device.
This class should really only be constructed through PCI(e)Endpoint or PCI(e)Bridge.

<a id="libapp.pcie.pci.PCIDevice.__init__"></a>

#### \_\_init\_\_

```python
def __init__(bdf=None, manager=None, device_path=None, config=None)
```

This just marks that a device with the specified BDF exists.
Call self.fill_info() to set device info.

<a id="libapp.pcie.pci.PCIDevice.iospace_regions"></a>

#### iospace\_regions

```python
@property
def iospace_regions()
```

List of regions mapped into I/O space

<a id="libapp.pcie.pci.PCIDevice.memspace_regions"></a>

#### memspace\_regions

```python
@property
def memspace_regions()
```

List of regions mapped into memory space

<a id="libapp.pcie.pci.PCIDevice.memspace_access_enabled"></a>

#### memspace\_access\_enabled

```python
@property
def memspace_access_enabled()
```

Whether memory space accesses are enabled

<a id="libapp.pcie.pci.PCIDevice.memspace_access_enabled"></a>

#### memspace\_access\_enabled

```python
@memspace_access_enabled.setter
def memspace_access_enabled(en)
```

Whether memory space accesses are enabled

<a id="libapp.pcie.pci.PCIDevice.rescan"></a>

#### rescan

```python
def rescan(remove=False)
```

Rescan the device.

If the device is not removed then rescanning is successful only if the corresponding object
type of the underlying hardware does not change, e.g. from PCIEndpoint to PCIeBridge.
Otherwise an exception is raised.

If the device is removed then all references to it are invalidated.
Get a new reference to the device by specifying its BDF to PCIDeviceManager.

<a id="libapp.pcie.pci.PCIDevice.remove"></a>

#### remove

```python
def remove()
```

Remove the device from the system. All references to the device are invalidated.

<a id="libapp.pcie.pci.PCIDevice.config_read_setpci"></a>

#### config\_read\_setpci

```python
def config_read_setpci(addr, nbytes, cap_name=None)
```

Read `nbytes` from the device's PCI configuration space as an integer.
The returned integer represents a little-endian bitstring.
This method is very slow because it may spawn a new subprocess for each byte read.
Prefer using config_read instead, which reads from the device's config file.
Returns (int): The requested configuration-space value.

<a id="libapp.pcie.pci.PCIDevice.config_write_setpci"></a>

#### config\_write\_setpci

```python
def config_write_setpci(value, addr, nbytes, cap_name=None)
```

Write value as a length nbytes bitstring to the device's configuration space, starting at address addr.
Param value: integer interpreted as a little endian bitstring of length nbytes

<a id="libapp.pcie.pci.PCIEndpoint"></a>

## PCIEndpoint Objects

```python
class PCIEndpoint(PCIDevice)
```

Class representing a PCI endpoint

<a id="libapp.pcie.pci.PCIBridge"></a>

## PCIBridge Objects

```python
class PCIBridge(PCIDevice)
```

Class representing a PCI bridge

<a id="libapp.pcie.pci.PCIeDevice"></a>

## PCIeDevice Objects

```python
class PCIeDevice(PCIDevice)
```

Class representing a PCIe device

<a id="libapp.pcie.pci.PCIeEndpoint"></a>

## PCIeEndpoint Objects

```python
class PCIeEndpoint(PCIeDevice, PCIEndpoint)
```

Class representing a PCIe endpoint

<a id="libapp.pcie.pci.PCIeBridge"></a>

## PCIeBridge Objects

```python
class PCIeBridge(PCIeDevice, PCIBridge)
```

Class representing a PCIe bridge

<a id="libapp.pcie.pci_ids"></a>

# libapp.pcie.pci\_ids

<a id="libapp.pcie.pci_ids.Base"></a>

## Base Objects

```python
class Base(Parsable)
```

<a id="libapp.pcie.pci_ids.Base.class_by_name"></a>

#### class\_by\_name

type: defaultdict[str,list[Class|Vendor]]

<a id="libapp.pcie.pci_ids.Base.vendor_by_name"></a>

#### vendor\_by\_name

type: defaultdict[str,list[Class|Vendor]]

<a id="libapp.pcie.pci_ids.PCI_IDs"></a>

## PCI\_IDs Objects

```python
class PCI_IDs(object)
```

Database of PCI IDs, providing name-to-ID and ID-to-name translations

<a id="libapp.pcie.pci_ids.PCI_IDs.vendor_id_inttokey"></a>

#### vendor\_id\_inttokey

```python
@classmethod
def vendor_id_inttokey(cls, intval)
```

Convert an integer vendor ID into its hex string representation.

<a id="libapp.pcie.pci_ids.PCI_IDs.device_id_inttokey"></a>

#### device\_id\_inttokey

```python
@classmethod
def device_id_inttokey(cls, intval)
```

Convert an integer device ID into its hex string representation.

<a id="libapp.pcie.pci_ids.PCI_IDs.class_id_inttokey"></a>

#### class\_id\_inttokey

```python
@classmethod
def class_id_inttokey(cls, intval)
```

Convert an integer class ID into its hex string representation.

<a id="libapp.pcie.pci_ids.PCI_IDs.subclass_id_inttokey"></a>

#### subclass\_id\_inttokey

```python
@classmethod
def subclass_id_inttokey(cls, intval)
```

Convert an integer subclass ID into its hex string representation.

<a id="libapp.pcie.pci_ids.PCI_IDs.get_unique_id"></a>

#### get\_unique\_id

```python
@staticmethod
def get_unique_id(func, name, **kwargs)
```

Helper function to warn if expecting a unique ID

<a id="libapp.pcie.pci_ids.PCI_IDs.get_vendor_name"></a>

#### get\_vendor\_name

```python
def get_vendor_name(vendor_id)
```

Get the vendor name given a vendor ID.

<a id="libapp.pcie.pci_ids.PCI_IDs.get_vendor_id"></a>

#### get\_vendor\_id

```python
def get_vendor_id(vendor_name)
```

Get the vendor ID given a vendor name.

<a id="libapp.pcie.pci_ids.PCI_IDs.get_device_name"></a>

#### get\_device\_name

```python
def get_device_name(device_id, vendor_id=None, vendor_name=None)
```

Get the device name given a device ID and its vendor ID or name.
Vendor name is used only if ID is unspecified.

<a id="libapp.pcie.pci_ids.PCI_IDs.get_device_id"></a>

#### get\_device\_id

```python
def get_device_id(device_name, vendor_id=None, vendor_name=None)
```

Get the device ID given a device name and its vendor ID or name.
Vendor name is used only if ID is unspecified.

<a id="libapp.pcie.pci_ids.PCI_IDs.get_class_id"></a>

#### get\_class\_id

```python
def get_class_id(class_name)
```

Get the class ID given a class name.

<a id="libapp.pcie.pci_ids.PCI_IDs.get_subclass_name"></a>

#### get\_subclass\_name

```python
def get_subclass_name(subclass_id, class_id=None, class_name=None)
```

Get the subclass name given a subclass ID and its class ID or name.
Class name is used only if ID is unspecified.

<a id="libapp.pcie.pci_ids.PCI_IDs.get_subclass_id"></a>

#### get\_subclass\_id

```python
def get_subclass_id(subclass_name, class_id=None, class_name=None)
```

Get the subclass ID given a subclass name and its class ID or name.
Class name is used only if ID is unspecified.

<a id="libapp.pcie.shell"></a>

# libapp.pcie.shell

<a id="libapp.pcie.shell.shellcmd"></a>

#### shellcmd

```python
def shellcmd(cmd, input=None, root=False, shell="bash")
```

Execute a shell command

<a id="libapp.pcie.shell.echo"></a>

#### echo

```python
def echo(msg, outfile=None, root=False)
```

echo a message to stdout, or outfile if provided

<a id="libapp.pl_smbus_burst"></a>

# libapp.pl\_smbus\_burst

<a id="libapp.profiles"></a>

# libapp.profiles

<a id="libapp.register_accessor"></a>

# libapp.register\_accessor

<a id="libapp.register_burst"></a>

# libapp.register\_burst

<a id="libapp.register_file"></a>

# libapp.register\_file

<a id="libapp.register_file.Retryable"></a>

#### Retryable

```python
def Retryable(retry_list)
```

Utility decorator to wrap methods which might flake (like i2c accesses).
Pass a list of sleeptimes and the decorated function is repeatedly called,
backing off the specified time,  until success, or the list is exhausted.
Upon failure, the most recently caught exception bubbles up.

<a id="libapp.register_file.RegisterFile"></a>

#### RegisterFile

```python
def RegisterFile(csvfile, accessor, array_offset=0)
```

A wrapper around register file described by a CSV file.

**Example**:

  >>> import struct
  >>> import libapp.register_file
  >>> regfile = libapp.register_file.RegisterFile(
  ...     "fpga/muxcore_registers.csv", fpga.communicator
  ... )
  >>> struct.pack(
  ...    "<IIII", regfile.app_name_0, regfile.app_name_1, regfile.app_name_2, regfile.app_name_3
  ... )
  b'lseries_muxcore '
  

**Arguments**:

- `csvfile` _str_ - Path to the CSV file describing the register file layout.
- `accessor` _RegisterAccess_ - The object to use to perform register access.

<a id="libapp.serial"></a>

# libapp.serial

Functions to serialize/deserialize data for agent config/status.

<a id="libapp.serial.dumps"></a>

#### dumps

```python
def dumps(obj)
```

Returns a string containing a serialized representation of an object.

**Arguments**:

- `obj` _any_ - The object to serialize.

<a id="libapp.serial.loads"></a>

#### loads

```python
def loads(data)
```

Returns a deserialized Python object.

**Arguments**:

- `data` _str_ - A serialized representation of an object.

<a id="libapp.subprocess"></a>

# libapp.subprocess

subprocess

A module mirroring the standard library's `subprocess` module using EosSdk's
reactor system for running child processes asynchronously.

**Examples**:

  import eossdk
  from libapp.subprocess import PIPE, SubprocessHandler, SubprocessMgr
  class MyDaemon(eossdk.AgentHandler, SubprocessHandler):
  def __init__(self, sdk):
  self.agent_mgr = sdk.get_agent_mgr()
  self.subprocess_mgr = SubprocessMgr()
  SubprocessHandler.__init__(self, self.subprocess_mgr)
  eossdk.AgentHandler.__init__(self, self.agent_mgr)
  
  def on_process_exit(self, child, exit_code):
  # This function runs whenever the child process exits
  print("Child process {} exited with code {}".format(child.pid, exit_code))
  print("	stdout: {}".format(child.stdout))
  
  def on_initialized(self):
  self.subprocess_mgr.run(["ls", "-la"], stdout=PIPE)

<a id="libapp.subprocess.SubprocessHandler"></a>

## SubprocessHandler Objects

```python
class SubprocessHandler(object)
```

<a id="libapp.subprocess.SubprocessHandler.on_process_exit"></a>

#### on\_process\_exit

```python
def on_process_exit(child, exit_code)
```

React to child processes run using the SubprocessMgr exiting.

<a id="libapp.subprocess.ChildProcess"></a>

## ChildProcess Objects

```python
class ChildProcess(Popen)
```

A class derived from Popen that represents a child process.

<a id="libapp.subprocess.ChildProcess.__init__"></a>

#### \_\_init\_\_

```python
def __init__(*args, **kwargs)
```

This constructor is identical to the constructor of Popen

<a id="libapp.subprocess.SubprocessMgr"></a>

## SubprocessMgr Objects

```python
class SubprocessMgr(object)
```

A manager class for running asynchronous subprocesses.

<a id="libapp.subprocess.SubprocessMgr.SubprocessReactor"></a>

## SubprocessReactor Objects

```python
class SubprocessReactor(eossdk.FdHandler)
```

An internal class for the SubprocessMgr that reacts to child processes
exiting.

<a id="libapp.subprocess.SubprocessMgr.run"></a>

#### run

```python
def run(*popenargs, **kwargs)
```

Run command with arguments and return a ChildProcess instance.

The returned class is a subclass of Popen, and has all of the same members
as Popen. This method only differs from the standard subprocess.run() method
in that it does not wait for the child process to terminate before
returning, and instead returns the child process object for use.

If you need to wait for completion, use
`child = manager.run(...); child.wait()`.

<a id="libapp.sysctl"></a>

# libapp.sysctl

Wrapper for Arista System Control.

<a id="libapp.sysctl.PhyConfig"></a>

## PhyConfig Objects

```python
class PhyConfig(object)
```

Provides an interface to configure PHY settings.

**Attributes**:

- `txdiffctrl` _int_ - TX Differential Swing (5 bits).
- `txprecursor` _int_ - TX Pre-Cursor (5 bits).
- `txpostcursor` _int_ - TX Post-Cursor (5 bits).
- `txpolarity` _int_ - TX Polarity (1 bit).
- `rxdfeen` _int_ - Selects between Rx DFE Equalization and LPM Equalization (1 bit).
- `rxpolarity` _int_ - RX Polarity (1 bit).
- `txinhibit` _int_ - TX Inhibit (1 bit).
- `rxinhibit` _int_ - RX Inhibit (1 bit).
- `value` _int_ - The raw 32-bit integer value of the register.

<a id="libapp.sysctl.AristaSysctlV2"></a>

## AristaSysctlV2 Objects

```python
class AristaSysctlV2(object)
```

Provides an interface to Arista System Control functionalities (Version 2).

**Attributes**:

- `phy` _dict_ - A dictionary mapping ports to their corresponding
  PhyConfigs.

<a id="libapp.sysctl.AristaSysctlV2.__init__"></a>

#### \_\_init\_\_

```python
def __init__(regfile)
```

Initializes the AristaSysctlV2 instance.

**Arguments**:

- `regfile` _Any_ - The top-level register file instantiated from
  `arista_sysctl_v2.csv`.

<a id="libapp.system"></a>

# libapp.system

<a id="libapp.system.eos_version"></a>

#### eos\_version

```python
def eos_version()
```

Returns the EOS version as a tuple of integers.

This function parses the '/etc/swi-version' file to extract the
major, minor, and patch numbers from the running EOS image.

For example, for version string "4.32.2F", this function
would return (4, 32, 2).

If '/etc/swi-version' is not present, it returns an empty tuple.

<a id="libapp.telemetry"></a>

# libapp.telemetry

The telemetry module provides a wrapper for time-series telemetry output.
For example, sampled packet counters, time offsets, etc.

<a id="libapp.telemetry.Telemetry"></a>

## Telemetry Objects

```python
class Telemetry(object)
```

A client for sending telemetry to Telegraf.

**Arguments**:

- `appname` _str_ - The value to include as the "application" tag.
- `author` _str_ - The value to be included as the "author" tag.
- `tags` _dict[str, Any]_ - Any other default tags to be included with each
  metric.

<a id="libapp.telemetry.Telemetry.ready"></a>

#### ready

```python
def ready()
```

Return whether the Telegraf socket path is readable.

This checks filesystem readability with `os.access`; it does not attempt
to connect to the socket.

Returns (bool): True if the path is readable, False otherwise.

<a id="libapp.telemetry.Telemetry.connect"></a>

#### connect

```python
def connect()
```

Connects to Telegraf socket.

<a id="libapp.telemetry.Telemetry.disconnect"></a>

#### disconnect

```python
def disconnect()
```

Closes Telegraf socket.

<a id="libapp.telemetry.Telemetry.add_default_tags"></a>

#### add\_default\_tags

```python
def add_default_tags(tags=None)
```

Adds extra default tags to the set included with metrics.

**Arguments**:

- `tags` _dict[str, Any]_ - Extra default tags to be included with each
  metric.

<a id="libapp.telemetry.Telemetry.send_metrics"></a>

#### send\_metrics

```python
def send_metrics(measurement, values, tags=None, timestamp=None)
```

Sends a metric to the Telegraf socket.

**Arguments**:

- `measurement` _str_ - The name of the actual measurement.
- `values` _Any | dict[str, Any]_ - The value or collection of values.
- `tags` _Optional[dict[str, Any]]_ - Dictionary of extra tags, if any.
- `timestamp` _Optional[int]_ - Timestamp for the datapoint in
  nanosecond-precision Unix time.

<a id="libapp.tuning"></a>

# libapp.tuning

<a id="libapp.tuning.TuningMixin"></a>

## TuningMixin Objects

```python
class TuningMixin()
```

Mixin for applying FPGA transceiver tuning through a matching PHY interface.

This mixin uses the `arista_sysctl_v2` PHY configuration record layout.
Use it where the corresponding PHY interface is provided by the board
support package. The application must provide `fpga`, `app_path`, an
`EthPhyIntfHandler`, an `eth_phy_intf_manager`, and an eAPI manager. Call
`on_initialized` and `on_agent_enabled` alongside the application's own
handler lifecycle.

The mixin reacts to initial interface state, link-speed changes, and
transceiver insertion.

