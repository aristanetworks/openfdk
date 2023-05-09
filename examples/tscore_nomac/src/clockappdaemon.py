# ------------------------------------------------------------------------------
#  Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
#    fdk-support@arista.com
#
#  Description:
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

from __future__ import absolute_import, print_function

import os
import subprocess
import time

from six.moves import range

from metamako import Rows, rowtype
from .applicationconfig import ApplicationConfigItem
from .daemon.clockapp import clockapp_mosapi as mosapi
from .appname import appname
from .format_docstring import format_docstring


# poor heuristic, but at least maintain perfect back-compat
def best_timesource():
    return "pps"


def onboard_ocxo():
    try:
        if mosapi.get_device_by_label("mezzanine").build_revision.startswith("lb"):
            return True
    except (mosapi.device_info.NoSuchDeviceException, AttributeError, TypeError):
        pass
    return False


def clock_module():
    try:
        cm = mosapi.get_device_by_label("clock_module")
        cm_name = cm.device_name
        cm_oscillator = None
        if hasattr(cm, "oscillator_part"):
            cm_oscillator = cm.oscillator_part
    except mosapi.device_info.NoSuchDeviceException:
        cm = None
        cm_name = None
        cm_oscillator = None
    return cm_name, cm_oscillator


def best_tscs():
    boardinfo = mosapi.boardinfo()
    mezzanine = boardinfo["mezzanine"]
    clock_mod, _ = clock_module()

    if mezzanine == "lb":
        # LB CMA if present, else fall back to its onboard oscillator
        if clock_mod == "CMA":
            return "module"

        return "onboard"

    if clock_mod:
        # Otherwise we use a clock module if present
        return "module"

    # Otherwise (i.e K/E-series and no CM) we just use crystal
    return "crystal"


req_app_attr = ["is_shutdown", "get_config", "set_config", "remove_config", "reg"]


################################################################################
#
# ClockAppDaemon Class
#
################################################################################
class ClockAppDaemon(object):
    def __init__(self, _appname, binfile_directory_path, *args, **kwargs):  # pylint: disable=unused-argument
        self.appname = _appname
        self.app = mosapi.get_app_by_name(_appname)
        self.__binpath = binfile_directory_path
        self.__statfile = "/var/run/metamako/apps/{}/pysync_status".format(self.appname)
        for attr in req_app_attr:
            assert hasattr(
                self.app, attr
            ), "Cannot init {} object, application {} doesn't have a {} attribute and it is required".format(
                ClockAppDaemon.__name__, _appname, attr
            )

    @property
    def mezzanine(self):
        boardinfo = mosapi.boardinfo()
        return boardinfo["mezzanine"]

    @property
    def __binfile(self):
        return os.path.join(self.__binpath, "pysync")

    @property
    def __binargs(self):
        def timesource_ref(timesrc):
            if "auto".startswith(timesrc):
                timesrc = best_timesource()
            return {
                "ptp": "-rchronptp",
                "pps": "-rchronpps",
                "system": "-rchronsystem",
                "freerun": "-rfreerun",
            }[timesrc]

        def clocksource_clock():
            tscs = self.app.get_config("ts-clock source")
            if tscs == "auto":
                tscs = best_tscs()
            if tscs == "onboard":
                assert self.mezzanine == "lb", "Only L-Series has onboard"
                return "-clbcmo"
            if tscs == "module":
                cm_name, cm_oscillator = clock_module()
                if cm_oscillator:
                    return "-c{}{}".format(cm_name, cm_oscillator)
                return "-c{}".format(cm_name)

            # Use addskip rather than try steer the SiLabs
            return "-cAddSkip"

        verbose_flag = "-v"
        ref_flag = timesource_ref(self.app.get_config("timesource"))
        clock_flag = clocksource_clock()
        app_flag = "-a{}".format(self.appname)
        return [verbose_flag, ref_flag, clock_flag, app_flag]

    def setup_gpio(self, gpio):
        gpiodir = "/sys/class/gpio/gpio{}".format(gpio)

        if not os.path.exists(gpiodir):
            # FIXME: use subprocess.DEVNULL when we move to py3
            with open(os.devnull, "w") as devnull:  # pylint: disable=unspecified-encoding
                subprocess.check_call(
                    'sudo sh -c "echo {} > /sys/class/gpio/export"'.format(gpio),
                    shell=1,
                    stderr=devnull,
                )
            subprocess.check_output('sudo sh -c "echo out > {}/direction"'.format(gpiodir), shell=1)
        assert os.access("/sys/class/gpio/export", os.F_OK)
        subprocess.check_output('sudo sh -c "echo 1 > {}/value"'.format(gpiodir), shell=1)

    def show_daemon(self):
        return self.__binfile, self.__binargs

    def start(self):
        # A linux update changed the GPIO numbering scheme. Try the old value (235) and if
        # that fails, use the new one. If both don't work we'll have problems.
        for g in [235, 491]:
            try:
                self.setup_gpio(g)
                break
            except subprocess.CalledProcessError:
                pass
        else:  ## the list of allowable GPIOS is exhausted
            raise Exception("Unable to configure sync pulse")

        # Remove the status file so that we know the logs are all from the current daemon process
        try:
            os.remove(self.__statfile)
        except OSError:
            # Will be thrown if the file doesn't exist - that is ok so ignore the error
            pass

        mosapi.start_daemon(self.__binfile, self.__binargs)

    def stop(self):
        mosapi.stop_daemon(self.__binfile)

    def check(self):
        return mosapi.check_daemon(self.__binfile)

    def status(self):
        try:
            path = self.__statfile
            with open(path, "r") as file:  # pylint: disable=unspecified-encoding
                status = file.read()
            since = time.ctime(os.path.getmtime(path))
            return status, since
        except IOError:
            return None, None

    def wait(self):
        daemon_status = ""
        daemon_started = False
        for _ in range(90):
            sds, _ = self.status()
            if sds is not None:
                if not sds.startswith("Exit"):
                    # The daemon did start at some point
                    daemon_started = True

                if sds != daemon_status and daemon_started:
                    if sds.startswith("Running"):
                        print("Daemon {}".format(sds))
                        break

                    print("Daemon {}...".format(sds))

                if sds.startswith("Exit") and daemon_started:
                    # Daemon did start, but now shows as exited again
                    raise Exception("Daemon failed to start")
            daemon_status = sds
            time.sleep(0.5)
        else:
            raise Exception("Daemon running timeout")


