# modules/packages/gaming.nix
# ------------------------------------------------------------------------------------------------------------------------
# Steam and gaming support.
# Proton (Windows compatibility layer) is bundled with Steam.
# ------------------------------------------------------------------------------------------------------------------------
{ pkgs, ... }:

{
  # Steam ----------------------------------------------------------------------------------------------------------------
  programs.steam = {
    enable                 = true;
    remotePlay.openFirewall = true;   # Steam Remote Play port
    dedicatedServer.openFirewall = true;
    # Proton-GE is installed as an additional Steam compatibility tool.
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    protontricks.enable = true;
  };

  # GameMode -------------------------------------------------------------------------------------------------------------
  # Optimise system performance while a game is running (CPU governor, etc.)
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    # MangoHud: in-game overlay for FPS, GPU/CPU usage, temps
    mangohud

    # Lutris: game manager for GOG, itch.io, emulators, etc.

    # Wine: run Windows games/apps outside of Steam
    wine
    winetricks
    protontricks

    # Heroic: Epic Games Store and GOG client
    heroic

    # Minecraft (via Flatpak - declared in services.nix)
    # Launch: flatpak run com.mojang.Minecraft
    prismlauncher
  ];
}
