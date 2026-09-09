{ config, pkgs, lib, ... }:

let
  baseFlags = [
    "-O2"
    "-pipe"
  ];

  # Only safe runtime-level tuning
  appFlags = baseFlags ++ [
    "-O3"
  ];

  withOptFlags = flags: drv:
    drv.overrideAttrs (old: {
      env = (old.env or {}) // {
        NIX_CFLAGS_COMPILE =
          (old.env.NIX_CFLAGS_COMPILE or "")
          + " "
          + lib.concatStringsSep " " flags;
      };
    });

  # VERY conservative overlay
  optimisedOverlay = final: prev: {

    ffmpeg = withOptFlags appFlags prev.ffmpeg;
    ffmpeg-full = withOptFlags appFlags prev.ffmpeg-full;

    zstd = withOptFlags appFlags prev.zstd;

    # avoid touching LLVM / Rust / Git / Nix / core toolchain
  };

in {

  nixpkgs = {
    overlays = [ optimisedOverlay ];

    config = {
      allowUnfree = true;
    };
  };

  nix.settings = {
    max-jobs = "auto";
    cores = 0;

    experimental-features = [ "nix-command" "flakes" ];

    sandbox = true;

    auto-optimise-store = true;

    keep-outputs = true;
    keep-derivations = true;

    warn-dirty = false;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  programs.ccache = {
    enable = true;
    cacheDir = "/var/cache/ccache";
  };

  environment.systemPackages = with pkgs; [
    ccache
    gcc
    binutils
    cmake
    ninja
    pkg-config
    libusb1
  ];

  programs.nix-ld.enable = true;

}
