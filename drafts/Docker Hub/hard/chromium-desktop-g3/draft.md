# chromium-desktop-g3

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: chromium-desktop-g3
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/chromium-desktop-g3
- **Source repository**: https://chromium.googlesource.com/chromium/src
- **Documentation**: https://www.chromium.org/developers/
- **Website**: https://www.chromium.org/

## Potentially relevant resources

- **Source code repository**: https://github.com/accetto/headless-drawing-g3
- **Container image**: https://hub.docker.com/r/accetto/ubuntu-vnc-xfce-chromium-g3

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Desktop with browser .deb packages on a VNC stack.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: xfce4 desktop, VNC server such as kasmvnc or tigervnc (inferred)
- python/pip: none
- node/npm: none
- other: Chromium .deb builds from vendor (not snap)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 6901/http (noVNC web desktop, inferred), 5901/tcp (VNC, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/chromium-desktop-g3
- non-root: possible - chart sets runAsUser 0; Chromium sandbox and VNC stack need rework
- read-only-rootfs: possible - chart sets false; desktop writes to home paths
- privileged: no - not set, common default false
- other-security: none in values; Chromium sandbox may need no-sandbox or namespace flags (draft)
- extra-persistence: /UNRAID_SHARE (pvc, chart mount)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Chromium's sandbox needs namespace or no-sandbox flags in a locked-down container; the default run may crash without them (inferred).
- caveat: The desktop runs through VNC and noVNC, so it is a full XFCE session and not a headless browser; it is heavy on RAM and CPU (inferred).
- caveat: The Chromium build comes from vendor .deb packages, so the version must be pinned and rechecked on each release, since Ubuntu's chromium is a snap.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: chromium-desktop-g3
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/accetto/ubuntu-vnc-xfce-chromium-g3:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/accetto/ubuntu-vnc-xfce-g3/blob/master/docker/Dockerfile.xfce.24-04)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://chromium.googlesource.com/chromium/src)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://www.chromium.org/getting-involved/download-chromium/)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: XFCE and VNC desktop running Chromium. Ubuntu's chromium is a snap, so the Dockerfile pulls .deb builds instead. It needs the kasmvnc or xvfb sibling plus several processes, and Chromium's sandbox needs namespace or no-sandbox flags in a locked-down container.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [accetto/ubuntu-vnc-xfce-chromium-g3:latest](https://hub.docker.com/r/accetto/ubuntu-vnc-xfce-chromium-g3)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
