---
description: "Use when working on Python-based ContainerForge apps (Dockerfiles based on ghcr.io/trueforge-org/python or python-node, or apps with /app/venv). Covers /app/venv read-only rule, /tmp/venv ephemeral, /config/venv persistent, seeding strategy, cache locations."
---

# Python Runtime Rules

`/app/venv` is bundled by the base image and MUST be treated as read-only at runtime.

## Venv mode selection

| Need | Location | Strategy |
|---|---|---|
| Read-only runtime | `/app/venv` | Use directly. |
| Writable + ephemeral | `/tmp/venv` | Seed/use in `start.sh`. |
| Writable + persistent | `/config/venv` | Seed from `/app/venv` in `start.sh` only when missing/empty. |

## Hard rules

- Do NOT write or mutate `/app/venv` at runtime.
- Do NOT use a symlink for `/config/venv` — use a real directory.
- Keep installer/build/cache artifacts in `/tmp` (never `/config`, never `/app/venv`).
- Pip cache, wheel cache, build scratch → `/tmp`.

## Empty `/config` startup

- For persistent-venv apps, `start.sh` SHOULD detect missing/empty `/config/venv` and seed it from `/app/venv` before launching the app.
