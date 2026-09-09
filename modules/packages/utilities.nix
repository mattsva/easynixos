# modules/packages/utilities.nix
# ========================================================================================================================
# Enhanced shell, version management, and quality-of-life CLI tools.
# These tools improve productivity and ergonomics without bloat.
# ========================================================================================================================
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # ====================================================================================================================
    # Version Management & Environment Switching
    # ====================================================================================================================
    # mise (formerly rtx): unified version manager for Python, Node.js, Ruby, Go, Rust, etc.
    # Simpler and faster than managing multiple version managers (pyenv, nvm, rbenv).
    # Declare versions in .mise.toml per-project for reproducible environments.
    mise

    # zoxide: smarter 'cd' replacement that learns your directory patterns.
    # 'z' becomes your new best friend. Especially powerful with fzf integration.
    zoxide

    # direnv: load/unload environment variables based on directory.
    # Already configured in home/shell.nix with nix-direnv integration.
    # Automatically activates .envrc files for project-specific setup.

    # ====================================================================================================================
    # Shell History & Enhancement
    # ====================================================================================================================
    # atuin: enhanced shell history with search, context, and local database.
    # Replaces default shell history with a searchable, timestamped version.
    # Sync across machines, filter by directory/exit code, and more.
    atuin

    # ====================================================================================================================
    # Prompt & Aesthetic
    # ====================================================================================================================
    # starship: cross-shell prompt written in Rust. Already configured in home/shell.nix.
    # Shows git status, language versions, and custom symbols elegantly.

    # ====================================================================================================================
    # Process & System Monitoring
    # ====================================================================================================================
    # procs: modern replacement for 'ps' with color and better default output.
    procs

    # bottom: fancy TUI system monitor (similar to htop but modern, already have btop though).
    # Keep btop as main alternative to htop.

    # tokei: count lines of code across projects (useful for metrics).
    tokei

    # ====================================================================================================================
    # Filesystem & Disk Management
    # ====================================================================================================================
    # dua: fast disk usage analyzer with interactive TUI.
    dua

    # ncdu: another disk usage analyzer option (lightweight).
    ncdu

    # ====================================================================================================================
    # Network & API Tools (beyond base curl/wget)
    # ====================================================================================================================
    # mtr: combined traceroute + ping tool for network diagnostics.
    mtr

    # bandwhich: real-time network bandwidth monitoring.
    bandwhich

    # JSON/YAML/Config Processing
    # ====================================================================================================================
    # dasel: query and update JSON/YAML/XML/CSV from CLI (like jq but multi-format).
    dasel

    # xml: command-line XML processor (streaming)
    # (xsv not available in nixpkgs - csv support via dasel instead)

    # ====================================================================================================================
    # Documentation & Learning
    # ====================================================================================================================
    # tealdeer: faster/better tldr pages client (already have tldr).
    # Can be used alongside tldr for comparison.

    # ====================================================================================================================
    # Misc Quality-of-Life Tools
    # ====================================================================================================================
    # hyperfine: command-line benchmarking (already in development.nix but useful enough to mention).

    # choose: alternative to cut/awk for text field extraction.
    choose

    # dust: more intuitive du (disk usage) for directories.
    dust

  ];
}
