# NixOS configuration

A modular NixOS desktop configuration for an x86_64 laptop/desktop with Hyprland, Home Manager, NetworkManager, PipeWire, gaming support, development tools, and selectable desktop shells.

## Repository layout

- `flake.nix` defines the `nixos` system and pins external inputs.
- `hardware-configuration.nix` is a portable placeholder; the installer replaces it with the target machine's generated hardware file.
- `vars.nix` contains the username, identity, desktop shell, browser, terminal, and wallpaper defaults.
- `hosts/nixos/default.nix` is the host manifest.
- `modules/system/` contains boot, hardware, locale, networking, audio, user, and security settings.
- `modules/desktop/` contains system-level Hyprland and shell enablement.
- `modules/packages/` contains package groups and optional services.
- `home/` contains Home Manager configuration for Hyprland, Fish, and the selectable shell.
- `Experimental/install.sh` is an interactive installer for a fresh NixOS system.

## Fresh installation

The repository expects the machine-generated hardware file at its root. From a NixOS installer or an existing NixOS system:

```bash
sudo mv /etc/nixos /etc/nixos.backup
sudo git clone https://github.com/mattsva/easynixos.git /etc/nixos
sudo nixos-generate-config --show-hardware-config \
  > /etc/nixos/hardware-configuration.nix
sudoedit /etc/nixos/vars.nix
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

The checked-in hardware file contains no disk identifiers or personal machine data, so it is safe to publish but is not a bootable hardware definition by itself. Generate a hardware file for the target machine before rebuilding; it supplies filesystems, swap, and initrd modules. The installer automates these steps and also enables flakes, but it remains in `Experimental/` because it is interactive and moves or backs up `/etc/nixos`.

At minimum, verify these values in `vars.nix`:

- `userName`, `userEmail`, and `gitName`
- `location.timezone`
- `browser`, `terminal`, and `fileManager`
- `wallpaperDir` and `wallpaperFile`
- `desktopShell`: `caelestia`, `noctalia`, `dank`, or `end4-dots`
- `hyprConfig`: currently `hyprlang` is recommended

## Daily workflow

The Fish configuration provides these abbreviations:

| Abbreviation | Command |
| --- | --- |
| `nr` | Rebuild and activate `/etc/nixos#nixos` |
| `nrt` | Test a rebuild without changing the boot entry |
| `nrb` | Build the next boot entry |
| `nfu` | Update the flake inputs in `/etc/nixos` |
| `update` | Update inputs, then rebuild `/etc/nixos#nixos` |
| `ncg` | Remove old Nix store generations |
| `gpu` | Run a command through `nvidia-offload` |

The installed system is expected to be the working copy at `/etc/nixos`. When developing from another checkout, sync or copy deliberate changes into `/etc/nixos` before running `update`; the command no longer uses a machine-specific absolute source path or deletes the installed configuration from an arbitrary directory.

## Desktop shells

Set `desktopShell` in `vars.nix` and rebuild. The selected shell is configured in both the system and Home Manager layers:

- `caelestia` is the current default and uses the Caelestia flake modules.
- `noctalia` uses the Noctalia package and Home Manager module.
- `dank` uses DankMaterialShell’s Home Manager module.
- `end4-dots` uses the end4-dots / end4-inspired Hyprland flow with the same launcher and clipboard conventions.

Hyprland keybindings use the configured terminal, file manager, browser, and shell commands. Monitor definitions in `home/hyprland.nix` are examples for the current machine and should be adjusted for different displays.

## Networking and security

NetworkManager, systemd-resolved, randomized Wi-Fi MAC addresses, Tailscale client mode, Tor client mode, KDE Connect, and the FortiSSL NetworkManager plugin are enabled. The firewall is enabled with KDE Connect ports limited to LAN-style interfaces, Tailscale’s WireGuard port, and service ports on `tailscale0`. Avahi opens mDNS for printer discovery.

SSH and Searx are not enabled by default. Open WebUI is declared but disabled. Enable services deliberately, provide secrets through a local-only module, and add only the corresponding firewall rules. AppArmor, conservative kernel sysctls, polkit, password-required sudo, and restricted namespaces are enabled.

## Services and packages

The configuration includes PipeWire/Bluetooth, CUPS and common printer drivers, Flatpak with Flathub, Steam and Proton support, Docker, VirtualBox, Ollama with CUDA, offline Kiwix tooling, development toolchains, and security/research utilities. Searx is present but disabled until a local secret is supplied. Several packages are intentionally heavyweight; remove a package group from `hosts/nixos/default.nix` if a smaller installation is desired.

## Validation

Run these commands on NixOS after changing the configuration:

```bash
nix flake check
sudo nixos-rebuild dry-build --flake .#nixos
nixfmt --check flake.nix hosts modules home vars.nix hardware-configuration.nix
bash -n Experimental/install.sh
```

The configuration targets `x86_64-linux`. The checked-in `flake.lock` must be refreshed with `nix flake update` whenever flake inputs are added or changed.

## License

MIT. See `LICENSE`.
