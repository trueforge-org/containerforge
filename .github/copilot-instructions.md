# Copilot Instructions for ContainerForge

## Quick Start (Agent)

- You MUST keep changes inside `apps/<app>/` unless the task explicitly requires shared or cross-app edits.
- You MUST keep changes minimal, and you MUST NOT make unrelated refactors or formatting-only edits.
- Containers MUST run as `apps`, MUST remain read-only-rootfs compatible, and MUST treat `/app` as read-only.
- You MUST treat `/config` as persistent storage that may be empty at startup, and you MUST use `/tmp` for ephemeral cache/scratch.
- For Python containers, you MUST treat `/app/venv` as image-provided and read-only at runtime; use `/tmp/venv` for ephemeral writable venvs and `/config/venv` for persistent writable venvs.
- For Docker bake/version edits, you MUST keep `docker-bake.hcl` and `Dockerfile` aligned, and you MUST run `docker buildx bake --print` from the app directory.
- For Go containers, you MUST build binaries in a build stage and copy them into the runtime stage, and you MUST NOT compile in the runtime stage.
- If a changed container image is used downstream via `FROM`, you MUST update `apps/<app>/DOWNSTREAM_CHANGES.md` with affected paths, exact required changes, and normalized base version (`x.y.z`).

Use these rules as strict defaults when making changes in this repository.

## 1) Scope and change boundaries

- You MUST treat this repo as one app per folder under `apps/<app>` plus shared assets in `include/`.
- You MUST scope changes to the smallest possible surface area for the affected app.
- You MUST keep most updates inside the same `apps/<app>/` directory.
- You MUST NOT introduce unrelated refactors or formatting-only edits.

## 2) Image/version consistency

- When changing container image versioning, you MUST ensure values in `docker-bake.hcl` are actually used by the corresponding `Dockerfile`.
- You SHOULD use semantic naming (Conventional Commits style) for commit messages and PR titles.

## 3) Validation requirements

- For Docker bake changes, you MUST validate from the app directory with:
  - `docker buildx bake --print`

## 4) Security and reliability defaults

- You SHOULD prefer pinned versions/digests where already used.
- You MUST NOT add dependencies unless required for the task.
- You MUST preserve rootless and minimal container behavior.

## 5) Go-specific rules

- You MUST NOT change `go.mod` or `go.sum` on unrelated PRs.
- Go binaries MUST be built in a dedicated build stage and copied into the final/runtime stage.
- You MUST NOT compile Go binaries in the runtime stage.

## 6) Container runtime requirements (mandatory)

- Containers MUST run as user `apps` (not `apps:apps`).
- Containers MUST remain compatible with read-only root filesystem (`read-only-rootfs`).
- You MUST assume `/app` is read-only.
- `/app` MUST contain the application binary and MUST NOT require write access.
- `/config` MUST be mountable as persistent storage and MAY be empty at container start.
- If the app needs writable files at runtime, you MUST populate/copy required files into `/config` during runtime.
- Applications using `ghcr.io/trueforge-org/golang` as their final stage MUST run correctly when `/config` is empty.
- `/config` is for persistence only; you MUST NOT place temporary caches there unless persistence is explicitly required.
- You SHOULD store application configuration files in `/config` when possible.
- `/tmp` is ephemeral (ramdisk-style) scratch space.
- Ephemeral caches (for example `GOCACHE`, pip cache, npm cache, build scratch) MUST use `/tmp`, not `/config`.
- Important system binaries (for example Go or Python) MAY be installed under `/usr/local` so `/app` remains empty for downstream `FROM` consumers.
- You MUST include `COPY --chmod=0755 container-test.yaml /container-test.yaml` in Dockerfiles to enable container tests, and you MUST NOT remove it unless explicitly requested.
- You MUST include `COPY --chmod=0755 . /` in Dockerfiles to enable container tests, and you MUST NOT remove it unless explicitly requested.
- container-test.yaml has a json schema in `testhelpers/container-test-schema.json` that defines required properties for container tests. You MUST follow the schema when editing or adding container-test.yaml files.

## 7) Base-image and downstream impact rules

- Before changing a container image, you MUST check whether it is used as a `FROM` base in other Dockerfiles.
- You MUST assume upstream base images run as `USER apps` by default.
- If commands require elevated permissions (for example `apt`/`apt-get`), you MUST switch to `USER root` first as needed.
- If a changed container image is used downstream, you MUST document required downstream updates in `apps/<app>/DOWNSTREAM_CHANGES.md` (in the source app directory).
- `apps/<app>/DOWNSTREAM_CHANGES.md` MUST include:
  - Each affected downstream container path.
  - The exact required change for each downstream container.
  - The base-image version where the change is expected, sourced from the app's `docker-bake.hcl` `VERSION` and normalized to `x.y.z`.
- You MUST NOT document downstream requirements as inline comments in Dockerfiles unless explicitly requested.

- You MUST avoid re-installing packages that are already provided by upstream/base images (for example via `apt-get`). Check the base image contents before adding OS-level packages, and prefer using what the base image supplies.

## 8) Practical execution checklist

When completing a task, you MUST verify:

1. Changes are minimal and app-scoped.
2. Version values in `docker-bake.hcl` and `Dockerfile` are consistent.
3. Runtime behavior remains rootless and read-only-rootfs compatible.
4. `/config` empty-start behavior works where required.
5. Any downstream `FROM` impact is documented in `apps/<app>/DOWNSTREAM_CHANGES.md`.
6. `docker buildx bake --print` has been run for Docker bake changes.

## 9) Python-specific runtime rules

- You MUST treat `/app/venv` as a bundled base venv and you MUST NOT write or mutate it at runtime.
- If Python deps/venv content must be writable and non-persistent, you MUST use `/tmp/venv`.
- If Python deps/venv content must be writable and persistent, you MUST use `/config/venv`.
- For empty `/config` startup, you SHOULD seed `/config/venv` from `/app/venv` in startup logic only when `/config/venv` is missing or empty.
- You MUST avoid runtime symlink assumptions for `/config/venv`; use an actual directory.
- You MUST keep temporary installer/build/cache artifacts in `/tmp` (not `/config` and not `/app/venv`).

Python venv mode selection:

- Read-only runtime: use `/app/venv` directly.
- Writable ephemeral runtime: seed/use `/tmp/venv`.
- Writable persistent runtime: seed/use `/config/venv`.

