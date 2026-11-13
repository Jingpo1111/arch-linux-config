# Control Center / bar modes

Run these commands in any terminal:

- `n-center`: new mode. The bar stays visible with a fixed reserved space. On each monitor, it is solid when the visible workspace contains an app and transparent on an empty desktop. The Control Center popup uses a solid background. Hovering does not resize app windows.
- `o-center`: original mode. Restores the previous smart auto-hide, translucent groups and hover-resize helper.

The most recently selected mode resumes at login. New mode is active after installation.

## Implementation

- `~/.local/bin/o-center` and `~/.local/bin/n-center` call `../Scripts/center-mode.py`.
- `~/.local/bin/center-mode-resume` is started by Noctalia's existing startup hook, alongside the unchanged workspace-compaction helper.
- `selected` stores `new` or `old`.
- `original.json` records the original bar appearance and backup path.
- `~/.config/noctalia/zzzz-center-mode.toml` is generated automatically; edit the source profiles/implementation instead.
- `helper.log` records watcher failures.
- New mode listens to Hyprland workspace/window events. It writes/reloads opacity overrides only when their contents change; it does not poll the mouse. Pinned apps and open special workspaces count as occupied.
- Existing Noctalia GUI overrides are preserved. Per-monitor overrides implement the new mode and are removed by old mode.
- The invalid `shell.panel.attach_control_center` setting was replaced with the supported `transparency_mode = "solid"`; the old effective popup was already solid.

## Validation

Noctalia validation passes without warnings. Populated/empty desktop, other-workspace, pinned-window, hidden-window and special-workspace logic passed checks. Live workspace switching confirmed opacity changes between 1.0 and 0.0 while the bar remains visible and the top reservation stays at 52 pixels. Old/new switching was tested and new mode restored. Only one new-mode watcher runs, and the hover-resize helper is stopped in new mode.

## Backup

Original files and the effective configuration are saved at:

/home/jingpo/.config/hypr/backups/center-modes-20261105-154115

Use `o-center` for ordinary switching. To fully uninstall later, restore the backed-up Noctalia hook/panel files, stop the mode watcher, and remove the generated override and command wrappers. Preserve any edits made since installation.
