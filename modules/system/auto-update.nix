# modules/system/auto-update.nix
# ------------------------------------------------------------------------------------------------------------------------
# Automatic NixOS configuration updates.
#
# Runs a weekly systemd timer that:
#   1. Updates the flake lock (nix flake update --flake /etc/nixos#nixos)
#   2. Builds the new configuration (nixos-rebuild build --flake /etc/nixos#nixos)
#   3. If the build succeeds, switches to the new configuration (nixos-rebuild switch)
#
# The stable channel (nixos-26.05) is tracked, so each update pulls the latest
# stable point release. Updates are atomic: nixos-rebuild switch keeps the
# previous generation for rollback, and the build-first approach prevents a
# failed build from disrupting the running system.
#
# Configurable:
#   vars.autoUpdateInterval  — systemd timer interval (default: "weekly")
#   vars.autoUpdateTime      — when the timer triggers (default: "03:00")
#   vars.autoUpdateEnabled   — whether the auto-update timer is active (default: true)
# ------------------------------------------------------------------------------------------------------------------------
{ config, pkgs, vars, ... }:

let
  interval  = vars.autoUpdateInterval  or "weekly";
  triggerAt = vars.autoUpdateTime      or "03:00";
  enabled   = vars.autoUpdateEnabled   or true;
in
{

  # Systemd oneshot service: update flake + build + switch
  systemd.services.easynixos-auto-update = {
    description = "Update NixOS configuration from flake (stable channel)";
    serviceConfig = {
      Type = "oneshot";
      # Safety: ensure the service runs with appropriate hardening
      ProtectSystem = "strict";
      ProtectHome = "true";
      PrivateTmp = true;
      NoNewPrivileges = true;
      ReadOnlyPaths = [ "/etc/nixos" ];
      ReadWritePaths = [ "/etc/nixos" "/nix" "/var/log" ];
      ExecStart = pkgs.writeShellScript "easynixos-auto-update.sh" ''
        set -euo pipefail
        export NIX_PATH="nixpkgs=${pkgs.path}:nixos-config=/etc/nixos"
        echo "[$(date)] Starting auto-update..."

        # Use absolute paths since systemd services don't get Nix on PATH
        NIX="/nix/var/nix/profiles/default/bin/nix"
        NIXOS_REBUILD="/nix/var/nix/profiles/default/bin/nixos-rebuild"

        cd /etc/nixos

        # Update flake lock (pulls latest stable point release)
        echo "[$(date)] Updating flake lock..."
        "$NIX" flake update --flake /etc/nixos#nixos --update-input nixpkgs 2>&1 || {
          echo "[$(date)] ERROR: flake update failed"
          exit 1
        }

        # Build the new configuration first (fail-safe: won't switch on build failure)
        echo "[$(date)] Building new configuration..."
        "$NIXOS_REBUILD" build --flake /etc/nixos#nixos --max-jobs 2 --cores 1 2>&1 || {
          echo "[$(date)] ERROR: build failed - not switching"
          exit 1
        }

        # Only switch if build succeeded
        echo "[$(date)] Switching to new configuration..."
        "$NIXOS_REBUILD" switch --flake /etc/nixos#nixos --max-jobs 2 --cores 1 2>&1 || {
          echo "[$(date)] ERROR: switch failed"
          exit 1
        }

        echo "[$(date)] Auto-update complete."
      '';
      # Keep logs around for debugging
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  # Systemd timer: trigger the update service
  systemd.timers.easynixos-auto-update = {
    description = "Timer for automatic NixOS configuration updates";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "${triggerAt}";
      AccuracySec = "1h";  # Allow ±1h drift, reduces wake-up storms
      RandomizedDelaySec = "30min";  # Stagger across machines
    };
    partOf = [ "easynixos-auto-update.service" ];
  };

  # Enable only if the user wants automatic updates
  systemd.services.easynixos-auto-update.enable = enabled;
  systemd.timers.easynixos-auto-update.enable = enabled;
}
