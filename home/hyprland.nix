{ config, pkgs, vars, ... }:

let
  # Helpers for selecting behavior based on vars
  isNoct = vars.desktopShell == "noctalia";
  isCaelestia = vars.desktopShell == "caelestia";
  dmsCmd = "dms"; # upstream executable for DankMaterialShell
  # Map the user-facing hyprConfig values to what the hypr home-module expects.
  # Accept either "hyprlandlua" or "lua" to mean the Lua-based config, otherwise
  # fall back to the hyprlang format.
  hyprConfigType = if vars.hyprConfig == "hyprlandlua" || vars.hyprConfig == "lua" then "lua" else "hyprlang";

  # Centralized shell command strings so keybindings can use whichever shell is selected.
  shellCmds = {
    menuCmd          = if isNoct then "noctalia msg panel-toggle launcher" else if isCaelestia then "hyprctl dispatch global caelestia:launcher" else dmsCmd;
    controlCenterCmd = if isNoct then "noctalia msg panel-toggle control-center" else if isCaelestia then "hyprctl dispatch global caelestia:sidebar" else "${dmsCmd} msg panel-toggle control-center";
    settingsCmd      = if isNoct then "noctalia msg panel-toggle settings" else if isCaelestia then "caelestia shell -s" else "${dmsCmd} msg panel-toggle settings";
    wallpaperCmd     = if isNoct then "noctalia msg panel-toggle wallpaper" else if isCaelestia then "caelestia wallpaper" else "${dmsCmd} msg panel-toggle wallpaper";
    sessionCmd       = if isNoct then "noctalia msg panel-toggle session" else if isCaelestia then "hyprctl dispatch global caelestia:session" else "${dmsCmd} msg panel-toggle session";
  };
  terminalCmd = if vars.terminal == "foot" then "footclient" else vars.terminal;
in
{
  # Allow selecting hypr config format (hyprlang or lua)
  wayland.windowManager.hyprland.configType = hyprConfigType;

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      # VARIABLES: Defaults for programs and navigation
      "$terminal"    = terminalCmd;
      "$fileManager" = vars.fileManager;
      "$mainMod"     = "SUPER";
      "$menu"        = shellCmds.menuCmd;

      # MONITOR SETUP
      # Default monitors (leave as-is or override)
      monitor = [
        "HDMI-A-1,1920x1080@160,0x0,1"
        "DP-1,1920x1080@60,1920x0,1,transform,1"
        "eDP-1,1920x1080@144,3000x420,1"
      ];

      # STARTUP COMMANDS
      "exec-once" = [
        (if vars.terminal == "foot" then "foot --server" else "true")
        "hypridle"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "nm-applet --indicator"
        "blueman-applet"
        # Start the selected shell as a fallback (the upstream homeModule may also enable a user service)
        (if isNoct then "noctalia" else if isCaelestia then "caelestia shell -d" else dmsCmd)
      ];

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      general = {
        gaps_in     = 0;
        gaps_out    = 0;
        border_size = 0;
        layout      = "dwindle";
      };

      decoration.rounding = 0;

      dwindle = { preserve_split = true; };

      input = {
        kb_layout  = "us,de";
        kb_options = "grp:alt_shift_toggle";
        touchpad = {
          natural_scroll = false;
        };
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo   = true;
      };

      gesture = [
        "3, horizontal, workspace"
        "3, up, dispatcher, exec, wlogout"
      ];

      bind = [
        "$mainMod, G, pin"
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        "$mainMod, left,  movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up,    movefocus, u"
        "$mainMod, down,  movefocus, d"

        "$mainMod ALT, left,  resizeactive, -40 0"
        "$mainMod ALT, right, resizeactive, 40 0"
        "$mainMod ALT, up,    resizeactive, 0 -40"
        "$mainMod ALT, down,  resizeactive, 0 40"

        "$mainMod SHIFT, left,  movewindow, l"
        "$mainMod SHIFT, right, movewindow, r"
        "$mainMod SHIFT, up,    movewindow, u"
        "$mainMod SHIFT, down,  movewindow, d"

        "$mainMod, SPACE, exec, ${shellCmds.menuCmd}"
        "$mainMod, B,     exec, ${vars.browser}"
        "$mainMod, K,     exec, $terminal"
        "$mainMod, E,     exec, $fileManager"

        "$mainMod, Q,     killactive,"
        "$mainMod, F,     fullscreen"
        "$mainMod, V,     togglefloating,"
        "$mainMod, P,     pseudo,"

        # Use centralized shell commands (Noctalia or DMS) for these bindings:
        "$mainMod, C,       exec, ${shellCmds.controlCenterCmd}"
        "$mainMod SHIFT, C, exec, ${shellCmds.settingsCmd}"
        "$mainMod, W,       exec, ${shellCmds.wallpaperCmd}"
        "$mainMod, X,       exec, ${shellCmds.sessionCmd}"

        "$mainMod, L, exec, hyprlock"

        "$mainMod, PERIOD, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
        ", Print,      exec, grim -g \"$(slurp)\" - | swappy -f -"
        "SHIFT, Print, exec, grim - | swappy -f -"

        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up,   workspace, e-1"
      ];

      bindel = [
        ", XF86AudioRaiseVolume,  exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute,         exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute,      exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86MonBrightnessUp,   exec, brightnessctl -e4 -n2 set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];

      bindl = [
        ", XF86AudioNext,  exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay,  exec, playerctl play-pause"
        ", XF86AudioPrev,  exec, playerctl previous"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };

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
        text = ''cmd[update:1000] date +"%H:%M"'';
        font_size = 72; halign = "center"; valign = "center"; position = "0, 80";
      }];
    };
  };
}
