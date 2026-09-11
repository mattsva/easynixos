{ config, pkgs, lib, ... }:

{
  # ====================================================================================================================
  # FIREWALL
  # ====================================================================================================================
  # Port lists (allowedTCPPorts/allowedUDPPorts/trustedInterfaces/…) all live in
  # modules/system/networking.nix - keeping them in one place avoids two modules silently
  # merging (Nix list options concatenate, they don't override) into a wider-open firewall
  # than either file shows on its own. Only enable + drop-logging live here.
  networking.firewall.enable = true;
  networking.firewall.logReversePathDrops = true;

  # ====================================================================================================================
  # APPARMOR
  # ====================================================================================================================
  security.apparmor.enable = true;

  # AppArmor can only confine *new* processes against a profile - a process already running when
  # a profile is (re)loaded stays unconfined until it restarts. This sends those a SIGTERM so
  # they restart confined instead of silently running outside their profile after an update.
  security.apparmor.killUnconfinedConfinables = true;

  # Cache compiled profiles in /var/cache/apparmor so reboots/rebuilds don't recompile every
  # profile from scratch each time.
  security.apparmor.enableCache = true;

  # ====================================================================================================================
  # KERNEL SYSCTL HARDENING (MERGED CLEANLY)
  # ====================================================================================================================
  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.unprivileged_bpf_disabled" = 1;
    "net.core.bpf_jit_harden" = 2;
  };

  # ====================================================================================================================
  # POLKIT
  # ====================================================================================================================
  security.polkit.enable = true;

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
        action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
        action.id == "org.freedesktop.login1.suspend" ||
        action.id == "org.freedesktop.login1.hibernate"
      ) {
        if (subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      }
    });
  '';

  # ====================================================================================================================
  # SUDO
  # ====================================================================================================================
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;

    extraConfig = ''
      Defaults lecture = always
      Defaults timestamp_timeout = 0
    '';
  };

  # ====================================================================================================================
  # LOGIND
  # ====================================================================================================================
  services.logind.settings.Login = {
      HandlePowerKey = "poweroff";
      HandleRebootKey = "reboot";
  };

  # ====================================================================================================================
  # USER ISOLATION (FIXED: removed invalid option)
  # ====================================================================================================================
  #security.protectKernelLogs = true;
  #security.protectHostname = true;
  #security.protectKernelTunables = true;
  #security.restrictNamespaces = true;

  # NOTE: removed invalid:
  # security.protectControlGroups (does NOT exist in nixpkgs)
}
