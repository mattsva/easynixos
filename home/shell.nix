# home/shell.nix
# ========================================================================================================================
# Shell configuration: Fish shell, custom prompt, Atuin history, Direnv, Git setup
# ========================================================================================================================
{ config, pkgs, vars, ... }:

{
  # ── Fish prompt function (deployed via home.file, not programs.fish) ─────
  home.file.".config/fish/functions/fish_prompt.fish".source = ./functions/fish_prompt.fish;

  # ========================================================================================================================
  # FISH SHELL
  # ========================================================================================================================
  programs.fish = {
    enable = true;

    # Abbreviations
    shellAbbrs = {
      ".."   = "cd ..";
      "..."  = "cd ../..";
      ls     = "eza --icons";
      ll     = "eza -la --icons --git";
      lt     = "eza --tree --icons";
      cat    = "bat --paging=never";
      less   = "bat";
      grep   = "rg";
      find   = "fd";
      g      = "git";
      gs     = "git status";
      ga     = "git add";
      gc     = "git commit";
      gp     = "git push";
      gpl    = "git pull";
      gl     = "lazygit";
      nr     = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      nrt    = "sudo nixos-rebuild test --flake /etc/nixos#nixos";
      nrb    = "sudo nixos-rebuild boot --flake /etc/nixos#nixos";
      nfu    = "nix flake update /etc/nixos";
      ncg    = "sudo nix-collect-garbage -d";
      update = "sudo nix flake update --flake /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      gpu    = "nvidia-offload";
      v      = "hx";
      vi     = "hx";
    };

    interactiveShellInit = ''
      set -g fish_greeting ""
      # fish_vi_key_bindings  # uncomment for vi mode
      direnv hook fish | source
      atuin init fish | source
    '';
  };

  # ====================================================================================================================
  # ATUIN
  # ====================================================================================================================
  programs.atuin = {
    enable = true;
    settings = {
      auto_sync = false;
      search_mode = "fuzzy";
    };
  };

  # ====================================================================================================================
  # DIRENV
  # ====================================================================================================================
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ====================================================================================================================
  # GIT
  # ====================================================================================================================
  programs.git = {
    enable = true;
    settings = {
      user.name          = vars.gitName;
      user.email         = vars.userEmail;
      init.defaultBranch = "main";
      pull.rebase        = false;
      core.editor        = "hx";
      credential.helper  = "!gh auth git-credential";
    };
  };

  # ====================================================================================================================
  # FONT: LiberationMono Nerd Font
  # ====================================================================================================================
  home.packages = [ pkgs.nerd-fonts.liberation ];
}
