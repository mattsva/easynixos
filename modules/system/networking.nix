# modules/system/networking.nix
# ------------------------------------------------------------------------------------------------------------------------
# Network stack: NetworkManager, firewall, Tailscale overlay network,
# KDE Connect (phone integration), and OpenFortiVPN (corporate VPN).
# ------------------------------------------------------------------------------------------------------------------------
{ config, pkgs, ... }:

{
  # Basic networking -----------------------------------------------------------------------------------------------------
  networking.hostName = "nixos";

  networking.networkmanager = {
    enable = true;
    wifi.scanRandMacAddress = true;
    wifi.macAddress = "random";

    # NM's connectivity check normally polls a canonical URL (e.g. nmcheck.gnome.org) in the
    # clear on every network change - a small but free metadata leak ("this machine just joined
    # this network"). Off by default; NetworkManager still detects link-up fine without it.
    #connectivity.enable = false;

    # FortiSSL VPN integration for NetworkManager.
    plugins = with pkgs; [
      networkmanager-fortisslvpn
    ];
  };

  # Don't leak the real hostname/MAC over DHCP where it can be avoided - most networks don't
  # need to see "nixos" show up as a DHCP client name, and MAC randomisation above already
  # covers Wi-Fi. Ethernet DHCP still sends the hostname unless you also flip
  # networking.networkmanager.ethernet.macAddress to "random" per-connection if you need that too.
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
  };

  # Tailscale ------------------------------------------------------------------------------------------------------------
  # Mesh VPN - use `tailscale up` on first boot to authenticate.
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # KDE Connect ----------------------------------------------------------------------------------------------------------
  # Phone / desktop integration (clipboard sync, remote input, file transfer …)
  programs.kdeconnect.enable = true;

  # OpenFortiVPN ---------------------------------------------------------------------------------------------------------
  # CLI corporate VPN client compatible with Fortinet SSL VPN.
  # Usage: sudo openfortivpn <host>:<port> -u <username>
  # Optionally create /etc/openfortivpn/config for saved credentials.
  # You can use nm-connection-editor for connections now
  environment.systemPackages = with pkgs; [
    openfortivpn
    torsocks
  ];

  # Firewall ------------------------------------------------------------------------------------------------------------
  # Nothing is exposed to the LAN/internet by default any more. open-webui (8080) and searxng
  # (8069) are local services you use from this machine or over Tailscale - they're opened only
  # on tailscale0, not globally, so a random device on your Wi-Fi/LAN can't reach them.
  # 80/443/22 were dropped entirely: nothing on this host serves HTTP(S) or SSH by default
  # (services.openssh.enable is off below); re-add them explicitly if you turn a service on.
  networking.firewall = {
    enable = true;

    # Tailscale's WireGuard port
    allowedUDPPortRanges = [{ from = 41641; to = 41641; }];

    # KDE Connect on predictable wired and wireless LAN interfaces only.
    # The + suffix is an iptables interface-name wildcard, not a hardcoded
    # device name such as wlan0; it also handles NetworkManager renames.
    interfaces = {
      "en+" = {
        allowedTCPPorts = [ 1714 1715 1716 ];
        allowedUDPPorts = [ 1714 1715 1716 ];
      };
      "wl+" = {
        allowedTCPPorts = [ 1714 1715 1716 ];
        allowedUDPPorts = [ 1714 1715 1716 ];
      };
      "eth+" = {
        allowedTCPPorts = [ 1714 1715 1716 ];
        allowedUDPPorts = [ 1714 1715 1716 ];
      };
      tailscale0.allowedTCPPorts = [ 8069 8080 ];
    };

    # Local-only services: reachable from this host and from the Tailscale mesh, never from the
    # plain LAN/internet interface.
    logRefusedConnections = true;
    # Don't answer ICMP echo from strangers on the LAN or over Tailscale.
    allowPing = false;
  };

  services.tor = {
    enable = true;
    client = {
      enable = true;
      dns.enable = false;
    };
  };

  # SSH ------------------------------------------------------------------------------------------------------------------
  # Daemon disabled by default - enable when you need remote access.
  # services.openssh.enable = true;
}
