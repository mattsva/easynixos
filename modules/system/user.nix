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

  # SECURITY NOTE: Docker group membership effectively grants root-equivalent
  # host control. Anyone in the docker group can mount the host filesystem,
  # access host devices, and escape container isolation. Only include trusted
  # users in the docker group, and consider rootless Docker (docker-rootless)
  # for additional isolation if supported by your workflow.

  security.sudo.wheelNeedsPassword = true;

  # Fish aktivieren - Konfiguration via home-manager (home/shell.nix)
  programs.fish.enable = true;

  services.displayManager.ly.enable = true;
  services.xserver.enable           = true;
}
