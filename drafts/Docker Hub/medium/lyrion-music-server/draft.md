# lyrion-music-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: lyrion-music-server
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: lyrion-music-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/lmscommunity/lyrionmusicserver:9.2.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/LMS-Community/slimserver-platforms/blob/d05c757/Docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/LMS-Community/slimserver)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://lyrion.org/downloads/)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Perl music server from the slimserver project with bundled native helpers, shipped as official Debian packages. On containerforge-ubuntu we would install the vendor .deb, which pulls Perl and bundles, and run rootless with state under /config. Several helper processes but a single server.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [lmscommunity/lyrionmusicserver:9.2.0](https://hub.docker.com/r/lmscommunity/lyrionmusicserver)
- **copy-from arm64**: [lmscommunity/lyrionmusicserver:9.2.0](https://hub.docker.com/r/lmscommunity/lyrionmusicserver)

### Dependency containers

- **Dependency containers**: none
