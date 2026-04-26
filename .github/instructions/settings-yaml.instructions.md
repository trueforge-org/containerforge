---
description: "settings.yaml rules for ContainerForge apps: schema header, ports/env/volumes/dependencies declarations, and alignment with Dockerfile, container-test.yaml, and start.sh."
applyTo: "apps/**/settings.yaml"
---

# settings.yaml Rules (apps/**/settings.yaml)

## Schema header

- MUST start with the schema header used by sibling apps:
  ```yaml
  # yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
  schema_version: 1
  ```
- MUST set `upstream_env_url` to the upstream project URL (same as `SOURCE` in `docker-bake.hcl`).

## Required sections

- `ports`: every port the container exposes, with `port`, `protocol`, `required`.
- `env`: every env var the app reads, with `name`, `default`, `required`. Defaults MUST match what `start.sh` and the upstream app expect.
- `volumes`: every mountable path. `/config` MUST be listed when the app persists state.
- `dependencies`: list other ContainerForge apps required at runtime (e.g. `postgresql`, `mariadb`).

## Cross-file alignment

- Every `ports[].port` MUST have a matching probe in the sibling `container-test.yaml`.
- Every `env[].name` SHOULD be referenced or defaulted in `start.sh` (or the app itself).
- `volumes[].path` MUST match what the Dockerfile and `start.sh` actually use (typically `/config`).
- `required: true` env vars MUST either have a non-empty `default` or be generated/handled by `start.sh` on first run.

## Discipline

- Do NOT invent env vars that the app does not actually read.
- Do NOT list ports the container does not actually open.
- Keep entries sorted/grouped consistently with sibling apps of the same family.
