#!/usr/bin/env python3
"""Switch Noctalia's old hover bar and a fixed, workspace-aware bar."""
import argparse
import copy
import fcntl
import json
import os
from pathlib import Path
import signal
import socket
import subprocess
import sys
import time

SCRIPT = Path(__file__).resolve()
DATA = SCRIPT.parent.parent / "center-modes"
CONFIG_ROOT = Path(os.environ.get("NOCTALIA_CONFIG_HOME", os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))))
OVERRIDE = CONFIG_ROOT / "noctalia/zzzz-center-mode.toml"
RUNTIME = Path(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}"))
HOVER = Path.home() / ".local/bin/bar-resize"
EVENTS = {"workspace", "workspacev2", "focusedmon", "focusedmonv2", "openwindow", "closewindow", "movewindow", "movewindowv2", "activespecial", "activespecialv2", "monitoradded", "monitoraddedv2", "monitorremoved", "moveworkspace", "moveworkspacev2", "pin", "configreloaded"}


def run(args):
    return subprocess.check_output(args, text=True, stderr=subprocess.PIPE, timeout=8)


def hypr(name):
    return json.loads(run(["hyprctl", "-j", name]))


def msg(*args):
    return run(["noctalia", "msg", *args])


def atomic_write(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name + f".{os.getpid()}.tmp")
    tmp.write_text(content)
    os.replace(tmp, path)


def toml(value):
    if isinstance(value, bool):
        return str(value).lower()
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, (float, int)):
        return repr(value)
    if isinstance(value, list):
        return "[" + ", ".join(toml(v) for v in value) + "]"
    if isinstance(value, dict):
        return "{ " + ", ".join(f"{toml(k)} = {toml(v)}" for k, v in value.items()) + " }"
    raise TypeError(value)


def render(monitors, clients, groups):
    lines = ["# Managed by n-center / o-center. Do not edit this generated file.",
             '[shell.panel]', 'transparency_mode = "solid"', '']
    for mon in monitors:
        workspace_ids = {mon['activeWorkspace']['id']}
        special = mon.get('specialWorkspace', {}).get('id')
        if special:
            workspace_ids.add(special)
        occupied = any(
            c.get('mapped', True) and not c.get('hidden', False)
            and (c.get('workspace', {}).get('id') in workspace_ids
                 or (c.get('pinned', False) and c.get('monitor') == mon['id']))
            for c in clients
        )
        capsules = copy.deepcopy(groups)
        if occupied:
            for group in capsules:
                group['opacity'] = 1.0
        values = dict(match=mon['name'], enabled=True, auto_hide=False,
                      smart_auto_hide=False, reserve_space=True, layer="overlay",
                      show_on_workspace_switch=False,
                      background_opacity=1.0 if occupied else 0.0,
                      capsule_group=capsules)
        lines.append(f'[bar.default.monitor.{toml(mon["name"])}]')
        lines.extend(f'{key} = {toml(value)}' for key, value in values.items())
        lines.append('')
    return '\n'.join(lines)


def refresh():
    original = json.loads((DATA / 'original.json').read_text())
    content = render(hypr('monitors'), hypr('clients'), original['bar'].get('capsule_group', []))
    if not OVERRIDE.exists() or OVERRIDE.read_text() != content:
        atomic_write(OVERRIDE, content)
        msg('config-reload')


def process_ids(kind):
    found = []
    for path in Path('/proc').iterdir():
        if not path.name.isdigit():
            continue
        try:
            args = (path / 'cmdline').read_bytes().split(b'\0')
            if kind == 'watch':
                match = len(args) > 2 and args[1] == os.fsencode(SCRIPT) and args[2] == b'watch'
            else:
                match = len(args) > 1 and args[1] == os.fsencode(HOVER) and Path(os.fsdecode(args[0])).name == 'bash'
            if match:
                found.append(int(path.name))
        except (FileNotFoundError, PermissionError, ProcessLookupError):
            pass
    return found


def stop(kind):
    pids = process_ids(kind)
    for pid in pids:
        try:
            os.kill(pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
    deadline = time.monotonic() + 3
    while set(pids) & set(process_ids(kind)):
        if time.monotonic() > deadline:
            raise RuntimeError(f'Could not stop {kind} helper')
        time.sleep(.05)


def spawn(args):
    with (DATA / 'helper.log').open('a') as log:
        subprocess.Popen(args, stdin=subprocess.DEVNULL, stdout=log, stderr=log,
                         start_new_session=True, close_fds=True)


def selected():
    path = DATA / 'selected'
    return path.read_text().strip() if path.exists() else 'new'


def switch(mode, resume=False):
    with (RUNTIME / 'center-mode-switch.lock').open('w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if resume and process_ids('watch' if mode == 'new' else 'hover'):
            return
        stop('watch')
        stop('hover')
        if mode == 'new':
            refresh()
            msg('bar-show', 'default')
            # A hover helper may have left a transient reservation override.
            time.sleep(.25)
            for monitor in hypr('monitors'):
                if monitor.get('reserved', [0, 0])[1] == 0:
                    msg('bar-reserve-toggle', 'default', monitor['name'])
            atomic_write(DATA / 'selected', 'new\n')
            spawn([sys.executable, str(SCRIPT), 'watch'])
        else:
            atomic_write(OVERRIDE, '# Old mode: use the original Noctalia configuration.\n')
            msg('config-reload')
            # Reset any temporary reserve flag left by the new mode.
            time.sleep(.25)
            original = json.loads((DATA / 'original.json').read_text())['bar']
            if not original.get('reserve_space', True):
                for monitor in hypr('monitors'):
                    if monitor.get('reserved', [0, 0])[1] > 0:
                        msg('bar-reserve-toggle', 'default', monitor['name'])
            atomic_write(DATA / 'selected', 'old\n')
            spawn([str(HOVER)])
        if not resume:
            print('New center: always visible, fixed window space, solid over apps, transparent on empty desktops.'
                  if mode == 'new' else 'Old center: original smart-hide, transparency and hover resizing restored.')


def watch():
    with (RUNTIME / 'center-mode-watch.lock').open('w') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        sockpath = RUNTIME / 'hypr' / os.environ['HYPRLAND_INSTANCE_SIGNATURE'] / '.socket2.sock'
        while selected() == 'new':
            try:
                with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
                    sock.connect(str(sockpath))
                    refresh()
                    buf = b''
                    while selected() == 'new':
                        data = sock.recv(65536)
                        if not data:
                            break
                        buf += data
                        lines = buf.split(b'\n')
                        buf = lines.pop()
                        if any(line.split(b'>>', 1)[0].decode(errors='replace') in EVENTS for line in lines):
                            time.sleep(.08)
                            refresh()
            except (OSError, subprocess.SubprocessError, ValueError) as error:
                if not sockpath.exists():
                    return  # The compositor session ended; its next login hook resumes the mode.
                print(f'center-mode watcher: {error}', file=sys.stderr, flush=True)
            time.sleep(1)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=('new', 'old', 'resume', 'watch', 'status'))
    mode = parser.parse_args().mode
    DATA.mkdir(parents=True, exist_ok=True)
    if mode == 'watch':
        watch()
    elif mode == 'status':
        print(selected())
    else:
        switch(selected() if mode == 'resume' else mode, resume=mode == 'resume')


if __name__ == '__main__':
    try:
        main()
    except (OSError, subprocess.SubprocessError, ValueError, RuntimeError) as error:
        print(f'center-mode: {error}', file=sys.stderr)
        sys.exit(1)
