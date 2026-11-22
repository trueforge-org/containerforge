# steam-headless

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: steam-headless
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/steam-headless
- **Website**: https://store.steampowered.com/about/

## Potentially relevant resources

- **Source code repository**: https://github.com/Steam-Headless/docker-steam-headless
- **Container image**: https://hub.docker.com/r/josh5/steam-headless

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Steam desktop streaming client installed from Valve apt packages on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: steam (Valve repo .deb), xvfb, x11vnc (inferred)
- python/pip: none
- node/npm: none
- other: Valve steam_latest.deb download (amd64 only)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8083/http (noVNC web UI, inferred), 8084/https (inferred), 47984/tcp (game streaming, inferred), 47990/tcp (streaming web API, inferred), 47998-48000/udp (streaming, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/steam-headless
- non-root: no - chart sets runAsUser 0, runAsGroup 0, runAsNonRoot false, privileged true
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: yes - chart sets container privileged true
- other-security: privileged; no GPU or /dev/input devices declared in values (Reason says GPU and input devices are needed)
- extra-persistence: /home/default (pvc, home), /mnt/games (pvc), /var/lib/flatpak (pvc)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: steam-headless
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/josh5/steam-headless:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Steam-Headless/docker-steam-headless/blob/824c88d/Dockerfile.debian)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://store.steampowered.com/about/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://repo.steampowered.com/steam/archive/stable/steam_latest.deb)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Steam desktop-streaming image with a VNC desktop, privileged mode, root init, and Steam from Valve apt packages. It is a desktop stack that needs GPU and input devices, so running rootless on a read-only rootfs needs heavy rework.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: no*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [josh5/steam-headless:latest](https://hub.docker.com/r/josh5/steam-headless)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
