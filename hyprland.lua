local config_dir = (os.getenv("HOME") or "") .. "/.config/hypr"
package.path = table.concat({
    config_dir .. "/?.lua",
    config_dir .. "/?/init.lua",
    package.path,
}, ";")

-- Reload configuration modules when the Lua state is reused.
for _, mod in ipairs({
    "monitors",
    "keybind",
    "windowrules",
    "animations",
    "animations.default",
    "themes.theme",
    "noctalia",
    "input-gestures",
    "one-app",
}) do
    package.loaded[mod] = nil
end

require("monitors")
require("startup")
require("keybind")
require("windowrules")
require("animations")
require("themes.theme")

hl.config({
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        anr_missed_pings = 5,
        allow_session_lock_restore = true,
    },
    xwayland = {
        force_zero_scaling = true,
    },
    general = {
        snap = {
            enabled = true,
        },
    },
})

-- For Noctalia Color templates
require("noctalia").apply_theme()




-- Clicking a notification brings its app/tab to the front
hl.config({
    misc = {
        focus_on_activate = true,
    },
})

-- Wallpaper shortcuts
hl.bind("SUPER + W", hl.dsp.exec_cmd("/home/jingpo/.local/bin/wall-picker"), { description = "Wallpaper picker" })
hl.bind("SUPER + ALT + right", hl.dsp.exec_cmd("noctalia msg wallpaper-next"), { description = "Next wallpaper" })
hl.bind("SUPER + ALT + left", hl.dsp.exec_cmd("noctalia msg wallpaper-previous"), { description = "Previous wallpaper" })
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("noctalia msg wallpaper-random"), { description = "Random wallpaper" })

-- Input + gestures (loaded safely: errors here will not break other binds)
local ok, err = pcall(require, "input-gestures")
if not ok then
    local f = io.open(os.getenv("HOME") .. "/.cache/hypr-gestures-error.txt", "w")
    if f then f:write(tostring(err)) f:close() end
end

-- One app per desktop (loaded safely)
local ok2, err2 = pcall(require, "one-app")
if not ok2 then
    local f = io.open(os.getenv("HOME") .. "/.cache/hypr-oneapp-error.txt", "w")
    if f then f:write(tostring(err2)) f:close() end
end

