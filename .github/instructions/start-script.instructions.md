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

## Network

- Servers MUST listen on all interfaces, as they are used from other containers. Packaged configs often default to localhost, so check what the server actually binds to, and connect from outside the container.
- The exception is a database started without a password. It SHOULD only listen on localhost, and say so in its log.

## Environment

- Read configuration from env vars defined in the sibling `settings.yaml`. Provide sensible defaults matching `settings.yaml`. The names in `settings.yaml` MUST be the ones the script and the app really read, as a wrong name is silently ignored.
- Values from the environment often end up in SQL, XML or a command. Do not break on special characters, and keep secrets out of files and the process list.
- For databases, apply passwords from the environment on every start, so changing one also works on existing data.
