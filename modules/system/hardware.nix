# modules/system/hardware.nix
# ------------------------------------------------------------------------------------------------------------------------
# GPU, CPU microcode, hardware acceleration, and power management.
# Configured for an Intel + NVIDIA PRIME Offload laptop.
# ------------------------------------------------------------------------------------------------------------------------
{ config, lib, pkgs, vars, ... }:

{
  # OpenGL / Vulkan ------------------------------------------------------------------------------------------------------
  # Required for Wayland, hardware video decode, and Steam/Proton.
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;   # needed for Steam (32-bit Proton games)
  };

  # Intel microcode ------------------------------------------------------------------------------------------------------
  hardware.cpu.intel.updateMicrocode = true;

  # Load modesetting for the iGPU
  # Using Nouveau (open-source NVIDIA driver) for kernel compatibility.
  # NVIDIA 595.71.05 proprietary driver is incompatible with Linux 7.2.6 kernel.
  # To use proprietary driver: switch to nixos-25.11 stable channel or use
  # linuxPackages_24_11 for a compatible kernel/driver combination.
  services.xserver.videoDrivers = lib.mkForce [ "modesetting" "nouveau" ];

  # NVIDIA driver --------------------------------------------------------------------------------------------------------
  # Using Nouveau (open-source) driver for kernel compatibility.
  # The proprietary NVIDIA 595.71.05 driver is incompatible with Linux 7.2.6 kernel.
  # To use proprietary driver: switch to nixos-25.11 stable channel.
  # PRIME Offload: iGPU is used by default; dGPU activated on demand via DRI_PRIME=1.
  hardware.nvidia = {
    open = true;  # Use Nouveau open-source driver

    # Fine-grained power management (Nouveau supports this on supported GPUs)
    powerManagement.enable           = true;
    powerManagement.finegrained      = true;

    nvidiaSettings = false;  # nvidia-settings not available with Nouveau

    prime = {
      offload = {
        enable           = true;
        enableOffloadCmd = false;  # nvidia-offload not available with Nouveau
      };

      # Bus IDs - configured in vars.nix (vars.nvidiaBusId / vars.intelBusId)
      # Verify with `lspci | grep -E "VGA|3D"`
      intelBusId  = vars.intelBusId;
      nvidiaBusId = vars.nvidiaBusId;
    };
  };

  # Power management -----------------------------------------------------------------------------------------------------
  # TLP is enabled in kernel.nix — do NOT enable power-profiles-daemon alongside it.
  services.upower.enable                = true;

  # Swap file for large builds (256GB) -------------------------------------------------------------------------------
  swapDevices = [
    {
      device = "/swapfile";
      size = 262144;   # 256GB in MB
    }
  ];

  # Firmware -------------------------------------------------------------------------------------------------------------
  hardware.enableRedistributableFirmware = true;
}
