#!/usr/bin/env python3
"""Holds a logind sleep delay inhibitor for idle/Idle.qml.

Closing the lid or running systemctl suspend makes logind suspend the machine
without involving the shell. This takes a delay inhibitor and, when logind
announces PrepareForSleep, prints "sleep" so the shell can lock. The inhibitor
is released once the lock marker file given as the first argument exists, or
after LOCK_WAIT seconds, whichever comes first. It is taken again after resume.
"""

import ctypes
import os
import signal
import sys
import time

try:
    from jeepney import DBusAddress, HeaderFields, MatchRule, MessageType, message_bus, new_method_call
    from jeepney.io.blocking import open_dbus_connection
except ImportError:
    print("sleep_lock: python-jeepney is not installed", file=sys.stderr)
    sys.exit(0)

LOGIN1 = DBusAddress(
    "/org/freedesktop/login1",
    bus_name="org.freedesktop.login1",
    interface="org.freedesktop.login1.Manager",
)

# logind gives delay inhibitors 5 seconds by default (InhibitDelayMaxSec)
LOCK_WAIT = 4.0
POLL_INTERVAL = 0.05


def take_inhibitor(conn):
    msg = new_method_call(LOGIN1, "Inhibit", "ssss", ("sleep", "Serpantinum", "Lock the screen before sleep", "delay"))
    return conn.send_and_get_reply(msg).body[0]


def wait_for_lock(marker):
    deadline = time.monotonic() + LOCK_WAIT
    while not os.path.exists(marker) and time.monotonic() < deadline:
        time.sleep(POLL_INTERVAL)


def main():
    if len(sys.argv) != 2:
        print("usage: sleep_lock.py <lock-marker-file>", file=sys.stderr)
        sys.exit(2)
    marker = sys.argv[1]

    # Don't outlive quickshell if it crashes, the inhibitor would pin sleep for nothing
    try:
        ctypes.CDLL(None, use_errno=True).prctl(1, signal.SIGTERM)  # PR_SET_PDEATHSIG
    except (AttributeError, OSError):
        pass

    conn = open_dbus_connection(bus="SYSTEM", enable_fds=True)
    rule = MatchRule(
        type="signal",
        interface=LOGIN1.interface,
        member="PrepareForSleep",
        path=LOGIN1.object_path,
    )
    conn.send_and_get_reply(message_bus.AddMatch(rule))

    inhibitor = take_inhibitor(conn)
    while True:
        msg = conn.receive()
        if msg.header.message_type != MessageType.signal:
            continue
        if msg.header.fields.get(HeaderFields.member) != "PrepareForSleep":
            continue
        if msg.body[0]:
            print("sleep", flush=True)
            wait_for_lock(marker)
            if inhibitor is not None:
                inhibitor.close()
                inhibitor = None
        elif inhibitor is None:
            inhibitor = take_inhibitor(conn)


if __name__ == "__main__":
    main()
