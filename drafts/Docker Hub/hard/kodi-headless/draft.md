# kodi-headless

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: kodi-headless
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/kodi-headless
- **Source repository**: https://github.com/xbmc/xbmc

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/linuxserver/kodi-headless

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Media app from apt with an Xvfb sibling.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: kodi-headless
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/linuxserver/kodi-headless:190`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-kodi-headless/blob/8962e35/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/xbmc/xbmc)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:kodi`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Kodi C++ compiled from a source tarball with patches in an lsiobase ubuntu bionic stage, then /usr copied into the runtime. Headless Kodi still needs an X server and audio stack, and a full source build is very large. ContainerForge would use Ubuntu's Kodi package with an Xvfb sibling, adding moving parts.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [linuxserver/kodi-headless:190](https://hub.docker.com/r/linuxserver/kodi-headless)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
