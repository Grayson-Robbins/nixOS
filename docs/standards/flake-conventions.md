# Flake Conventions

## Purpose

This document describes conventions for the repository's root flake and nested local flakes. It does not assume every local flake is a standalone deployable system.

## Root flake responsibilities

The root `flake.nix` is the repository's primary composition point.

It should:
- Declare external and local flake inputs.
- Keep input relationships explicit, using `follows` where appropriate.
- Define shared values such as the target system where useful.
- Construct host configurations.
- Pass required inputs or special arguments explicitly.
- Avoid containing large amounts of reusable module implementation.

The observed root flake defines an `x86_64-linux` system, a `nixosConfigurations.desktop` configuration, and a `nixosConfigurations.nixos` alias to the desktop configuration. It also references local flakes for services such as Immich, Sure, Grocy, and Ollama.

Verify the current root flake before relying on this description after future refactors.

## Local flakes

Use a nested flake when a component benefits from an independently managed input set, lock file, output interface, or reusable module boundary.

The repository currently has nested flakes for:
- `modules/selfhosted/sure/`
- `modules/selfhosted/immich/`
- `modules/selfhosted/grocy/`
- `modules/selfhosted/ollama/`
- `modules/nixos/nvf/`
- `homeModules/applications/odysseus/` (legacy location; migration planned)

A nested flake should have a clearly defined purpose and documented outputs. Do not assume that a nested flake is automatically part of a host configuration simply because it exists.

## Inputs and outputs

- Give inputs descriptive names.
- Use `inputs.<name>.url` consistently.
- Use `inputs.<name>.inputs.nixpkgs.follows = "nixpkgs"` when the dependency should share the root nixpkgs input.
- Keep output arguments readable; use `...` only when appropriate.
- Expose module outputs with clear names when the flake provides NixOS or Home Manager modules.
- Keep package outputs distinct from module outputs.
- Do not confuse a flake input with an imported module or an enabled feature.

## Local path inputs

For local flakes, use explicit local paths and maintain the corresponding root input declaration and output wiring.

When moving a nested flake:
1. Update the root flake input path.
2. Update any imports or references to its outputs.
3. Run flake evaluation and validation.
4. Review the root `flake.lock` changes.
5. Confirm the resulting host configuration still evaluates.

## Lock files

- Commit lock-file changes that are required for reproducible builds.
- Do not hand-edit lock files unless there is a specific, understood reason.
- Review lock-file diffs after changing inputs.
- Keep nested flake lock files when those flakes are intentionally independently locked; document why they exist.
- Avoid unnecessary lock-file churn.

## Flake/module boundaries

Prefer this separation:
- Root flake: repository inputs and host composition.
- Host modules: host-specific selection and values.
- Reusable module directories: reusable implementation.
- Nested flakes: independently versioned or composed components with explicit outputs.

A nested flake should not become a workaround for unclear module boundaries. Use one only when the independent flake interface provides real value.

## Validation

After changing a flake:
- Run `nix flake show` for the relevant flake.
- Evaluate the affected output where practical.
- Run the appropriate NixOS or Home Manager build/check.
- Inspect `flake.lock` changes.
- Confirm that local path inputs resolve from the intended repository location.

Use the repository's actual available commands and host names; do not assume an output exists without checking.