################################################################################
#
# CLI Commands for status
#
################################################################################


def get_sync_history(verbose, field="Error"):  # pylint: disable=too-many-locals,too-many-branches,too-many-statements
    import influxdb  # pylint: disable=import-outside-toplevel
    import requests  # pylint: disable=import-outside-toplevel
    from requests.packages.urllib3.exceptions import (  # pylint: disable=import-outside-toplevel
        InsecureRequestWarning,
    )

    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

    client = influxdb.InfluxDBClient(
        username="mm_ronly_user",
        password="mm_ronly_pass",
        database="telegraf",
        ssl=True,
    )

    # These are aggregations with no grouping, so we know there's only on row to be returned.
    # Get all the points now and call next() once to get that row out of the
    # iterator in a more friendly manner.
    try:
        last = next(
            client.query(
                "SELECT time,{field} FROM {appname}_sync"
                " WHERE time > now()-5s AND time <= now()"
                " ORDER BY time DESC LIMIT 1".format(appname=appname, field=field)
            ).get_points()
        )
    except StopIteration:
        last = None

    try:
        min1 = next(
            client.query(
                "SELECT Count({field}),min({field}),max({field}),mean({field}),stddev({field})"
                " FROM {appname}_sync"
                " WHERE time > now()-1m AND time <= now()".format(appname=appname, field=field)
            ).get_points()
        )
    except StopIteration:
        min1 = None

    try:
        hr1 = next(
            client.query(
                "SELECT Count({field}),min({field}),max({field}),mean({field}),stddev({field})"
                " FROM {appname}_sync"
                " WHERE time > now()-1h AND time <= now()".format(appname=appname, field=field)
            ).get_points()
        )
    except StopIteration:
        hr1 = None

    if verbose:
        try:
            day1 = next(
                client.query(
                    "SELECT Count({field}),min({field}),max({field}),mean({field}),stddev({field})"
                    " FROM {appname}_sync"
                    " WHERE time > now()-1d AND time <= now()".format(appname=appname, field=field)
                ).get_points()
            )
        except StopIteration:
            day1 = None

        hourly = list(
            client.query(
                "SELECT Count({field}),min({field}),max({field}),mean({field}),stddev({field})"
                " FROM {appname}_sync"
                " WHERE time > now()-1d AND time <= now()"
                " GROUP by time(1h)"
                " ORDER BY time DESC".format(appname=appname, field=field)
            ).get_points()
        )

        daily = list(
            client.query(
                "SELECT Count({field}),min({field}),max({field}),mean({field}),stddev({field})"
                " FROM {appname}_sync"
                " WHERE time <= now()"
                " GROUP by time(1d)"
                " ORDER BY time DESC".format(appname=appname, field=field)
            ).get_points()
        )

    else:
        day1 = None
        hourly = None
        daily = None

    rows = Rows(
        "{{Sync {field} (ns):17}} {{Samples:>7}} {{Min:>9}} {{Max:>9}} {{Average:>9}} {{Std_Deviation:>13}}".format(
            field=field
        )
    )
    rtype = rowtype(
        "Sync {field} (ns)".format(field=field),
        "Samples",
        "Min",
        "Max",
        "Average",
        "Std_Deviation",
    )

    if last:
        rows.append(rtype("Now", 1, "", "", last["{field}".format(field=field)], ""))
    else:
        rows.append(rtype("Now", 0, "", "", "n/a", ""))

    def addrow(desc, info):
        # Sometimes there are no min/max/mean/stddev values (i.e in the first 1 second of a given hour)
        # So we use a conditional formatstring, based on None-ness.
        def format_ifNone(v, a, b):
            return (a if (v is None) else b).format(v)

        if info:
            mean = format_ifNone(info["mean"], "n/a", "{:.4f}")
            stddev = format_ifNone(info["stddev"], "n/a", "{:.4f}")
            minv = format_ifNone(info["min"], "n/a", "{}")
            maxv = format_ifNone(info["max"], "n/a", "{}")
            count = info["count"]  # count is always sensible, maybe zero
        else:
            mean = "n/a"
            stddev = "n/a"
            minv = "n/a"
            maxv = "n/a"
            count = 0
        rows.append(rtype(desc, count, minv, maxv, mean, stddev))

    addrow("Last 1 Minute", min1)
    addrow("Last 1 Hour", hr1)

    if verbose:
        for i, h in enumerate(hourly):
            if h["count"] == 0:
                break

            if i == 0:
                desc = "This hour"
            elif i == 1:
                desc = "1 Hour ago"
            else:
                desc = "{} hours ago".format(i)
            addrow(desc, h)
        addrow("Last 1 day", day1)
        for i, d in enumerate(daily):
            if d["count"] == 0:
                break

            if i == 0:
                desc = "Today"
            elif i == 1:
                desc = "1 day ago"
            else:
                desc = "{} days ago".format(i)
            addrow(desc, d)

    if any([last, min1, hr1, hourly, day1, daily]):
        return rows

    return "No telemetery available"


