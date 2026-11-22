# universal-media-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: universal-media-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/universal-media-server
- **Source repository**: https://github.com/UniversalMediaServer/UniversalMediaServer

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/universalmediaserver/ums
- **Website**: https://www.universalmediaserver.com

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java17](https://github.com/trueforge-org/containerforge/tree/main/apps/java17) (`ghcr.io/trueforge-org/java17`)
- **Reason**: Java media server with no Java version named, so java17 is the default.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: ffmpeg
- python/pip: none
- node/npm: none
- other: UMS release tarball or AppImage (JRE from java17 sibling)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9001/http (web UI), 5001/http (inferred, media streaming), 1900/udp (SSDP discovery)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/universal-media-server
- non-root: no - runAsUser 0, runAsGroup 0 overrides
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default privileged false, not overridden
- other-security: none
- extra-persistence: /root/.config/UMS/ (pvc, chart config); /media (pvc, chart-defined)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Discovery relies on SSDP over UDP 1900 and multicast, which usually needs host networking or a network that forwards multicast; in a bridged container, DLNA devices often do not find the server (inferred).
- caveat: Upstream release is an AppImage for amd64 and a tarball for arm64, so the arm64 build path differs and needs its own testing.
- caveat: Media transcoding uses ffmpeg, which needs enough CPU and RAM; hardware transcoding is not set up by default (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: universal-media-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/universalmediaserver/ums:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/UniversalMediaServer/UniversalMediaServer/blob/main/src/main/external-resources/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/UniversalMediaServer/UniversalMediaServer)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/UniversalMediaServer/UniversalMediaServer/releases/download/15.9.0/UMS-Linux-15.9.0-x86_64.AppImage) · [arm64](https://github.com/UniversalMediaServer/UniversalMediaServer/releases/download/15.9.0/UMS-Linux-15.9.0-arm64.tgz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Java media server (UMS) with a Dockerfile on ubuntu:22.04 that installs a JRE and the app. It can run on the java sibling with ffmpeg from apt, and state goes to /config. It writes to its home dir, so paths need redirecting to /config and /tmp.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [universalmediaserver/ums:latest](https://hub.docker.com/r/universalmediaserver/ums)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
