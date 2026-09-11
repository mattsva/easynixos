# modules/desktop/dankmaterial.nix
# System-level module for DankMaterialShell (DMS).
# Provides the dms binary as a system package when available from the flake,
# and registers a PAM service for screen-locking integration.
{ pkgs, lib, inputs, ... }:
let
  system = pkgs.system;
  dmPkgs = (if inputs ? dankmaterials && inputs.dankmaterials ? packages &&
              builtins.hasAttr system inputs.dankmaterials.packages
           then inputs.dankmaterials.packages.${system}
           else null);

  # Try multiple known attribute names for the main DMS binary.
  dmsPkg = (if dmPkgs != null then
    builtins.foldl' (found: name:
      if found != null then found
      else if dmPkgs ? name then dmPkgs.${name}
      else null
    ) null [ "default" "dms-shell" "dms" ]
    else null);
in
{
  environment.systemPackages = lib.optional (dmsPkg != null) dmsPkg;

  # PAM service so DMS can participate in PAM sessions (e.g. for lockscreen).
  security.pam.services.dms = lib.mkIf (dmsPkg != null) {};
}
