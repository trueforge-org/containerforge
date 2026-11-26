# alpine-docker/crane (upstream Dockerfile for alpine/crane)

**Source URL(s) + fetch date:** https://github.com/alpine-docker/crane/blob/master/Dockerfile (fetched via https://raw.githubusercontent.com/alpine-docker/crane/master/Dockerfile) · fetched 2026-11-26

## What it is
Dockerfile that packages the go-containerregistry `crane` binary into a small alpine-based image (published as `alpine/crane`). Not the ContainerForge build; reference only.

## Install/build steps and build deps
- Stage 1 `alpine` (alias builder). ARGs: `ARCH` (no default), `VERSION` (default `v0.16.1` in this Dockerfile, older than the current release), `OS` (default `Linux`).
- RUN 1: `uname -m` mapped to arch: x86_64 -> x86_64; armv7l, aarch64 -> arm64; ppc64le -> ppc64le; s390x -> s390x; anything else exits 1. Written to `/envfile`.
- RUN 2: `apk add --update --no-cache curl ca-certificates bash git`; downloads `https://github.com/google/go-containerregistry/releases/download/${VERSION}/go-containerregistry_${OS}_${ARCH}.tar.gz` and extracts with tar; moves `crane` to `/usr/bin/crane`.
- Stage 2 `alpine`: copies `/usr/bin/crane`, `chmod +x`.

## Runtime deps
alpine base; crane itself is a static Go binary.

## Binaries/entrypoint/CLI flags
- ENTRYPOINT `["/usr/bin/crane"]`, CMD `["--help"]`.

## Env vars
None set.

## Ports
None.

## Volumes/paths
No VOLUME. Docker Hub examples mount `$(pwd)/.docker` at `/root/.docker` for credentials.

## User/UID & permissions
No USER set: runs as root.

## Config files and formats
Docker `config.json` at `/root/.docker/config.json` after login.

## Version/release info
Dockerfile default VERSION v0.16.1 (overridden by build arg in practice). Chart pins alpine/crane 0.22.1.

## Gotchas
- Runs as root; plan.md's ContainerForge build runs as `apps` user (intentional difference).
- Sets no ENV/WORKDIR/VOLUME.
