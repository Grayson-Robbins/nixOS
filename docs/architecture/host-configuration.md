# Host Configuration

## Purpose

This document defines the intended responsibilities of host directories and records the currently observed host layout.

## Host layout

```text
hosts/
├── desktop/
│   ├── default.nix
│   ├── hardware-configuration.nix
│   ├── home.nix
│   ├── infrastructure.nix
│   └── selfhost.nix
└── server/
```

The repository listing shows a populated desktop host and an empty `hosts/server/` directory. The server directory is a planned location, not evidence of an existing server configuration.

## Desktop host

### `hosts/desktop/default.nix`

The desktop NixOS entry module contains host-level configuration and imports host-specific and reusable modules.

The observed import groups include:
- Hardware configuration.
- Desktop-specific self-hosted configuration.
- Desktop infrastructure configuration.
- Shared NixOS modules such as `nh`, gaming, and SearXNG.

Keep this file focused on desktop composition and genuinely desktop-specific settings. Move reusable implementation into `modules/`.

### `hosts/desktop/hardware-configuration.nix`

Contains machine-specific hardware configuration. Treat this file as generated or hardware-bound configuration unless deliberately maintaining it by hand.

Avoid moving generic service or desktop policy into this file.

### `hosts/desktop/home.nix`

The desktop user's Home Manager entry point. It should compose reusable Home Manager modules and set desktop-user-specific preferences.

As `homeModules/` is migrated, update this entry point and all relevant imports to use the canonical `modules/home-manager/` tree.

### `hosts/desktop/infrastructure.nix`

Contains desktop-specific infrastructure composition. Keep host-specific infrastructure selection here; place reusable infrastructure implementation in the appropriate `modules/` domain.

### `hosts/desktop/selfhost.nix`

Contains desktop-specific self-hosted selection and values. It should choose which services and shared self-hosted capabilities are enabled on the desktop, while service implementations remain reusable under `modules/selfhosted/`.

## Future server host

`hosts/server/` is currently empty in the observed tree.

When implementing it:
- Create a server-specific NixOS entry module.
- Add server hardware configuration only when the target hardware is known.
- Reuse shared modules rather than copying desktop service implementations.
- Select only the services and infrastructure appropriate for the server.
- Create a separate Home Manager entry point only if the server requires user-level Home Manager configuration.
- Add the server output to the root flake explicitly.
- Keep secrets and machine-specific values out of shared reusable modules.

Do not assume the server should inherit desktop configuration wholesale. A server may share self-hosted services and infrastructure while omitting desktop, gaming, styling, and interactive-user configuration.

## Host responsibilities

A host directory should contain:
- Host entry point and import composition.
- Hardware-specific configuration.
- Host-specific service selection.
- Host-specific values and policy.
- User entry points where needed.

A host directory should generally not contain:
- Generic reusable service implementation.
- Generic styling modules.
- Shared Docker deployment scripts.
- Reusable Home Manager application modules.
- Logic that belongs to a domain module and may be shared by multiple hosts.

## Adding a new host

1. Create `hosts/<host>/`.
2. Add the host's NixOS entry module.
3. Add hardware configuration when applicable.
4. Import reusable modules explicitly.
5. Set host-specific option values and service selection.
6. Add a corresponding root flake `nixosConfigurations.<host>` output.
7. Add Home Manager integration only if needed.
8. Evaluate and build the new host output.
9. Check that desktop-only modules and user settings have not leaked into the server configuration.

## Host-tracing checklist

For any host-specific question, establish:
- Which root flake output is being evaluated?
- Which host entry module is included?
- Which modules are imported directly and transitively?
- Which Home Manager users are configured?
- Which options are assigned by the host?
- Which assignments are conditional?
- What is the evaluated value, if the question concerns effective state?
