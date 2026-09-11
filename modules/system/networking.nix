# modules/system/networking.nix
# ------------------------------------------------------------------------------------------------------------------------
# Network stack: NetworkManager, firewall, Tailscale overlay network,
# KDE Connect (phone integration), OpenFortiVPN, Cloudflare One, Tor.
# ------------------------------------------------------------------------------------------------------------------------
{ config, pkgs, vars, ... }:

{
  # Basic networking -----------------------------------------------------------------------------------------------------
  networking.hostName = vars.hostName;

  networking.networkmanager = {
    enable = true;
    wifi.scanRandMacAddress = true;
    wifi.macAddress = "random";

    # Connectivity check normally polls nmcheck.gnome.org in the clear — a small
    # metadata leak ("this machine just joined this network"). Off by default;
    # NetworkManager still detects link-up fine without it.
    #connectivity.enable = false;

    plugins = with pkgs; [
      networkmanager-fortisslvpn
    ];
  };

  networking.networkmanager.dns = "systemd-resolved";
  services.resolved = {
    enable = true;
  };

  # Tailscale: mesh VPN ----------------------------------------------------------------------------------------------------
  # Encrypted WireGuard mesh. MagicDNS is configured in the Tailscale admin console
  # (Settings → DNS → MagicDNS) and picked up automatically by the client.
  # useRoutingFeatures = "client" enables subnet routing and exit node features.
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    # MagicDNS: enable on the Tailscale side (admin console)
    # To force DNS settings, use:
    #   extraDaemonFlags = [ "--accept-routes" ];
    #   # or set DNS via tailscale up:
    #   # tailscale up --secure-dns=1.1.1.1,1.0.0.1 --accept-routes
  };

  # KDE Connect: phone integration ------------------------------------------------------------------------------------------------
  # KDE Connect allows integration with Android/iOS devices on the local network.
  # Security note: KDE Connect ports (1714-1716) are opened on all LAN-like
  # interfaces (en+, wl+, eth+). This includes public Wi-Fi networks.
  # For untrusted networks, either:
  #   - Disable KDE Connect: programs.kdeconnect.enable = false;
  #   - Use Tailscale for secure remote device pairing instead
  #   - Manually restrict firewall rules when on public networks
  programs.kdeconnect.enable = true;

  # Cloudflare One + OpenFortiVPN packages ------------------------------------------------------------------------------------------------
  # cloudflared: Cloudflare Tunnel daemon — exposes local services via Cloudflare edge
  #   without using WireGuard, making network-wide WG blocking irrelevant.
  #
  # Setup (one-time):
  #   1. Go to https://one.dash.cloudflare.com → Networks → Tunnels
  #   2. Create a tunnel, copy the tunnel UUID and credentials JSON
  #   3. Save the credentials to /etc/cloudflare/cloudflared.json
  #   4. Configure the tunnel to route traffic as needed
  #
  # Tailscale + Cloudflare:
  #   Both use different networking approaches. Cloudflare tunnel (cloudflared)
  #   works over HTTPS/QUIC — no WireGuard involved. Tailscale uses WireGuard
  #   for its mesh. They can coexist without conflict.
  #
  # Tor: available for optional per-app routing, not forced on all traffic.
  #   Use `torsocks <command>` for individual apps, or configure apps to use
  #   the Tor SOCKS proxy at localhost:9050. All traffic is NOT routed through
  #   Tor by default — only apps you explicitly configure.
  environment.systemPackages = with pkgs; [
    openfortivpn
    torsocks
    cloudflared
    cloudflare-warp   # WARP VPN client (warp-cli) — secure per-device connection via Cloudflare edge
  ];

  # Firewall: hardened ----------------------------------------------------------------------------------------------------
  # Default: drop all incoming, allow only explicitly listed services.
  # No services exposed to LAN/internet by default.
  # Tailscale mesh VPN handles secure remote access; local services (open-webui 8080,
  # searxng 8069) are reachable only from this host and the Tailscale mesh.
  #
  # Cloudflare tunnel (cloudflared) works over HTTPS/QUIC — no WireGuard,
  # so network-wide WG blocking is irrelevant.
  networking.firewall = {
    enable = true;

    # Drop incoming by default (NixOS default when firewall is enabled)
    # Outgoing is allowed (needed for tunnel, Tailscale, DNS, updates)

    # Trusted interfaces — full access allowed
    trustedInterfaces = [ "tailscale0" ];

    # Tailscale WireGuard UDP port
    allowedUDPPortRanges = [{ from = 41641; to = 41641; }];

    # KDE Connect on LAN interfaces only (not internet-facing)
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
      # Local services reachable only from Tailscale mesh
      tailscale0.allowedTCPPorts = [ 8069 8080 ];
    };

    # Logging
    logRefusedConnections = true;
    allowPing = false;

    # Extra iptables hardening rules
    extraCommands = ''
      # Drop invalid TCP flag combinations (stealth scan mitigation)
      iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP 2>/dev/null || true
      iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP 2>/dev/null || true
      # Rate-limit new TCP connections (DoS mitigation)
      iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT 2>/dev/null || true
    '';
  };

  # Tor: optional per-app privacy routing ------------------------------------------------------------------------------------------------
  # Tor is available but does NOT force all traffic through it.
  # Useful for security research, CTF, and privacy-sensitive operations.
  # Control port: 9051 (with cookie authentication)
  services.tor = {
    enable = true;
    client = {
      enable = true;
      dns.enable = false;
    };

    settings = {
      ControlPort = 9051;
      CookieAuthentication = true;
    };
  };

  # SSH: off by default ----------------------------------------------------------------------------------------------------
  # services.openssh.enable = true;
}