if appname == "metawatch":

    @mosapi.cli_command
    @format_docstring(appname=appname)
    def show_app_status(ctx=None, verbose="", field="Error"):  # pylint: disable=unused-argument
        """show status - show {appname} synchronisation status with respect to the selected timesource
        Usage: show status [verbose]
        Group: Application {appname}
        Mode: config-app-{appname}

        This command reports the synchronisation status of {appname} with respect to
        the selected source of time.

        See also::

        timesource

        Example::

            hostname(config-app-{appname})#show status
            Sync Error (ns)   Samples       Min       Max   Average Std Deviation
            ----------------- ------- --------- --------- --------- -------------
            Last 1 Minute          60      -1.5       1.5    -0.368        0.9379

        """

        app = mosapi.get_app_by_name(appname)
        ret = []
        if app.is_shutdown():
            ret.append("{appname} in shutdown state".format(appname=appname))
        else:
            ret.append(get_sync_history(verbose, field))

        if not app.is_shutdown():
            status, since = app.sync_daemon.status()
            if status is not None:
                ret.append("Sync Status      : {}".format(status))
                if since is not None:
                    ret[-1] += "\nSince            : {}".format(since)
            try:
                path = "/var/run/metamako/apps/metawatch/watchmaster_status"
                with open(path, "r") as file:  # pylint: disable=unspecified-encoding
                    status = file.read()
                since = time.ctime(os.path.getmtime(path))
                ret.append("Telemetry Status : {}".format(status))
                ret[-1] += "\nSince            : {}".format(since)
            except IOError:
                ret.append("Telemetry Status : Not running")
        else:
            ret.append("Sync Status      : Not running")
            ret[-1] += "\nTelemetry Status : Not running"

        return ret

    for cmd in ["status", "synchronisation status"]:

        @mosapi.cli_command
        @format_docstring(appname=appname, cmd=cmd)  # pylint: disable=cell-var-from-loop
        def show_status(ctx=None, verbose="", field="Error"):
            """show {appname} {cmd} - show {appname} synchronisation status with respect to the selected timesource
            Usage: show {appname} {cmd} [verbose]
            Group: Application {appname}
            Mode: priv

            This command reports the synchronisation status of {appname} with respect to
            the selected source of time.

            Example::

                hostname#show {appname} {cmd}
                Sync Error (ns)   Samples       Min       Max   Average Std Deviation
                ----------------- ------- --------- --------- --------- -------------
                Last 1 Minute          60      -1.5       1.5    -0.368        0.9379

            """
            return show_app_status(ctx, verbose, field)

