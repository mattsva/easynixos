# modules/system/optimization.nix
# CPU-optimized compilation overlay — disabled by default to keep builds fast and memory-safe.
# Enable by flipping `useOptimisedStdenv` to true below.
{ pkgs, lib, ... }:
let
  useOptimisedStdenv = false;  # <-- set to true to enable -march=native -O3 on all C/C++
in {
  nixpkgs.overlays = lib.optional useOptimisedStdenv (final: prev: {
    stdenv = prev.withCFlags [
      "-march=native"
      "-mtune=native"
      "-O3"
      "-pipe"
    ] prev.stdenv;
  });

  # NOTE: nix.settings and nixpkgs.config are managed by modules/system/nix.nix.
  # This file only provides the optional stdenv overlay above.
}
