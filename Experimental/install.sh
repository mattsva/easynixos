#!/usr/bin/env bash
# ==============================================================================
#  install.sh — Installer for mattsva/easynixos
if is_our_repo "$NIXOS_DIR"; then
  info "Found repo already at ${BOLD}${NIXOS_DIR}${RESET}"
  NIXOS_IS_REPO=true
fi

if $NIXOS_IS_REPO; then
  info "Checking for upstream updates…"
  git -C "$NIXOS_DIR" fetch origin main --tags --quiet
  LOCAL_HASH=$(git -C "$NIXOS_DIR" rev-parse HEAD)
  REMOTE_HASH=$(git -C "$NIXOS_DIR" rev-parse origin/main)

  LOCAL_TAG=$(git -C "$NIXOS_DIR" describe --tags --abbrev=0 2>/dev/null || true)
  REMOTE_TAG=$(git -C "$NIXOS_DIR" ls-remote --tags origin | awk -F'/' '/refs\/tags\// {print $3}' | sed 's/\^{}$//' | sort -V | tail -n1)

  if [[ -n "$REMOTE_TAG" && "$REMOTE_TAG" != "$LOCAL_TAG" ]]; then
    echo ""
    info "A release tag is available on origin: ${BOLD}${REMOTE_TAG}${RESET}"
    read -rp "$(echo -e "  ${BOLD}Switch to this release tag? [Y/n] ${RESET}")" _use_tag
    if [[ ! "${_use_tag,,}" =~ ^(n|no)$ ]]; then
      # Preserve vars.nix
      if [[ -f "$NIXOS_DIR/vars.nix" ]]; then
        cp "$NIXOS_DIR/vars.nix" /tmp/vars.nix.bak
        info "Backed up vars.nix to /tmp/vars.nix.bak"
      fi
      git -C "$NIXOS_DIR" checkout --force "tags/$REMOTE_TAG" || die "Failed to check out tag $REMOTE_TAG"
      git -C "$NIXOS_DIR" reset --hard
      success "Checked out release ${REMOTE_TAG}."
      # Restore vars.nix
      if [[ -f /tmp/vars.nix.bak ]]; then
        mv /tmp/vars.nix.bak "$NIXOS_DIR/vars.nix"
        info "Restored your vars.nix."
      fi
    else
      info "Not switching to the release tag."
    fi
  else
    if [[ "$LOCAL_HASH" == "$REMOTE_HASH" ]]; then
      success "Already up to date (${LOCAL_HASH:0:7})."
    else
      warn "New commits available on origin/main."
      warn "  local  → ${LOCAL_HASH:0:7}"
      warn "  remote → ${REMOTE_HASH:0:7}"
      read -rp "$(echo -e "${BOLD}Pull updates now? [Y/n] ${RESET}")" _pull
      if [[ ! "${_pull,,}" =~ ^(n|no)$ ]]; then
        if [[ -f "$NIXOS_DIR/vars.nix" ]]; then
          cp "$NIXOS_DIR/vars.nix" /tmp/vars.nix.bak
          info "Backed up vars.nix to /tmp/vars.nix.bak"
        fi
        attempt_pull_with_resolution "$NIXOS_DIR"
        if [[ -f /tmp/vars.nix.bak ]]; then
          cp /tmp/vars.nix.bak "$NIXOS_DIR/vars.nix"
          info "Restored your vars.nix."
        fi
      fi
    fi
  fi
elif [[ -n "$LOCAL_CANDIDATE" ]]; then
  # Repo is in CWD — move / copy it to /etc/nixos
  info "Repo found locally at ${BOLD}${LOCAL_CANDIDATE}${RESET}."

  # Update it first
  info "Pulling latest changes from origin/main…"
  git -C "$LOCAL_CANDIDATE" fetch origin main --quiet
  LOCAL_HASH=$(git -C "$LOCAL_CANDIDATE" rev-parse HEAD)
  REMOTE_HASH=$(git -C "$LOCAL_CANDIDATE" rev-parse origin/main)
  if [[ "$LOCAL_HASH" != "$REMOTE_HASH" ]]; then
    attempt_pull_with_resolution "$LOCAL_CANDIDATE"
  fi

  # Back up existing /etc/nixos if needed
  if [[ -d "$NIXOS_DIR" ]] && ! is_our_repo "$NIXOS_DIR"; then
    warn "/etc/nixos exists and is NOT the mattsva/easynixos repo."
    BACKUP_PATH="/etc/nixos.bak_$(date +%Y%m%d_%H%M%S)"
    info "Backing it up to ${BOLD}${BACKUP_PATH}${RESET}…"
    mv "$NIXOS_DIR" "$BACKUP_PATH"
    success "Backup done."
  fi

  echo ""
  echo -e "  ${BOLD}Where should the repo be placed?${RESET}"
  echo -e "  ${CYAN}1)${RESET} Move  ${LOCAL_CANDIDATE} → /etc/nixos"
  echo -e "  ${CYAN}2)${RESET} Copy  ${LOCAL_CANDIDATE} → /etc/nixos  (keep original)"
  read -rp "$(echo -e "${BOLD}Choice [1/2, default 1]: ${RESET}")" _mv_choice
  if [[ "${_mv_choice}" == "2" ]]; then
    cp -a "$LOCAL_CANDIDATE" "$NIXOS_DIR"
    success "Copied to /etc/nixos."
  else
    mv "$LOCAL_CANDIDATE" "$NIXOS_DIR"
    success "Moved to /etc/nixos."
  fi

