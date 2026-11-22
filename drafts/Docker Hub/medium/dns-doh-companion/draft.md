# dns-doh-companion

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: dns-doh-companion
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/dns-doh-companion
- **Source repository**: https://github.com/cloudflare/cloudflared

## Potentially relevant resources

- **Website**: https://developers.cloudflare.com/1.1.1.1/dns-over-https/cloudflared-proxy
- **Container image**: https://hub.docker.com/r/testdasi/simple-dns-doh

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Prebuilt tunnel binary wrapped by a shell script on ubuntu.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: dns-doh-companion
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/testdasi/simple-dns-doh:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/testdasi/simple-dns-doh/blob/354be66/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/cloudflare/cloudflared)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/cloudflare/cloudflared/releases/download/2026.11.1/cloudflared-amd64.pkg) · [arm64](https://github.com/cloudflare/cloudflared/releases/download/2026.11.1/cloudflared-arm64.pkg)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Prebuilt cloudflared binary wrapped by a shell script that serves DNS on port 53. ContainerForge can ship the binary on containerforge-ubuntu, but port 53 needs root or a remapped unprivileged port, which is a small rework. No extra services.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [testdasi/simple-dns-doh:latest](https://hub.docker.com/r/testdasi/simple-dns-doh)
- **copy-from arm64**: [testdasi/simple-dns-doh:latest](https://hub.docker.com/r/testdasi/simple-dns-doh)

### Dependency containers

- **Dependency containers**: none
