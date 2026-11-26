# github.com/browserless/chrome (legacy v1 repo, referenced by the draft)

Source URL(s) + fetch date:
- https://github.com/browserless/chrome (README via raw) · fetched 2026-11-26
- https://github.com/browserless/chrome/releases · fetched 2026-11-26
- https://github.com/browserless/chrome/blob/2ebe1345023358d9006a3058b17dbfcc87347843/docker/chrome/Dockerfile (raw: https://raw.githubusercontent.com/browserless/chrome/2ebe1345023358d9006a3058b17dbfcc87347843/docker/chrome/Dockerfile) · fetched 2026-11-26

## What it is
Repo behind Docker Hub `browserless/chrome`. Its Dockerfile is a two-stage build on `ghcr.io/browserless/base:$VERSION` (the v2 base) and it is the image that now points at the `browserless/browserless` v2 line. The Docker Hub page calls this the old v1; the README itself does not mark it legacy (see the Docker Hub summary).

## Install/build steps and build deps
- Dockerfile `ARG VERSION=latest`; `FROM ghcr.io/browserless/base:$VERSION AS builder`, then `npm run build`, `npm run build:function`, `npm run install:debugger` in one RUN.
- Runtime stage (same base): `npm prune --omit=dev`; `bash ./scripts/install-chrome.sh`; `apt-get clean`; removes `/var/lib/apt/lists/*`, `/tmp/*`, `/var/tmp/*`; copies `build`, `static`, `extensions` from `$APP_DIR`; `chown -R blessuser:blessuser $APP_DIR`; `USER blessuser`; `CMD ["./scripts/start.sh"]`.
- No explicit apt install in the Dockerfile itself; packages come from `install-chrome.sh` (contents not fetched) and the base.
- install-chrome.sh (per Dockerfile comment) installs Google's Chrome .deb directly for the native architecture because Playwright's `install chrome` hard-fails on arm64.
- No `ENV`, `EXPOSE`, `ENTRYPOINT`, or user creation in this Dockerfile; `$APP_DIR` is defined in the base image.

## Runtime deps
See github-browserless-browserless.md (Node >=24, Xvfb for headful when DISPLAY is unset, dumb-init).

## Binaries/entrypoint/CLI flags
`CMD ["./scripts/start.sh"]` (no ENTRYPOINT).

## Env vars
Not in the README (checked). The Docker Hub page for `browserless/chrome` (v1 README) also lists none.

## Ports
3000 (README `-p 3000:3000`).

## Volumes/paths and persistent data
None mentioned in the README.

## User/UID & permissions
`blessuser` (set in Dockerfile; must exist in base).

## Healthcheck/readiness endpoints
Not stated in the README; see the browserless v2 docs (`/pressure`).

## Version/release info and asset naming
Releases page: latest release is **v2.64.4** (25 Nov 2026), i.e. the same tag series as `browserless/browserless` (the releases page for this repo reports the same versions). No v1 deprecation notice on the page. Image tags on Docker Hub: `latest`, `1-arm64`, `arm64` (local build example).

## Arch support
Dockerfile has no arch logic; install-chrome.sh picks the native deb. README: arm64 build via `docker buildx build --platform linux/arm64`.

## Gotchas
- The draft's pinned SHA `2ebe13450...` is a commit of the old repo's Dockerfile; the file path `docker/chrome/Dockerfile` is valid at that commit (fetched).
- Container image draft pins `1.61.1`, which is not the v2 line; plan.md's v2 recommendation is appropriate.
