# firefox

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: hard
- **Chart**: firefox
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/firefox
- **Source repository**: https://github.com/mozilla-firefox/firefox
- **Documentation**: https://support.mozilla.org/

## Potentially relevant resources

- **Container image**: https://ghcr.io/linuxserver/firefox
- **Source code repository**: https://github.com/linuxserver/docker-firefox

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: firefox
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/firefox:1160.0.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-firefox/blob/1be26bbc8f8aa6fea0e94f46a68bbc660a030d47/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/mozilla-firefox/firefox)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://download.mozilla.org/?product=firefox-160.0.1-SSL&os=linux64&lang=en-US) · [arm64](https://download.mozilla.org/?product=firefox-160.0.1-SSL&os=linux64-aarch64&lang=en-US)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Firefox desktop browser run as a Selkies/VNC desktop image with several processes. Install the Mozilla linux64 or linux64-aarch64 tarball (or Mozilla apt repo) into /app on containerforge-ubuntu, since Ubuntu has no deb firefox. The desktop and display stack plus rootless rework make it hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/linuxserver/firefox:1160.0.1](https://ghcr.io/linuxserver/firefox)
- **copy-from arm64**: [ghcr.io/linuxserver/firefox:1160.0.1](https://ghcr.io/linuxserver/firefox)

### Dependency containers

- **Dependency containers**: none
