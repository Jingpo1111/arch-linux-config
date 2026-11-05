# Hyprland desktop configuration

Personal Hyprland configuration built with Lua and Bash, with Noctalia providing desktop controls and generated colors. The configuration includes English/Khmer input, touchpad gestures, workspace navigation, screenshot annotation, and application launchers.

This guide describes the files in this repository. Files under `backups/` are historical snapshots; they are not loaded by the main configuration.

## Technologies and dependencies

| Technology or command | Use in this configuration |
| --- | --- |
| Hyprland with the Lua `hl` API | Compositor, monitors, input, rules, keybindings, animations, and window dispatchers |
| `hyprctl` | Workspace queries, Lua dispatcher calls, configuration reloads, and diagnostics |
| Lua | Modular configuration loaded through `hyprland.lua` |
| Bash | Browser, video, screenshot, and workspace scripts |
| Noctalia (`noctalia`) | Desktop shell, launcher, lock screen, settings, control center, wallpaper commands, media controls, brightness, and volume display |
| `kenn/keybind-cheatsheet` Noctalia plugin | Cheatsheet panel opened with `Super + H` |
| Kitty, VS Code (`code`), Thunar | Default terminal, editor, and file manager |
| Steam, Quod Libet (`quodlibet`) | Game and music shortcuts |
| Brave, Firefox, Zen Browser, Vivaldi, or LibreWolf | Browser launcher candidates; see the exact priority below |
| mpv, VLC, or Celluloid | Video launcher candidates |
| Flatpak | Fallback launch method for supported browsers, video players, and Satty |
| Hyprshot | Window, monitor, and region screenshots |
| Grim, Slurp, Satty | Region capture and screenshot annotation |
| `jq` | Parse Hyprland workspace JSON |
| `flock`, `pgrep` | Prevent overlapping screenshot sessions |
| `notify-send` | Report that no supported browser was found |
| `wpctl` (WirePlumber) | Change the default audio sink volume |
| EasyEffects | Background audio effects service |
| `wl-clip-persist` | Keep regular clipboard contents available |
| polkit-gnome, GNOME Keyring | Authentication agent and secrets service |
| `xdg-desktop-portal-hyprland`, `xdg-desktop-portal` | Desktop portal services started with the session |
| systemd user services and D-Bus | Start services and propagate the Wayland session environment |
| Qt / `qt6ct` | Qt platform theme and scaling environment |
| Bibata Modern Classic | Cursor theme, configured at size 24 |
| Rofi | Layer styling for the external wallpaper picker |
| nwg-displays | Generator identified in the monitor file header |

The scripts also use standard Linux tools such as `date`, `sort`, `grep`, `mkdir`, and `sleep`. Dependencies are needed for the features that invoke them; applications mentioned only in window rules do not all need to be installed.

**Compatibility:** this repository expects a Hyprland build exposing `hl.config`, `hl.bind`, `hl.gesture`, and the other Lua APIs used in the source. The workspace script also dispatches Lua expressions. A build that only accepts a traditional `hyprland.conf` cannot use these files unchanged. No exact compatible version or dependency lockfile is recorded here.

## File map

| File | Responsibility |
| --- | --- |
| [hyprland.lua](hyprland.lua) | Entry point, module loading, general behavior, wallpaper shortcuts, and guarded optional modules |
| [monitors.lua](monitors.lua) | Display output, resolution, refresh rate, scale, and brightness |
| [startup.lua](startup.lua) | Environment variables and session startup commands |
| [keybind.lua](keybind.lua) | Application, window, workspace, screenshot, media, and system shortcuts |
| [input-gestures.lua](input-gestures.lua) | Keyboard, pointer, touchpad, and three/four-finger gestures |
| [windowrules.lua](windowrules.lua) | Floating windows, fullscreen idle inhibition, picture-in-picture, and app-specific rules |
| [one-app.lua](one-app.lua) | Terminal workspace policy, btop window, and Rofi layer styling |
| [animations.lua](animations.lua) | Loads the default animation module |
| [animations/default.lua](animations/default.lua) | Animation curve, speeds, and transition styles |
| [themes/theme.lua](themes/theme.lua) | Cursor, gaps, borders, layout, opacity, shadows, and blur |
| [noctalia.lua](noctalia.lua) | Generated palette and border/group color application |
| [Scripts/browser-launcher.sh](Scripts/browser-launcher.sh) | Select and launch an available browser |
| [Scripts/video.sh](Scripts/video.sh) | Select and launch an available video player |
| [Scripts/satty.sh](Scripts/satty.sh) | Capture a region and open it in Satty |
| [Scripts/workspace.sh](Scripts/workspace.sh) | Navigate workspaces on the focused monitor |
| [backups/](backups/) | Previous configurations and optimization records |