else
  # Need to clone from scratch
  info "Repo not found locally. Cloning from GitHub…"

  # Back up existing /etc/nixos
  if [[ -d "$NIXOS_DIR" ]]; then
    BACKUP_PATH="/etc/nixos.bak_$(date +%Y%m%d_%H%M%S)"
    warn "/etc/nixos already exists (not our repo). Backing up to ${BACKUP_PATH}…"
    mv "$NIXOS_DIR" "$BACKUP_PATH"
    success "Backup done."
  fi

  git clone "$REPO_URL" "$NIXOS_DIR"
  success "Cloned to /etc/nixos ($(git -C "$NIXOS_DIR" rev-parse --short HEAD))."
fi
  else
    if [[ "$LOCAL_HASH" == "$REMOTE_HASH" ]]; then
      success "Already up to date (${LOCAL_HASH:0:7})."
    else
      warn "New commits available on origin/main."
      warn "  local  → ${LOCAL_HASH:0:7}"
      warn "  remote → ${REMOTE_HASH:0:7}"
      read -rp "$(echo -e "${BOLD}Pull updates now? [Y/n] ${RESET}")" _pull
      if [[ ! "${_pull,,}" =~ ^(n|no)$ ]]; then
        if [[ -f "$NIXOS_DIR/vars.nix" ]]; then
          cp "$NIXOS_DIR/vars.nix" /tmp/vars.nix.bak
          info "Backed up vars.nix to /tmp/vars.nix.bak"
        fi
        attempt_pull_with_resolution "$NIXOS_DIR"
        if [[ -f /tmp/vars.nix.bak ]]; then
          cp /tmp/vars.nix.bak "$NIXOS_DIR/vars.nix"
          info "Restored your vars.nix."
        fi
      fi
    fi
  fi
fi

elif [[ -n "$LOCAL_CANDIDATE" ]]; then
  # Repo is in CWD — move / copy it to /etc/nixos
  info "Repo found locally at ${BOLD}${LOCAL_CANDIDATE}${RESET}."

  # Update it first
  info "Pulling latest changes from origin/main…"
  git -C "$LOCAL_CANDIDATE" fetch origin main --quiet
  LOCAL_HASH=$(git -C "$LOCAL_CANDIDATE" rev-parse HEAD)
  REMOTE_HASH=$(git -C "$LOCAL_CANDIDATE" rev-parse origin/main)
  if [[ "$LOCAL_HASH" != "$REMOTE_HASH" ]]; then
    attempt_pull_with_resolution "$LOCAL_CANDIDATE"
  fi

  # Back up existing /etc/nixos if needed
  if [[ -d "$NIXOS_DIR" ]] && ! is_our_repo "$NIXOS_DIR"; then
    warn "/etc/nixos exists and is NOT the mattsva/easynixos repo."
    BACKUP_PATH="/etc/nixos.bak_$(date +%Y%m%d_%H%M%S)"
    info "Backing it up to ${BOLD}${BACKUP_PATH}${RESET}…"
    mv "$NIXOS_DIR" "$BACKUP_PATH"
    success "Backup done."
  fi

  echo ""
  echo -e "  ${BOLD}Where should the repo be placed?${RESET}"
  echo -e "  ${CYAN}1)${RESET} Move  ${LOCAL_CANDIDATE} → /etc/nixos"
  echo -e "  ${CYAN}2)${RESET} Copy  ${LOCAL_CANDIDATE} → /etc/nixos  (keep original)"
  read -rp "$(echo -e "${BOLD}Choice [1/2, default 1]: ${RESET}")" _mv_choice
  if [[ "${_mv_choice}" == "2" ]]; then
    cp -a "$LOCAL_CANDIDATE" "$NIXOS_DIR"
    success "Copied to /etc/nixos."
  else
    mv "$LOCAL_CANDIDATE" "$NIXOS_DIR"
    success "Moved to /etc/nixos."
  fi

else
  # Need to clone from scratch
  info "Repo not found locally. Cloning from GitHub…"

  # Back up existing /etc/nixos
  if [[ -d "$NIXOS_DIR" ]]; then
    BACKUP_PATH="/etc/nixos.bak_$(date +%Y%m%d_%H%M%S)"
    warn "/etc/nixos already exists (not our repo). Backing up to ${BACKUP_PATH}…"
    mv "$NIXOS_DIR" "$BACKUP_PATH"
    success "Backup done."
  fi

  git clone "$REPO_URL" "$NIXOS_DIR"
  success "Cloned to /etc/nixos ($(git -C "$NIXOS_DIR" rev-parse --short HEAD))."
fi
        4)
          warn "Skipping update for $dir."
          break
          ;;
        *)
          warn "Invalid choice."
          ;;
      esac
    done
  }

