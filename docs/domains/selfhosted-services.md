# Self-Hosted Services: Architecture and Conventions

## Purpose and scope

This document describes the self-hosted services architecture in the `~/nixOS` repository. It is intended as shared domain context for focused code search and RAG-assisted source inspection.

The current deployment is centered on the desktop NixOS host and rootless Docker. The architecture is being organized so service definitions and reusable configuration can eventually be deployed on a separate NixOS server. That future server migration is a design goal, not a description of the current deployment.

When answering questions about this repository, inspect the named source file. This document explains relationships and intent; it does not replace the implementation.

## Architectural overview

The self-hosted configuration is divided into several responsibilities:

1. **Host selection and policy** — a host enables the self-hosted system and selects services.
2. **Shared module interface** — `modules/selfhosted/options.nix` declares the `services.selfhost` option namespace and its service/deployment settings.
3. **Deployment infrastructure** — `modules/selfhosted/deployments/rootless-docker.nix` provides the rootless Docker deployment layer.
4. **Application integration** — `modules/selfhosted/applications/home-manager.nix` connects enabled applications to Home Manager-managed user-level configuration/deployment.
5. **Service-specific definitions** — directories such as `modules/selfhosted/sure/`, `modules/selfhosted/immich/`, `modules/selfhosted/grocy/`, and `modules/selfhosted/ollama/` contain service-specific flake/configuration code.
6. **Host-level network access** — Tailscale Serve is configured at the NixOS host level to expose selected local service ports through the tailnet.

These layers are related but not interchangeable. An option declaration does not enable a service. A host assignment does not by itself prove a container is running. A flake input does not prove that its module is imported or selected. Trace each claim to the relevant declaration, import, assignment, and runtime evidence.

## Repository locations

| Path | Responsibility |
|---|---|
| `hosts/desktop/selfhost.nix` | Desktop host's self-hosted service selections and settings |
| `hosts/desktop/default.nix` | Desktop NixOS entry point; imports host and shared modules |
| `hosts/desktop/infrastructure.nix` | Desktop infrastructure composition |
| `modules/selfhosted/default.nix` | Self-hosted module aggregator |
| `modules/selfhosted/options.nix` | Shared `services.selfhost` option declarations and defaults |
| `modules/selfhosted/deployments/rootless-docker.nix` | Rootless Docker deployment infrastructure |
| `modules/selfhosted/applications/home-manager.nix` | Home Manager integration for self-hosted applications |
| `modules/selfhosted/infrastructure/` | Shared self-hosted infrastructure integrations, including Home Manager and Tailscale-related configuration |
| `modules/selfhosted/sure/` | Sure service-specific flake/configuration |
| `modules/selfhosted/immich/` | Immich service-specific flake/configuration |
| `modules/selfhosted/grocy/` | Grocy service-specific flake/configuration |
| `modules/selfhosted/ollama/` | Ollama service-specific flake/configuration |

Check the current tree before relying on this inventory; files may move as the architecture evolves.

## Configuration flow

The intended configuration path is:

```text
root flake
  └── NixOS desktop configuration
        ├── hosts/desktop/default.nix
        │     ├── hosts/desktop/selfhost.nix
        │     └── shared modules, including modules/selfhosted/
        └── self-hosted module aggregator
              ├── options.nix
              ├── deployments/rootless-docker.nix
              ├── applications/home-manager.nix
              └── service-specific modules / flakes
```

The exact import and evaluation path must be verified from the current root flake, host entry point, and aggregator. Do not infer that a file is active merely because it exists in the repository.

At the host layer, `services.selfhost` is used to enable the shared self-hosted configuration, provide Docker DNS settings, and select individual services. The current desktop configuration has used service enable flags such as `immich.enable`, `sure.enable`, and `grocy.enable`. Confirm the current `hosts/desktop/selfhost.nix` before quoting the exact active values.

## Deployment model: rootless Docker

The current deployment approach is rootless Docker. The project intentionally postponed migration to native NixOS containers; do not recommend or describe native NixOS containers as the current implementation.

The rootless deployment layer is kept separate from service-specific definitions so that deployment mechanics can be reused or changed without embedding all host policy in every application.

Important distinctions:

- The Docker daemon/socket is user-level in the rootless deployment model.
- A container's internal listening port is not necessarily the host-facing port.
- Host networking, container networking, published ports, and Tailscale Serve targets are separate configuration decisions.
- A Home Manager module or subflake may configure a user-level deployment without being a NixOS system service.
- A configured deployment does not prove successful runtime state; use Docker and service logs for runtime verification.

The dedicated `selfhost` system user has been configured with UID/GID `996` in the current setup. Verify the current declaration before changing ownership or hard-coding these values elsewhere.

The shared self-hosted options have included a configurable data directory, UID/GID, and Docker DNS list. The desktop host has supplied external DNS servers through `services.selfhost.docker.dns`. Check the option declarations and host assignments for authoritative defaults and current values.

## Service-specific responsibilities

### Sure

Sure is deployed using its service-specific configuration under `modules/selfhosted/sure/`. The known container stack has included:

- `ghcr.io/we-promise/sure:stable` for the web application
- PostgreSQL 16
- Redis 7

