-- Global window rules
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- qBittorrent window rules
hl.window_rule({
    name = "qbittorrent-workspace",
    match = { class = "org.qbittorrent.qBittorrent" },
    workspace = "3",
})

-- Steam window rules
hl.window_rule({
    name = "steam-workspace",
    match = { class = "steam" },
    workspace = "2",
    no_initial_focus = true,
})

-- Emoji Picker window rules (Alacritty)
hl.window_rule({
    name = "alacritty-emoji-picker",
    match = { class = "alacritty-emoji-picker" },
    float = true,
    fullscreen = false,
    center = true,
    size = { "monitor_w*0.3", "monitor_h*0.3" },
})

-- Emoji Picker window rules (Ghostty)
hl.window_rule({
    name = "ghostty-emoji-picker",
    match = { title = "ghostty-emoji-picker" },
    float = true,
    fullscreen = false,
    center = true,
    size = { "monitor_w*0.3", "monitor_h*0.3" },
})

hl.window_rule({
    name = "xwayland-video-bridge-fixes",
    match = { class = "xwaylandvideobridge" },
    no_initial_focus = true,
    no_focus = true,
    no_anim = true,
    no_blur = true,
    max_size = { 1, 1 },
    opacity = 0.0,
})
