# modules/desktop/hyprland.nix
# ------------------------------------------------------------------------------------------------------------------------
# System-level Hyprland enablement.
# The actual hyprland.conf is managed by home-manager (home/hyprland.nix)
# so it lives in ~/.config/hypr/ and can be rebuilt without sudo.
# ------------------------------------------------------------------------------------------------------------------------
{ config, pkgs, ... }:

{
  # Hyprland compositor --------------------------------------------------------------------------------------------------
  programs.hyprland = {
    enable          = true;
    xwayland.enable = true;   # compatibility layer for X11 apps
  };

  # Portal (screen sharing, file picker, …) ------------------------------------------------------------------------------
  # xdg-desktop-portal-hyprland provides proper Wayland portal support.
  xdg.portal = {
    enable      = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = "*";
  };

  # Environment variables ------------------------------------------------------------------------------------------------
  # Set globally so any session / launcher picks them up.
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_WEBRENDER = "1";
    NIXOS_OZONE_WL   = "1";    # enable Ozone Wayland for Electron apps (VS Code, etc.)
    WLR_NO_HARDWARE_CURSORS = "1";  # fix invisible cursor on some NVIDIA configs
    QT_QPA_PLATFORM  = "wayland;xcb";
    SDL_VIDEODRIVER  = "wayland";
    CLUTTER_BACKEND  = "wayland";
  };

  # Hyprland-adjacent tools (system-level) -------------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    hyprlock         # lock screen
    hyprpicker       # color picker
    hypridle         # idle daemon (screen lock / suspend trigger)
    wlogout          # logout / shutdown menu
    rofi             # alternative app launcher (optional, Noctalia has its own)
    brightnessctl    # backlight control
    playerctl        # MPRIS media player control
    pamixer          # PulseAudio/PipeWire volume control CLI
    wl-clipboard     # wl-copy / wl-paste for CLI clipboard
    cliphist         # clipboard history daemon
    grim             # screenshot tool
    slurp            # screen region selector
    swappy           # screenshot annotation
    libnotify        # notify-send
    foot             # fast Wayland terminal (default $terminal)
    xdg-utils        # xdg-open, xdg-mime, etc.

    # Thunar file manager + gvfs for mounting (MTP, SMB, SFTP, Trash…)
    thunar
    thunar-volman
    thunar-archive-plugin
    thunar-media-tags-plugin
    gvfs             # virtual filesystem (required for Thunar mounting)
    tumbler     # thumbnail service for Thunar

    # File archive support in Thunar
    file-roller
    p7zip
    unrar
  ];

  # gvfs / tumbler services ----------------------------------------------------------------------------------------------
  services.gvfs.enable  = true;
  services.tumbler.enable = true;
}
