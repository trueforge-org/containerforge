# nextpvr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: nextpvr
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/nextpvr
- **Website**: https://nextpvr.com

## Potentially relevant resources

- **Source code repository**: https://github.com/sub3/NextPVR/wiki/Install-Docker
- **Container image**: https://hub.docker.com/r/nextpvr/nextpvr_amd64

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Guess: vendor installer on ubuntu with no runtime base named.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: vendor Linux installer (amd64 only, arm64 no)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8866/http (web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/nextpvr
- non-root: possible - no securityContext override, common runAsUser 568; draft says the app needs root
- read-only-rootfs: possible - no override, common default true; draft expects root-era paths
- privileged: unknown - no privileged flag or device mount in values; draft says TV tuner hardware access
- other-security: nextpvr-udp service (UDP); no capabilities or devices in values
- extra-persistence: /recordings (pvc); /buffer (pvc). /config is the chart's own mount.
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: nextpvr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/nextpvr/nextpvr_amd64:stable`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://nextpvr.com)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://nextpvr.com/download.html)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Closed-source NextPVR server with no public Dockerfile, so the image must be rebuilt from the vendor Linux installer. It needs TV tuner and hardware access, plus a service stack and root, which makes it hard to run rootless.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [nextpvr/nextpvr_amd64:stable](https://hub.docker.com/r/nextpvr/nextpvr_amd64)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
