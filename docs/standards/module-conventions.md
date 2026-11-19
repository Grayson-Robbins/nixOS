# Module Conventions

## Scope

This document defines how reusable NixOS and Home Manager modules should be structured and how they should interact with host configuration.

## Module responsibilities

A reusable module should have a focused responsibility:

- Declare options owned by that module or domain.
- Define configuration derived from those options.
- Import closely related submodules when it is the domain's aggregator.
- Avoid embedding unrelated host-specific policy.
- Expose meaningful configuration through options instead of requiring consumers to edit implementation files.

Host modules should select modules and set host-specific values. They should not duplicate reusable implementation.

## NixOS and Home Manager boundaries

Treat NixOS and Home Manager as separate module systems.

- NixOS modules use NixOS option namespaces and are evaluated as part of a NixOS configuration.
- Home Manager modules use Home Manager option namespaces and are evaluated in the relevant Home Manager configuration.
- A NixOS module may integrate Home Manager, but that does not make every option it assigns a NixOS option.
- When a NixOS module configures `home-manager.users.<name>`, distinguish the outer NixOS integration from the inner Home Manager options.

Keep module placement aligned with the configuration system it primarily defines:
- `modules/nixos/` for reusable NixOS modules.
- `modules/home-manager/` for reusable Home Manager modules.
- `modules/selfhosted/` for the self-hosted domain, while clearly separating system-level and Home Manager layers inside it.

## Standard module shape

For a module with options and conditional configuration:

```nix
{ config, lib, ... }:

let
  cfg = config.services.example;
in
{
  options.services.example.enable =
    lib.mkEnableOption "the example service";

  config = lib.mkIf cfg.enable {
    # Configuration activated by the option.
  };
}
```

Use `config = lib.mkIf ...` when the module has multiple conditional settings. For a simple module without custom enablement, direct assignments may be appropriate.

## Enable options

- Declare an enable option in the module that owns the feature.
- Use a fully qualified option path.
- Give the enable option a specific description.
- Gate the feature's configuration with the corresponding `cfg.enable`.
- Do not create multiple similarly named enable options for the same feature without a clear reason.
- Do not infer that a feature is enabled because its module is imported.

A parent module may expose a separate switch controlling whether a child module is included or configured. Document the relationship explicitly.

For example, a parent option such as `services.selfhost.sure.enable` and a child module option such as `services.sure.enable` are distinct declarations in distinct configuration layers. Their names and descriptions must be read from their own source files, not inferred from one another.

## Aggregator modules

Use `default.nix` or another clearly named entry point to import related modules.

- Keep imports explicit.
- Avoid hidden directory-wide discovery unless the repository deliberately adopts and documents it.
- Keep option declarations and implementation ownership clear.
- Do not import a module from multiple paths unless duplicate inclusion is intentional and safe.

## Shared infrastructure and feature modules

Separate common mechanisms from individual features.

For self-hosted services, for example:
- Shared options belong in the shared self-hosted options module.
- Rootless Docker lifecycle and user infrastructure belong in deployment/infrastructure modules.
- Tailscale integration belongs in shared networking/exposure infrastructure.
- Service-specific compose definitions, environment setup, and service lifecycle belong with the service.
- Host-specific service selection belongs in the host configuration.

Avoid copying the same Docker, networking, or user setup into every service module.

## Cross-module option wiring

When a parent module forwards values into another module system, make the mapping explicit and easy to trace.

Document:
1. Where the source option is declared.
2. Where its value is assigned.
3. Which module consumes the destination option.
4. Which configuration system evaluates that destination.

Do not assume two similarly named options are aliases. Verify the assignment that connects them.

## File organization

- Use `default.nix` for a directory's explicit aggregator or primary module when that is the established pattern.
- Use descriptive filenames for independent modules.
- Keep helper files adjacent to the module that owns them.
- Keep service-specific flakes inside their service directories when they are independently composed.
- Avoid putting unrelated functionality into a generic `common.nix`.

## Module review checklist

- Does this module have one clear responsibility?
- Is it a NixOS module, Home Manager module, or an intentional integration?
- Are its options declared in the correct namespace?
- Is configuration gated by the correct enable option?
- Are shared concerns factored out?
- Are host-specific choices kept in host files?
- Can a reader trace every forwarded option?
