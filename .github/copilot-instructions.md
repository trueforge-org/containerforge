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
- When working on containers, check if they are used as `from` containers in other Dockerfiles and take this into account when making alterations.
- When a container is used as a `from` container elsewhere, ensure to document required changes on those other containers.
- Assume the dockerfile always has to explicitly move to `USER root` because the from container likely runs as non-root
- `/app` will be read-only
- `/config` will be mounted as a persistent storage option and hence empty on runtime
- `/app` contains the application (binary) itself, that does not require write access
- Application configuration files go into `/config` when possible
- If an application requires write access, use copy those things to `/config` during runtime
- Important system binaries, such as go or python, can be put into `/usr/local` paths. This ensures `/app` is empty for containers using this as a `from` container
