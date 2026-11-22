# lyrion-music-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: lyrion-music-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/lyrion-music-server
- **Source repository**: https://github.com/LMS-Community/slimserver
- **Documentation**: https://lyrion.org/getting-started
- **Website**: https://lyrion.org

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/lmscommunity/lyrionmusicserver

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Perl server installed from the vendor .deb, so ubuntu with apt packages fits.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: vendor .deb from lyrion.org installed with apt/dpkg (not a repo package)
- python/pip: none
- node/npm: none
- other: Perl runtime pulled by the vendor .deb

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9000/http (web UI and streaming), 9090/tcp (CLI), 3483/tcp (SlimProto player control), 3483/udp (player discovery)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/lyrion-music-server
- non-root: possible - chart forces runAsUser 0 and runAsNonRoot false; Perl server from .deb
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false
- privileged: no - common default, not overridden
- other-security: none (ports 3483 tcp and udp, 9090 CLI)
- extra-persistence: none beyond /config
- confidence: medium

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
