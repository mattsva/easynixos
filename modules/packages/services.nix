# modules/packages/services.nix
# ------------------------------------------------------------------------------------------------------------------------
# System services: CUPS printing, Flatpak, GNOME online accounts.
# ------------------------------------------------------------------------------------------------------------------------
{ pkgs, ... }:

{
  # Printing (CUPS) ------------------------------------------------------------------------------------------------------
  services.printing = {
    enable = true;
    # Common printer drivers - add/remove as needed for your printer
    drivers = with pkgs; [
      gutenprint          # open-source drivers for many printers
      hplip               # HP printers
      epson-escpr         # Epson inkjets
      brlaser             # Brother laser printers
    ];
  };

  # Avahi: printer auto-discovery on the local network (mDNS / DNS-SD)
  services.avahi = {
    enable      = true;
    openFirewall = true;
    nssmdns4    = true;   # resolve .local hostnames
  };

  # Flatpak --------------------------------------------------------------------------------------------------------------
  # nix-flatpak module provides declarative Flatpak management.
  # Packages listed here are installed/kept in sync on every rebuild.
  services.flatpak = {
    enable = true;

    # Automatically add Flathub remote on activation
    remotes = [{
      name     = "flathub";
      location = "https://flathub.org/repo/flathub.flatpakrepo";
    }];

    packages = [
      # Minecraft Java Edition
      { appId = "com.mojang.Minecraft"; origin = "flathub"; }
      # Burp Suite Community (web security testing)
      { appId = "net.portswigger.BurpSuite-Community"; origin = "flathub"; }
    ];

    # Keep Flatpak apps up to date automatically
    update.auto = {
      enable    = true;
      onCalendar = "weekly";
    };
  };

  # GNOME services (needed by some GTK apps even on Hyprland) ------------------------------------------------------------
  # evolution-data-server: calendar / contacts backend (Thunderbird, GNOME Calendar)
  services.gnome.evolution-data-server.enable = true;
  # GNOME Online Accounts: Google, Nextcloud, Exchange integration
  services.gnome.gnome-online-accounts.enable = true;

  # Polkit ---------------------------------------------------------------------------------------------------------------
  # Required for GUI apps that need elevated privileges (GParted, etc.)
  security.polkit.enable = true;
}