if $NIXOS_IS_REPO; then
  # Already in place — check for updates
  info "Checking for upstream updates…"
  git -C "$NIXOS_DIR" fetch origin main --quiet
  LOCAL_HASH=$(git -C "$NIXOS_DIR" rev-parse HEAD)
  REMOTE_HASH=$(git -C "$NIXOS_DIR" rev-parse origin/main)

  if [[ "$LOCAL_HASH" == "$REMOTE_HASH" ]]; then
    success "Already up to date (${LOCAL_HASH:0:7})."
  else
    warn "New commits available on origin/main."
    warn "  local  → ${LOCAL_HASH:0:7}"
    warn "  remote → ${REMOTE_HASH:0:7}"
    read -rp "$(echo -e "${BOLD}Pull updates now? [Y/n] ${RESET}")" _pull
    if [[ ! "${_pull,,}" =~ ^(n|no)$ ]]; then
      # Preserve vars.nix if the user already customised it
      if [[ -f "$NIXOS_DIR/vars.nix" ]]; then
        cp "$NIXOS_DIR/vars.nix" /tmp/vars.nix.bak
        info "Backed up vars.nix to /tmp/vars.nix.bak"
      fi
      attempt_pull_with_resolution "$NIXOS_DIR"
      # Restore vars.nix if it was backed up
      if [[ -f /tmp/vars.nix.bak ]]; then
        cp /tmp/vars.nix.bak "$NIXOS_DIR/vars.nix"
        info "Restored your vars.nix."
      fi
    fi
  fi

elif [[ -n "$LOCAL_CANDIDATE" ]]; then
  # Repo is in CWD — move / copy it to /etc/nixos
  info "Repo found locally at ${BOLD}${LOCAL_CANDIDATE}${RESET}."

  # Update it first
  info "Pulling latest changes from origin/main…"
  git -C "$LOCAL_CANDIDATE" fetch origin main --quiet
  LOCAL_HASH=$(git -C "$LOCAL_CANDIDATE" rev-parse HEAD)
  REMOTE_HASH=$(git -C "$LOCAL_CANDIDATE" rev-parse origin/main)
  if [[ "$LOCAL_HASH" != "$REMOTE_HASH" ]]; then
    attempt_pull_with_resolution "$LOCAL_CANDIDATE"
  fi

  # Back up existing /etc/nixos if needed
  if [[ -d "$NIXOS_DIR" ]] && ! is_our_repo "$NIXOS_DIR"; then
    warn "/etc/nixos exists and is NOT the mattsva/easynixos repo."
    BACKUP_PATH="/etc/nixos.bak_$(date +%Y%m%d_%H%M%S)"
    info "Backing it up to ${BOLD}${BACKUP_PATH}${RESET}…"
    mv "$NIXOS_DIR" "$BACKUP_PATH"
    success "Backup done."
  fi

  echo ""
  echo -e "  ${BOLD}Where should the repo be placed?${RESET}"
  echo -e "  ${CYAN}1)${RESET} Move  ${LOCAL_CANDIDATE} → /etc/nixos"
  echo -e "  ${CYAN}2)${RESET} Copy  ${LOCAL_CANDIDATE} → /etc/nixos  (keep original)"
  read -rp "$(echo -e "${BOLD}Choice [1/2, default 1]: ${RESET}")" _mv_choice
  if [[ "${_mv_choice}" == "2" ]]; then
    cp -a "$LOCAL_CANDIDATE" "$NIXOS_DIR"
    success "Copied to /etc/nixos."
  else
    mv "$LOCAL_CANDIDATE" "$NIXOS_DIR"
    success "Moved to /etc/nixos."
  fi

else
  # Need to clone from scratch
  info "Repo not found locally. Cloning from GitHub…"

  # Back up existing /etc/nixos
  if [[ -d "$NIXOS_DIR" ]]; then
    BACKUP_PATH="/etc/nixos.bak_$(date +%Y%m%d_%H%M%S)"
    warn "/etc/nixos already exists (not our repo). Backing up to ${BACKUP_PATH}…"
    mv "$NIXOS_DIR" "$BACKUP_PATH"
    success "Backup done."
  fi

  git clone "$REPO_URL" "$NIXOS_DIR"
  success "Cloned to /etc/nixos ($(git -C "$NIXOS_DIR" rev-parse --short HEAD))."
fi

# ==============================================================================
#  2. Collect user variables
# ==============================================================================
header "Step 2 — Personal Variables (vars.nix)"

echo -e "  Please fill in the values below."
echo -e "  Press ${BOLD}Enter${RESET} to accept the shown default.\n"

# Helper: prompt with validation -----------------------------------------------
ask() {
  # ask <VAR_NAME> <PROMPT> <DEFAULT> [VALIDATOR_FUNCTION]
  local varname="$1" prompt="$2" default="$3" validator="${4:-}"
  local value=""
  while true; do
    if [[ -n "$default" ]]; then
      read -rp "$(echo -e "  ${BOLD}${prompt}${RESET} ${CYAN}[${default}]${RESET}: ")" value
      value="${value:-$default}"
    else
      read -rp "$(echo -e "  ${BOLD}${prompt}${RESET}: ")" value
    fi
    if [[ -z "$value" ]]; then
      warn "This field cannot be empty."
      continue
    fi
    if [[ -n "$validator" ]] && ! $validator "$value"; then
      continue
    fi
    printf -v "$varname" '%s' "$value"
    break
  done
}

