-- Input settings (merged with Khmer keyboard)
hl.config({
    input = {
        kb_layout = "us,kh",
        kb_options = "grp:alt_shift_toggle",
        numlock_by_default = true,
        repeat_delay = 400,
        repeat_rate = 25,

        -- Mouse
        accel_profile = "flat",
        sensitivity = 1.0,
        scroll_factor = 1.2,

        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            scroll_factor = 1.2,
        },
        special_fallthrough = true,
        follow_mouse = 1,
    },
})


-- Floating -> Tiled -> Fullscreen
local function window_step_up()
    local win = hl.get_active_window()
    if not win then return end
    if win.fullscreen and win.fullscreen > 0 then return end
    if win.floating then
        hl.dispatch(hl.dsp.window.float({ action = "unset" }))
    else
        hl.dispatch(hl.dsp.window.fullscreen({ action = "set" }))
    end
end

-- Fullscreen -> Tiled -> Centered floating window
local function window_step_down()
    local win = hl.get_active_window()
    if not win then return end
    if win.fullscreen and win.fullscreen > 0 then
        hl.dispatch(hl.dsp.window.fullscreen({ action = "unset" }))
        return
    end
    if not win.floating then
        hl.dispatch(hl.dsp.window.float({ action = "set" }))
        local mon = win.monitor or hl.get_active_monitor()
        if mon and mon.width and mon.height then
            local scale = (mon.scale and mon.scale > 0) and mon.scale or 1
            local target_w = math.floor((mon.width / scale) * 0.75)
            local target_h = math.floor((mon.height / scale) * 0.75)
            hl.dispatch(hl.dsp.window.resize({ x = target_w, y = target_h, relative = false }))
        end
        hl.dispatch(hl.dsp.window.center())
    else
        hl.dispatch(hl.dsp.window.center())
    end
end

-- 3 fingers
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "pinchout", action = window_step_up })
hl.gesture({ fingers = 3, direction = "pinchin", action = window_step_down })
hl.gesture({ fingers = 3, direction = "up", action = window_step_up })
hl.gesture({ fingers = 3, direction = "down", action = window_step_down })

-- 4 fingers: switch windows
hl.gesture({ fingers = 4, direction = "right", action = function()
    hl.dispatch(hl.dsp.window.cycle_next({ next = true }))
end })
hl.gesture({ fingers = 4, direction = "left", action = function()
    hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
end })

-- 4 fingers: expand / restore
hl.gesture({ fingers = 4, direction = "up", action = window_step_up })
hl.gesture({ fingers = 4, direction = "down", action = window_step_down })
