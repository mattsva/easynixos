# home/end4-dots.nix
# Minimal end4-dots profile tuned to the same launcher/clipboard flow used elsewhere.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    rofi-wayland
    cliphist
    wl-clipboard
  ];

  home.sessionVariables = {
    END4_DOTS = "1";
    END4_STYLE = "mattsva";
  };
}
