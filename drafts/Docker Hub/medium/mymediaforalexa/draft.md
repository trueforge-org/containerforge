# mymediaforalexa

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: mymediaforalexa
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/mymediaforalexa
- **Website**: https://www.mymediaalexa.com/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/bizmodeller/mymediaforalexa
- **Website**: https://www.mymediaalexa.com/home/docker#dockerhub

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Vendor .deb files unpacked with dpkg on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none (vendor .deb unpacked with dpkg -x, no repo packages)
- python/pip: none
- node/npm: none
- other: vendor .deb amd64 and arm64 (bizmodeller S3)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: mymediaforalexa
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/bizmodeller/mymediaforalexa:1.3.156.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.mymediaalexa.com/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://bizmodeller.s3.amazonaws.com/MyMediaForAlexa/1.3.147.994/linux/mymedia_1.3.147.994-1_amd64.deb) · [arm64](https://bizmodeller.s3.amazonaws.com/MyMediaForAlexa/1.3.152.0/linux/mymedia_1.3.152.0-1_arm64.deb)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Closed-source vendor debs for amd64 and arm64 from the vendor download page, unpacked on containerforge-ubuntu with dpkg -x. Version on the page lags the 1.3.156.0 tag; needs two fixed ports on the host network and writable /datadir under /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [bizmodeller/mymediaforalexa:1.3.156.0](https://hub.docker.com/r/bizmodeller/mymediaforalexa)
- **copy-from arm64**: [bizmodeller/mymediaforalexa:1.3.156.0](https://hub.docker.com/r/bizmodeller/mymediaforalexa)

### Dependency containers

- **Dependency containers**: none
