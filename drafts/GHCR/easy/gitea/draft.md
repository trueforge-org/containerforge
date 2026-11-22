# gitea

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: gitea
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/go-gitea/gitea
- **Documentation**: https://docs.gitea.com/
- **Website**: https://about.gitea.com/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: gitea
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/go-gitea/gitea:28.4.0-rootless`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/go-gitea/gitea/blob/v28.4.0/Dockerfile.rootless)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/go-gitea/gitea)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/go-gitea/gitea/releases/download/v28.4.0/gitea-28.4.0-linux-amd64) · [arm64](https://github.com/go-gitea/gitea/releases/download/v28.4.0/gitea-28.4.0-linux-arm64)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go server with web assets embedded in the release binary, so the official gitea release binary can run directly on containerforge-ubuntu. Upstream is already rootless; it needs a database (chart dependency) and writes to /config. One process, and the built-in SSH server is optional.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: memcache ✅, postgresql (CNPG) ✅
