# barcodebuddy

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: barcodebuddy
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/barcodebuddy
- **Source repository**: https://github.com/Forceu/barcodebuddy

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/f0rc3/barcodebuddy

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: PHP web app with a Go supervisor binary, with PHP provided by apt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: nginx, php-fpm and PHP extensions (inferred)
- python/pip: none
- node/npm: none
- other: PHP app fetched from git; Go supervisor built in a golang stage

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/barcodebuddy
- non-root: possible - chart sets runAsUser 0; web server and Go supervisor need a non-root layout
- read-only-rootfs: possible - chart sets false; draft moves state to /config
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: none beyond /config
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: barcodebuddy
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/f0rc3/barcodebuddy:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Forceu/barcodebuddy-docker/blob/527c3c637a39298fb0b5ab57cf532bbdc2aa54b5/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Forceu/barcodebuddy)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Forceu/barcodebuddy/releases/tag/v1.9.0.1)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: PHP web app fetched from git plus a Go supervisor binary built in a golang stage, all on alpine. Several processes (web server, PHP and supervisor) need an s6-style layout or a custom supervisor on containerforge-ubuntu, with state moved to /config. The compiled supervisor adds per-arch builds.

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
