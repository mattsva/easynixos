# modules/system/audio.nix
# ------------------------------------------------------------------------------------------------------------------------
# PipeWire audio server with PulseAudio and ALSA compatibility layers.
# Also handles Bluetooth audio (A2DP, HFP via PipeWire).
# ------------------------------------------------------------------------------------------------------------------------
{ config, pkgs, ... }:

{
  # PipeWire -------------------------------------------------------------------------------------------------------------
  # Real-time audio/video server - replaces PulseAudio and JACK.
  services.pipewire = {
    enable            = true;
    pulse.enable      = true;   # PulseAudio compatibility (for most apps)
    alsa.enable       = true;   # ALSA compatibility (for legacy/native apps)
    alsa.support32Bit = true;   # 32-bit ALSA (Steam games, Wine)
    jack.enable       = true;   # JACK compatibility (DAWs)

    # Let WirePlumber manage ALSA profiles and ports automatically.
    # This keeps HDMI/DisplayPort, analog speakers and other outputs
    # available for selection instead of forcing one output.
    wireplumber.extraConfig."10-alsa-config" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              "device.name" = "alsa_card.pci-0000_00_1f.3";
            }
          ];

          actions = {
            update-props = {
              "api.acp.auto-profile" = true;
              "api.acp.auto-port" = true;
            };
          };
        }
      ];
    };

    # Low-latency tuning - adjust if you experience audio glitches.
    # extraConfig.pipewire."92-low-latency" = {
    #   context.properties = {
    #     default.clock.rate         = 48000;
    #     default.clock.quantum      = 64;
    #     default.clock.min-quantum  = 64;
    #     default.clock.max-quantum  = 64;
    #   };
    # };
  };

  # RTKit gives PipeWire real-time CPU scheduling priority.
  security.rtkit.enable = true;

  # Bluetooth ------------------------------------------------------------------------------------------------------------
  hardware.bluetooth = {
    enable      = true;
    powerOnBoot = true;

    settings.Policy.AutoEnable = "true";
  };

  # Blueman: system tray applet for Bluetooth management.
  services.blueman.enable = true;

  # Audio-related packages ----------------------------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    jack2
    pipewire
    pipewire.jack
  ];
}
