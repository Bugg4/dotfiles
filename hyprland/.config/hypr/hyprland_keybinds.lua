-- Keybindings configuration

local mainMod = "SUPER"

-- Submap for reloading various programs
hl.bind(mainMod .. " + R", hl.dsp.submap("reload"))

hl.define_submap("reload", function()
    hl.bind("w", hl.dsp.exec_cmd("killall qs && hyprctl dispatch exec " .. status_bar))
    hl.bind("w", hl.dsp.submap("reset"))
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Standard binds
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + ALT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd(terminal .. " --class alacritty-emoji-picker -e " .. emoji_picker))

hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(launcher), { release = true })
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(grimshot))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [1-4]
for i = 1, 4 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
end

-- Move active window to next/prev workspace
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ workspace = "prev" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ workspace = "next" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize active window with mainMod + ALT + arrow keys (repeating)
hl.bind(mainMod .. " + ALT + left",  hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }),  { repeating = true })
hl.bind(mainMod .. " + ALT + up",    hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + down",  hl.dsp.window.resize({ x = 0, y = 20, relative = true }),  { repeating = true })

-- Dwindle layout messages
hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + W", hl.dsp.layout("swapsplit"))
hl.bind(mainMod .. " + L", hl.dsp.window.float({ action = "toggle" }))

-- Scrolling layout: resize columns with SUPER + ALT + SHIFT + left/right
hl.bind(mainMod .. " + ALT + SHIFT + left",  hl.dsp.layout("colresize -0.2"))
hl.bind(mainMod .. " + ALT + SHIFT + right", hl.dsp.layout("colresize +0.2"))

-- Laptop multimedia keys for volume and LCD brightness (locked and repeating)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Playerctl media controls (locked)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