`hyprland.lua` adds `~/.config/hypr` to Lua's module search path. It loads monitors, startup, keybindings, window rules, animations, and the base theme, then applies general settings and Noctalia colors. Input/gestures and the terminal workspace policy are loaded with `pcall` so an error in either can be recorded without stopping the rest of the entry point.

Most configuration modules are removed from `package.loaded` before being required again. `startup` is intentionally absent from that reset list, so its event handler is not re-registered when the Lua state is reused.

## Setup and customization

1. Use a Hyprland build compatible with this repository's Lua configuration API and configure the session to load `hyprland.lua`.
2. Place the configuration at `~/.config/hypr`, backing up any existing configuration before copying files.
3. Install the dependencies for the features you use, including Noctalia and the selected applications.
4. Adapt `monitors.lua` to the output names and modes reported by `hyprctl monitors`. Its header identifies it as generated by nwg-displays; coordinate manual changes with that generator.
5. Review application commands in `keybind.lua` and the launcher priority lists in `Scripts/`.
6. Supply or replace the external helper commands listed below. Update the absolute `/home/jingpo` paths when using another account.
7. Ensure the scripts are executable, then reload and check the configuration from a running Hyprland session.

```bash
chmod +x ~/.config/hypr/Scripts/*.sh
hyprctl reload
hyprctl configerrors
```

Startup commands are attached to the `hyprland.start` event. A configuration reload does not substitute for starting a new session when testing those commands.

The following helpers are referenced but are **not provided as active scripts in this repository**:

| Absolute path | Binding / intended action |
| --- | --- |
| `/home/jingpo/.local/bin/wall-picker` | `Super + W`: wallpaper picker |
| `/home/jingpo/.local/bin/btop-toggle` | `Ctrl + Shift + Escape`: btop task manager |
| `/home/jingpo/.local/bin/close-all` | `Super + Shift + M`: close all windows |

Their implementations determine their behavior. The Rofi and btop rules here only style matching windows/layers. Noctalia's full configuration, wallpapers, the cheatsheet plugin, and active Kitty/Fish configurations are also outside this repository's loaded configuration.

## Desktop settings

| Area | Configured value |
| --- | --- |
| Display | `eDP-1`, `1920x1080@120.0`, position `0x0`, scale `1.0` |
| Display brightness / VRR | `sdrbrightness = 1.2`, `vrr = 0` |
| Layout | `dwindle`, preserving splits; master layout's `new_status` is `master` if that layout is used |
| Gaps / borders | Inner gap `2`, outer gap `6`, border `2`; resize on border enabled |
| Corners / shadows | Rounding `12`; shadows enabled |
| Opacity | Active, inactive, and fullscreen opacity all `1.0` |
| Blur | Enabled; size `1`, one pass, optimizations enabled, ignores opacity, no X-ray, special-workspace blur enabled |
| Tearing / snapping | Tearing disabled; snapping enabled |
| Cursor | `Bibata-Modern-Classic`, size `24`, for Hyprcursor, Xcursor, and Qt |
| XWayland | `force_zero_scaling = true` |
| Activation | `focus_on_activate = true` |
| Session lock | `allow_session_lock_restore = true` |
| Other behavior | Logo and splash disabled; `force_default_wallpaper = 0`; `anr_missed_pings = 5` |

