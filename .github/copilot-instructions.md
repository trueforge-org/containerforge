# Copilot Instructions for ContainerForge

> **MANDATORY** — Before editing or creating any file under `apps/<app>/`, you MUST read the matching instruction file(s) in [.github/instructions/](instructions/) and follow them exactly. Do not proceed from memory or summary; the instruction files are the source of truth.

## Always-on rules (universal)

- Treat this repo as **one app per folder** under `apps/<app>/` plus shared assets in `include/`.
- Scope every change to the smallest possible surface area for the affected app. Most changes MUST stay inside the same `apps/<app>/` directory.
- No unrelated refactors, no formatting-only edits, no dependency additions unless required for the task.
- Use Conventional Commits style for commit messages and PR titles.
- Never commit secrets, tokens, or `.env` files.
- Ignore everything under `porting/` — it is legacy tooling and not part of any agent workflow.

## Required reading per file type

When you touch any of these files, you MUST first load and follow the matching instruction file:

| Editing this file | Required instructions |
|---|---|
| `apps/**/Dockerfile` | [dockerfile.instructions.md](instructions/dockerfile.instructions.md) |
| `apps/**/docker-bake.hcl` | [docker-bake.instructions.md](instructions/docker-bake.instructions.md) |
| `apps/**/settings.yaml` | [settings-yaml.instructions.md](instructions/settings-yaml.instructions.md) |
| `apps/**/container-test.yaml` | [container-test.instructions.md](instructions/container-test.instructions.md) |
| `apps/**/start.sh`, `apps/**/entrypoint.sh`, `apps/**/root/**/run` | [start-script.instructions.md](instructions/start-script.instructions.md) |
| Any Python-based app (base `python` / `python-node`, or `/app/venv` present) | [python-runtime.instructions.md](instructions/python-runtime.instructions.md) |
| Any Go-based app (Go build stage, or base `golang`) | [go-runtime.instructions.md](instructions/go-runtime.instructions.md) |
| Any build/run/test work in `apps/<app>/` (all agents and AI runners) | [build-test-protocol.instructions.md](instructions/build-test-protocol.instructions.md) |

These are the source of truth for runtime model (`/app` vs `/config` vs `/tmp`), `USER apps` rules, read-only-rootfs compatibility, base-image reuse, version alignment, renovate annotations, and per-language venv/build rules. Do NOT restate or reinterpret them here — read them.

## Validation gates (mandatory)

- For any `docker-bake.hcl` or `Dockerfile` change: run `docker buildx bake --print` from the app directory. Must succeed.
- For any container behavior change: container tests defined in `apps/<app>/container-test.yaml` must pass. Never weaken a test to make it pass — fix the real defect.
- For any build/run/test work, follow the shared loop in [build-test-protocol.instructions.md](instructions/build-test-protocol.instructions.md): bake-print → build → run + log success check → test, with per-app commit cadence in PR mode and the documented narrow exception for database-dependent apps.

## Downstream impact

- Before changing a container image, check whether it is used as a `FROM` base in other Dockerfiles in this repo.
- If a changed image is consumed downstream, document required downstream updates in `apps/<app>/DOWNSTREAM_CHANGES.md`, including:
  - each affected downstream container path,
  - the exact required change,
  - the base-image version where the change is expected, sourced from this app's `docker-bake.hcl` `VERSION` and normalized to `x.y.z`.
- Do NOT document downstream requirements as inline comments in Dockerfiles unless explicitly requested.

## Pre-completion checklist

1. Changes are minimal and app-scoped.
2. The matching instruction files were loaded and followed.
3. `docker-bake.hcl` and `Dockerfile` are version-aligned.
4. Runtime stays rootless and read-only-rootfs compatible.
5. `/config` empty-start behavior works where required.
6. Downstream `FROM` impact is documented in `apps/<app>/DOWNSTREAM_CHANGES.md` when applicable.
7. `docker buildx bake --print` ran for any bake/Dockerfile change.
