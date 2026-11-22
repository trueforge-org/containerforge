# vikunja

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: vikunja
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/go-vikunja/vikunja
- **Documentation**: https://vikunja.io/docs/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: vikunja
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/vikunja/vikunja:2.8.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/go-vikunja/vikunja/blob/v2.8.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/go-vikunja/vikunja)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/go-vikunja/vikunja/releases/download/v2.8.0/veans-v2.8.0-linux-amd64-full.zip) · [arm64](https://github.com/go-vikunja/vikunja/releases/download/v2.8.0/veans-v2.8.0-aarch64.apk)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go API with the frontend embedded, shipped as release archives for linux amd64 and arm64. ContainerForge can run the binary from /app with data under /config. A valkey sibling is optional, and it runs as a single process.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [vikunja/vikunja:2.8.0](https://hub.docker.com/r/vikunja/vikunja)
- **copy-from arm64**: [vikunja/vikunja:2.8.0](https://hub.docker.com/r/vikunja/vikunja)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: valkey ✅, postgresql (CNPG) ✅
