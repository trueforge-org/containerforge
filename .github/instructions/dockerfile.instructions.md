---
description: "Dockerfile rules for ContainerForge apps: user/permissions, read-only-rootfs, /app vs /config vs /tmp, COPY --chmod, base image reuse, runtime user switching, downstream FROM consumers."
applyTo: "apps/**/Dockerfile"
---

# Dockerfile Rules (apps/**/Dockerfile)

## Runtime user

- The final stage MUST end with `USER apps` (not `apps:apps`).
- Switch to `USER root` only for elevated install steps (e.g. `apt-get`), then switch back.
- Assume upstream base images already run as `USER apps`.

## Filesystem (read-only-rootfs compatible)

- `/app` is read-only at runtime. It MUST contain the application binary/assets and MUST NOT require write access.
- `/config` is persistent storage, MAY be empty at container start. Apps using `ghcr.io/trueforge-org/golang` MUST run correctly with empty `/config`.
- `/tmp` is ephemeral (ramdisk-style) scratch space. ALL build/runtime caches (`GOCACHE`, pip cache, npm cache, scratch) MUST go to `/tmp`, never `/config`.
- Do NOT place temporary caches in `/config` unless persistence is explicitly required.
- System binaries (Go, Python, etc.) MAY live under `/usr/local` so `/app` stays empty for downstream `FROM` consumers.

## Required directives

- MUST include `COPY --chmod=0755 . /` so container tests work. Do NOT remove it unless explicitly requested.
- `include/.dockerignore` is copied into each app's folder during the build, and it is an allow-list. `COPY . /` only copies the paths it lists, such as `start.sh`, `scripts/`, `defaults/`, `etc/` and `health/`. Any other file in the app's folder silently does not reach the image, so put extra files in one of those paths.

## Layout siblings

- `app/`, `etc/`, `defaults/` belong at the same level as `docker-bake.hcl` and SHOULD be used as the runtime copy source.
- `root/` is reserved for run-time copy-to-rootfs only and MUST NOT be touched by agents.

## Base image reuse

- Do NOT re-install packages already provided by the upstream/base image (check before adding `apt-get install`).
- Pinned digests on base images SHOULD be preserved when already present.

## Go in Dockerfiles

- Go binaries MUST be built in a dedicated build stage and copied into the runtime stage with `COPY --from=`.
- Do NOT compile Go in the runtime stage.

## Version alignment

- `ARG VERSION` (and similar) values MUST match the defaults declared in the sibling `docker-bake.hcl`.
- The image MUST contain the version it is tagged with. An unpinned `apt-get install` gets whatever the base image's release has, so pin the package and check it against `VERSION`, as `apps/valkey/Dockerfile` does.

## Downloaded software

- Verify downloads against the checksum the upstream publishes, where it has one.
- When extracting only some files from an upstream archive, also ship its license and third-party notices, for example in `/usr/share/licenses/<app>/`.
- The `LICENSE` in `docker-bake.hcl` MUST be the license of the software in the image.
