# Arch desktop optimization — 2026-11-05

## Applied in this pass

- Removed 17 superseded Fish function definitions and redundant Tab bindings, retaining the effective implementations.
- Replaced the external `cat` used to read the app cache with a Fish builtin.
- Avoided touching existing saved-folder/link data files on every Fish startup.
- Removed Kitty's identical second styling block; effective appearance settings are preserved.
- Removed Noctalia startup/battery hooks referencing the nonexistent `~/.local/bin/refresh-by-power`.
- Updated `~/.local/bin/bar-resize` to parse coordinates with Bash builtins instead of spawning `cut` and `tr` on each poll. The 50 ms polling interval is unchanged. Added a lock to prevent duplicate watchers and validation for malformed coordinates. Restarted only this helper.

## Earlier changes retained

- Hyprland blur: 3 passes to 1.
- Keyboard repeat: 250 to 400 ms delay; 35 to 25 repeats per second.
- Starship initializes once, only in interactive Fish shells.
- The original monitor configuration was restored after HDMI was reported disconnected during a 74.97 Hz test. The laptop remains at 120 Hz. External refresh-rate testing remains outstanding.
- Earlier originals: `../smooth-20261105-113802/`.

## Checked; no further tuning needed from current evidence

- AMD and NVIDIA drivers are loaded; NVIDIA DRM modesetting reports Y.
- Installed AMD microcode and kernel are present. No driver/kernel packages were changed.
- TLP and tlp-pd manage power profiles; power-profiles-daemon is masked, avoiding that conflict. Automatic charger/battery profile changes are enabled. The profile was performance during initial checks and balanced during the final check; this pass did not switch it.
- SSD fstrim timer is enabled and active.
- 4 GiB zram is active and unused in the samples; approximately 8.6 GiB RAM was available at the initial check.
- Sampled CPU, memory and I/O pressure averages were zero; vmstat samples were approximately 96% CPU idle with no swap I/O.
- Hyprland debug file logging is disabled and debug.vfr is enabled.
- No failed system or user services were reported.

## Validation and measurements

- Fish, Bash, Lua, Kitty and Noctalia TOML configuration checks passed; Hyprland reports no configuration errors.
- All final top-level function bodies in the two deduplicated Fish files match the originals. Selected active app/Tab functions and the complete listed key bindings also match the baseline, ignoring source locations and listing order.
- Mocked bar-helper test: one toggle on entering, one on leaving; malformed coordinates ignored; second instance exits.
- Five-run median `fish -ic exit`: 46.5 ms before, 41.5 ms after.
- Five-run median startup plus explicit `fish_greeting`: 64.2 ms before, 59.5 ms after.
- These are small local startup measurements, not a whole-system performance benchmark. Fastfetch and the existing prompt appearance were retained.

## Activation and restore

- The updated bar helper is running now. Hyprland changes from the earlier pass are active.
- Open a new terminal for the cleaned Fish configuration. Noctalia hook edits take effect when its configuration is reloaded or at the next session; this pass did not restart the desktop shell.
- Original files are stored here under `.config/` and `.local/`, preserving their paths relative to `/home/jingpo`.
- `manifest.json` maps every changed file to its backup and records before/after SHA-256 hashes. Restore individual originals to their listed paths if needed; review any later edits first.

## References used

Fish startup profiling follows the [Fish command documentation](https://fishshell.com/docs/current/cmds/fish.html).
The existing weekly SSD maintenance matches [Arch's periodic TRIM guidance](https://wiki.archlinux.org/title/Solid_State_Drive).
The existing profile setup was checked against [TLP's operation and profiles documentation](https://linrunner.de/tlp/settings/operation.html).
