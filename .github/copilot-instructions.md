# Copilot Instructions for ContainerForge

## Repository focus

- This repository contains one app per folder under `apps/<app>` plus shared files in `include/`.
- Keep changes scoped to the smallest possible surface area for the affected app.

## Expected change patterns

- Most app updates should only touch files in the same `apps/<app>/` directory.
- When changing image versioning, ensure values in `docker-bake.hcl` are actually used by the corresponding `Dockerfile`.
- Do not introduce unrelated refactors or formatting-only edits.
- Use semantic naming (Conventional Commits style) for both commit messages and PR titles.

## Validation

- For Docker bake changes, validate from the app directory with:
  - `docker buildx bake --print`


## Security and reliability

- Prefer pinned versions/digests where already used.
- Avoid adding dependencies unless required for the task.
- Preserve rootless and minimal-container behavior.

## Go specifics

- Don't change go.sum and go.mod on unrelated PRs

## Container requirements
- Run as `apps` user
- Run `read-only-rootfs` compatible
- Ensure /config is mountable as a persistence storage option (so empty at start)
