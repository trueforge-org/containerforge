# GitHub tiltedphoques/TiltedEvolution (Dockerfile at v1.8.4)

Source URL(s) + date:
- https://raw.githubusercontent.com/tiltedphoques/TiltedEvolution/v1.8.4/Dockerfile
- https://api.github.com/repos/tiltedphoques/TiltedEvolution/releases/latest (failed, see README)
- Fetched 2026-11-27

## Build (multi-stage Dockerfile)
- Build stage: `FROM debian:12 AS builder`, `DEBIAN_FRONTEND=noninteractive`, `XMAKE_ROOT=y`, `SHELL ["/bin/bash", "-c"]`, `ARG GITHUB_ACTIONS`
  - `apt-get install -y --no-install-recommends build-essential curl pkg-config git ca-certificates unzip libssl-dev`
  - `curl -fsSL https://xmake.io/shget.text | bash` (installs xmake)
  - `WORKDIR /src`, `COPY . /src`
  - Cache mounts `/root/.xmake/packages`, `/root/.xmake/repositories`
  - `xmake config -y -m release && xmake -y && xmake install -y -o package`
- Runtime stage: `FROM debian:12-slim AS runtime`, `WORKDIR /st-server`
  - Copies `/src/package/lib/libSTServer.so` and `/src/package/bin/SkyrimTogetherServer` to `/st-server/`
  - `ENTRYPOINT ["./SkyrimTogetherServer"]`
  - `EXPOSE 10578/udp`

## Facts
- Runtime base: glibc `debian:12-slim`
- Runs as root (no USER). No HEALTHCHECK, no VOLUME, no ENV in runtime stage, no CMD.
- Build comments: amd64 `docker build -t imagename .`; arm64 via `--platform linux/arm64`; multi-platform via buildx.
- Comment: `GITHUB_ACTIONS` build arg passed from workflow so xmake picks github.com.

## Gotchas
- No config or data path documented in the Dockerfile; config format and env overrides not fetched.
- Release tarball asset names and layout not verifiable (releases API rate-limited).
