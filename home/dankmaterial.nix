# home/dankmaterial.nix
# Minimal home-manager module to include DankMaterialShell (DMS) when selected via vars.desktopShell.
# This version probes the dankmaterials flake input for packages.${system}.default or packages.${system}."dms-shell"
# and will also attempt to include additional packages provided by the flake (dsearch, dms-greeter) when available.

{ config, pkgs, inputs, vars, ... }:

let
  # Prefer pkgs.system (set by the caller) and fall back to a sensible default.
  system = if pkgs ? system then pkgs.system else "x86_64-linux";

  # Check whether the dankmaterials flake exposes packages.${system}
  hasDankPackages = (inputs ? dankmaterials) && (inputs.dankmaterials ? packages) && builtins.hasAttr system inputs.dankmaterials.packages;
  dmPkgs = if hasDankPackages then inputs.dankmaterials.packages.${system} else null;

  # Helper to safely try evaluate an attribute from dmPkgs (returns { success, value })
  tryDmAttr = attr: if dmPkgs != null && builtins.hasAttr attr dmPkgs then builtins.tryEval (dmPkgs.${attr}) else { success = false; value = null; };

  # Safely attempt to obtain the main package from the dankmaterials flake.
  tryDefault = tryDmAttr "default";
  tryDmsShell = tryDmAttr "dms-shell"; # flake uses a hyphenated name
  tryDms = tryDmAttr "dms";

  foundPkg = if tryDefault.success then tryDefault.value
             else if tryDmsShell.success then tryDmsShell.value
             else if tryDms.success then tryDms.value
             else null;

  dankPkg = if foundPkg != null then foundPkg
            else pkgs.runCommand "dankmaterial-shell-not-found" {} ''
              mkdir -p $out
              echo "# DMS not found in flake inputs; please ensure AvengeMedia/DankMaterialShell exposes packages.${system}.default or packages.${system}.\"dms-shell\" or adjust home/dankmaterial.nix" > $out/README
            '';

  havePkg = foundPkg != null;

  # Try to pick up additional DMS-related packages from the flake: dsearch and dms-greeter
  tryDsearch = tryDmAttr "dsearch";
  tryDsearchAlt = tryDmAttr "d-search";
  foundDsearch = if tryDsearch.success then tryDsearch.value else if tryDsearchAlt.success then tryDsearchAlt.value else null;

  tryGreeter = tryDmAttr "dms-greeter";
  tryGreeterAlt1 = tryDmAttr "dms_greeter";
  tryGreeterAlt2 = tryDmAttr "dmsGreeter";
  tryGreeterAlt3 = tryDmAttr "greeter";
  foundGreeter = if tryGreeter.success then tryGreeter.value
                 else if tryGreeterAlt1.success then tryGreeterAlt1.value
                 else if tryGreeterAlt2.success then tryGreeterAlt2.value
                 else if tryGreeterAlt3.success then tryGreeterAlt3.value
                 else null;

  # As a convenience, also try to pick dsearch from nixpkgs if the flake didn't provide it.
  dsearchPkg = if foundDsearch != null then foundDsearch else (if pkgs ? dsearch then pkgs.dsearch else null);
  greeterPkg = if foundGreeter != null then foundGreeter else null;

in
{
  # Add the package(s) only if we successfully found them in the flake (or nixpkgs fallback for dsearch).
  home.packages = (if havePkg then [ dankPkg ] else [])
                ++ (if dsearchPkg != null then [ dsearchPkg ] else [])
                ++ (if greeterPkg != null then [ greeterPkg ] else []);

  # Expose a launcher command variable used by hyprland (dms is upstream executable name)
  home.sessionVariables = {
    DMS_LAUNCHER = "dms";
  };

  # Note: don't define a "programs.dms-shell" option here because home-manager
  # does not provide a built-in `programs.dms-shell` option. If you want a
  # user systemd service for dms or additional configuration, add one of the
  # following in your home configuration or in this module:
  #
  # - Enable the user systemd service installed by the package:
  #   systemd.user.services.dms = lib.mkIf havePkg {
  #     description = "DankMaterialShell (dms)";
  #     wantedBy = [ "default.target" ];
  #     serviceConfig = {
  #       ExecStart = "${dankPkg}/bin/dms";
  #       Restart = "on-failure";
  #     };
  #   };
  #
  # - Or enable/manage dms via the upstream flake's homeModule:
  #   inputs.dankmaterials.homeModules.dank-material-shell
  #
  # Keeping this module minimal avoids evaluation errors on systems where the
  # dank flake doesn't export a home-manager module named `programs.dms-shell`.
}
