# modules/system/user.nix
{ config, pkgs, vars, ... }:
{
  users.users.${vars.userName} = {
    isNormalUser = true;
    description  = vars.userName;
    shell        = pkgs.fish;
    extraGroups  = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
      "docker"
      "input"
      "dialout"
    ];
  };

  security.sudo.wheelNeedsPassword = true;

  # Fish aktivieren - Konfiguration via home-manager (home/shell.nix)
  programs.fish.enable = true;

  services.displayManager.ly.enable = true;
  services.xserver.enable           = true;
}
