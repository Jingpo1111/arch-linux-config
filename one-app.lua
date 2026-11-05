-- Desktop 1 = terminals only
hl.window_rule({
    name = "terminal-on-1",
    match = { class = "^(kitty)$" },
    workspace = "1",
})

-- btop task manager: floating, centered, on the current desktop
hl.window_rule({
    name = "btop-float",
    match = { class = "^(btop)$" },
    float = true,
    size = "1100 700",
    center = true,
})

-- Blur + pop-in behind the rofi wallpaper carousel
hl.layer_rule({
    name = "rofi-blur",
    match = { namespace = "^rofi$" },
    blur = true,
    animation = "popin 80%",
    ignore_alpha = 0.3,
})

-- Guard: non-terminal windows on desktop 1 move to the next empty desktop
hl.window_rule({
    name = "desktop1-terminals-only",
    match = {
        workspace = "1",
        class = "negative:^(kitty|btop|noctalia.*|polkit-gnome-authentication-agent-1|xdg-desktop-portal-gtk|org.freedesktop.impl.portal.desktop.*|pinentry.*)$",
    },
    workspace = "emptyn",
})

-- Terminals always tile
hl.window_rule({
    name = "kitty-always-tile",
    match = { class = "^(kitty)$" },
    suppress_event = "fullscreen maximize",
})
