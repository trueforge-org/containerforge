# airsonic

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: medium
- **Chart**: airsonic
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: airsonic
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/airsonic:version-v10.6.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-airsonic/blob/f234e90a76a58bc74953236f891055c99c432e4a/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/airsonic/airsonic)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/airsonic/airsonic/releases/download/v10.6.2/airsonic.war)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: airsonic.war from GitHub releases, a Java web app run on a java17 sibling with a bundled servlet container. Keep music and database in /config and move temp dirs to /tmp. The linuxserver s6 wrapper must be replaced. Medium.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/linuxserver/airsonic:version-v10.6.2](https://ghcr.io/linuxserver/airsonic)
- **copy-from arm64**: [ghcr.io/linuxserver/airsonic:version-v10.6.2](https://ghcr.io/linuxserver/airsonic)

### Dependency containers

- **Dependency containers**: none