Noctalia's generated palette is applied after the base theme:

| Palette key | Color |
| --- | --- |
| Primary | `#fff59b` |
| Surface | `#070722` |
| On surface | `#f3edf7` |
| Secondary | `#a9aefe` |
| On secondary | `#0e0e43` |
| Error | `#fd4663` |
| On error | `#0e0e43` |

Primary/surface color active/inactive window borders. Secondary colors active groups and group bars, while error colors locked active groups. The generated `noctalia.lua` file may be replaced by Noctalia's color template workflow.

Animations use the `smooth` Bézier curve with control points `(0.25, 0.1)` and `(0.25, 1.0)`:

| Animation | Speed value | Style |
| --- | --- | --- |
| Windows / windows in | `3` | `slide` |
| Windows out | `2` | `slide` |
| Window movement | `2.5` | `slide` |
| Border / fade | `2` | No explicit style |
| Workspaces | `3` | `slidefade 20%` |
| Border angle | Disabled | — |

## Session startup

`startup.lua` sets these environment variables:

```text
XDG_CURRENT_DESKTOP=Hyprland
XDG_SESSION_TYPE=wayland
QT_QPA_PLATFORMTHEME=qt6ct
QT_AUTO_SCREEN_SCALE_FACTOR=1
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
ELECTRON_OZONE_PLATFORM_HINT=wayland
```

At `hyprland.start`, it launches the polkit GNOME agent (with `/usr/lib` then `/usr/libexec` path fallback), GNOME Keyring's secrets component, the Hyprland/general portal services, Noctalia, and regular clipboard persistence. EasyEffects starts after a three-second delay. It also imports `WAYLAND_DISPLAY` and `XDG_CURRENT_DESKTOP` into D-Bus/systemd activation environments and schedules `hyprctl reload` after two seconds.

## Keyboard and pointer input

| Setting | Value |
| --- | --- |
| Keyboard layouts | `us,kh` (English US and Khmer) |
| Layout toggle | `Alt + Shift` (`grp:alt_shift_toggle`) |
| Num Lock | Enabled by default |
| Key repeat | Delay `400`, rate `25` |
| Mouse acceleration | Flat profile, sensitivity `1.0` |
| Mouse / touchpad scroll factor | `1.2` / `1.2` |
| Touchpad | Natural scrolling, disable while typing, clickfinger behavior |
| Focus / special workspaces | `follow_mouse = 1`, `special_fallthrough = true` |

## Keyboard shortcuts

`Super` is the main modifier, usually the Windows key.

| Shortcut | Action |
| --- | --- |
| `Super + Space` | Kitty terminal |
| `Super + E` | Thunar file manager |
| `Super + C` | VS Code |
| `Super + B` | Browser launcher |
| `Super + V` | Video player launcher |
| `Super + S` | Steam |
| `Super + M` | Quod Libet |
| `Super + R` | Noctalia launcher |
| `Super + L` | Lock screen |
| `Super + T` | Noctalia settings |
| `Super + H` | Noctalia keybinding cheatsheet plugin |
| `Super + Shift + N` | Noctalia control center |
| `Ctrl + Shift + Escape` | External btop toggle helper |
| `Super + Shift + M` | External close-all helper |
| Power button (`XF86PowerOff`) | Noctalia lock and suspend |

| Window shortcut | Action |
| --- | --- |
| `Super + Q` | Close focused window |
| `Super + Shift + F` | Toggle floating |
| `Super + F` | Toggle fullscreen |
| `Super + Arrow` | Focus in that direction |
| `Alt + Tab` | Cycle windows |
| `Super + Shift + Arrow` | Resize by 30 units: left/up shrink, right/down grow |
| `Super + Ctrl + Shift + Arrow` | Move or swap in that direction |
| `Super + Left mouse drag` | Drag window |
| `Super + Right mouse drag` | Resize window |

