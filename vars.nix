# vars.nix - Global variables shared by NixOS modules and home-manager.
# Edit this file to personalise the system without touching module internals.
{
  # Replace these example values before deploying.
  userName = "nixos";
  userEmail = "user@example.com";

  gitName = "NixOS User";

  location = {
    timezone = "Etc/UTC";
    city     = "Example City";
  };

  # Default terminal emulator used by Hyprland keybinds, Noctalia launcher, etc.
  terminal = "foot";

  # Default file manager
  fileManager = "thunar";

  # Wallpaper used to seed hyprpaper, waypaper, and matugen.
  wallpaperDir  = "/home/nixos/Pictures/Wallpapers";
  wallpaperFile = "wallpaper.jpg";

  # Default browser (privacy-focused). Set as the XDG default in hosts/nixos/default.nix
  # and used by Hyprland/shell keybinds ($mainMod, B).
  browser = "librewolf";

  # Desktop shell selection. Options:
  #  - "noctalia"   -> Noctalia Shell
  #  - "dank"       -> DankMaterialShell (DMS)
  #  - "caelestia"  -> Caelestia Shell (quickshell-based, minimal/squarish default look)
  desktopShell = "caelestia";

  # Hyprland config format selection. Options:
  #  - "hyprlang"      -> current hyprlang format
  #  - "hyprlandlua"   -> Hyprland Lua-based config (if your hyprland/home-module supports it)
  hyprConfig = "hyprlang";
}
