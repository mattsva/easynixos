# home/hyprland.nix
# ------------------------------------------------------------------------------------------------------------------------
# Hyprland with HyprLua config — uses the hl.* Lua API (Hyprland 0.55+).
# Pattern: hl.bind("MOD + KEY", hl.dsp.X(arg), {opts}) — dispatcher
# objects passed directly to hl.bind, no function wrapper needed.
# ------------------------------------------------------------------------------------------------------------------------

{ config, pkgs, vars, ... }:

let
  isNoct      = vars.desktopShell == "noctalia";
  isCaelestia = vars.desktopShell == "caelestia";
  isEnd4      = vars.desktopShell == "end4-dots";
  dmsCmd      = "dms";
  terminalCmd = if vars.terminal == "foot" then "footclient" else vars.terminal;
  fileManager = vars.fileManager;  # "nemo"
  browser     = vars.browser;       # "librewolf"
  menuCmd     = if isNoct then "noctalia msg panel-toggle launcher"
                else if isCaelestia then "hyprctl dispatch global caelestia:launcher"
                else if isEnd4 then "rofi -show drun" else dmsCmd;
  controlCmd  = if isNoct then "noctalia msg panel-toggle control-center"
                else if isCaelestia then "hyprctl dispatch global caelestia:sidebar"
                else if isEnd4 then "rofi -show window" else "${dmsCmd} msg panel-toggle control-center";
  settingsCmd = if isNoct then "noctalia msg panel-toggle settings"
                else "caelestia shell -s";
  wallpaperCmd= if isNoct then "noctalia msg panel-toggle wallpaper"
                else "caelestia wallpaper";
  sessionCmd  = if isNoct then "noctalia msg panel-toggle session"
                else "hyprctl dispatch exit";
  shellStartup= if isNoct then "noctalia --daemon"
                else if isCaelestia then "caelestia shell -d" else dmsCmd;
  volUpCmd    = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
  volDownCmd  = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
  volMuteCmd  = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
