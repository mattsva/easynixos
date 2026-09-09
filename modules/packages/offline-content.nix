# modules/packages/offline-content.nix
# ========================================================================================================================
# Offline reference materials for local access without internet dependency.
# Includes Wikipedia and other compact offline resources via Kiwix.
# ========================================================================================================================
{ config, pkgs, lib, ... }:

let
  # Kiwix is a content server that allows access to offline resources like Wikipedia, Wiktionary, etc.
  # Install reference materials with `kiwix-manage` command-line tool.
  
in {
  environment.systemPackages = with pkgs; [

    # ====================================================================================================================
    # Kiwix: Offline Content Server
    # ====================================================================================================================
    # Web interface to browse Wikipedia, Wiktionary, and other resources offline.
    # UI runs on localhost:8080 by default.
    # Command: kiwix-serve ~/.local/share/kiwix/
    # 
    # Collections available:
    # - Wikipedia (English) ~87GB - Comprehensive encyclopedia
    # - Wiktionary (English) ~8GB - Dictionary and thesaurus
    # See: https://wiki.kiwix.org/wiki/Content_in_all_languages
    kiwix

    # kiwix-tools: CLI utilities for managing Kiwix content libraries.
    kiwix-tools

  ];

  # ====================================================================================================================
  # Systemd Service for Offline Content (Optional)
  # ====================================================================================================================
  # Uncomment below to run Kiwix as a background service.
  # This keeps the Kiwix server running and accessible via localhost:8080
  # 
  # systemd.user.services.kiwix-server = {
  #   Unit = {
  #     Description = "Kiwix Offline Content Server";
  #     After = [ "network-online.target" ];
  #     Wants = [ "network-online.target" ];
  #   };
  #   Service = {
  #     Type = "simple";
  #     ExecStart = "${pkgs.kiwix}/bin/kiwix-serve --port 8080 %h/.local/share/kiwix/";
  #     Restart = "on-failure";
  #   };
  #   Install = {
  #     WantedBy = [ "default.target" ];
  #   };
  # };

  # ====================================================================================================================
  # Setup Instructions for Offline Content
  # ========================================================================================================================
  # 
  # 1. WIKIPEDIA (English) - ~87GB
  #    Download: https://wiki.kiwix.org/wiki/Content_in_all_languages#english_wikipedia
  #    Save to: ~/.local/share/kiwix/wikipedia_en.zim
  # 
  # 2. WIKTIONARY (English) - ~8GB
  #    Download: https://wiki.kiwix.org/wiki/Content_in_all_languages#english_wiktionary
  #    Save to: ~/.local/share/kiwix/wiktionary_en.zim
  # 
  # Post-Download Setup:
  # - Place .zim files in ~/.local/share/kiwix/
  # - Run: kiwix-serve ~/.local/share/kiwix/
  # - Access: http://localhost:8080
  # - Configure systemd service (uncommented above) for auto-startup
  #
  # Storage Note:
  # Wikipedia + Wiktionary = ~95GB total
  # Consider using external storage if system drive is limited.
  # Mount point example: /mnt/offline-content
  # Then: kiwix-serve /mnt/offline-content/
  # 
  # ========================================================================================================================
}

