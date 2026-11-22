# kdenlive-vnc

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: kdenlive-vnc
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/kdenlive-vnc
- **Source repository**: https://github.com/KDE/kdenlive
- **Documentation**: https://docs.kdenlive.org/en/
- **Website**: https://kdenlive.org/

## Potentially relevant resources

- **Source code repository**: https://github.com/JonathanTreffler/kdenlive-vnc-docker
- **Container image**: https://hub.docker.com/r/tessypowder/docker-kdenlive

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Video editor and player from apt on a desktop.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: kdenlive, vlc, xvfb (inferred)
- python/pip: none
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5800/http (noVNC web desktop, inferred), 5900/tcp (VNC, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/kdenlive-vnc
- non-root: no - chart sets runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none in values (VNC service ports)
- extra-persistence: /sharedContent (pvc, chart default)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Kdenlive is a GUI-only app, so it is used through VNC or noVNC with a password set before first use (inferred).
- caveat: Video editing needs a lot of RAM and disk for media, so the container's resources must be sized well above a typical service (inferred).
- caveat: The apt-installed Kdenlive version follows the distro, not the upstream release, so features and bugs track the base image (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: kdenlive-vnc
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/tessypowder/docker-kdenlive:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/JonathanTreffler/kdenlive-vnc-docker/blob/64ec5a1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/KDE/kdenlive)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:kdenlive`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Kdenlive and VLC installed with apt on top of a jlesage GUI base, meaning a desktop with VNC. ContainerForge would need a kasmvnc or xvfb sibling, and the user-facing app is GUI-only. The apt packages exist for both architectures, so packaging is not the blocker.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [tessypowder/docker-kdenlive:latest](https://hub.docker.com/r/tessypowder/docker-kdenlive)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
