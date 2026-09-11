{ pkgs, ... }:

{
  # System packages required by the end4-inspired Hyprland profile. Keep this
  # minimal — the user's home config will add the launcher/clipboard tools,
  # but installing the system-side helpers ensures functionality for all users.
  environment.systemPackages = with pkgs; [
    rofi
    wl-clipboard
    cliphist
    foot
  ];

  # Set session variables globally so the home hyprland config can detect
  # the end4 styling and behavior expected by the home module.
  environment.sessionVariables = {
    END4_DOTS = "1";
    END4_STYLE = "mattsva";
  };

}