else:

    @mosapi.cli_command
    @format_docstring(appname=appname)
    def show_status(ctx=None, verbose="", field="Error"):  # pylint: disable=unused-argument
        """show {appname} synchronisation status - show {appname} synchronisation status for the selected timesource
        Usage: show {appname} synchronisation status [verbose]
        Group: Application {appname}
        Mode: priv

        This command reports the synchronisation status of {appname} with respect to
        the selected source of time.

        See also::

        timesource

        Example::

            hostname#show {appname} synchronisation status
            Sync Error (ns)   Samples       Min       Max   Average Std Deviation
            ----------------- ------- --------- --------- --------- -------------
            Last 1 Minute          60      -1.5       1.5    -0.368        0.9379

        """

        app = mosapi.get_app_by_name(appname)
        ret = []
        if app.is_shutdown():
            ret.append("{appname} in shutdown state".format(appname=appname))
        else:
            ret.append(get_sync_history(verbose, field))

        if not app.is_shutdown():
            daemon = ClockAppDaemon(appname, "")
            status, since = daemon.status()
            if status is not None:
                ret.append("Sync Status      : {}".format(status))
                if since is not None:
                    ret[-1] += "Since           : {}".format(since)
        else:
            ret.append("Sync Status      : Not running")

        return ret


@mosapi.cli_command
@format_docstring(appname=appname)
def show_status_adjust(ctx=None, verbose=""):
    """show {appname} synchronisation status adjust - show {appname} synchronisation status adjust
    Usage: show {appname} synchronisation status adjust [verbose]
    Mode: priv
    Hidden: hidden
    """

    r = []
    r += ["pysync:"]
    r += show_status(ctx, verbose, "adjust")

    return r


################################################################################
#
# CLI Commands for timesource setting
#
################################################################################

ApplicationConfigItem("timesource", "auto")


@mosapi.cli_command
@format_docstring(appname=appname)
def timesource(ctx=None, method=""):
    """timesource - set the method used to discipline the timestamp unit
    Usage: timesource auto|freerun|pps|ptp|system
    Group: Application {appname}
    Mode: config-app-{appname}

    In 'timesource auto' mode (default), {appname} will select an available timesource.
    Currently this will be equivalent to 'ptp' on K and L-series, and "pps" on E-series.
    Future versions of {appname} may refine the auto-selection mechanism.

    In 'timesource ptp' mode, {appname} synchronises to the PTP Hardware Clock (PHC).
    If the PHC is not currently synchronized, or PTP is not running then {appname} will freerun.

    In 'timesource system' mode, {appname} synchronises to the system's clock, which
    in turn may be managed via NTP or manually with the `clock set` CLI command.
    This is a low-quality timesource

    In 'timesource pps' mode, {appname} synchronises to the top of the second
    indicated by the rising-edge of the PPS signal, and uses the system clock to
    determine which second that rising-edge indicated.
    This is a high-quality timesource.

    In 'timesource freerun' mode, {appname} sets the timestamp counter once at startup
    based on the system clock. Timestamps then increment in an undisciplined
    manner: their absolute values will initially be "close" to the true time and
    they will advance at a rate relative to the quality of the underlying
    oscillator. This may be useful when calculating deltas based on timestamps.

    Note::

    In 'timesource pps' mode {appname} requires that the PPS signal and the
    system clock of the device be synchronized to within +/- 250ms. Synchronizing
    the system clock can be achieved using either PTP or NTP.
    """
    app = ctx.mode_ctx["app"]
    if not app.is_shutdown():
        raise Exception(
            "timesource setting cannot be changed while {appname} is running, shutdown {appname} first".format(
                appname=appname
            )
        )
    app.set_config("timesource", method)


