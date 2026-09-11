# modules/system/nix.nix
# Core Nix settings, overlays, and tooling.
#
# Binary safety:
#   - NixOS verifies substitute integrity via NarHash by default.
#   - If a verified binary substitute exists, it's used.
#   - If no verified substitute exists (or verification fails), the package
#     is built locally from source.
#   - Sandbox builds isolate compilation from the host system.
{ config, pkgs, lib, ... }:
let
  useOptimisedStdenv = false;

  withOptFlags = flags: drv:
    drv.overrideAttrs (old: {
      env = (old.env or {}) // {
        NIX_CFLAGS_COMPILE =
          (old.env.NIX_CFLAGS_COMPILE or "")
          + " "
          + lib.concatStringsSep " " flags;
      };
    });

  optimisedOverlay = final: prev: {
    ffmpeg = if useOptimisedStdenv then withOptFlags ["-O2" "-pipe" "-O3"] prev.ffmpeg else prev.ffmpeg;
    ffmpeg-full = if useOptimisedStdenv then withOptFlags ["-O2" "-pipe" "-O3"] prev.ffmpeg-full else prev.ffmpeg-full;
    zstd = if useOptimisedStdenv then withOptFlags ["-O2" "-pipe" "-O3"] prev.zstd else prev.zstd;
  };
in {
  nixpkgs = {
    overlays = [
      optimisedOverlay
      (final: prev: {
        python314Packages = prev.python314Packages // {
          torch = (prev.python314Packages.torch-bin or prev.python314Packages.torch);
        };
      })
    ];

    config = {
      allowUnfree = true;
      problems.handlers = {
        torch.unsupported-cuda-version = "ignore";
      };
    };
  };

  nix.settings = {
    # Binary substitutes: use when available and integrity-verified.
    # Falls back to local build when no verified substitute exists.
    substitute = true;
    # Verify substituter integrity (NarHash verification — on by default, explicit here)
    # verify-cache removed: not a valid setting in Nix 2.24+
    # Sandbox builds: isolate compilation from host for safety
    sandbox = true;
    # Keep build artifacts for debugging and reuse
    keep-derivations = true;
    keep-outputs = true;
    # Auto-optimise the store after builds
    auto-optimise-store = true;
    # Respect dirty repo state
    warn-dirty = true;
    # Parallelism: 6 jobs across 2 cores per job (total ~12 cores used)
    max-jobs = 6;
    cores = 2;
    experimental-features = [ "nix-command" "flakes" ];
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
