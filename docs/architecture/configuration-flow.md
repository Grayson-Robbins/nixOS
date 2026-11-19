# Configuration Flow

## Purpose

This document explains how configuration is expected to move from flake inputs through host composition and reusable modules into evaluated NixOS and Home Manager settings.

It describes the observed design at a high level. For a specific option, always verify the current source and actual import/assignment chain.

## High-level flow

```text
Root flake.nix
  |
  +-- declares nixpkgs, Home Manager, and other inputs
  |
  +-- defines nixosConfigurations.desktop
        |
        +-- hosts/desktop/default.nix
        |     |
        |     +-- hardware configuration
        |     +-- desktop-specific imports
        |     +-- shared NixOS modules
        |
        +-- root-level module list
              |
              +-- external NixOS modules
              +-- local module integrations
```

Within the desktop host, configuration is composed from host-specific files and reusable modules. The observed desktop default imports `hardware-configuration.nix`, `selfhost.nix`, `infrastructure.nix`, and shared modules including `nh.nix`, gaming configuration, and SearXNG configuration. Verify the current import list before relying on it.

## NixOS module evaluation

NixOS evaluates the modules supplied by the root flake's host output, together with their transitive imports.

During evaluation:
1. Module option declarations contribute to the option schema.
2. Module configuration assignments contribute values.
3. Conditions such as `lib.mkIf` determine which definitions apply.
4. Priorities and merge rules resolve compatible definitions.
5. The resulting configuration is evaluated for the selected host.

An imported module is not necessarily enabled. A declared option is not necessarily assigned `true`. A package being available or installed does not prove that a corresponding service or feature is enabled.

## Home Manager integration

The desktop host includes Home Manager integration through the root flake and host configuration.

The desktop user's Home Manager entry point is `hosts/desktop/home.nix`. Reusable Home Manager modules are intended to live under `modules/home-manager/`.

The self-hosted integration also configures a dedicated `selfhost` Home Manager user through the self-hosted modules. This is a separate user configuration from the desktop user's Home Manager configuration.

When tracing a setting, identify which Home Manager user receives the module and which module system evaluates the option.

## Self-hosted configuration flow

The observed self-hosted architecture separates selection, shared infrastructure, and service-specific implementation.

Conceptually:

```text
Desktop host configuration
  |
  +-- selects self-hosted infrastructure and services
        |
        +-- modules/selfhosted/default.nix
        |     |
        |     +-- shared options
        |     +-- rootless Docker deployment
        |     +-- shared infrastructure
        |     +-- service integrations
        |
        +-- service-specific local flakes
              |
              +-- Sure
              +-- Immich
              +-- Grocy
              +-- Ollama
```

The service selection values are forwarded into service modules and, in some cases, into the dedicated `selfhost` Home Manager configuration. The exact option names can differ across these layers. Trace the actual assignments rather than assuming matching names represent the same option.

The rootless Docker deployment is shared infrastructure. Service-specific modules should provide their own compose and lifecycle details while relying on the shared deployment layer where appropriate.

## Tracing an option

To answer “is this feature enabled?” or “where is this option declared?” follow this sequence:

1. Find the exact option declaration.
2. Identify the module system and namespace.
3. Find every assignment to that exact option.
4. Trace imports to determine whether the declaring module participates in the target host/user evaluation.
5. Resolve conditional definitions and defaults.
6. Inspect the evaluated configuration when the question asks for the effective value.

Do not infer an option's effective value from a declaration, a default, an import, a package, or a similarly named option elsewhere.

## Configuration flow versus source search

RAG retrieval can find relevant source snippets, but it does not itself establish the complete import graph or evaluated value. For questions involving effective configuration, retrieve the relevant host entry point and every link in the option-assignment chain. For exact source declarations, inspect the declaration in its own file and preserve its source attribution.
