# Caelestia Shell system package for Hyprland.
{ pkgs, inputs, ... }:

{
  environment.systemPackages = [
    inputs.caelestia-shell.packages.${pkgs.system}.with-cli
  ];
}
