# home/default.nix
{ config, pkgs, inputs, vars, ... }:

let
  useNoct = vars.desktopShell == "noctalia";
  useCaelestia = vars.desktopShell == "caelestia";
in
{
  imports = ([
    ./hyprland.nix
    ./shell.nix
  ] ++ (if useNoct then [
    inputs.noctalia.homeModules.default
    ./noctalia.nix
  ] else if useCaelestia then [
    inputs.caelestia-shell.homeManagerModules.default
    ./caelestia.nix
  ] else [
    # Import the upstream Dank homeModule so it configures what it expects
    inputs.dankmaterials.homeModules.dank-material-shell
    ./dankmaterial.nix
  ]));

  home.stateVersion  = "25.05";
  home.username      = vars.userName;
  home.homeDirectory = "/home/${vars.userName}";

  xdg.enable                       = true;
  xdg.userDirs.enable              = true;
  xdg.userDirs.createDirectories   = true;
  xdg.userDirs.setSessionVariables = true;

  gtk = {
    enable = true;
    theme = {
      name    = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name    = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name    = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size    = 24;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.theme = config.gtk.theme;
  };

  qt = {
    enable             = true;
    platformTheme.name = "adwaita";
    style.name         = "adwaita-dark";
  };

  programs.home-manager.enable = true;
}