in
{

  home.packages = [ pkgs.hyprland ];

  home.file.".config/hypr/hyprland.lua".text = builtins.concatStringsSep "\n" (
    [ "-- Auto-generated HyprLua config for mattsva"
      "-- Managed by home-manager; do not edit manually."
      ""
      "local terminal    = \"${terminalCmd}\""
      "local fileManager = \"${fileManager}\""
    ] ++
    (builtins.map (m: "hl.monitor({ output = \"${m.output}\", mode = \"${m.mode}\", position = \"${m.position}\", scale = \"${m.scale}\"${if m.transform == "0" then "" else ", transform = ${m.transform}"} })") vars.monitors
    ) ++
    [ ""
      "hl.config({"
      "  general = {"
      "    gaps_in     = 0,"
      "    gaps_out    = 0,"
      "    border_size = 0,"
      "    layout      = \"dwindle\","
      "  },"
      "  decoration = {"
      "    rounding = 0,"
      "  },"
      "  dwindle = {"
      "    preserve_split = true,"
      "  },"
      "  input = {"
      "    kb_layout  = \"us,de\","
      "    kb_options = \"grp:alt_shift_toggle\","
      "    touchpad = {"
      "      natural_scroll = false,"
      "    },"
      "  },"
      "  misc = {"
      "    force_default_wallpaper = 0,"
      "    disable_hyprland_logo   = true,"
      "  },"
      "})"
      ""
      "hl.gesture({ fingers = 3, direction = \"horizontal\", action = \"workspace\" })"
      "hl.gesture({ fingers = 3, direction = \"up\", action = function() hl.dispatch(hl.dsp.exec_cmd('wlogout')) end })"
      ""
      "hl.bind(\"SUPER + 1\",  hl.dsp.focus({ workspace = 1 }))"
      "hl.bind(\"SUPER + 2\",  hl.dsp.focus({ workspace = 2 }))"
      "hl.bind(\"SUPER + 3\",  hl.dsp.focus({ workspace = 3 }))"
      "hl.bind(\"SUPER + 4\",  hl.dsp.focus({ workspace = 4 }))"
      "hl.bind(\"SUPER + 5\",  hl.dsp.focus({ workspace = 5 }))"
      "hl.bind(\"SUPER + 6\",  hl.dsp.focus({ workspace = 6 }))"
      "hl.bind(\"SUPER + 7\",  hl.dsp.focus({ workspace = 7 }))"
      "hl.bind(\"SUPER + 8\",  hl.dsp.focus({ workspace = 8 }))"
      "hl.bind(\"SUPER + 9\",  hl.dsp.focus({ workspace = 9 }))"
      "hl.bind(\"SUPER + 0\",  hl.dsp.focus({ workspace = 10 }))"
      ""
      "hl.bind(\"SUPER + SHIFT + 1\",  hl.dsp.window.move({ workspace = 1 }))"
      "hl.bind(\"SUPER + SHIFT + 2\",  hl.dsp.window.move({ workspace = 2 }))"
      "hl.bind(\"SUPER + SHIFT + 3\",  hl.dsp.window.move({ workspace = 3 }))"
      "hl.bind(\"SUPER + SHIFT + 4\",  hl.dsp.window.move({ workspace = 4 }))"
      "hl.bind(\"SUPER + SHIFT + 5\",  hl.dsp.window.move({ workspace = 5 }))"
      "hl.bind(\"SUPER + SHIFT + 6\",  hl.dsp.window.move({ workspace = 6 }))"
      "hl.bind(\"SUPER + SHIFT + 7\",  hl.dsp.window.move({ workspace = 7 }))"
      "hl.bind(\"SUPER + SHIFT + 8\",  hl.dsp.window.move({ workspace = 8 }))"
      "hl.bind(\"SUPER + SHIFT + 9\",  hl.dsp.window.move({ workspace = 9 }))"
      "hl.bind(\"SUPER + SHIFT + 0\",  hl.dsp.window.move({ workspace = 10 }))"
      ""
      "hl.bind(\"SUPER + left\",  hl.dsp.focus({ direction = \"l\" }))"
      "hl.bind(\"SUPER + right\", hl.dsp.focus({ direction = \"r\" }))"
      "hl.bind(\"SUPER + up\",    hl.dsp.focus({ direction = \"u\" }))"
      "hl.bind(\"SUPER + down\",  hl.dsp.focus({ direction = \"d\" }))"
      ""
      "hl.bind(\"SUPER + ALT + left\",  hl.dsp.window.resize({ x = -40, y = 0 }))"
      "hl.bind(\"SUPER + ALT + right\", hl.dsp.window.resize({ x = 40, y = 0 }))"
      "hl.bind(\"SUPER + ALT + up\",    hl.dsp.window.resize({ x = 0, y = -40 }))"
      "hl.bind(\"SUPER + ALT + down\",  hl.dsp.window.resize({ x = 0, y = 40 }))"
      ""
      "hl.bind(\"SUPER + SHIFT + left\",  hl.dsp.window.move({ direction = \"l\" }))"
      "hl.bind(\"SUPER + SHIFT + right\", hl.dsp.window.move({ direction = \"r\" }))"
      "hl.bind(\"SUPER + SHIFT + up\",    hl.dsp.window.move({ direction = \"u\" }))"
      "hl.bind(\"SUPER + SHIFT + down\",  hl.dsp.window.move({ direction = \"d\" }))"
      ""
      "hl.bind(\"SUPER + G\", hl.dsp.window.pin())"
      ""
      "hl.bind(\"SUPER + SPACE\", hl.dsp.exec_cmd(\"${menuCmd}\"), { locked = true })"
      "hl.bind(\"SUPER + B\",     hl.dsp.exec_cmd(\"${browser}\"), {locked = true})"
      "hl.bind(\"SUPER + K\",     hl.dsp.exec_cmd(\"${terminalCmd}\"), {locked = true})"
      "hl.bind(\"SUPER + E\",     hl.dsp.exec_cmd(\"${fileManager}\"), {locked = true})"
      ""
      "hl.bind(\"SUPER + Q\", hl.dsp.window.close())"
      "hl.bind(\"SUPER + F\", hl.dsp.window.fullscreen())"
      "hl.bind(\"SUPER + V\", hl.dsp.exec_cmd(\"cliphist list | rofi -dmenu | cliphist decode | wl-copy\"), {locked = true})"
      "hl.bind(\"SUPER + P\", hl.dsp.window.pseudo())"
      ""
      "hl.bind(\"SUPER + C\",        hl.dsp.exec_cmd(\"${controlCmd}\"), {locked = true})"
      "hl.bind(\"SUPER + SHIFT + C\", hl.dsp.exec_cmd(\"${settingsCmd}\"), {locked = true})"
      "hl.bind(\"SUPER + W\",        hl.dsp.exec_cmd(\"${wallpaperCmd}\"), {locked = true})"
      "hl.bind(\"SUPER + X\",        hl.dsp.exec_cmd(\"${sessionCmd}\"), {locked = true})"
      "hl.bind(\"SUPER + L\",        hl.dsp.exec_cmd(\"hyprlock\"), {locked = true})"
      ""
      "hl.bind(\"SUPER + PERIOD\", hl.dsp.exec_cmd(\"cliphist list | rofi -dmenu | cliphist decode | wl-copy\"), {locked = true})"
      ""
      "hl.bind(\"PRINT\",          hl.dsp.exec_cmd(\"grim -g \\\"$(slurp)\\\" - | swappy -f -\"), {locked = true})"
      "hl.bind(\"SHIFT + PRINT\",  hl.dsp.exec_cmd(\"grim - | swappy -f -\"), {locked = true})"
      ""
      "hl.bind(\"SUPER + mouse_down\", hl.dsp.focus({ workspace = \"e+1\" }), {locked = true, repeating = true})"
      "hl.bind(\"SUPER + mouse_up\",   hl.dsp.focus({ workspace = \"e-1\" }), {locked = true, repeating = true})"
      ""
      "hl.bind(\"SUPER + mouse:272\", hl.dsp.window.drag(), { mouse = true })"
      "hl.bind(\"SUPER + mouse:273\", hl.dsp.window.resize(), { mouse = true })"
      ""
      "hl.bind(\"XF86AudioRaiseVolume\", hl.dsp.exec_cmd(\"${volUpCmd}\"), {locked = true, repeating = true})"
      "hl.bind(\"XF86AudioLowerVolume\", hl.dsp.exec_cmd(\"${volDownCmd}\"), {locked = true, repeating = true})"
      "hl.bind(\"XF86AudioMute\",        hl.dsp.exec_cmd(\"${volMuteCmd}\"), {locked = true, repeating = true})"
      "hl.bind(\"XF86AudioMicMute\",     hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle\"), {locked = true, repeating = true})"
      "hl.bind(\"XF86MonBrightnessUp\",   hl.dsp.exec_cmd(\"brightnessctl -e4 -n2 set 5%+\"), {locked = true, repeating = true})"
      "hl.bind(\"XF86MonBrightnessDown\", hl.dsp.exec_cmd(\"brightnessctl -e4 -n2 set 5%-\"), {locked = true, repeating = true})"
      ""
      "hl.bind(\"XF86AudioNext\",  hl.dsp.exec_cmd(\"playerctl next\"), {locked = true})"
      "hl.bind(\"XF86AudioPause\", hl.dsp.exec_cmd(\"playerctl play-pause\"), {locked = true})"
      "hl.bind(\"XF86AudioPlay\",  hl.dsp.exec_cmd(\"playerctl play-pause\"), {locked = true})"
      "hl.bind(\"XF86AudioPrev\",  hl.dsp.exec_cmd(\"playerctl previous\"), {locked = true})"
      ""
      "hl.env(\"XCURSOR_SIZE\",    \"24\")"
      "hl.env(\"HYPRCURSOR_SIZE\", \"24\")"
      ""
      "hl.on(\"hyprland.start\", function()"
      (if vars.terminal == "foot" then "  hl.dispatch(hl.dsp.exec_cmd(\"foot --server < /dev/null\"));" else "")
      "  hl.dispatch(hl.dsp.exec_cmd(\"hypridle\"));"
      "  hl.dispatch(hl.dsp.exec_cmd(\"wl-paste --type text --watch cliphist store\"));"
      "  hl.dispatch(hl.dsp.exec_cmd(\"wl-paste --type image --watch cliphist store\"));"
      "  hl.dispatch(hl.dsp.exec_cmd(\"nm-applet --indicator\"));"
      "  hl.dispatch(hl.dsp.exec_cmd(\"blueman-applet\"));"
      "  hl.dispatch(hl.dsp.exec_cmd(\"${shellStartup}\"));"
      "end)"
      ""
      "-- eof"
    ]);

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd         = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd  = "hyprctl dispatch dpms on";
      };
      listener = [
        { timeout = 300; on-timeout = "brightnessctl -s set 10%"; on-resume = "brightnessctl -r"; }
        { timeout = 360; on-timeout = "loginctl lock-session"; }
        { timeout = 600; on-timeout = "systemctl suspend"; }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = { disable_loading_bar = true; hide_cursor = true; };
      background = [{ path = "screenshot"; blur_size = 8; blur_passes = 3; brightness = 0.5; }];
      input-field = [{
        size = "300, 50"; position = "0, -80";
        halign = "center"; valign = "center";
        dots_center = true; fade_on_empty = false; placeholder_text = "";
      }];
      label = [{
        text = "cmd[update:1000] date +\"%H:%M\"";
        font_size = 72; halign = "center"; valign = "center"; position = "0, 80";
      }];
    };
  };
}
