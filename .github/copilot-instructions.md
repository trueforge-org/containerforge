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
- Go binaries must be built in a dedicated build stage and copied into the final/runtime stage; do not compile Go binaries in the runtime stage.

## Container requirements
- Run as `apps` user, not `apps:apps`
- Run `read-only-rootfs` compatible
- Ensure /config is mountable as a persistence storage option (so empty at start)
- When working on containers, check if they are used as `from` containers in other Dockerfiles and take this into account when making alterations.
- When a container is used as a `from` container elsewhere, document required downstream changes in `apps/<app>/DOWNSTREAM_CHANGES.md` in the source app directory.
- `apps/<app>/DOWNSTREAM_CHANGES.md` must list each affected downstream container path and the exact required change.
- `apps/<app>/DOWNSTREAM_CHANGES.md` must include the base-image version the change is expected in, sourced from that app's `docker-bake.hcl` `VERSION` value and normalized to `x.y.z`.
- Do not document downstream requirements as inline comments in Dockerfiles unless explicitly requested.
- Assume every `FROM` container runs as `USER apps` by default and hence might require `USER root` before running most commands, such as apt and apt-get
- `/app` will be read-only
- `/app` contains the application (binary) itself, that does not require write access
- If an application requires write access, copy those things to `/config` during runtime
- `/config` will be mounted as a persistent storage option and hence empty on runtime
- Applications using `ghcr.io/trueforge-org/golang` as their main/final stage must run correctly when `/config` is empty at container start.
- `/config` is persistence only; do not place temporary caches there unless persistence is explicitly required
- Application configuration files go into `/config` when possible
- `/tmp` will be throw away temporary storage (ramdisk) for things like cache files
- Ephemeral caches (for example `GOCACHE`, pip cache, npm cache, build scratch) must use `/tmp`, not `/config`
- Important system binaries, such as go or python, can be put into `/usr/local` paths. This ensures `/app` is empty for containers using this as a `from` container
