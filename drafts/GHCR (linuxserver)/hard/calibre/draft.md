# calibre

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: hard
- **Chart**: calibre
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/calibre
- **Source repository**: https://github.com/kovidgoyal/calibre
- **Documentation**: https://manual.calibre-ebook.com/
- **Website**: https://calibre-ebook.com/

## Potentially relevant resources

- **Container image**: https://ghcr.io/linuxserver/calibre

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: calibre
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/calibre:9.18.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-calibre/blob/8aa349b17edf2d4bed988982d71803684399f01a/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/kovidgoyal/calibre)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/kovidgoyal/calibre/releases/download/v9.18.0/calibre-9.18.0-x86_64.txz) · [arm64](https://github.com/kovidgoyal/calibre/releases/download/v9.18.0/calibre-9.18.0-arm64.txz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Calibre e-book manager (Qt/Python) delivered by linuxserver as a selkies browser desktop. Upstream now ships prebuilt x86_64 and arm64 tarballs, but it needs a desktop/VNC layer (kasmvnc, xvfb exist), root-style GUI base rework and a large Qt stack, so hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/linuxserver/calibre:9.18.0](https://ghcr.io/linuxserver/calibre)
- **copy-from arm64**: [ghcr.io/linuxserver/calibre:9.18.0](https://ghcr.io/linuxserver/calibre)

### Dependency containers

- **Dependency containers**: none
