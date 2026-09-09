# modules/packages/base.nix
# ========================================================================================================================
# Essential CLI utilities, browsers, and everyday desktop applications.
# This module provides the core tooling for general system use.
# ========================================================================================================================
{ pkgs, inputs, ... }:

{
  # ====================================================================================================================
  # FLATPAK SUPPORT
  # ====================================================================================================================
  # Flatpak: Container-based application isolation for desktop apps
  # Flathub: Primary Flatpak repository (Linux App Store)
  # Pre-installed: Lumi (PDF reader via Flatpak)
  services.flatpak = {
    enable = true;

    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    packages = [
      #"fi.lumi.Lumi"  # Lightweight PDF reader
    ];
  };

  environment.systemPackages = with pkgs; [

    # ====================================================================================================================
    # BROWSERS
    # ====================================================================================================================
    # LibreWolf: hardened Firefox fork (Firefox privacy patches, no telemetry, uBlock Origin
    # baked in, resist-fingerprinting on by default). Set as the default browser in
    # hosts/nixos/default.nix via xdg.mime.defaultApplications and bound to $mainMod+B.
    librewolf

    # Tor Browser: for when you need actual anonymity, not just reduced tracking.
    tor-browser

    # Google Chrome: kept only for the handful of sites that misbehave on Gecko engines.
    # Not the default - launch explicitly when you need it.
    google-chrome

    # Stock Firefox kept as a compatibility fallback (some enterprise/DRM sites, WebExtensions
    # that assume Firefox). LibreWolf remains the daily driver.
    firefox

    # ====================================================================================================================
    # SHELL & CORE CLI UTILITIES
    # ====================================================================================================================
    # Version control & code
    git         # Distributed version control

    # Download utilities
    wget        # Non-interactive network downloader
    curl        # Data transfer via URLs (also used as library)

    # System monitoring
    htop        # Interactive process viewer (classic)
    btop        # Modern system monitor with GPU support

    # Archive management
    unzip       # Extract ZIP files
    zip         # Create ZIP files
    p7zip       # 7-Zip compression utility

    # File utilities
    file        # Determine file types
    tree        # Show directory tree
    ripgrep     # Fast, recursive grep alternative (rg)
    fd          # Fast find replacement (fd)
    bat         # Syntax-highlighted cat alternative
    eza         # Modern ls replacement (exa fork)
    fzf         # Fuzzy file finder for CLI

    # Data processing
    jq          # Query and manipulate JSON
    yq          # Query and manipulate YAML

    # Documentation
    tldr        # Simplified man pages (examples)
    man-db      # Manual pages database

    # ====================================================================================================================
    # SYSTEM UTILITIES
    # ====================================================================================================================
    # Disk management
    gparted     # Graphical disk partitioning tool

    # USB utilities
    usbutils    # lsusb - list USB devices
    pciutils    # lspci - list PCI devices

    # Process & system introspection
    lsof        # List open files (diagnose file descriptor issues)
    strace      # System call tracer (debug programs)
    dconf       # GNOME settings backend (needed by GTK apps)

    # ====================================================================================================================
    # NETWORK UTILITIES
    # ====================================================================================================================
    networkmanagerapplet   # NM system tray icon for network switching
    speedtest-cli          # Test internet speed from CLI
    openssh                # SSH client and server
    sshfs                  # Mount remote filesystems over SSH
    fuse3                  # Userspace filesystem support

    # ====================================================================================================================
    # PRODUCTIVITY & COMMUNICATION
    # ====================================================================================================================
    libreoffice            # Office suite (LibreOffice: Writer, Calc, Impress)
    thunderbird            # Email and calendar client

    # ====================================================================================================================
    # FONTS
    # ====================================================================================================================
    noto-fonts             # Google Noto font family (comprehensive Unicode coverage)
    noto-fonts-color-emoji # Color emoji fonts
    noto-fonts-cjk-sans    # CJK (Chinese, Japanese, Korean) fonts

    # Nerd Fonts: Monospace fonts with additional glyphs for terminal/UI
    pkgs.nerd-fonts.jetbrains-mono  # JetBrains Mono (development)
    pkgs.nerd-fonts.fira-code       # Fira Code (clean, readable)
    pkgs.nerd-fonts.hack            # Hack (technical programming)

    # ====================================================================================================================
    # SYSTEM INFORMATION
    # ====================================================================================================================
    cowsay      # Print ASCII art with text (fun!)
    fastfetch   # System information display (fast alternative to neofetch)

    # ====================================================================================================================
    # KERNEL & DEVELOPMENT UTILITIES
    # ====================================================================================================================
    linuxPackages.kernel.dev  # Linux kernel development headers

    # ====================================================================================================================
    # MISCELLANEOUS UTILITIES
    # ====================================================================================================================
    khal                   # Calendar utility
    steam-run              # Container for running Steam games outside Steam
    texmaker               # LaTeX editor
    texliveFull            # Full TeX Live distribution

    # ====================================================================================================================
    # SECURITY & PASSWORD MANAGEMENT
    # ====================================================================================================================
    bitwarden-cli          # Command-line password manager
    bitwarden-desktop      # Desktop password manager GUI
    proton-pass            # Proton's password manager

    # ====================================================================================================================
    # MULTIMEDIA & MUSIC
    # ====================================================================================================================
    ncspot                 # Spotify TUI client
    spotifyd               # Spotify daemon (headless player)
    pipewire               # Audio server (already configured in audio.nix but included for completeness)

    # ====================================================================================================================
    # DISK USAGE & FILE ANALYSIS
    # ====================================================================================================================
    qdirstat               # Disk usage analyzer with visual tree
    kdePackages.filelight  # KDE disk usage analyzer

    # ====================================================================================================================
    # REFERENCE & KNOWLEDGE MANAGEMENT
    # ====================================================================================================================
    zotero                 # Reference manager for research
    foliate                # E-book reader
    appflowy               # Open-source Notion alternative
    onlyoffice-desktopeditors  # Office suite (lighter alternative to LibreOffice)
    kiwix                  # Offline content browser (Wikipedia, etc.) - see offline-content.nix

    # ====================================================================================================================
    # TEXT-TO-SPEECH & ACCESSIBILITY
    # ====================================================================================================================
    piper-tts              # Multi-language TTS (text-to-speech)

    # ====================================================================================================================
    # NOTE-TAKING & KNOWLEDGE BASE
    # ====================================================================================================================
#    logseq                 # Outliner and knowledge base
    affine                 # Collaborative canvas app (open-source)
    siyuan                 # Personal knowledge management
#    joplin-desktop         # Note-taking and to-do app

    # ====================================================================================================================
    # OTHER UTILITIES
    # ====================================================================================================================
    syncthing              # File synchronization across devices (decentralized)
    hyperfine

    maigret


    qt6Packages.qt6ct
#    kdePackages.qt6ct-kde

  ];

}