@mosapi.cli_command
@format_docstring(appname=appname)
def no_timesource(ctx=None):
    """no timesource - use the default timesource (ptp)
    Usage: no timesource
    Group: Application {appname}
    Mode: config-app-{appname}
    """
    app = ctx.mode_ctx["app"]
    if not app.is_shutdown():
        raise Exception(
            "timesource setting cannot be changed while {appname} is running, shutdown {appname} first".format(
                appname=appname
            )
        )
    app.remove_config("timesource")


@mosapi.cli_command
@format_docstring(appname=appname)
def default_timesource(ctx=None):
    """default timesource - use the default timesource (ptp)
    Usage: default timesource
    Group: Application {appname}
    Mode: config-app-{appname}
    """
    no_timesource(ctx)


@mosapi.cli_command
@format_docstring(appname=appname)
def show_timesource(ctx=None):
    """show timesource - display the currently active source of time
    Usage: show timesource
    Group: Application {appname}
    Mode: config-app-{appname}
    """
    app = ctx.mode_ctx["app"]
    conf = app.get_config("timesource")
    if "auto".startswith(conf):
        ts = best_timesource()
    else:
        ts = conf
    return "{} Timesource: {}".format("Default" if conf == "auto" else "Configured", ts)


################################################################################
#
# CLI Commands for ts-clock source  setting
#
################################################################################


@ApplicationConfigItem("ts-clock source", "auto")
def set_ts_clock_source(app, key, value, ignore_is_shutdown):  # pylint: disable=unused-argument
    if "auto".startswith(value):
        value = best_tscs()

    # Perform some checks to make sure the selected mode is valid
    if "module".startswith(value):
        if not clock_module()[0]:
            raise Exception("Cannot set Clock Module as ts-clock source, no Clock Module installed")
        val = 1

    elif "onboard".startswith(value):
        if not onboard_ocxo:
            raise Exception("Cannot set Onboard as ts-clock source, none present on this platform")
        val = 3

    elif "crystal".startswith(value):
        val = 0

    else:
        raise Exception("Unknown ts-clocksource: {}".format(value))

    # Only attempt to configure the FPGA if it is already programmed.
    # If it is not alreayd programmed, this function will be called again after programming during 'no shutdown'.
    if not app.is_shutdown() or ignore_is_shutdown:
        app.reg.ts.time_sync.control = val


@mosapi.cli_command
@format_docstring(appname=appname)
def show_ts_clock_source(ctx=None):
    """show ts-clock source - show the {appname} time-stamping clock source
    Usage: show ts-clock source
    Group: Application {appname}
    Mode: config-app-{appname}

    Show the {appname} time-stamping clock source

    Example::

        hostname>en
        hostname#conf
        hostname(config)#app {appname}
        hostname(config-app-{appname})#show ts-clock source
        Selected time-stamping clock source: Crystal oscillator (crystal)
        hostname(config-app-{appname})#

    """
    app = ctx.mode_ctx["app"]

    source = app.get_config("ts-clock source")
    r = "Configured time-stamping clock source: "

    if "auto".startswith(source):
        source = best_tscs()
        r = "Automatically selected time-stamping clock source: "

    if "crystal".startswith(source):
        r += "Crystal oscillator (crystal)"
    elif "module".startswith(source):
        r += "Clock module (module)"
    elif "onboard".startswith(source):
        boardinfo = mosapi.boardinfo()
        if boardinfo["mezzanine"] == "lb":
            r += "L-Series Onboard OCXO (onboard)"
        else:
            r += "Unknown onboard oscillator (onboard)"
            r += "\n% Builtin is not currently supported on this platform."
    return r


