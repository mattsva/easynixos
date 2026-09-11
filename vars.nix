# vars.local.nix — ACTUAL VALUES (git-ignored)
# ------------------------------------------------------------------------------------------------------------------------
# This file holds your real machine-specific settings. It is NOT committed.
# Copy from vars.nix (the example template) when adding new options.
# ------------------------------------------------------------------------------------------------------------------------
{
  userName = "mattsva";
  userEmail = "mattsva@proton.me";
  gitName = "mattsva";

  hostName = "unknown";
  keyboardLayout = "us";

  location = {
    timezone = "Europe/Berlin";
    city = "Berlin";
  };

  terminal = "kitty";
  fileManager = "nemo";

  wallpaperDir  = "/home/mattsva/Pictures/Wallpapers";
  wallpaperFile = "wallpaper.jpg";

  browser = "librewolf";

  desktopShell = "noctalia";
  hyprConfig = "hyprlua";

  autoUpdateEnabled = true;
  autoUpdateInterval = "weekly";
  autoUpdateTime = "03:00";

  securityTools = false;

  nvidiaBusId = "PCI:1:0:0";
  intelBusId  = "PCI:0:2:0";

  monitors = [
    {
      output = "eDP-1";
      mode = "1920x1080@144";
      position = "0x0";
      scale = "1";
      transform = "0";
    }
  ];
}