| Workspace shortcut | Action |
| --- | --- |
| `Super + 1…9`, `Super + 0` | Focus workspace 1–9 or 10 |
| `Super + Shift + 1…9`, `Super + Shift + 0` | Move window to workspace 1–9 or 10 |
| `Super + Tab` | Run the monitor-aware workspace script |
| `Super + Shift + Tab` | Previous workspace on monitor (`m-1`) |
| `Super + Ctrl + Right / Left` | Next / previous workspace (`r+1` / `r-1`) |
| `Super + Ctrl + Down` | Focus an empty workspace |
| `Super + Ctrl + Alt + Right / Left` | Move window to next / previous workspace |
| `Super + Mouse wheel down / up` | Next / previous existing workspace (`e+1` / `e-1`) |

| Capture / wallpaper shortcut | Action |
| --- | --- |
| `Super + Print` | Hyprshot window screenshot |
| `Alt + Print` | Hyprshot monitor screenshot |
| `Shift + Print` | Hyprshot region screenshot |
| `Super + A` | Capture a region and annotate with Satty |
| `Super + W` | External wallpaper picker |
| `Super + Alt + Right / Left` | Next / previous Noctalia wallpaper |
| `Super + Shift + W` | Random Noctalia wallpaper |

Screenshots target `~/Pictures/Screenshots`. The Satty helper creates that directory and names output files `Screenshot-YYYYMMDD-HHMMSS.png`.

| Hardware media key | Action |
| --- | --- |
| Brightness up / down | Noctalia brightness ±5% |
| Play / next / previous | Noctalia playback toggle / next track / previous track |
| Volume up | `wpctl` +5%, capped at 120%, then Noctalia volume display |
| Volume down | `wpctl` −5%, then Noctalia volume display |

Brightness, playback, and volume bindings have `locked = true`; volume bindings also repeat while held. The audio mute binding is commented out.

## Touchpad gestures

| Gesture | Action |
| --- | --- |
| Three-finger horizontal swipe | Workspace gesture |
| Three-finger pinch out or swipe up | Step window up |
| Three-finger pinch in or swipe down | Step window down |
| Four-finger swipe right / left | Cycle next / previous window |
| Four-finger swipe up / down | Step window up / down |

Stepping up changes **floating → tiled → fullscreen**, one step per gesture. Stepping down changes **fullscreen → tiled → centered floating**. When changing a tiled window to floating, the helper requests 75% of the monitor's logical width and height. Stepping down on an already floating window centers it; stepping up on a fullscreen window does nothing.

## Window and workspace rules

Workspace 1 is reserved primarily for Kitty terminals. Kitty windows are assigned there, and matching non-terminal windows on workspace 1 are sent to `emptyn`. Exceptions include btop, Noctalia, authentication agents, portals, and pinentry windows. This module does not enforce one window per workspace across the entire desktop.

Kitty suppresses application fullscreen/maximize events. The btop class floats, centers, and requests `1100 × 700`. Rofi layers receive blur, `popin 80%`, and `ignore_alpha = 0.3`.

Additional rules in `windowrules.lua`:

- Float Shortwave, Signal, Clapper, Warp, ProtonUp-Qt (`net.davidotek.pupgui2`), Yad, Eye of GNOME, Planify, Upscaler, Video Downloader, and Impression.
- Float Mission Center at `1290 × 950`, pavucontrol at `1221 × 619`, file operation progress and xfce-polkit at `600 × 50`, and Blueman at `600 × 300`.
- Float and center the “Choose files to upload” dialog at `800 × 500`, with animation, shadow, border, and blur disabled. Float “All Files” at `800 × 600`.
- Apply reduced decoration/effects and immediate/opaque flags to the “Affinity Photo 2” title. The source uses the bare Lua value `off` for `tonemap`; its effective meaning depends on the host Lua environment.
- Float Steam Settings and Friends List windows.
- Request fullscreen idle inhibition for matching Celluloid/mpv/VLC, Spotify, and LibreWolf/Floorp/Brave/Firefox/Chromium/Zen/Vivaldi classes.
- Tag picture-in-picture titles, then float and pin them, preserve aspect ratio, and request position `73% 72%` and size `25% 25%`.
- Prevent initial focus for JetBrains windows with titles matching `win[0-9]+`.

