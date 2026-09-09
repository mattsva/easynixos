{ config, pkgs, lib, ... }:

{
  # ====================================================================================================================
  # NIX AUTOMATION
  # ====================================================================================================================

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  # ====================================================================================================================
  # NIX STORE VERIFICATION
  # ====================================================================================================================

  systemd.timers.nix-store-verify = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      OnBootSec = "10min";
      Persistent = true;
    };
  };

  systemd.services.nix-store-verify = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.nix}/bin/nix store verify --repair";
    };
  };

  # ====================================================================================================================
  # TMP CLEANUP
  # ====================================================================================================================

  systemd.timers.cleanup-tmp = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      OnBootSec = "15min";
      Persistent = true;
    };
  };

  systemd.services.cleanup-tmp = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.findutils}/bin/find /tmp /var/tmp -atime +30 -delete 2>/dev/null || true";
    };
  };

  # ====================================================================================================================
  # JOURNALD (FIXED: SINGLE SOURCE OF TRUTH)
  # ====================================================================================================================

  services.journald.settings = {
    Storage = "persistent";

    # Persistent storage limits
    SystemMaxUse = "500M";
    SystemKeepFree = "100M";
    MaxRetentionSec = "30day";

    # Runtime limits
    RuntimeMaxUse = "100M";
    RuntimeKeepFree = "50M";
    RuntimeMaxFileSize = "50M";

    # Rotation
    MaxFileSec = "1day";
  };

  # ====================================================================================================================
  # DISK MONITORING
  # ====================================================================================================================

  systemd.timers.disk-space-check = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "1h";
      Persistent = true;
    };
  };

  systemd.services.disk-space-check = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "check-disk-space" ''
        usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

        if [ "$usage" -gt 90 ]; then
          echo "CRITICAL: Disk usage at $usage%" >&2
        elif [ "$usage" -gt 80 ]; then
          echo "WARNING: Disk usage at $usage%" >&2
        fi
      '';
    };
  };

  # ====================================================================================================================
  # SYSTEM TOOLING
  # ====================================================================================================================

  environment.systemPackages = with pkgs; [
    nix-tree
    nix-du
    nix-output-monitor

    nvme-cli
    smartmontools
    lvm2

    dosfstools
    ntfs3g
    exfatprogs

    testdisk
    photorec
  ];

  # ====================================================================================================================
  # SYSTEM HEALTH SCRIPT
  # ====================================================================================================================

  environment.etc."nixos-check".text = ''
    #!/bin/sh
    echo "=== NixOS Health Check ==="
    echo "Store size: $(du -sh /nix/store 2>/dev/null | cut -f1)"
    echo "Disk usage: $(df -h / | tail -1 | awk '{print $5}')"
    echo "System time: $(date)"
  '';

  system.activationScripts.makeHealthCheckScript = {
    text = ''
      chmod +x /etc/nixos-check || true
    '';
  };
}