The web application has been served locally on port `3000`. Tailscale Serve has been configured to proxy HTTPS on the tailnet to `127.0.0.1:3000`. The application server itself speaks HTTP on that local target; do not configure the Puma endpoint as HTTPS merely because users access it through Tailscale HTTPS.

Secrets and credentials must remain outside committed source files. Do not expose secret values in generated documentation, RAG prompts, logs, or command output.

### Immich

Immich is defined under `modules/selfhosted/immich/`. Its data directory has been configured under `/home/graysonr/immich`, and its local service port is `2283`. Tailscale Serve has been configured to expose it through host port `8443`, targeting `127.0.0.1:2283`.

Verify current service ports and data paths in source before modifying them.

### Grocy

Grocy is defined under `modules/selfhosted/grocy/` and has used a rootless Docker Compose deployment based on the LinuxServer image. Its local service port has been `9283`. Tailscale Serve has been configured to expose it through host port `8444`, targeting `127.0.0.1:9283`.

Verify the Compose file and current data directory before making changes.

### Ollama

Ollama has a service-specific configuration under `modules/selfhosted/ollama/`. It is used as a local model-serving backend, including by aichat. The current rootless Docker endpoint used by aichat has been `http://127.0.0.1:11435/v1`.

Do not assume that the host's `ollama` CLI can connect to this container automatically. The user has encountered the host CLI reporting that it cannot connect to an Ollama server even while the rootless container is the intended deployment. Inspect the container, published port, and configured endpoint rather than assuming a host-native daemon.

## Tailscale Serve and network boundaries

Tailscale Serve is configured at the NixOS host level, separately from the rootless Docker service definitions. The current host-level oneshot service is named `selfhost-tailscale-serve`; it is ordered after Tailscale and network-online prerequisites and configures local reverse-proxy targets.

Known mappings:

| Service | Local target | Tailnet HTTPS port |
|---|---:|---:|
| Sure | `127.0.0.1:3000` | `443` |
| Immich | `127.0.0.1:2283` | `8443` |
| Grocy | `127.0.0.1:9283` | `8444` |

These mappings describe the known configuration at the time this document was written. Confirm the current NixOS module and runtime Serve status before relying on them.

Keep the layers clear:

- Container port: where the application listens inside its container.
- Host loopback port: where the deployment makes the service available on the host.
- Tailscale Serve port: the HTTPS port exposed to tailnet clients.

Do not expose these services publicly by adding broad LAN/WAN firewall openings unless the user explicitly intends that network exposure. Tailscale access and public internet access are different threat models.

## Data, persistence, and secrets

Persistent application data should be stored outside ephemeral container layers and should use the service's configured data directory or volume mappings. Before moving a service to another host, identify every persistent volume, database, secret, environment variable, and required ownership mapping.

Do not assume that changing a data-directory option migrates existing data. A safe migration requires a backup, a verified destination, correct ownership/permissions, and a tested restore or cutover procedure.

Never put passwords, API tokens, database credentials, private keys, or other secret values in this document or in RAG-indexed Markdown. Document secret *names and wiring locations* only when needed, not secret values.

## Reuse and future server migration

The longer-term goal is to make the self-hosted configuration portable to a separate dedicated NixOS server. To support that goal:

- Keep reusable service definitions separate from desktop-specific host policy.
- Keep host selections, hardware assumptions, local paths, and network addresses at the host layer where practical.
- Avoid embedding desktop-only assumptions in shared service modules.
- Make persistence paths, user IDs, DNS, ports, and external access explicit options where they genuinely vary by host.
- Keep deployment mechanics separate from application-specific configuration.
- Document dependencies between services and their data stores.
- Validate the actual module import graph before moving or extracting modules.

The server host directory has been planned but was empty in the repository listing used to create this document. Do not describe a server deployment as implemented until its host configuration exists and is evaluated.

## Troubleshooting and source-of-truth rules

For a question about a specific option, quote the declaration from the file that actually declares it. Do not infer a child option's description from a similarly named parent option.

For a question about whether a service is enabled, inspect both:
1. the option declaration and its default; and
2. the active host assignment.

For a question about whether a module participates in the build, trace imports from the root flake through the host entry point and module aggregators.

For runtime questions, inspect the actual rootless Docker containers, Compose configuration, logs, published ports, and Tailscale Serve status. Nix source establishes intended configuration, not proof of successful runtime state.

Useful investigation targets include:

- `flake.nix`
- `hosts/desktop/default.nix`
- `hosts/desktop/selfhost.nix`
- `hosts/desktop/infrastructure.nix`
- `modules/selfhosted/default.nix`
- `modules/selfhosted/options.nix`
- `modules/selfhosted/deployments/rootless-docker.nix`
- `modules/selfhosted/applications/home-manager.nix`
- the relevant service directory under `modules/selfhosted/`

## RAG guidance

This document is shared architectural context, not a substitute for source retrieval. Prefer the actual implementation files for exact option names, descriptions, values, imports, and service definitions.

When answering source-inspection questions:

1. Identify the exact file requested.
2. Retrieve that file's own relevant declaration or assignment.
3. Distinguish it from similarly named declarations in parent modules or other services.
4. Quote the source path and exact text when requested.
5. If the requested source text is absent from retrieved context, say so and request or retrieve the file rather than guessing.
