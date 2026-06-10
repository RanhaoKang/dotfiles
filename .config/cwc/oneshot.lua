-- script which better run once on startup

local cwc = cwc

-- autostart app
cwc.spawn_with_shell("swaybg --output '*' --color '#222222'")
cwc.spawn_with_shell("waybar")
cwc.spawn_with_shell("playerctld daemon")

-- for app that use tray better to wait for the bar to load
cwc.timer.new(3, function()
    cwc.spawn { "fcitx5" }
    cwc.spawn { "clash-verge" }
    cwc.spawn { "aria2tray", "--hide-window" }
end, { one_shot = true })

-- env var
cwc.setenv("HYPRCURSOR_THEME", "Bibata-Modern-ice")

-- xdg-desktop-portal-wlr
cwc.spawn_with_shell(
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

-- load builtin cwc C plugin
local plugins_folder = cwc.is_nested() and "./build/plugins" or cwc.get_datadir() .. "/plugins"
cwc.plugin.load(plugins_folder .. "/cwcle.so")
cwc.plugin.load(plugins_folder .. "/flayout.so")
cwc.plugin.load(plugins_folder .. "/dwl-ipc.so")
