# ------------------------------------------------------------------------------
#  Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
#    fdk-support@arista.com
#
#  Description:
#    Subprocess support library
#    This library is only supported on EOS
#
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

"""subprocess

A module mirroring the standard library's `subprocess` module using EosSdk's
reactor system for running child processes asynchronously.

Examples:
    from libapp.subprocess import SubprocessHandler, SubprocessMgr
    class MyDaemon(eossdk.AgentHandler, SubprocessHandler):
        def __init__(self, sdk):
            self.agent_mgr = sdk.get_agent_mgr()
            self.subprocess_mgr = SubprocessMgr()
            SubprocessHandler.__init__(self, self.subprocess_mgr)
            eossdk.AgentHandler.__init__(self, self.agent_mgr)

        def on_process_exit(self, child, exit_code):
            # This function runs whenever the child process exits
            print("Child process {} exited with code {}".format(child.pid, exit_code))
            print("\tstdout: {}".format(child.stdout))

        def on_initialized(self):
            self.subprocess_manager.run(['ls', '-la'])
"""

from __future__ import absolute_import, division, print_function

try:
    import eossdk
except Exception:  # pylint: disable=broad-except

    class MockedEosSdk:
        class FdHandler:
            pass

    eossdk = MockedEosSdk()
import fcntl
import os
import weakref
from subprocess import PIPE, Popen

import six


class SubprocessHandler(object):
    def __init__(self, subprocess_mgr):
        # We don't actually want to store the manager in the handler, as it'll cause
        # a reference loop, preventing us from being able to ever clean up either
        # the manager or the handler.
        subprocess_mgr._handlers.add(self)

    def on_process_exit(self, child, exit_code):  # pylint: disable=unused-argument
        """React to child processes run using the SubprocessMgr exiting."""
        return


class ChildProcess(Popen):
    """A class derived from Popen that represents a child process."""

    def __init__(self, *args, **kwargs):
        """This constructor is identical to the constructor of Popen"""
        r, w = os.pipe()
        self._fd = r

        # The default for close_fds is `False` in Python 2, and `True` in Python 3
        if kwargs.get("close_fds", six.PY3) or "pass_fds" in kwargs:
            pass_fds = list(kwargs.pop("pass_fds", tuple()))
            pass_fds.append(w)
            kwargs["pass_fds"] = tuple(pass_fds)

        # Python 2 subprocess doesn't support `pass_fds`, so we need to sort of add
        # our own to a preexec_fn to make sure that the write side of the pipe is
        # not closed early
        if six.PY2:
            pass_fds = set(kwargs.pop("pass_fds", tuple()))
            close_fds = kwargs.get("close_fds", False)
            fn = kwargs.get("preexec_fn", None)

            pass_fds.add(w)

            def preexec_fn():
                from six.moves import range  # pylint: disable=import-outside-toplevel

                if fn:
                    fn()
                # We should always close the read end of the pipe in the child
                os.close(r)
                # We set close_fds to False, so we need to make sure that all the
                # fds that need to be close are closed if it was previously True
                if close_fds:
                    for fd in range(3, 256):
                        if fd not in pass_fds:
                            try:
                                os.close(fd)
                            except OSError:
                                pass

            kwargs["close_fds"] = False
            kwargs["preexec_fn"] = preexec_fn

        Popen.__init__(self, *args, **kwargs)

        flags = fcntl.fcntl(r, fcntl.F_GETFL)
        flags |= os.O_NONBLOCK
        fcntl.fcntl(r, fcntl.F_SETFL, flags)
        # Close the write end in the parent
        os.close(w)

    def terminated_fd(self):
        return self._fd


class SubprocessMgr(object):
    """A manager class for running asynchronous subprocesses."""

    class SubprocessReactor(eossdk.FdHandler):
        """An internal class for the SubprocessMgr that reacts to child processes
        exiting.
        """

        def __init__(self, parent):
            self.parent = weakref.ref(parent)
            self._fd_map = {}
            eossdk.FdHandler.__init__(self)

        def on_readable(self, fd):
            child = self._fd_map.pop(fd, None)  # type: ChildProcess|None
            if child:
                self.watch_readable(fd, False)
                parent = self.parent()
                if not parent:
                    return
                for handler in parent._handlers:  # pylint: disable=protected-access
                    handler.on_process_exit(child, child.wait())
                os.close(fd)

        def add_child(self, child):
            fd = child.terminated_fd()
            self._fd_map[fd] = child
            self.watch_readable(fd, True)

    def __init__(self):
        self._handlers = weakref.WeakSet()
        self._reactor = self.SubprocessReactor(self)

    def run(self, *popenargs, **kwargs):
        """Run command with arguments and return a ChildProcess instance.

        The returned class is a subclass of Popen, and has all of the same members
        as Popen. This method only differs from the standard subprocess.run() method
        in that it does not wait for the child process to terminate before
        returning, and instead returns the child process object for use.

        If you'd like a similar interface to the standard subprocess.run() method,
        use `child=Subprocess.run(...); child.wait()`.
        """
        inputarg = kwargs.pop("input", None)
        if inputarg is not None:
            if kwargs.get("stdin") is not None:
                raise ValueError("stdin and input arguments may not both be used")
            kwargs["stdin"] = PIPE

        child = ChildProcess(*popenargs, **kwargs)
        self._reactor.add_child(child)

        if inputarg and child.stdin:
            child.stdin.write(inputarg)

        return child