ts_clock_sources = "auto|crystal|module|onboard"


@mosapi.cli_command
@format_docstring(appname=appname, ts_clock_sources=ts_clock_sources)
def sel_ts_clock_source_force(ctx=None, source=None):
    """ts-clock source force - select the timestamp clock source
    Usage: ts-clock source {ts_clock_sources} force
    Group: Application {appname} debug
    Mode: config-app-{appname}
    Hidden: hidden
    """
    app = ctx.mode_ctx["app"]
    for s in ["auto", "crystal", "module", "onboard"]:
        if s.startswith(source):
            source = s
            break

    # Store the current config so we can revert if needed
    current_source = app.get_config("ts-clock source")
    try:
        app.set_config("ts-clock source", source)
    except Exception:
        # Reset the config state back to what it was before
        app.set_config("ts-clock source", current_source)
        raise


@mosapi.cli_command
@format_docstring(appname=appname, ts_clock_sources=ts_clock_sources)
def sel_ts_clock_source(ctx=None, source=None):
    """ts-clock source - select the timestamp clock source
    Usage: ts-clock source {ts_clock_sources}
    Group: Application {appname}
    Mode: config-app-{appname}

    Select the clock source for the time-stamp clock.
    auto    - Automatic selection of the best available
    crystal - Crystal Oscillator
    module  - Clock Module (Rb or OCXO, if available)
    onboard - Platform-specific high-quality onboard oscillator (if available)


    Example::

        hostname>en
        hostname#conf
        hostname(config)#app {appname}
        hostname(config-app-{appname})#ts-clock source crystal
        hostname(config-app-{appname})#

    """

    app = ctx.mode_ctx["app"]
    if not app.is_shutdown():
        raise Exception(
            "ts-clock source setting cannot be changed while {appname} is running, shutdown {appname} first".format(
                appname=appname
            )
        )
    sel_ts_clock_source_force(ctx, source)


@mosapi.cli_command
@format_docstring(appname=appname)
def no_ts_clock_source(ctx=None):
    """no ts-clock source - set the timestamp clock source to default
    Usage: no ts-clock source
    Group: Application {appname}
    Mode: config-app-{appname}

    Set the timestamp clock source to default

    Example::

        hostname>en
        hostname#conf
        hostname(config)#app {appname}
        hostname(config-app-{appname})#default ts-clock
        hostname(config-app-{appname})#

    """

    app = ctx.mode_ctx["app"]
    if not app.is_shutdown():
        raise Exception(
            "ts-clock source setting cannot be changed while {appname} is running, shutdown {appname} first".format(
                appname=appname
            )
        )
    app.remove_config("ts-clock source")


@mosapi.cli_command
@format_docstring(appname=appname)
def default_ts_clock_source(ctx=None):
    """default ts-clock source - set the timestamp clock source to default
    Usage: default ts-clock source
    Group: Application {appname}
    Mode: config-app-{appname}

    Set the timestamp clock source to default

    Example::

        hostname>en
        hostname#conf
        hostname(config)#app {appname}
        hostname(config-app-{appname})#default ts-clock
        hostname(config-app-{appname})#

    """
    no_ts_clock_source(ctx)


################################################################################
#
# Config and CLI Commands for tuning the control loop
#
################################################################################


def capv():
    return "0.3"


def caiv():
    return "0.006"


ApplicationConfigItem(
    "tuning proportional",
    capv,
    gen_cli={
        "allowed_values": ["FLOAT"],
        "description": "proportional gain of new control loop",
    },
    gen_hidden=True,
)
ApplicationConfigItem(
    "tuning integral",
    caiv,
    gen_cli={
        "allowed_values": ["FLOAT"],
        "description": "integral gain of new control loop",
    },
    gen_hidden=True,
)
ApplicationConfigItem(
    "tuning derivative",
    "0.0",
    gen_cli={
        "allowed_values": ["FLOAT"],
        "description": "derivative gain of new control loop",
    },
    gen_hidden=True,
)
ApplicationConfigItem(
    "tuning adjustinit",
    "auto",
    gen_cli={
        "allowed_values": ["NEGNUMBER"],
        "description": "initial frequency offset for control loop",
    },
    gen_hidden=True,
)