## Script behavior

**Browser launcher:** tries native commands in this order: `brave-browser`, `brave-origin`, `brave`, `firefox`, `zen-browser`, `vivaldi`, `librewolf`. If none is found, it tries Flatpak `com.brave.Browser`, then `com.vivaldi.Vivaldi`. It forwards all arguments to the chosen browser and uses `notify-send` when no candidate is found.

**Video launcher:** tries native mpv, VLC, then Celluloid, followed by Flatpak `io.mpv.Mpv`, `org.videolan.VLC`, and `io.github.celluloid_player.Celluloid`. Native mpv uses `--player-operation-mode=pseudo-gui`. The script accepts one optional file or URL argument and exits with an error if no player is found.

**Satty helper:** exits if Slurp or Satty is already running and acquires `/tmp/satty.lock` with `flock`. Slurp selects a region, Grim captures it, and the result is piped to native Satty or Flatpak `org.satty.Satty`.

**Workspace helper:** waits 50 ms, reads the active workspace/monitor, and uses a per-monitor timestamp file under `/tmp` to debounce calls within 250 ms. It combines occupied workspaces and numeric workspace rules for that monitor, preferring a higher occupied workspace, then rule-based navigation or wraparound. Its fallback branch searches for an unused workspace ID. This behavior depends on the queried workspace/rule data; it is not a fixed 1–10 loop.

## Historical configurations

| Backup | Contents |
| --- | --- |
| `backups/smooth-20261105-082329/` | Earlier entry point, keybindings, and animations |
| `backups/smooth-20261105-113802/` | Earlier Hyprland input/monitor/theme files and Fish startup/prompt configuration |
| `backups/arch-opt-20261105-114657/` | Original Fish helpers, Kitty settings, Noctalia hooks, and a bar-resize helper, plus an optimization report and hash manifest |

The archived Fish configuration includes Starship, Fastfetch, `eza`, `bat`, and `fzf`; saved-folder/link helpers; GUI launching on empty desktops; and application-specific helpers. Archived Kitty settings use Fish, a Noctalia theme include, JetBrainsMono Nerd Font at `11.5`, opacity `0.85`, padding `16`, an animated beam cursor, and a top powerline tab bar. These files describe historical settings, not verified active settings outside this repository.

The archived Noctalia hooks reference `ws-compact-daemon`, `refresh-by-power`, and `bar-resize` under `~/.local/bin`. The [optimization report](backups/arch-opt-20261105-114657/README.md) records removal of obsolete `refresh-by-power` hooks and other changes. Its performance measurements and hardware/service observations are historical, not current system checks.

For restoration, consult [manifest.json](backups/arch-opt-20261105-114657/manifest.json), which maps original paths to backup files and before/after hashes. Review individual files against later edits before restoring; copying the entire backup can reintroduce superseded settings.

## Diagnostics

Run compositor queries inside the active Hyprland session:

```bash
hyprctl version
hyprctl configerrors
hyprctl monitors
hyprctl activeworkspace -j
hyprctl workspaces -j
hyprctl workspacerules -j
```

For failed guarded module loads, inspect `~/.cache/hypr-gestures-error.txt` and `~/.cache/hypr-oneapp-error.txt`. These logs are written only when an error occurs and the file can be opened; successful loads do not clear old logs.

If a shortcut does nothing, check its command in `keybind.lua`, any required external helper, and whether Noctalia or the relevant application is available. A compositor socket error from `hyprctl` means that query did not reach the running session; it does not establish a configuration syntax error.

The Bash helpers can be syntax-checked without launching applications:

```bash
for script in ~/.config/hypr/Scripts/*.sh; do
    bash -n "$script" || break
done
```

Plain Lua execution is not a compositor validation method: these modules depend on the `hl` API supplied by Hyprland.
