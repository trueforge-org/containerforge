# flaresolverr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: flaresolverr
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/flaresolverr
- **Source repository**: https://github.com/FlareSolverr/FlareSolverr

## Potentially relevant resources

- **Container image**: https://ghcr.io/flaresolverr/flaresolverr

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python service that drives a Chromium browser.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: chromium (deb or tarball build, not snap; inferred)
- python/pip: selenium, undetected-chromedriver, bottle, waitress (inferred from upstream requirements)
- node/npm: none
- other: release tarball v3.5.2

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: flaresolverr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/flaresolverr/flaresolverr:v3.5.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/FlareSolverr/FlareSolverr/blob/93125d6ea6956906c8dfa29e169b2dc67d993dc3/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/FlareSolverr/FlareSolverr)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/FlareSolverr/FlareSolverr/releases/download/v3.5.2/flaresolverr_linux_x64.tar.gz) · [arm64](https://github.com/FlareSolverr/FlareSolverr/releases/tag/v3.5.2)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Python 3.11 service that drives a Chromium browser, so the image is a large stack. Ubuntu ships Chromium as a snap, so a deb or tarball browser build is needed for containerforge-ubuntu. Upstream runs as root, so the browser profile must move to /tmp for a read-only rootfs.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/flaresolverr/flaresolverr:v3.5.2](https://ghcr.io/flaresolverr/flaresolverr)
- **copy-from arm64**: [ghcr.io/flaresolverr/flaresolverr:v3.5.2](https://ghcr.io/flaresolverr/flaresolverr)

### Dependency containers

- **Dependency containers**: none
