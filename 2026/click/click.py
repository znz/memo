#!/usr/bin/env python3
"""xdotool-like mouse control using python-wayland + zwlr_virtual_pointer_v1."""

import sys
import time

import wayland
from wayland.client import wayland_class


@wayland_class("wl_output")
class Output(wayland.wl_output):
    def __init__(self, app=None):
        super().__init__(app=app)
        self.width = 0
        self.height = 0

    def on_mode(self, flags, width, height, refresh):
        if flags & wayland.wl_output.mode.current:
            self.width = width
            self.height = height


@wayland_class("wl_registry")
class Registry(wayland.wl_registry):
    def __init__(self, app=None):
        super().__init__(app=app)
        self.vptr_mgr = None
        self.seat = None
        self.output = None

    def on_global(self, name, interface, version):
        if interface == "zwlr_virtual_pointer_manager_v1":
            self.vptr_mgr = self.bind(name, interface, version)
        elif interface == "wl_seat":
            self.seat = self.bind(name, interface, version)
        elif interface == "wl_output":
            self.output = self.bind(name, interface, version)


def to_wl_fixed(val):
    """Convert a value to wl_fixed_t (signed 24.8) as uint32.

    The library internally multiplies by 256 and packs as unsigned.
    We pre-compute the two's complement and divide back by 256
    so that the library's conversion produces the correct wire value.
    """
    return (int(val * 256) & 0xFFFFFFFF) / 256


BUTTONS = {
    "1": 0x110, "left": 0x110,
    "2": 0x112, "middle": 0x112,
    "3": 0x111, "right": 0x111,
    "4": 0x113, "side": 0x113,
    "5": 0x114, "extra": 0x114,
    "6": 0x115, "forward": 0x115,
    "7": 0x116, "back": 0x116,
    "8": 0x117, "task": 0x117,
}


def usage():
    print("Usage:")
    print("  click.py mousemove x y")
    print("  click.py mousemove_relative x y")
    print("  click.py click [button] [--repeat N] [--delay MS]")
    print()
    print("Commands can be chained:")
    print("  click.py mousemove 500 300 click 1")
    print("  click.py mousemove 500 300 click 1 --repeat 2")
    print()
    print("Buttons: 1=left (default), 2=middle, 3=right,")
    print("         4=side, 5=extra, 6=forward, 7=back, 8=task")
    sys.exit(1)


def setup():
    display = wayland.wl_display()
    registry = display.get_registry()

    display.dispatch_timeout(0.2)
    display.dispatch_timeout(0.2)

    if registry.vptr_mgr is None:
        print("ERROR: zwlr_virtual_pointer_manager_v1 is not available.")
        print("A wlroots-based compositor (Sway, Hyprland, etc.) is required.")
        sys.exit(1)

    if registry.output is None or registry.output.width == 0:
        print("ERROR: Could not detect screen resolution.")
        sys.exit(1)

    vptr = registry.vptr_mgr.create_virtual_pointer(registry.seat)
    display.dispatch_timeout(0.1)

    return display, registry, vptr


def main():
    args = sys.argv[1:]
    if not args:
        usage()

    display, registry, vptr = setup()
    x_extent = registry.output.width
    y_extent = registry.output.height

    i = 0
    while i < len(args):
        cmd = args[i]

        if cmd == "mousemove":
            if i + 2 >= len(args):
                print("ERROR: mousemove requires x y arguments.")
                sys.exit(1)
            x, y = int(args[i + 1]), int(args[i + 2])
            ts = int(time.monotonic() * 1000) & 0xFFFFFFFF
            vptr.motion_absolute(ts, x, y, x_extent, y_extent)
            vptr.frame()
            display.dispatch_timeout(0.05)
            i += 3

        elif cmd == "mousemove_relative":
            if i + 2 >= len(args):
                print("ERROR: mousemove_relative requires x y arguments.")
                sys.exit(1)
            dx, dy = int(args[i + 1]), int(args[i + 2])
            ts = int(time.monotonic() * 1000) & 0xFFFFFFFF
            vptr.motion(ts, to_wl_fixed(dx), to_wl_fixed(dy))
            vptr.frame()
            display.dispatch_timeout(0.05)
            i += 3

        elif cmd == "click":
            button = "1"
            repeat = 1
            delay = 12
            j = i + 1
            while j < len(args):
                if args[j] in BUTTONS:
                    button = args[j]
                    j += 1
                elif args[j] == "--repeat" and j + 1 < len(args):
                    repeat = int(args[j + 1])
                    j += 2
                elif args[j] == "--delay" and j + 1 < len(args):
                    delay = int(args[j + 1])
                    j += 2
                else:
                    break
            i = j
            btn = BUTTONS[button]
            for n in range(repeat):
                if n > 0 and delay > 0:
                    time.sleep(delay / 1000)
                ts = int(time.monotonic() * 1000) & 0xFFFFFFFF
                vptr.button(ts, btn, wayland.wl_pointer.button_state.pressed)
                vptr.frame()
                display.dispatch_timeout(0.05)
                ts = int(time.monotonic() * 1000) & 0xFFFFFFFF
                vptr.button(ts, btn, wayland.wl_pointer.button_state.released)
                vptr.frame()
                display.dispatch_timeout(0.05)

        else:
            print(f"ERROR: Unknown command: {cmd}")
            usage()

    vptr.destroy()
    display.dispatch_timeout(0.1)


if __name__ == "__main__":
    main()
