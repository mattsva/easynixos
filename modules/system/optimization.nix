# modules/system/optimization.nix
{ pkgs, ... }:

{
  nix.settings = {
    cores = 0;
    max-jobs = "auto";
    keep-going = true;

    # Build everything locally (no binary substitutes)
    substituters = [ ];
    substitute = false;
  };

  nixpkgs.config = {
    allowBroken = true;
    allowUnfree = true;
  };

  # CPU-optimized compilation for all C/C++ builds
  nixpkgs.overlays = [
    (final: prev: {
      stdenv = prev.withCFlags [
        "-march=native"
        "-mtune=native"
        "-O3"
        "-pipe"
      ] prev.stdenv;
    })
  ];

  # NOTE:
  # environment.variables is NOT needed for Nix builds anymore.
  # Keeping it can confuse assumptions, so we avoid it.
}