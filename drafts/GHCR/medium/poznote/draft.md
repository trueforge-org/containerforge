# poznote

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: poznote
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/poznote
- **Source repository**: https://github.com/timothepoznanski/poznote

## Potentially relevant resources

- **Container image**: https://ghcr.io/timothepoznanski/poznote

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: poznote
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/timothepoznanski/poznote:6.153.0-rootless`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/timothepoznanski/poznote/blob/5db51e94dfa0f6f204f267505153cf5fd143feb2/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/timothepoznanski/poznote)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/timothepoznanski/poznote/releases/tag/6.153.0)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Pure PHP 8.5 FPM application, so it needs a PHP runtime that ContainerForge lacks; install PHP from Ubuntu apt and copy the source into /app, with uploads and the SQLite or data files kept under /config. Upstream already runs rootless, and its Alpine apk packages need replacing with Ubuntu equivalents.

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

- **Dependency containers**: none
