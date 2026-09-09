# modules/packages/development.nix
# ========================================================================================================================
# Development tools: editors, compilers, language runtimes, containers, databases.
# 
# Editors: VSCodium, Helix, and Emacs
# Languages: Python, JavaScript/Node.js, Rust, Go, Java, LLVM
# Tools: Git, Docker, Kubernetes, databases, API clients, debuggers
# ========================================================================================================================
{ pkgs, vars, ... }:

{
  # ====================================================================================================================
  # Documentation Settings
  # ====================================================================================================================
  # Disable generated docs to reduce store bloat. Use tldr/man-db from CLI instead.
  documentation = {
    enable = false;
    dev.enable = false;
    doc.enable = false;
    man.enable = false;
    man.generateCaches = false;
    nixos.enable = false;
  };

  environment.systemPackages = with pkgs; [

    quickshell

    # ====================================================================================================================
    # EDITORS & TERMINALS
    # ====================================================================================================================
    # VSCodium: Open-source VS Code without Microsoft telemetry.
    # Keep VSCodium and skip the redundant Microsoft build.
    vscodium
    # vscode  # Uncomment only if you specifically need the Microsoft build

    # Helix: modal editor with built-in language-server support.
    helix

    # Emacs: extensible editor and development environment.
    emacs

    # Tmux: Terminal multiplexer. Configured below with battery status plugin.
    tmux

    # ====================================================================================================================
    # BUILD TOOLS & COMPILER INFRASTRUCTURE
    # ====================================================================================================================
    gcc
    clang
    gnumake
    cmake
    ninja
    pkg-config
    autoconf
    automake
    bc
    flex
    bison
    xorriso
    grub2
    grub2_efi
    elfutils
    openssl
    nasm
    fakeroot
    gtk4
    wrapGAppsHook4
    qemu

    harfbuzz
    freetype
    fontconfig

    cacert # needed for certificates for python requests

    # ====================================================================================================================
    # NIX-SPECIFIC TOOLING
    # ====================================================================================================================
    nil              # Nix language server (LSP for editors)
    nixfmt           # Official Nix code formatter
    nix-tree         # Visualize Nix store dependency trees
    nix-du           # Disk usage analyzer for Nix store

    # ====================================================================================================================
    # PYTHON & DATA SCIENCE
    # ====================================================================================================================
    (python3.withPackages (ps: with ps; [
      pip              # Package manager
      virtualenv       # Virtual environments
      numpy            # Numerical computing
      requests         # HTTP library
      pillow           # Image processing
      matplotlib       # Plotting
      django           # Web framework
      textual          # TUI framework
      pyyaml           # YAML parsing
      # manim disabled temporarily because it pulls cloup and triggers the current Python build issue
      flask            # Lightweight web framework
      flask-socketio   # WebSocket for Flask
      setuptools       # Package setup tools
      pysocks          # SOCKS proxy support
      stem             # Tor controller
    ]))

    # OCR & Computer Vision
    tesseract        # Optical character recognition
    opencv           # Computer vision library
    libGL            # OpenGL support
    stdenv.cc.cc.lib
    zlib
    glib

    # ====================================================================================================================
    # JAVASCRIPT / NODE.JS
    # ====================================================================================================================
    nodejs_22        # Node.js runtime
    # npm              # npm comes bundled with nodejs_22
    # nodejs_22.pnpm   # Uncomment for pnpm package manager
    # nodejs_22.yarn   # Uncomment for yarn package manager
    sccache          # Shared compilation cache

    # ====================================================================================================================
    # RUST TOOLCHAIN
    # ====================================================================================================================
    rustup           # Rust toolchain manager (handles multiple versions)

    # ====================================================================================================================
    # GO TOOLCHAIN
    # ====================================================================================================================
    go               # Go compiler & runtime

    # ====================================================================================================================
    # JAVA TOOLCHAIN
    # ====================================================================================================================
    jdk21            # Java Development Kit

    # ====================================================================================================================
    # VERSION CONTROL & UTILITIES
    # ====================================================================================================================
    gh               # GitHub CLI tool
    lazygit          # TUI Git client
    git              # Git version control

    # ====================================================================================================================
    # CONTAINERS & VIRTUALIZATION
    # ====================================================================================================================
    docker-compose   # Docker Compose for multi-container apps
    kubectl          # Kubernetes command-line tool
    k9s              # Kubernetes TUI dashboard
    # Docker daemon enabled below via virtualisation.docker

    # ====================================================================================================================
    # DATABASE CLIENTS
    # ====================================================================================================================
    sqlite           # SQLite CLI
    postgresql       # PostgreSQL client (psql)
    dbeaver-bin      # Universal database GUI client

    # ====================================================================================================================
    # API & HTTP TESTING TOOLS
    # ====================================================================================================================
    curl             # HTTP client (already in base, but needed here)
    httpie           # User-friendly curl alternative
    insomnia         # API client GUI (like Postman, open-source)

    # ====================================================================================================================
    # DEBUGGING & PROFILING
    # ====================================================================================================================
    gdb              # GNU debugger
    valgrind         # Memory profiling & debugging
    hyperfine        # CLI benchmarking tool
    # ====================================================================================================================
    # STORAGE CLEANUP & DISK ANALYSIS
    # ====================================================================================================================
    duf              # Friendly disk usage summary
    ncdu             # Interactive disk usage analyzer
    fdupes           # Find duplicate files
    baobab           # GNOME disk usage analyzer
    bleachbit        # Cleaner for caches/temp files
    # ====================================================================================================================
    # GAME DEVELOPMENT
    # ====================================================================================================================
    # godot_4          # Disabled: optional, can be re-enabled if you need it

    # ====================================================================================================================
    # EMBEDDED & HARDWARE
    # ====================================================================================================================
    # arduino          # Disabled: old IDE, use arduino-ide instead
    arduino-ide      # Arduino IDE (newer version)
    arduino-cli

    # ====================================================================================================================
    # LINUX KERNEL DEVELOPMENT UTILITIES
    # ====================================================================================================================
    ncurses          # Terminal UI library
    # Note: gcc, gnumake, bison, flex, openssl, elfutils already listed above

    # ====================================================================================================================
    # MULTIMEDIA LIBRARIES (for Firefox/Zen builds)
    # ====================================================================================================================
    alsa-lib         # ALSA audio library
    alsa-utils       # ALSA utilities
    alsa-lib.dev     # ALSA development files

    typos
    vale

 ];

  # ====================================================================================================================
  # NVIDIA GPU SETTINGS
  # ====================================================================================================================
  hardware.nvidia.modesetting.enable = true;

  # ====================================================================================================================
  # OLLAMA: Local LLM Server with GPU Acceleration
  # ====================================================================================================================
  # Ollama runs multiple language models locally with CUDA GPU support.
  # Web UI: Open WebUI (http://localhost:8080)
  # API: http://localhost:11434/api/generate
  # Command-line: ollama run <model>
  #
  # Model Selection Strategy:
  # - mistral: Fast, good general-purpose model (7B, ~4.1GB)
  # - neural-chat: Optimized for conversation (7B, ~4.1GB)
  # - orca-mini: Lightweight, good reasoning (3B, ~1.7GB)
  # - llama2: Solid fallback, very stable (7B, ~3.8GB)
  # - codegemma: Specialized for code generation (7B, ~4.0GB)
  # - nomic-embed-text: Text embeddings for RAG/search (274M, ~274MB)
  # - mxbai-embed-large: Larger embeddings (335M, ~335MB)
  #
  # Load time depends on RAM. Keep total under your VRAM capacity.
  # Current selection: ~13-15GB total (fits on modern GPUs).
  services.ollama = {
    enable = true; # re-enabled per user request
    package = pkgs.ollama-cuda; # keep CUDA package if you have NVIDIA GPU

    # Models to preload on startup. Comment out unused models to free VRAM.
    loadModels = [
      "mistral:latest"           # 7B - Fast, balanced, best for general use
      "neural-chat:latest"       # 7B - Conversation-optimized
      "orca-mini:3b"             # 3B - Lightweight, good reasoning
      "codegemma:latest"         # 7B - Code generation specialist
      "nomic-embed-text:latest"  # 274M - Text embeddings for search/RAG
    ];

    # No serviceConfig here — set systemd service options below instead.
  };

  # Ensure the generated systemd unit runs as the correct user and has needed env
  systemd.services.ollama.serviceConfig = {
    User = vars.userName;
    Environment = [ "HOME=/home/${vars.userName}" "OLLAMA_NUM_GPU=999" "CUDA_VISIBLE_DEVICES=0" ];
  };

  # ====================================================================================================================
  # OPEN-WEBUI: Web Interface for Ollama
  # ====================================================================================================================
  # User-friendly web UI for interacting with Ollama models.
  # Access: http://localhost:8080
  # Supports:
  # - Chat interface with all loaded models
  # - Model management
  # - Conversation history
  # - API integration
  services.open-webui = {
    enable = false; # disabled temporarily to avoid Python build/service failures during debugging
    port = 8080;
    # openaiAPIKey can be set here if integrating with OpenAI alongside Ollama
  };

  # ====================================================================================================================
  # SEARX: Private Meta-Search Engine
  # ====================================================================================================================
  # Self-hosted, privacy-respecting search engine that aggregates results from multiple sources.
  # Access: http://localhost:8069
  # Features:
  # - No tracking, no profiling
  # - Respects Do Not Track requests
  # - Query anonymization
  # - Multiple language support (DE, EN configured)
  # Enable Searx only after providing a private server.secret_key in a local
  # module. This keeps reusable credentials out of the public flake and Nix store.
  services.searx.enable = false;

  # ====================================================================================================================
  # DOCKER: Container Runtime & Virtualization
  # ====================================================================================================================
  # Docker daemon for containerized development and deployment.
  # The configured user is in the "docker" group (set in modules/system/user.nix).
  # Note: Starts on first docker command, not automatically at boot.
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;  # Lazy-load: start on first docker command
  };

  # ====================================================================================================================
  # VIRTUALBOX: Virtual Machine Hypervisor
  # ====================================================================================================================
  # VirtualBox for running virtual machines.
  # User added to vboxusers group for hardware acceleration.
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ vars.userName ];

  # ====================================================================================================================
  # DIRENV: Environment Switching
  # ====================================================================================================================
  # Automatically load/unload environment variables based on .envrc files.
  # Integrated with nix-direnv for Nix flake environments.
  # (Home-manager configuration in home/shell.nix)
  programs.direnv.enable = true;

  # ====================================================================================================================
  # TMUX: Terminal Multiplexer
  # ====================================================================================================================
  # Terminal multiplexer with battery status in status bar.
  # Keybinds: Prefix is Ctrl+b by default
  # Session management: tmux new-session -s <name>
  programs.tmux = {
    enable = true;

    plugins = with pkgs.tmuxPlugins; [
      battery          # Show battery status in status bar
    ];

    extraConfig = ''
      # Status bar right side: show battery icon and percentage
      set -g status-right "#{battery_icon} #{battery_percentage}"
    '';
  };

  # ====================================================================================================================
  # TOR: Privacy-Focused Networking
  # ====================================================================================================================
  # Tor client for privacy-respecting network traffic.
  # Useful for security research, CTF, and privacy-sensitive operations.
  # Control port: 9051 (with cookie authentication)
  services.tor = {
    enable = true;
    client.enable = true;

    settings = {
      ControlPort = 9051;
      CookieAuthentication = true;
    };
  };


security.pki.certificateFiles = [
  pkgs.cacert
];

}
