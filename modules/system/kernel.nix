{ config, pkgs, lib, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    "nvme_core.default_ps_max_latency_us=5500"
    "quiet"
    "splash"
    "mem_sleep_default=deep"
    "transparent_hugepage=madvise"
    "intel_pstate=hwp_dynamic_boost=1"
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  powerManagement.cpuFreqGovernor = "schedutil";

  # Option A: TLP (recommended for laptops, advanced power tuning)
  services.tlp.enable = true;

  # Option B (alternative, NOT recommended together with TLP):
  # powerManagement.powertop.enable = true;
}
