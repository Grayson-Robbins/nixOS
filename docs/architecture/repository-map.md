# Repository Architecture Map

## Purpose

This document describes the repository's configuration domains, their current locations, and the intended organization. It is an architectural guide, not proof that every file is imported, evaluated, or enabled.

## Top-level layout

```text
nixOS/
├── flake.nix
├── flake.lock
├── hosts/
│   ├── desktop/
│   │   ├── default.nix
│   │   ├── hardware-configuration.nix
│   │   ├── home.nix
│   │   ├── infrastructure.nix
│   │   └── selfhost.nix
│   └── server/
├── modules/
│   ├── gaming/
│   ├── home-manager/
│   │   ├── applications/
│   │   ├── desktop/
│   │   ├── development/
│   │   ├── shell/
│   │   └── tools/
│   ├── nixos/
│   ├── selfhosted/
│   └── services/
├── homeModules/                 # legacy; planned migration
└── docs/
    ├── architecture/
    └── standards/
```

The tree above reflects the observed repository listing. Some directories are currently empty or contain only a subset of their intended domain.

## Configuration domains

### `hosts/`

Contains host-specific composition and hardware/configuration entry points.

- `hosts/desktop/default.nix`: desktop NixOS host module.
- `hosts/desktop/hardware-configuration.nix`: hardware-specific NixOS configuration generated for that host.
- `hosts/desktop/home.nix`: desktop user's Home Manager entry point.
- `hosts/desktop/infrastructure.nix`: desktop-specific infrastructure composition.
- `hosts/desktop/selfhost.nix`: desktop-specific self-hosted service selection/configuration.
- `hosts/server/`: reserved for the future dedicated server host; currently no files were shown in the repository listing.

Host files should select and compose reusable modules. Reusable implementation should generally live under `modules/`, not be duplicated between hosts.

### `modules/nixos/`

Reusable system-level NixOS modules and NixOS-oriented integrations.

Observed examples:
- `nh.nix`
- `vpn.nix`
- `nvf/` (a standalone flake/integration with its own `flake.nix` and `nvf-configuration.nix`)

A module in this domain configures NixOS options and services. Do not classify a module as NixOS or Home Manager solely from its directory name; verify the module's arguments, options, and option namespaces.

### `modules/home-manager/`

Reusable Home Manager configuration, organized by functional domain.

Observed domains:
- `applications/`: application configuration, including the aichat module and its helper/tool definitions.
- `desktop/styling/`: visual appearance and desktop presentation, including Stylix, GTK, cursor, Mako, and Waybar configuration.
- `desktop/window-managers/`: Hyprland and Niri configuration, options, and keybindings.
- `development/`: reserved for development environment configuration.
- `shell/`: shell and terminal configuration.
- `tools/`: user tools.

This is the intended destination for the legacy `homeModules/` content. Keep one canonical Home Manager module tree rather than maintaining two competing roots.

### `modules/selfhosted/`

Reusable self-hosted infrastructure and service integrations.

Observed structure:
- `default.nix`: self-hosted module aggregation/entry point.
- `options.nix`: shared self-hosted option declarations.
- `deployments/rootless-docker.nix`: rootless Docker deployment infrastructure.
- `infrastructure/`: shared service infrastructure such as Home Manager and Tailscale integration.
- `applications/home-manager.nix`: integration that composes service-specific Home Manager modules.
- `sure/`, `immich/`, `grocy/`, `ollama/`: service-specific local flakes.

A service may span multiple layers: a service flake can declare options and deployment behavior, while shared modules provide common infrastructure and the host selects which services are enabled. Trace the imports and option definitions before describing the effective configuration.

### `modules/gaming/`

Reusable gaming-related configuration, including Steam, VR, Vintage Story, and related server/package modules.

### `modules/services/`

Reusable service modules not currently organized under a more specific domain. The observed example is `searxng.nix`.

### `homeModules/` (legacy)

This directory currently contains Home Manager-related configuration, including application modules, shell/terminal configuration, Git, tmux, Yazi, qutebrowser, and window-manager content.

**Migration intent:** move this content into appropriate subdirectories of `modules/home-manager/`. Until migration is complete, treat `homeModules/` as a legacy source tree. Do not assume its files are imported merely because they exist.

Likely destination mapping (confirm imports and dependencies during each move):

| Legacy path | Intended destination |
|---|---|
| `homeModules/applications/` | `modules/home-manager/applications/` |
| `homeModules/window-managers/` | `modules/home-manager/desktop/window-managers/` |
| `homeModules/git.nix` | `modules/home-manager/development/` or an appropriate tools/development subdomain |
| `homeModules/terminal.nix` | `modules/home-manager/shell/` |
| `homeModules/tmux.nix` | `modules/home-manager/shell/` |
| `homeModules/qutebrowser.nix` | `modules/home-manager/applications/` |
| `homeModules/yazi.nix` | `modules/home-manager/tools/` |
| `homeModules/packages.nix` | `modules/home-manager/` or a clearly named package-management submodule |

Do not move files mechanically without updating imports, relative paths, flake references, and any file paths embedded in scripts or configuration.

## Architectural principles

1. **Hosts compose; modules implement.** Host directories select reusable functionality and provide host-specific values.
2. **Keep configuration domains cohesive.** Styling belongs together; self-hosted service deployment belongs together; application-specific user configuration belongs together.
3. **Separate NixOS from Home Manager.** Their option namespaces and evaluation contexts are distinct even when they cooperate.
4. **Make dependencies explicit.** Prefer explicit imports, flake inputs, and option wiring over relying on directory presence or naming conventions.
5. **Keep shared infrastructure separate from service-specific configuration.**
6. **Document intended state separately from current state.** In particular, the `hosts/server/` and `homeModules/` migration plans are not yet completed architecture.

## Reading this repository accurately

When answering a configuration question, distinguish these facts:

- A file exists.
- A file is imported.
- A flake is an input.
- A module is included in a host's module list.
- An option is declared.
- An option is assigned a value.
- An option is enabled in the evaluated configuration.
- A package is installed.

These are not interchangeable. Follow the actual import and option-assignment chain.
