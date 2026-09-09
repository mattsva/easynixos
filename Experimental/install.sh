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
INSTALLER_VERSION="dev"

# ==============================================================================
#  0. Root check
# ==============================================================================
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

  █████████  ██████████ ███████████ █████  █████ ███████████     █████ ██████   █████  █████████  ███████████   █████████   █████       █████       ██████████ ███████████  
 ███▒▒▒▒▒███▒▒███▒▒▒▒▒█▒█▒▒▒███▒▒▒█▒▒███  ▒▒███ ▒▒███▒▒▒▒▒███   ▒▒███ ▒▒██████ ▒▒███  ███▒▒▒▒▒███▒█▒▒▒███▒▒▒█  ███▒▒▒▒▒███ ▒▒███       ▒▒███       ▒▒███▒▒▒▒▒█▒▒███▒▒▒▒▒███ 
▒███    ▒▒▒  ▒███  █ ▒ ▒   ▒███  ▒  ▒███   ▒███  ▒███    ▒███    ▒███  ▒███▒███ ▒███ ▒███    ▒▒▒ ▒   ▒███  ▒  ▒███    ▒███  ▒███        ▒███        ▒███  █ ▒  ▒███    ▒███ 
▒▒█████████  ▒██████       ▒███     ▒███   ▒███  ▒██████████     ▒███  ▒███▒▒███▒███ ▒▒█████████     ▒███     ▒███████████  ▒███        ▒███        ▒██████    ▒██████████  
 ▒▒▒▒▒▒▒▒███ ▒███▒▒█       ▒███     ▒███   ▒███  ▒███▒▒▒▒▒▒      ▒███  ▒███ ▒▒██████  ▒▒▒▒▒▒▒▒███    ▒███     ▒███▒▒▒▒▒███  ▒███        ▒███        ▒███▒▒█    ▒███▒▒▒▒▒███ 
 ███    ▒███ ▒███ ▒   █    ▒███     ▒███   ▒███  ▒███            ▒███  ▒███  ▒▒█████  ███    ▒███    ▒███     ▒███    ▒███  ▒███      █ ▒███      █ ▒███ ▒   █ ▒███    ▒███ 
▒▒█████████  ██████████    █████    ▒▒████████   █████           █████ █████  ▒▒█████▒▒█████████     █████    █████   █████ ███████████ ███████████ ██████████ █████   █████
 ▒▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒▒▒    ▒▒▒▒▒      ▒▒▒▒▒▒▒▒   ▒▒▒▒▒           ▒▒▒▒▒ ▒▒▒▒▒    ▒▒▒▒▒  ▒▒▒▒▒▒▒▒▒     ▒▒▒▒▒    ▒▒▒▒▒   ▒▒▒▒▒ ▒▒▒▒▒▒▒▒▒▒▒ ▒▒▒▒▒▒▒▒▒▒▒ ▒▒▒▒▒▒▒▒▒▒ ▒▒▒▒▒   ▒▒▒▒▒ 
                                                                                                                                                                                                                                                                                                                                                
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

# ==============================================================================
#  1. Locate / clone / update the repo
# ==============================================================================
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
      git -C "$NIXOS_DIR" pull --ff-only origin main
      success "Repository updated to $(git -C "$NIXOS_DIR" rev-parse --short HEAD)."
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
    git -C "$LOCAL_CANDIDATE" pull --ff-only origin main
    success "Updated to $(git -C "$LOCAL_CANDIDATE" rev-parse --short HEAD)."
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

ask VAR_USERNAME  "System username (userName)"          "$_default_user"  validate_username
ask VAR_GIT_NAME  "Git display name (gitName)"          "$VAR_USERNAME"
ask VAR_EMAIL     "Git / user email (userEmail)"        ""                validate_email
ask VAR_HOSTNAME  "Machine hostname"                    "$_default_hostname" validate_hostname
ask VAR_KEYBOARD  "Keyboard layout (us, de, us,de, ...)" "$_default_keyboard" validate_keyboard
ask VAR_TIMEZONE  "Timezone (e.g. Europe/Berlin)"       "$_default_tz"   validate_timezone
ask VAR_CITY      "City (display only)"                 "$_default_city"
ask VAR_TERMINAL  "Default terminal emulator"           "foot"            validate_terminal
ask VAR_FM        "Default file manager"                "thunar"          validate_filemanager
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
[[ "${_ok,,}" =~ ^(n|no)$ ]] && die "Aborted. No files have been modified."

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

cat > "$VARS_FILE" << VARSNIX
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
    sed -i 's/^experimental-features\s*=\s*/experimental-features = nix-command flakes /' "$NIX_CONF"
  else
    printf '%s\n' "experimental-features = nix-command flakes" >> "$NIX_CONF"
  fi
  success "Flakes enabled."
fi

# ==============================================================================
#  5. nixos-rebuild switch
# ==============================================================================
header "Step 5 — Building NixOS"

# Rebuilds are performed against the checked-out repo in /etc/nixos. If that tree was
# created or moved by a different user or from a backup, it may not be writable by the
# user doing the rebuild. Fix the ownership/permissions here before invoking nixos-rebuild.
if [[ -d "$NIXOS_DIR" ]]; then
  info "Ensuring the NixOS config tree is writable for the rebuild…"
  chown -R root:root "$NIXOS_DIR"
  chmod -R u+rwX,go+rX "$NIXOS_DIR"
fi

echo -e "  About to run:"
echo -e "  ${BOLD}sudo nixos-rebuild switch --flake ${NIXOS_DIR}#nixos${RESET}\n"
echo -e "  ${YELLOW}This will download all flake inputs on first run."
echo -e "  It can take quite a while — grab a coffee. ☕${RESET}\n"

read -rp "$(echo -e "${BOLD}Start the build now? [Y/n] ${RESET}")" _build
if [[ "${_build,,}" =~ ^(n|no)$ ]]; then
  warn "Build skipped. Run manually when ready:"
  echo -e "  sudo nixos-rebuild switch --flake /etc/nixos#nixos\n"
  exit 0
fi

sudo nixos-rebuild switch --flake "${NIXOS_DIR}#nixos"

# ==============================================================================
#  Done
# ==============================================================================
echo ""
echo -e "${GREEN}${BOLD}"
cat << 'DONE'
  ╔══════════════════════════════════════════════╗
  ║   ✓  Installation complete!                  ║
  ║                                              ║
  ║   Reboot to enjoy Hyprland + Noctalia Shell  ║
  ╚══════════════════════════════════════════════╝
DONE
echo -e "${RESET}"

echo -e "  Useful aliases (available after reboot / new shell):\n"
echo -e "  ${CYAN}nr${RESET}     — rebuild & switch"
echo -e "  ${CYAN}nfu${RESET}    — update all flake inputs"
echo -e "  ${CYAN}ncg${RESET}    — collect garbage (free disk space)"
echo -e "  ${CYAN}nrt${RESET}    — test build (no bootloader entry)\n"

echo -e "  ${BOLD}Your vars.nix backup:${RESET} ${VARS_FILE}.bak  (if it existed before)"
echo ""