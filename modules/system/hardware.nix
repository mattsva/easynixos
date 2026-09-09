# modules/system/hardware.nix
# ------------------------------------------------------------------------------------------------------------------------
# GPU, CPU microcode, hardware acceleration, and power management.
# Configured for an Intel + NVIDIA PRIME Offload laptop.
# ------------------------------------------------------------------------------------------------------------------------
{ config, lib, pkgs, ... }:

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
  services.xserver.videoDrivers = lib.mkForce [ "modesetting" "nvidia" ];

  # NVIDIA driver --------------------------------------------------------------------------------------------------------
  # Using PRIME Offload: iGPU is used by default; dGPU activated on demand
  # with `nvidia-offload <program>` or per-app via DRI_PRIME=1.
  hardware.nvidia = {
    modesetting.enable = true;

    # Fine-grained power management: dGPU fully powers down when idle.
    # Requires kernel ≥ 5.5 and a supported GPU.
    powerManagement.enable           = true;
    powerManagement.finegrained      = true;

    # Use the proprietary driver (better performance + CUDA support)
    open = false;
    nvidiaSettings = true;

    prime = {
      offload = {
        enable           = true;
        enableOffloadCmd = true;  # installs `nvidia-offload` helper
      };

      # Bus IDs - verify with `lspci | grep -E "VGA|3D"`
      intelBusId  = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Power management -----------------------------------------------------------------------------------------------------
  services.power-profiles-daemon.enable = true;
  services.upower.enable                = true;

  # Firmware -------------------------------------------------------------------------------------------------------------
  hardware.enableRedistributableFirmware = true;
}
