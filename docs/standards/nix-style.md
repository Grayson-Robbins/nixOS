# Nix Style Guide

## Goals

Write Nix that is readable, consistent, easy to review, and straightforward for both humans and retrieval-augmented tools to inspect.

## Formatting

- Use two spaces for indentation.
- Put opening braces and brackets consistently with the surrounding file.
- Use one attribute assignment per line for nontrivial sets.
- Use multiline lists when they contain multiple entries or are likely to grow.
- Keep related attributes grouped together.
- Avoid deeply nested expressions when a named `let` binding improves clarity.
- Preserve the existing formatter's conventions when one is configured; do not introduce a conflicting style in an isolated file.

Example:

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.services.example;
in
{
  options.services.example.enable =
    lib.mkEnableOption "the example service";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.example
    ];
  };
}
```

## Names and option paths

- Use descriptive names that communicate the domain and purpose.
- Follow established NixOS and Home Manager namespaces where appropriate.
- Use a project-specific namespace for custom options to avoid collisions.
- Keep option paths explicit in declarations and assignments.
- Avoid abbreviations unless they are already established project terminology.

## Options and descriptions

- Use `lib.mkEnableOption` for boolean enable switches.
- The description passed to `lib.mkEnableOption` should explain what enabling the option activates.
- Use `lib.mkOption` when an option needs a type, default, example, description, or other metadata.
- Give custom options useful descriptions and explicit types.
- Do not rely on a nearby option declaration to infer the meaning or value of another option.

Example:

```nix
options.services.example.enable =
  lib.mkEnableOption "the example service";

options.services.example.dataDirectory = lib.mkOption {
  type = lib.types.str;
  default = "/var/lib/example";
  description = "Directory used to store example service data.";
};
```

## `let` bindings

- Use `let` for values reused more than once or expressions that would obscure the main module structure.
- Name bindings after their purpose (`cfg`, `dataDirectory`, `composeFile`).
- Keep side-effecting scripts and long command strings in named bindings rather than embedding them inside large option assignments.
- Avoid introducing a binding used only once if it makes the code harder to follow.

## Imports and paths

- Use explicit relative paths for local imports.
- Keep import lists easy to scan.
- When moving a file, update relative imports and every path that refers to the moved file.
- Do not assume a directory is imported recursively; Nix module imports must be established by actual code.

## Comments

- Explain why a non-obvious choice exists, not merely what the next line does.
- Remove stale comments and commented-out configuration when it is no longer useful.
- Clearly label temporary, experimental, deprecated, and migration-related code.
- Never let a comment contradict the effective option assignment.

## Strings and scripts

- Use double-quoted strings for ordinary strings.
- Use Nix indented strings (`'' ... ''`) for multiline shell scripts or multiline text where appropriate.
- Quote shell variables and paths in shell scripts.
- Prefer `set -eu` (or stricter appropriate shell settings) in deployment scripts.
- Make environment assumptions explicit, especially runtime socket paths and user-specific directories.
- Keep secrets out of the Nix store and source-controlled files. Use runtime secret files or an established secret-management mechanism.

## Review checklist

- Is the option namespace correct for NixOS or Home Manager?
- Are option types and descriptions explicit?
- Are imports and paths correct?
- Are shell variables quoted?
- Are secrets kept out of the store?
- Does the code follow nearby formatting?
- Have obsolete comments and unused declarations been removed?
