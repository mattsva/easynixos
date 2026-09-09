# home/shell.nix
# ========================================================================================================================
# Shell configuration: Fish shell, Starship prompt, Atuin history, Direnv, Git setup
# ========================================================================================================================
{ config, pkgs, vars, ... }:

{
  # ====================================================================================================================
  # FISH SHELL: Modern, user-friendly shell with built-in features
  # ====================================================================================================================
  programs.fish = {
    enable = true;

    # ====================================================================================================================
    # Aliases & Abbreviations
    # ====================================================================================================================
    # Use `shellAbbrs` instead of aliases for expandable abbreviations that show the command before execution.
    # Abbreviations are more user-friendly than aliases in interactive use.
    shellAbbrs = {
      # Directory navigation
      ".."   = "cd ..";
      "..."  = "cd ../..";

      # Listing & viewing
      ls     = "eza --icons";                    # Modern ls replacement
      ll     = "eza -la --icons --git";         # Long listing with git status
      lt     = "eza --tree --icons";            # Tree view
      cat    = "bat --paging=never";            # Syntax-highlighted cat
      less   = "bat";                           # Use bat for paging

      # Searching & finding
      grep   = "rg";                            # Fast grep replacement (ripgrep)
      find   = "fd";                            # User-friendly find replacement

      # Git shortcuts
      g      = "git";
      gs     = "git status";
      ga     = "git add";
      gc     = "git commit";
      gp     = "git push";
      gpl    = "git pull";
      gl     = "lazygit";                       # TUI git client

      # NixOS management
      nr     = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";       # Rebuild & switch
      nrt    = "sudo nixos-rebuild test --flake /etc/nixos#nixos";        # Test rebuild (temporary)
      nrb    = "sudo nixos-rebuild boot --flake /etc/nixos#nixos";        # Rebuild for next boot
      nfu    = "nix flake update /etc/nixos";                             # Update flake inputs
      ncg    = "sudo nix-collect-garbage -d";                            # Garbage collect
      # update the installed repository and rebuild it
      update = "sudo nix flake update --flake /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos#nixos";

      # Hardware & system
      gpu    = "nvidia-offload";

      # Editors
      v      = "hx";
      vi     = "hx";
    };

    interactiveShellInit = ''
      # ====================================================================================================================
      # Shell Initialization Settings
      # ====================================================================================================================
      # Disable greeting message
      set -g fish_greeting ""

      # Vi key bindings (commented - uncomment if you prefer vim-style editing)
      # fish_vi_key_bindings

      # Load direnv hook for automatic environment switching
      direnv hook fish | source

      # Atuin setup - enhanced shell history with search
      atuin init fish | source
    '';
  };

  # ====================================================================================================================
  # STARSHIP: Cross-shell prompt written in Rust
  # ====================================================================================================================
  # Beautiful, fast prompt with git status, language versions, and custom symbols.
  # Displays at-a-glance information about your current directory and project.
  #programs.starship = {
  #  enable = true;
  #  settings = {
  #    # General prompt settings
  #    add_newline = false;                       # No extra blank line before prompt
  #    
  #    # Prompt character: changes color based on last command exit status
  #    character = {
  #      success_symbol = "[❯](bold green)";      # Green for successful commands
  #      error_symbol   = "[❯](bold red)";        # Red for failed commands
  #    };

  #    # Module-specific customizations
  #    nix_shell.symbol            = " ";         # Nix snowflake symbol
  #    git_branch.symbol           = " ";         # Git branch symbol
  #    directory.truncation_length = 3;           # Truncate deep paths to 3 components

      # Optional: customize other modules
      # git_status.disabled = false;
      # rust.disabled = false;
      # python.disabled = false;
  #  };
  #};

  # ====================================================================================================================
  # ATUIN: Enhanced Shell History
  # ====================================================================================================================
  # Replaces shell history with a local SQLite database for powerful search and filtering.
  # Features:
  # - Full-text search of command history
  # - Filter by exit code, directory, hostname
  # - Sync history across machines (optional)
  # - Statistics and insights about your command usage
  #
  # Usage:
  # - Ctrl+R: interactive search through history
  # - atuin history list: show recent commands
  # - atuin history search <query>: search for specific commands
  programs.atuin = {
    enable = true;
    settings = {
      # Auto-login for seamless history sync (set to false for local-only)
      auto_sync = false;

      # Search mode: 'fuzzy' for interactive search, 'skim' for more advanced filtering
      search_mode = "fuzzy";

      # Sync server details (leave commented for local-only mode)
      # sync_address = "https://api.atuin.sh";
      # sync_username = "${vars.userName}";
    };
  };

  # ====================================================================================================================
  # DIRENV: Environment Variable Management
  # ====================================================================================================================
  # Automatically load/unload environment variables from .envrc files based on directory.
  # Integrated with nix-direnv for seamless Nix environment activation.
  # Example .envrc:
  #   use nix
  #   export API_KEY="secret"
  #   export DATABASE_URL="postgres://..."
  programs.direnv = {
    enable            = true;
    nix-direnv.enable = true;  # Optimized Nix integration
  };

  # ====================================================================================================================
  # GIT: Version Control Configuration
  # ====================================================================================================================
  # Global Git settings and user identity.
  programs.git = {
    enable   = true;
    settings = {
      user.name          = vars.gitName;        # Name for commits
      user.email         = vars.userEmail;      # Email for commits
      init.defaultBranch = "main";              # Default branch for new repos
      pull.rebase        = false;               # Use merge strategy for pulls
      core.editor        = "hx";               # Use Helix for commit messages
    };
  };

}

