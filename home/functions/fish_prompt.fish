# ~/.config/fish/functions/fish_prompt.fish
# Prompt for mattsva's Noctalia-themed NixOS desktop.
# Reads colors from Noctalia's generated kitty theme.
# Derived from Noctalia's wallpaper-derived palette.

function fish_prompt
    # ── Read colors from Noctalia's generated kitty theme ──────────────
    set -l theme_file "$HOME/.config/kitty/themes/noctalia.conf"

    # Fallback colors (Noctalia dark purple theme)
    set -l pf "#cdd6f4"   # foreground
    set -l pcy "#89b4fa"  # blue
    set -l pg "#a6e3a1"   # green
    set -l pr "#f38ba8"   # red
    set -l pa "#b4befe"   # indigo/purple accent
    set -l pm "#6c7086"   # muted

    if test -f "$theme_file"
        set -l lines (cat "$theme_file" | string trim)
        for line in $lines
            set -l trimmed (string trim "$line")
            if test -z "$trimmed"
                continue
            end
            set -l parts (string split ' ' "$trimmed")
            switch "$parts[1]"
                case 'foreground'
                    set -l pf "$parts[2]"
                case 'color6'
                    set -l pcy "$parts[2]"
                case 'color4'
                    set -l pg "$parts[2]"
                case 'color9'
                    set -l pr "$parts[2]"
                case 'color13'
                    set -l pa "$parts[2]"
                case 'color8'
                    set -l pm "$parts[2]"
            end
        end
    end

    # ── User and host ────────────────────────────────────────────────────
    set -l user (whoami)
    set -l host (hostname | string split '.' | head -n 1)

    # ── Directory shortening ────────────────────────────────────────────
    set -l cwd (pwd)
    set -l home (string trim -c '/' -- $HOME)

    set -l shortened "$cwd"
    if string match -q "^$home/" "$cwd"; or test "$cwd" = "$home"
        if test "$cwd" = "$home"
            set -l shortened "~"
        else
            set -l rel (string replace -r "^$home/" "~/" "$cwd")
            set -l parts (string split '/' "$rel")
            set -l n (count $parts)
            if test "$n" -gt 0
                set -l result "~"
                for i in (seq 1 (math "$n - 1"))
                    set -l dir $parts[$i]
                    if test (string length "$dir") -gt 0
                        set -l result "$result/$dir[1]"
                    end
                end
                set -l result "$result/$parts[$n]"
                set -l shortened "$result"
            end
        end
    else
        set -l parts (string split '/' "$cwd")
        set -l n (count $parts)
        if test "$n" -gt 2
            set -l result ''
            for i in (seq 1 (math "$n - 1"))
                set -l dir $parts[$i]
                if test (string length "$dir") -gt 0
                    set -l result "$result/$dir[1]"
                end
            end
            set -l result "$result/$parts[$n]"
            set -l shortened "$result"
        end
    end

    # ── Environment indicators ───────────────────────────────────────────
    set -l env_tags
    if set -q __fish_nix_shell
        set -a env_tags '[nix]'
    end
    if set -q VIRTUAL_ENV
        set -l venv_name (string split '/' "$VIRTUAL_ENV" | last)
        if test "$venv_name" != "venv" -a "$venv_name" != ".venv" -a \
           "$venv_name" != "env" -a "$venv_name" != ".env"
            set -a env_tags "[$venv_name]"
        end
    end
    if set -q NODE_VERSION
        set -a env_tags '[node]'
    end
    if set -q RUSTUP_TOOLCHAIN
        set -a env_tags '[rust]'
    end
    if set -q GOENV
        set -a env_tags '[go]'
    end
    if set -q PIPENV_ACTIVE
        set -a env_tags '[pipenv]'
    end
    if set -q CONDA_DEFAULT_ENV
        set -a env_tags '[conda]'
    end
    if set -q npm_config_user_config
        set -a env_tags '[npm]'
    end

    set -l env_str ''
    if test (count $env_tags) -gt 0
        set -l env_str (string join ' ' $env_tags)
    end

    # ── First line: user@host cwd [env] ─────────────────────────────────
    set_color "$pf"
    echo -n "$user"
    set_color "$pm"
    echo -n '@'
    set_color "$pf"
    echo -n "$host "
    set_color "$pcy"
    echo -n "$shortened"
    if test -n "$env_str"
        set_color "$pg"
        echo -n ' '
        echo -n "$env_str"
    end
    set_color normal
    echo ''

    # ── Git info (second line) ─────────────────────────────────────────────
    set -l git_dir (git rev-parse --git-dir 2>/dev/null)
    if test -n "$git_dir"
        set remote_url (git remote get-url origin 2>/dev/null)
        set branch (git branch --show-current 2>/dev/null)
        set git_prefix 'git'
        set git_repo ''

        if test -n "$remote_url"
            # Strip .git suffix (use function-scoped set so it persists)
            if string match -rq '\.git$' "$remote_url"
                set -l stripped (string replace -r '\.git$' '' "$remote_url")
                set remote_url "$stripped"
            end

            # Extract host
            set -l https_host (string replace -r '^[^:]+://([^/]+)/.*' '\1' "$remote_url")
            if test "$https_host" != "$remote_url"
                set url_host "$https_host"
            end
            if test -z "$url_host"
                set -l ssh_host (string replace -r '^[^@]+@([^:]+):.*' '\1' "$remote_url")
                if test "$ssh_host" != "$remote_url"
                    set url_host "$ssh_host"
                end
            end

            # Determine prefix
            if test "$url_host" = "github.com"
                set git_prefix 'gh'
            else if test "$url_host" = "gitlab.com"
                set git_prefix 'gl'
            end

            # Extract repo path
            if string match -rq '^[^:]+://' "$remote_url"
                # HTTPS
                set -l no_scheme (string replace -r '^[^:]+://' '' "$remote_url")
                set -l parts (string split '/' "$no_scheme")
                set -l clean_parts
                for p in $parts
                    if test (string length "$p") -gt 0
                        set -a clean_parts $p
                    end
                end
                if test (count $clean_parts) -gt 0
                    if test "$git_prefix" = "gh" -o "$git_prefix" = "gl"
                        # GitHub/GitLab: skip host (index 1), take owner/repo (index 2+)
                        if test (count $clean_parts) -ge 2
                            set git_repo "$clean_parts[2]"
                            for i in (seq 3 (count $clean_parts))
                                set git_repo "$git_repo/$clean_parts[$i]"
                            end
                        end
                    else
                        # Other: full host/owner/repo
                        set git_repo "$clean_parts[1]"
                        for i in (seq 2 (count $clean_parts))
                            set git_repo "$git_repo/$clean_parts[$i]"
                        end
                    end
                end
            else if string match -rq '^[^@]+@' "$remote_url"
                # SSH: user@host:path
                set -l at_parts (string split '@' "$remote_url")
                if test (count $at_parts) -gt 1
                    set -l host_path "$at_parts[2]"
                    set -l colon_parts (string split ':' "$host_path")
                    if test (count $colon_parts) -gt 1
                        set ssh_host "$colon_parts[1]"
                        set ssh_path "$colon_parts[2]"
                        if test "$git_prefix" = "gh" -o "$git_prefix" = "gl"
                            set git_repo "$ssh_path"
                        else
                            set git_repo "$ssh_host/$ssh_path"
                        end
                    end
                end
            else
                # Bare path
                set -l parts (string split '/' "$remote_url")
                set -l clean_parts
                for p in $parts
                    if test (string length "$p") -gt 0
                        set -a clean_parts $p
                    end
                end
                if test (count $clean_parts) -gt 0
                    if test "$git_prefix" = "gh" -o "$git_prefix" = "gl"
                        if test (count $clean_parts) -ge 2
                            set git_repo "$clean_parts[2]"
                            for i in (seq 3 (count $clean_parts))
                                set git_repo "$git_repo/$clean_parts[$i]"
                            end
                        end
                    else
                        set git_repo "$clean_parts[1]"
                        for i in (seq 2 (count $clean_parts))
                            set git_repo "$git_repo/$clean_parts[$i]"
                        end
                    end
                end
            end
        end

        # Output git line
        set_color "$pm"
        echo -n "$git_prefix"
        if test -n "$git_repo"
            set_color "$pa"
            echo -n " $git_repo"
        end
        set_color "$pf"
        echo -n " $branch"

        # ── Git status indicators ────────────────────────────────────────
        set staged 0
        set untracked 0
        set dirty false
        set conflicts 0
        set merging false
        set ahead 0
        set behind 0

        # Use git status --porcelain with proper line splitting
        set -l porcelain_raw (git status --porcelain 2>/dev/null)
        if test -n "$porcelain_raw"
            set -l porcelain_lines (string split '\n' "$porcelain_raw")
            for line in $porcelain_lines
                if test -z "$line"
                    continue
                end
                set -l idx "$line[1]"
                set -l work "$line[2]"
                if test "$idx" != ' '
                    set staged (math "$staged + 1")
                end
                if test "$work" = '?'
                    set untracked (math "$untracked + 1")
                end
                if test "$idx" = 'U' -o "$work" = 'U'
                    set conflicts (math "$conflicts + 1")
                end
                if test "$idx" != 'U' -a "$idx" != ' '
                    set dirty true
                end
            end
        end

        # Check merge/rebase in progress
        if test -d .git/MERGE_HEAD -o -d .git/REBASE_HEAD -o \
           -f .git/CHERRY_PICK_HEAD -o -f .git/REVERT_HEAD -o \
           -d .git/rebase-merge -o -d .git/rebase-apply
            set merging true
        end

        # Ahead/behind
        if test -n "$remote_url"
            if git rev-parse --verify @{upstream} >/dev/null 2>&1
                set -l ahead_raw (git rev-list --count @{upstream}..HEAD 2>/dev/null | string trim)
                set -l behind_raw (git rev-list --count HEAD..@{upstream} 2>/dev/null | string trim)
                if test -n "$ahead_raw" -a "$ahead_raw" != '0'
                    set ahead "$ahead_raw"
                end
                if test -n "$behind_raw" -a "$behind_raw" != '0'
                    set behind "$behind_raw"
                end
            end
        end

        # Build status string (only non-zero values)
        set -l st_parts
        if test "$conflicts" -gt 0
            set -a st_parts '✕'
        end
        if test "$merging" = true -a "$conflicts" -eq 0
            set -a st_parts '⚡'
        end
        if test "$dirty" = true
            set -a st_parts '*'
        end
        if test "$staged" -gt 0
            set -a st_parts "+$staged"
        end
        if test "$untracked" -gt 0
            set -a st_parts "?$untracked"
        end
        if test "$ahead" -gt 0
            set -a st_parts "↑$ahead"
        end
        if test "$behind" -gt 0
            set -a st_parts "↓$behind"
        end

        if test (count $st_parts) -gt 0
            set_color "$pr"
            echo -n ' '
            echo -n (string join ' ' $st_parts)
        end

        set_color "$pa"
        echo -n ' ❯'
        set_color normal
    else
        set_color "$pa"
        echo -n ' ❯'
        set_color normal
    end
end