@mosapi.cli_command
@format_docstring(appname=appname)
def show_tuning(ctx=None):
    """show tuning - show advanced tuning parameters for synchronisation daemon
    Usage: show tuning
    Group: Application {appname}
    Mode: config-app-{appname}
    Hidden: hidden - for advanced tuning
    """
    app = ctx.mode_ctx["app"]

    new = Rows("{Parameter:19} {Value:>10}")
    rtype = rowtype("Parameter", "Value")

    pv = float(app.get_config("tuning proportional"))
    iv = float(app.get_config("tuning integral"))
    dv = float(app.get_config("tuning derivative"))
    ia = app.get_config("tuning adjustinit")
    try:
        ia = float(ia)
    except ValueError:
        pass
    new.append(rtype("Proportional Gain", pv))
    new.append(rtype("Integral Gain", iv))
    new.append(rtype("Derivative Gain", dv))
    new.append(rtype("Initial Adjust", ia))

    return new


@mosapi.cli_command
@format_docstring(appname=appname)
def no_tuning(ctx=None):
    """no tuning - return to default control tuning
    Usage: no tuning
    Group: Application {appname}
    Mode: config-app-{appname}
    Hidden: hidden - for advanced tuning
    """
    app = ctx.mode_ctx["app"]
    app.remove_config("tuning integral")
    app.remove_config("tuning proportional")
    app.remove_config("tuning derivative")
    app.remove_config("tuning adjustinit")


@mosapi.cli_command
@format_docstring(appname=appname)
def default_tuning(ctx=None):
    """default tuning - return to default control tuning
    Usage: default tuning
    Group: Application {appname}
    Mode: config-app-{appname}
    Hidden: hidden - for advanced tuning
    """
    return no_tuning(ctx)


################################################################################
#
# Syntactic sugar CLI Commands for tuning the control loop
#
################################################################################


@mosapi.cli_command
@format_docstring(appname=appname)
def tuning_slow(ctx=None, factor=""):
    """tuning slow - set tuning values to respond slowly
    Usage: tuning slow [FLOAT]
    Group: Application {appname}
    Mode: config-app-{appname}
    Hidden: hidden - for advanced tuning
    """
    try:
        k = float(factor)
    except (ValueError, TypeError):
        k = 2.0
    app = ctx.mode_ctx["app"]
    app.set_config(
        "tuning proportional",
        "{}".format(float(app.default["tuning proportional"]) / k),
    )
    app.set_config("tuning integral", "{}".format(float(app.default["tuning integral"]) / (k**2)))


@mosapi.cli_command
@format_docstring(appname=appname)
def tuning_fast(ctx=None, factor=""):
    """tuning fast - set tuning values to respond quickly
    Usage: tuning fast [FLOAT]
    Group: Application {appname}
    Mode: config-app-{appname}
    Hidden: hidden - for advanced tuning
    """
    try:
        k = float(factor)
    except (ValueError, TypeError):
        k = 2.0
    app = ctx.mode_ctx["app"]
    app.set_config(
        "tuning proportional",
        "{}".format(float(app.default["tuning proportional"]) * k),
    )
    app.set_config("tuning integral", "{}".format(float(app.default["tuning integral"]) * (k**2)))


@mosapi.cli_command
@format_docstring(appname=appname)
def tuning_tau(ctx=None, tau=""):
    """tuning time-constant - approximately set tuning time-constant (in seconds)
    Usage: tuning time-constant [FLOAT]
    Group: Application {appname}
    Mode: config-app-{appname}
    Hidden: hidden - for advanced tuning
    """
    k = 35.0 / float(tau)
    app = ctx.mode_ctx["app"]
    app.set_config(
        "tuning proportional",
        "{}".format(float(app.default["tuning proportional"]) * k),
    )
    app.set_config("tuning integral", "{}".format(float(app.default["tuning integral"]) * (k**2)))
