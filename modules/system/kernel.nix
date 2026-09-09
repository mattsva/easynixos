{ config, pkgs, lib, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelPatches = [
    {
      name = "balanced-efficiency";

      extraStructuredConfig = with lib.kernel; {

        PREEMPT_DYNAMIC = yes;
        HZ_250 = yes;

        CPU_FREQ = yes;
        CPU_FREQ_GOV_SCHEDUTIL = yes;
        CPU_IDLE = yes;
        CPU_IDLE_GOV_LADDER = yes;

        NO_HZ_FULL = no;
      };
    }
  ];

  powerManagement.cpuFreqGovernor = "schedutil";


  # Option A: TLP (recommended for laptops, advanced power tuning)
  services.tlp.enable = true;

  # Option B (alternative, NOT recommended together with TLP):
  # powerManagement.powertop.enable = true;

  boot.kernelParams = [
    "nvme_core.default_ps_max_latency_us=5500"
    "quiet"
  ];
}
