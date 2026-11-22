# debian-bullseye

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: debian-bullseye
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/debian-bullseye
- **Website**: https://www.debian.org/
- **Documentation**: https://www.debian.org/support
- **Documentation**: https://www.debian.org/doc/

## Potentially relevant resources

- **Container image**: https://ghcr.io/ich777/debian-bullseye

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Guess: Debian desktop image with no application runtime to pick.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: novnc, websockify (inferred), fluxbox, x11vnc (inferred), xvfb (inferred)
- python/pip: none
- node/npm: none
- other: debootstrap bullseye rootfs (inferred)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 6080/http (noVNC web desktop, inferred), 5900/tcp (VNC, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/debian-bullseye
- non-root: no - chart forces runAsUser 0 and runAsGroup 0 (desktop image)
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, default false
- other-security: none in values
- extra-persistence: /debian (type not set, likely pvc)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: debian-bullseye
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/debian-bullseye:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-debian-bullseye/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.debian.org/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://archive.debian.org/debian/dists/bullseye/)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Full Debian bullseye desktop image with noVNC and fluxbox, built from apt packages on a Debian-based base. The app is Debian itself, so there is no upstream application to port. The desktop/VNC stack and a large package set put it in the hard band.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/debian-bullseye:latest](https://ghcr.io/ich777/debian-bullseye)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
