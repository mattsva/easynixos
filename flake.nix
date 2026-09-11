# flake.nix
{
  description = "mattsva's modular NixOS desktop configuration with Hyprland and selectable shells";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # DankMaterialShell flake input (AvengeMedia)
    dankmaterials = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Caelestia Shell - quickshell-based Hyprland shell (github:caelestia-dots/shell)
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, noctalia, dankmaterials, caelestia-shell, nix-flatpak, ... }:
  let
    #nixpkgs.hostPlatform = "x86_64-linux";

    # Import vars.local.nix if it exists (git-ignored, real values), else fall back to vars.nix (committed template).
    vars =
      if builtins.pathExists ./vars.local.nix
      then import ./vars.local.nix
      else import ./vars.nix;

    pkgConfig = {
      allowUnfree = true;
      allowSubstitutes = true;
    };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs vars; };
      modules = [
        ./hosts/nixos/default.nix
        { nixpkgs.config = pkgConfig; }
        # Custom packages / overlays
        {
          nixpkgs.overlays = [
            # Python compatibility overlay
            (final: prev: {
              python3Packages = prev.python3Packages // {
                setuptools_scm =
                  prev.python3Packages.buildPythonPackage rec {
                    pname = "setuptools_scm";
                    version = "6.0.1";
                    src = prev.python3Packages.fetchPypi {
                      inherit pname version;
                    };
                    doCheck = false;
                    propagatedBuildInputs = [
                      prev.python3Packages.setuptools
                    ];
                  };
              };
            })
            # Pin wf-recorder to an older ffmpeg API provider to avoid build failures
            (final: prev:
              let
                ffmpegPkg = if prev ? ffmpeg_5 then prev.ffmpeg_5 else prev.ffmpeg_4;
              in {
                wf-recorder = prev.wf-recorder.override {
                  ffmpeg = ffmpegPkg;
                };
              })
          ];
        }
        # Flatpak support behalten,
        # aber OpenDeck nicht mehr darüber installieren
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hm-bak";
          home-manager.backupCommand = "cp -f $old $new";
          home-manager.extraSpecialArgs = { inherit inputs vars; };
          home-manager.users.${vars.userName} = import ./home/default.nix;
        }
      ];
    };
  };
}