validate_username() {
  if [[ ! "$1" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
    warn "Invalid username. Use lowercase letters, digits, - or _ (must start with a letter/underscore)."
    return 1
  fi
}

validate_email() {
  if [[ ! "$1" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
    warn "That doesn't look like a valid email address."
    return 1
  fi
}

validate_timezone() {
  if ! timedatectl list-timezones 2>/dev/null | grep -qx "$1"; then
    warn "'$1' is not a recognised timezone."
    warn "Examples: Europe/Berlin  America/New_York  Asia/Tokyo"
    warn "Run 'timedatectl list-timezones' to see all options."
    return 1
  fi
}

validate_terminal() {
  local allowed=("foot" "kitty" "alacritty" "wezterm" "xterm" "ghostty")
  for t in "${allowed[@]}"; do
    [[ "$t" == "$1" ]] && return 0
  done
  warn "Unknown terminal '${1}'. Common choices: ${allowed[*]}"
  warn "You can still proceed — just make sure it is installed."
  read -rp "$(echo -e "  ${BOLD}Use '${1}' anyway? [y/N] ${RESET}")" _force
  [[ "${_force,,}" =~ ^(y|yes)$ ]] && return 0
  return 1
}

validate_filemanager() {
  local allowed=("thunar" "dolphin" "nautilus" "nemo" "pcmanfm")
  for f in "${allowed[@]}"; do
    [[ "$f" == "$1" ]] && return 0
  done
  warn "Unknown file manager '${1}'. Common choices: ${allowed[*]}"
  read -rp "$(echo -e "  ${BOLD}Use '${1}' anyway? [y/N] ${RESET}")" _force
  [[ "${_force,,}" =~ ^(y|yes)$ ]] && return 0
  return 1
}

validate_hostname() {
  if [[ ! "$1" =~ ^[A-Za-z0-9][A-Za-z0-9.-]*$ ]]; then
    warn "Invalid hostname '${1}'. Use letters, digits, dots or hyphens; must start with a letter or digit."
    return 1
  fi
}

validate_keyboard() {
  if [[ ! "$1" =~ ^[A-Za-z0-9,_-]+(,[A-Za-z0-9,_-]+)*$ ]]; then
    warn "Invalid keyboard layout '${1}'. Common examples: us, de, us,de, us,fr"
    return 1
  fi
}

validate_desktop_shell() {
  local allowed=("caelestia" "noctalia" "dank" "end4-dots")
  for s in "${allowed[@]}"; do
    [[ "$s" == "$1" ]] && return 0
  done
  warn "Unknown desktop shell '${1}'. Choose: ${allowed[*]} (dank = DMS)."
  return 1
}

# Detect sensible defaults from the running system where possible
_default_user="${SUDO_USER:-$(getent passwd 1000 2>/dev/null | cut -d: -f1)}"
_default_user="${_default_user:-nixos}"
_default_tz=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "Europe/London")
_default_city=$(echo "$_default_tz" | cut -d'/' -f2 | tr '_' ' ')
_default_hostname=$(hostnamectl --static 2>/dev/null || hostname 2>/dev/null || echo "nixos")
_default_keyboard=$(localectl --no-pager status 2>/dev/null | awk -F': ' '/X11 Layout|VC Keymap/ {print $2; exit}' || true)
_default_keyboard="${_default_keyboard:-us}"
_default_desktop_shell="caelestia"
if [[ -f "$NIXOS_DIR/vars.nix" ]]; then
  _existing_desktop_shell=$(sed -n 's/^[[:space:]]*desktopShell[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$NIXOS_DIR/vars.nix" | head -n 1 || true)
  if [[ -n "$_existing_desktop_shell" ]]; then
    _default_desktop_shell="$_existing_desktop_shell"
  fi
fi

# Helper: fetch an existing value from the current vars.nix if available
get_existing_var() {
  local key="$1" file="$2" val
  file="${file:-$NIXOS_DIR/vars.nix}"
  case "$key" in
    timezone)
      val=$(sed -n 's/.*timezone[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$file" | head -n1 || true)
      ;;
    city)
      val=$(sed -n 's/.*city[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$file" | head -n1 || true)
      ;;
    *)
      val=$(sed -n "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*\"\([^"]*\)\".*/\1/p" "$file" | head -n1 || true)
      ;;
  esac
  printf '%s' "$val"
}

# If an existing vars.nix is present, prefer its values as defaults
if [[ -f "$NIXOS_DIR/vars.nix" ]]; then
  _existing_user=$(get_existing_var userName)
  [[ -n "$_existing_user" ]] && _default_user="$_existing_user"
  _existing_git=$(get_existing_var gitName)
  [[ -n "$_existing_git" ]] && _default_git="$_existing_git"
  _existing_email=$(get_existing_var userEmail)
  [[ -n "$_existing_email" ]] && _default_email="$_existing_email"
  _existing_host=$(get_existing_var hostName)
  [[ -n "$_existing_host" ]] && _default_hostname="$_existing_host"
  _existing_kb=$(get_existing_var keyboardLayout)
  [[ -n "$_existing_kb" ]] && _default_keyboard="$_existing_kb"
  _existing_tz=$(get_existing_var timezone)
  [[ -n "$_existing_tz" ]] && _default_tz="$_existing_tz"
  _existing_city=$(get_existing_var city)
  [[ -n "$_existing_city" ]] && _default_city="$_existing_city"
  _existing_term=$(get_existing_var terminal)
  [[ -n "$_existing_term" ]] && _default_terminal="$_existing_term"
  _existing_fm=$(get_existing_var fileManager)
  [[ -n "$_existing_fm" ]] && _default_fm="$_existing_fm"
  _existing_ds=$(get_existing_var desktopShell)
  [[ -n "$_existing_ds" ]] && _default_desktop_shell="$_existing_ds"
fi

# Fallback defaults for prompts that may have been filled from existing vars
_default_git="${_default_git:-$_default_user}"
_default_email="${_default_email:-""}"
_default_terminal="${_default_terminal:-foot}"
_default_fm="${_default_fm:-thunar}"

ask VAR_USERNAME  "System username (userName)"          "$_default_user"  validate_username
ask VAR_GIT_NAME  "Git display name (gitName)"          "$_default_git"
ask VAR_EMAIL     "Git / user email (userEmail)"        "$_default_email"                validate_email
ask VAR_HOSTNAME  "Machine hostname"                    "$_default_hostname" validate_hostname
ask VAR_KEYBOARD  "Keyboard layout (us, de, us,de, ...)" "$_default_keyboard" validate_keyboard
ask VAR_TIMEZONE  "Timezone (e.g. Europe/Berlin)"       "$_default_tz"   validate_timezone
ask VAR_CITY      "City (display only)"                 "$_default_city"
ask VAR_TERMINAL  "Default terminal emulator"           "$_default_terminal"            validate_terminal
ask VAR_FM        "Default file manager"                "$_default_fm"          validate_filemanager
ask VAR_DESKTOP_SHELL "Desktop shell (caelestia / noctalia / dank)" "$_default_desktop_shell" validate_desktop_shell

echo ""
echo -e "  ${BOLD}Summary of your choices:${RESET}"
echo -e "  userName      = ${GREEN}${VAR_USERNAME}${RESET}"
echo -e "  gitName       = ${GREEN}${VAR_GIT_NAME}${RESET}"
echo -e "  userEmail     = ${GREEN}${VAR_EMAIL}${RESET}"
echo -e "  hostname      = ${GREEN}${VAR_HOSTNAME}${RESET}"
echo -e "  keyboard      = ${GREEN}${VAR_KEYBOARD}${RESET}"
echo -e "  timezone      = ${GREEN}${VAR_TIMEZONE}${RESET}"
echo -e "  city          = ${GREEN}${VAR_CITY}${RESET}"
echo -e "  terminal      = ${GREEN}${VAR_TERMINAL}${RESET}"
echo -e "  fileManager   = ${GREEN}${VAR_FM}${RESET}"
echo -e "  desktopShell  = ${GREEN}${VAR_DESKTOP_SHELL}${RESET}"
echo ""
read -rp "$(echo -e "${BOLD}Look good? Proceed? [Y/n] ${RESET}")" _ok
if [[ "${_ok,,}" =~ ^(n|no)$ ]]; then
  info "Opening an editor to adjust your variables before writing vars.nix."
  _edit="y"
fi

# Write vars.nix ---------------------------------------------------------------
VARS_FILE="$NIXOS_DIR/vars.nix"
# Keep existing vars.nix as backup
[[ -f "$VARS_FILE" ]] && cp "$VARS_FILE" "${VARS_FILE}.bak"

escape_nix_string() {
  local value="$1"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  printf '%s' "$value"
}

# Build the vars content into a temporary file so the user can edit it before
# it replaces the system file.
TMP_VARS="/tmp/vars.nix.new.$$"
cat > "$TMP_VARS" << VARSNIX
# vars.nix - Global variables shared by NixOS modules and home-manager.
# Generated by install.sh on $(date).
# Edit this file to personalise the system without touching module internals.
{
  userName    = "$(escape_nix_string "$VAR_USERNAME")";
  userEmail   = "$(escape_nix_string "$VAR_EMAIL")";
  gitName     = "$(escape_nix_string "$VAR_GIT_NAME")";

  hostName       = "$(escape_nix_string "$VAR_HOSTNAME")";
  keyboardLayout = "$(escape_nix_string "$VAR_KEYBOARD")";

  location = {
    timezone = "$(escape_nix_string "$VAR_TIMEZONE")";
    city     = "$(escape_nix_string "$VAR_CITY")";
  };

  # Default terminal emulator used by Hyprland keybinds, Noctalia launcher, etc.
  terminal    = "$(escape_nix_string "$VAR_TERMINAL")";

  # Default file manager
  fileManager = "$(escape_nix_string "$VAR_FM")";

  # Default browser and desktop settings used by the active modules.
  browser      = "librewolf";
  desktopShell = "$(escape_nix_string "$VAR_DESKTOP_SHELL")";
  hyprConfig   = "hyprlang";

  wallpaperDir  = "/home/$(escape_nix_string "$VAR_USERNAME")/Pictures/Wallpapers";
  wallpaperFile = "wallpaper.jpg";
}
VARSNIX

# Offer the user a chance to edit the generated file interactively
if [[ -z "${_edit:-}" ]]; then
  read -rp "$(echo -e "${BOLD}Edit vars.nix now? [y/N] ${RESET}")" _edit
fi
if [[ "${_edit,,}" =~ ^(y|yes)$ ]]; then
  : "${EDITOR:=nano}"
  $EDITOR "$TMP_VARS"
fi

# Move the temp file into place
mv "$TMP_VARS" "$VARS_FILE"
success "vars.nix written to ${VARS_FILE}"

# ==============================================================================
#  3. Generate hardware configuration
# ==============================================================================
header "Step 3 — Hardware Configuration"

HW_TARGET="$NIXOS_DIR/hardware-configuration.nix"

if [[ -f "$HW_TARGET" ]]; then
  warn "hardware-configuration.nix already exists."
  read -rp "$(echo -e "${BOLD}Re-generate it for this machine? [Y/n] ${RESET}")" _regen
  if [[ "${_regen,,}" =~ ^(n|no)$ ]]; then
    info "Keeping existing hardware-configuration.nix."
  else
    info "Generating hardware-configuration.nix…"
    nixos-generate-config --show-hardware-config > "$HW_TARGET"
    success "Written to ${HW_TARGET}"
  fi
else
  info "Generating hardware-configuration.nix…"
  nixos-generate-config --show-hardware-config > "$HW_TARGET"
  success "Written to ${HW_TARGET}"
fi

# ==============================================================================
#  4. Enable flakes (if not already)
# ==============================================================================
header "Step 4 — Enabling Nix Flakes"

NIX_CONF="/etc/nix/nix.conf"
if grep -q "experimental-features.*flakes" "$NIX_CONF" 2>/dev/null; then
  success "Flakes already enabled in ${NIX_CONF}."
else
  info "Adding flakes + nix-command to ${NIX_CONF}…"
  mkdir -p /etc/nix
  # Append only if the line isn't there yet
  if grep -q "^experimental-features" "$NIX_CONF" 2>/dev/null; then
    # Extend existing line
    #!/usr/bin/env bash
    # ==============================================================================
    #  install.sh — Installer for mattsva/easynixos
    #  https://github.com/mattsva/easynixos
    # ==============================================================================
    set -euo pipefail

    # Colours ----------------------------------------------------------------------
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
    CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

    info()    { echo -e "${CYAN}${BOLD}[INFO]${RESET}  $*"; }
    success() { echo -e "${GREEN}${BOLD}[ OK ]${RESET}  $*"; }
    warn()    { echo -e "${YELLOW}${BOLD}[WARN]${RESET}  $*"; }
    error()   { echo -e "${RED}${BOLD}[ERR ]${RESET}  $*" >&2; }
    die()     { error "$*"; exit 1; }

    header() {
      echo -e "\n${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
      echo -e "${BOLD}${CYAN}  $*${RESET}"
      echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    }

    # Constants --------------------------------------------------------------------
    REPO_URL="https://github.com/mattsva/easynixos.git"
    NIXOS_DIR="/etc/nixos"
    REPO_NAME="easynixos"
    # Default installer version shown in banner. When running from a checked-out
    # tagged revision this will be replaced with the actual tag; keep a sensible
    # default here for direct runs.
    INSTALLER_VERSION="alpha-0.0.2"

    # ============================================================================
    #  0. Root check
    # ============================================================================
    if [[ $EUID -ne 0 ]]; then
      die "This script must be run as root. Use: sudo bash install.sh"
    fi

    required_commands=(
      git
      getent
      grep
      nixos-generate-config
      nixos-rebuild
      sed
      timedatectl
    )
    missing_commands=()
    for command_name in "${required_commands[@]}"; do
      command -v "$command_name" >/dev/null 2>&1 || missing_commands+=("$command_name")
    done
    if ((${#missing_commands[@]} > 0)); then
      die "Missing required commands: ${missing_commands[*]}. Run this on a NixOS system."
    fi

    clear
    echo -e "${BOLD}"
    cat << 'BANNER'
     ██████   ██████   █████████   ███████████ ███████████  █████████  █████   █████   █████████    ██            ██████   █████ █████ █████ █████    ███████     █████████ 
    ▒▒██████ ██████   ███▒▒▒▒▒███ ▒█▒▒▒███▒▒▒█▒█▒▒▒███▒▒▒█ ███▒▒▒▒▒███▒▒███   ▒▒███   ███▒▒▒▒▒███  ███           ▒▒██████ ▒▒███ ▒▒███ ▒▒███ ▒▒███   ███▒▒▒▒▒███  ███▒▒▒▒▒███
     ▒███▒█████▒███  ▒███    ▒███ ▒   ▒███  ▒ ▒   ▒███  ▒ ▒███    ▒▒▒  ▒███    ▒███  ▒███    ▒███ ▒▒▒   █████     ▒███▒███ ▒███  ▒███  ▒▒███ ███   ███     ▒▒███▒███    ▒▒▒ 
     ▒███▒▒███ ▒███  ▒███████████     ▒███        ▒███    ▒▒█████████  ▒███    ▒███  ▒███████████      ███▒▒      ▒███▒▒███▒███  ▒███   ▒▒█████   ▒███      ▒███▒▒█████████ 
     ▒███ ▒▒▒  ▒███  ▒███▒▒▒▒▒███     ▒███        ▒███     ▒▒▒▒▒▒▒▒███ ▒▒███   ███   ▒███▒▒▒▒▒███     ▒▒█████     ▒███ ▒▒██████  ▒███    ███▒███  ▒███      ▒███ ▒▒▒▒▒▒▒▒███
     ▒███      ▒███  ▒███    ▒███     ▒███        ▒███     ███    ▒███  ▒▒▒█████▒    ▒███    ▒███      ▒▒▒▒███    ▒███  ▒▒█████  ▒███   ███ ▒▒███ ▒▒███     ███  ███    ▒███
     █████     █████ █████   █████    █████       █████   ▒▒█████████     ▒▒███      █████   █████     ██████     █████  ▒▒█████ █████ █████ █████ ▒▒▒███████▒  ▒▒█████████ 
    ▒▒▒▒▒     ▒▒▒▒▒ ▒▒▒▒▒   ▒▒▒▒▒    ▒▒▒▒▒       ▒▒▒▒▒     ▒▒▒▒▒▒▒▒▒       ▒▒▒      ▒▒▒▒▒   ▒▒▒▒▒     ▒▒▒▒▒▒     ▒▒▒▒▒    ▒▒▒▒▒ ▒▒▒▒▒ ▒▒▒▒▒ ▒▒▒▒▒    ▒▒▒▒▒▒▒     ▒▒▒▒▒▒▒▒▒  
                                                                                                                                                                                                                                                                                                                                               
                                                          mattsva/easynixos
    BANNER
    echo -e "${RESET}"

    # Discover the checked-out repo version as soon as it is available so the banner shows
    # the active installer revision instead of only a generic placeholder.
    if git -C "$NIXOS_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      INSTALLER_VERSION=$(git -C "$NIXOS_DIR" describe --tags --always --dirty 2>/dev/null || git -C "$NIXOS_DIR" rev-parse --short HEAD 2>/dev/null || echo "dev")
    fi

    echo -e "  This installer will:\n"
    echo -e "  ${CYAN}1.${RESET} Clone or update the config repo into ${BOLD}/etc/nixos${RESET}"
    echo -e "  ${CYAN}2.${RESET} Ask you for your personal variables (${BOLD}vars.nix${RESET})"
    echo -e "  ${CYAN}3.${RESET} Generate ${BOLD}hardware-configuration.nix${RESET} for this machine"
    echo -e "  ${CYAN}4.${RESET} Run ${BOLD}nixos-rebuild switch --flake /etc/nixos#nixos${RESET}\n"
    echo -e "  ${BOLD}Current installer version:${RESET} ${GREEN}${INSTALLER_VERSION}${RESET}\n"

    read -rp "$(echo -e "${BOLD}Continue? [Y/n] ${RESET}")" _confirm
    [[ "${_confirm,,}" =~ ^(n|no)$ ]] && die "Aborted by user."

    # ============================================================================
    #  1. Locate / clone / update the repo
    # ============================================================================
    header "Step 1 — Repository"

    NIXOS_IS_REPO=false
    LOCAL_CANDIDATE=""

    # Helper: is a directory a clone of our repo?
    is_our_repo() {
      local dir="$1"
      [[ -d "$dir/.git" ]] || return 1
      local remote
      remote=$(git -C "$dir" remote get-url origin 2>/dev/null || true)
      [[ "$remote" == "$REPO_URL" || "$remote" == "${REPO_URL%.git}" ]]
    }

    # Check current working directory first
    CWD_CANDIDATE="$PWD"
    if is_our_repo "$CWD_CANDIDATE"; then
      info "Found repo in current directory: ${BOLD}$CWD_CANDIDATE${RESET}"
      LOCAL_CANDIDATE="$CWD_CANDIDATE"
    fi

    # Check /etc/nixos
    if is_our_repo "$NIXOS_DIR"; then
      info "Found repo already at ${BOLD}${NIXOS_DIR}${RESET}"
      NIXOS_IS_REPO=true
    fi

    # Decide what to do ------------------------------------------------------------
    attempt_pull_with_resolution() {
      local dir="$1"
      if git -C "$dir" pull --ff-only origin main; then
        success "Repository updated to $(git -C "$dir" rev-parse --short HEAD)."
        return 0
      fi

      warn "Fast-forward pull failed: local and remote branches have diverged."
      echo ""
      echo "Choose how to resolve the divergence:"
      echo "  1) Merge    — merge origin/main into local (preserve both histories)"
      echo "  2) Rebase   — rebase local commits onto origin/main (rewrites local history)"
      echo "  3) Reset    — reset local branch to origin/main (discard local commits)"
      echo "  4) Skip     — do not update (keep local branch as-is)"
      while true; do
        read -rp "$(echo -e "${BOLD}Choice [1/2/3/4, default 1]: ${RESET}")" _choice
        _choice="${_choice:-1}"
        case "$_choice" in
          1)
            if git -C "$dir" merge --no-edit origin/main; then
              success "Merged origin/main into local ($(git -C \"$dir\" rev-parse --short HEAD))."
              break
            else
              die "Merge failed — please resolve conflicts in $dir manually."
            fi
            ;;
          2)
            if git -C "$dir" rebase origin/main; then
              success "Rebased local commits on top of origin/main ($(git -C \"$dir\" rev-parse --short HEAD))."
              break
            else
              die "Rebase failed — please resolve conflicts in $dir manually."
            fi
            ;;
          3)
            read -rp "$(echo -e "${BOLD}This will discard local commits. Continue? [y/N] ${RESET}")" _force
            if [[ "${_force,,}" =~ ^(y|yes)$ ]]; then
              git -C "$dir" reset --hard origin/main
              success "Reset local branch to origin/main ($(git -C \"$dir\" rev-parse --short HEAD))."
              break
            else
              continue
            fi
            ;;
          4)
            warn "Skipping update for $dir."
            break
            ;;
          *)
            warn "Invalid choice."
            ;;
        esac
      done
    }

    if $NIXOS_IS_REPO; then
      # Already in place — check for updates
      info "Checking for upstream updates…"
      git -C "$NIXOS_DIR" fetch origin main --quiet
      LOCAL_HASH=$(git -C "$NIXOS_DIR" rev-parse HEAD)
      REMOTE_HASH=$(git -C "$NIXOS_DIR" rev-parse origin/main)

      if [[ "$LOCAL_HASH" == "$REMOTE_HASH" ]]; then
        success "Already up to date (${LOCAL_HASH:0:7})."
      else
        warn "New commits available on origin/main."
        warn "  local  → ${LOCAL_HASH:0:7}"
        warn "  remote → ${REMOTE_HASH:0:7}"
        read -rp "$(echo -e "${BOLD}Pull updates now? [Y/n] ${RESET}")" _pull
        if [[ ! "${_pull,,}" =~ ^(n|no)$ ]]; then
          # Preserve vars.nix if the user already customised it
          if [[ -f "$NIXOS_DIR/vars.nix" ]]; then
            cp "$NIXOS_DIR/vars.nix" /tmp/vars.nix.bak
            info "Backed up vars.nix to /tmp/vars.nix.bak"
          fi
          attempt_pull_with_resolution "$NIXOS_DIR"
          # Restore vars.nix if it was backed up
          if [[ -f /tmp/vars.nix.bak ]]; then
            cp /tmp/vars.nix.bak "$NIXOS_DIR/vars.nix"
            info "Restored your vars.nix."
          fi
        fi
      fi

    elif [[ -n "$LOCAL_CANDIDATE" ]]; then
      # Repo is in CWD — move / copy it to /etc/nixos
      info "Repo found locally at ${BOLD}${LOCAL_CANDIDATE}${RESET}."

      # Update it first
      info "Pulling latest changes from origin/main…"
      git -C "$LOCAL_CANDIDATE" fetch origin main --quiet
      LOCAL_HASH=$(git -C "$LOCAL_CANDIDATE" rev-parse HEAD)
      REMOTE_HASH=$(git -C "$LOCAL_CANDIDATE" rev-parse origin/main)
      if [[ "$LOCAL_HASH" != "$REMOTE_HASH" ]]; then
        attempt_pull_with_resolution "$LOCAL_CANDIDATE"
      fi

      # Back up existing /etc/nixos if needed
      if [[ -d "$NIXOS_DIR" ]] && ! is_our_repo "$NIXOS_DIR"; then
        warn "/etc/nixos exists and is NOT the mattsva/easynixos repo."
        BACKUP_PATH="/etc/nixos.bak_$(date +%Y%m%d_%H%M%S)"
        info "Backing it up to ${BOLD}${BACKUP_PATH}${RESET}…"
        mv "$NIXOS_DIR" "$BACKUP_PATH"
        success "Backup done."
      fi

      echo ""
      echo -e "  ${BOLD}Where should the repo be placed?${RESET}"
      echo -e "  ${CYAN}1)${RESET} Move  ${LOCAL_CANDIDATE} → /etc/nixos"
      echo -e "  ${CYAN}2)${RESET} Copy  ${LOCAL_CANDIDATE} → /etc/nixos  (keep original)"
      read -rp "$(echo -e "${BOLD}Choice [1/2, default 1]: ${RESET}")" _mv_choice
      if [[ "${_mv_choice}" == "2" ]]; then
        cp -a "$LOCAL_CANDIDATE" "$NIXOS_DIR"
        success "Copied to /etc/nixos."
      else
        mv "$LOCAL_CANDIDATE" "$NIXOS_DIR"
        success "Moved to /etc/nixos."
      fi

    else
      # Need to clone from scratch
      info "Repo not found locally. Cloning from GitHub…"

      # Back up existing /etc/nixos
      if [[ -d "$NIXOS_DIR" ]]; then
        BACKUP_PATH="/etc/nixos.bak_$(date +%Y%m%d_%H%M%S)"
        warn "/etc/nixos already exists (not our repo). Backing up to ${BACKUP_PATH}…"
        mv "$NIXOS_DIR" "$BACKUP_PATH"
        success "Backup done."
      fi

      git clone "$REPO_URL" "$NIXOS_DIR"
      success "Cloned to /etc/nixos ($(git -C "$NIXOS_DIR" rev-parse --short HEAD))."
    fi