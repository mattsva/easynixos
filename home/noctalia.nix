# home/noctalia.nix
{ pkgs, inputs, vars, ... }:

{
  programs.noctalia = {
    enable  = true;
    package = inputs.noctalia.packages.${pkgs.system}.default;
    systemd.enable = true;

    settings = {
      shell = {
        corner_radius_scale    = 0.0;
        settings_show_advanced = true;
        shared_gl_context      = true;
        show_location          = true;
        app_icon_colorize      = false;
        clipboard_auto_paste   = "auto";
        clipboard_enabled      = true;
        clipboard_history_max_entries = 50;
        date_format            = "%A, %x";
        font_family            = "sans-serif";
        niri_overview_type_to_launch_enabled = false;
        offline_mode           = false;
        password_style         = "default";
        polkit_agent           = true;
        telemetry_enabled      = false;
        time_format            = "{:%H:%M}";
        ui_scale               = 0.85;
      };

      shell.animation = {
        enabled = true;
        speed   = 0.8;
      };

      shell.shadow = {
        direction = "down";
        alpha     = 0.55;
      };

      shell.panel = {
        transparency_mode          = "solid";
        borders                    = true;
        shadow                     = true;
        launcher_placement         = "attached";
        clipboard_placement        = "attached";
        control_center_placement   = "attached";
        wallpaper_placement        = "attached";
        session_placement          = "attached";
        open_near_click_launcher   = false;
        open_near_click_clipboard  = false;
        open_near_click_control_center = false;
      };

      shell.screen_corners = {
        enabled = false;
        size    = 1;
      };

      shell.screenshot = {
        copy_to_clipboard = true;
        freeze_screen     = true;
        save_to_file      = true;
      };

      bar.widgets = {
        enabled            = true;
        position           = "top";
        thickness          = 30;
        background_opacity = 1.0;
        radius             = 0;
        radius_bottom_left = 0;
        radius_bottom_right = 0;
        radius_top_left    = 0;
        radius_top_right   = 0;
        capsule            = false;
        capsule_radius     = 0.0;
        capsule_fill       = "surface_variant";
        capsule_opacity    = 1.0;
        padding            = 14;
        widget_spacing     = 6;
        scale              = 0.8;
        shadow             = true;
        auto_hide          = false;
        reserve_space      = true;
        layer              = "top";
        start              = [ "launcher" "workspaces" "taskbar" "media" "audio_visualizer" ];
        center             = [ "date" "clock" ];
        end                = [ "wallpaper" "notifications" "clipboard" "network" "bluetooth" "volume" "brightness" "battery" "control-center" "session" ];
      };

      # Only use the 'widgets' bar and disable the default 'main' bar
      bar = {
        order = [ "widgets" ];
        main = { enabled = false; };
      };

      wallpaper = {
        enabled            = true;
        directory          = vars.wallpaperDir;
        fill_mode          = "crop";
        transition         = [ "fade" "wipe" "disc" "stripes" "zoom" "honeycomb" ];
        transition_duration = 1500;
        edge_smoothness    = 0.3;
      };

      wallpaper.automation = {
        enabled = false;
        recursive = true;
        order = "random";
      };

      theme = {
        mode    = "dark";
        source  = "wallpaper";
        builtin = "Noctalia";
        wallpaper_scheme = "m3-content";
      };

      theme.templates = {
        enable_builtin_templates = true;
        enable_community_templates = true;
        builtin_ids = [ "alacritty" "btop" "cava" "emacs" "foot" "gtk3" "gtk4" "ghostty" "helix" "hyprland" "kcolorscheme" "kitty" "labwc" "mango" "niri" "qt" "scroll" "starship" "sway" "wezterm" ];
      };

      notification = {
        enable_daemon      = true;
        show_app_name      = true;
        show_actions       = true;
        layer              = "top";
        scale              = 1.0;
        background_opacity = 0.97;
        offset_x           = 20;
        offset_y           = 8;
        position           = "top_right";
        collapse_on_dismiss = true;
        blacklist_allow_critical = true;
      };

      osd = {
        background_opacity = 0.97;
        offset_x = 20;
        offset_y = 8;
        position = "top_center";
        scale = 1.0;
      };

      osd.kinds = {
        bluetooth = true;
        brightness = true;
        caffeine = true;
        dnd = true;
        keyboard_layout = true;
        lock_keys = true;
        power_profile = true;
        volume = true;
      };

      battery = {
        warning_threshold = 20;
      };

      keybinds = {
        validate = [ "Return" "KP_Enter" ];
        cancel   = [ "Escape" ];
        left     = [ "Left" ];
        right    = [ "Right" ];
        up       = [ "Up" ];
        down     = [ "Down" ];
      };

      widget.media = {
        type = "media";
        max_length = 220;
        min_length = 80;
        title_scroll = "none";
      };

      widget.active_window = {
        type = "active_window";
        max_length = 260;
        min_length = 80;
        title_scroll = "none";
      };

      widget.date = {
        type = "clock";
        format = "{:%a %d %b}";
      };

      widget.clock = {
        type = "clock";
      };
    };
  };
}
