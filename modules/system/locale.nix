# modules/system/locale.nix
# ------------------------------------------------------------------------------------------------------------------------
# Timezone, locale, and keyboard layout.
# Locale: English UI, German formatting (dates, currency, measurements).
# ------------------------------------------------------------------------------------------------------------------------
{ config, pkgs, vars, ... }:

{
  time.timeZone = vars.location.timezone;  # "Europe/Berlin"

  # Interface language stays English; category overrides use German conventions
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT    = "de_DE.UTF-8";
    LC_MONETARY       = "de_DE.UTF-8";
    LC_NAME           = "de_DE.UTF-8";
    LC_NUMERIC        = "de_DE.UTF-8";
    LC_PAPER          = "de_DE.UTF-8";
    LC_TELEPHONE      = "de_DE.UTF-8";
    LC_TIME           = "de_DE.UTF-8";
  };

  # Keyboard layout can be overridden per machine. The installer fills this from the
  # running system or from the overview prompt, and the module then applies it here.
  services.xserver.xkb = {
    layout  = vars.keyboardLayout;
    options = "grp:alt_shift_toggle";
  };

  # TTY keyboard layout (for virtual consoles, before Wayland starts)
  console.keyMap = vars.keyboardLayout;
}
