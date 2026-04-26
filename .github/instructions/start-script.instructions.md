---
description: "start.sh / entrypoint rules for ContainerForge apps: idempotent startup, seed empty /config, never write to /app, use /tmp for ephemeral state."
applyTo: "apps/**/start.sh, apps/**/entrypoint.sh, apps/**/root/**/run"
---

# Startup Script Rules

## Idempotency & empty-/config

- Scripts MUST run cleanly with an empty `/config` and on subsequent restarts.
- Seed required files into `/config` only when missing/empty. Do NOT overwrite existing user state.

## Writable paths

- Never write to `/app` (read-only at runtime).
- Persistent state → `/config`. Ephemeral/cache/scratch → `/tmp`.

## Process model

- The script SHOULD `exec` the final long-running process so signals propagate (PID 1 / tini handoff).

## Environment

- Read configuration from env vars defined in the sibling `settings.yaml`. Provide sensible defaults matching `settings.yaml`.
