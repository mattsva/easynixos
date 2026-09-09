# modules/system/boot.nix
{ config, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  boot.kernelParams = [ "quiet" "splash" "mem_sleep_default=deep" ];
}