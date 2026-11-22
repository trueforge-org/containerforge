# boinc

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: hard
- **Chart**: boinc
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/boinc
- **Source repository**: https://github.com/BOINC/boinc
- **Documentation**: https://github.com/BOINC/boinc/wiki/
- **Website**: https://boinc.berkeley.edu/

## Potentially relevant resources

- **Container image**: https://ghcr.io/linuxserver/boinc

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Headless client installed with apt on ubuntu.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: boinc
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/boinc:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-boinc/blob/f7a1ea8759dae4d9fed9069d86d25aceca07acc2/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/BOINC/boinc)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:boinc-client`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: BOINC client installed from a PPA on a linuxserver selkies desktop base with a GUI manager. A headless boinc-client from Ubuntu apt would be easier, but the desktop wrapper and config in /config still need rework. The desktop stack makes it hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/linuxserver/boinc:latest](https://ghcr.io/linuxserver/boinc)
- **copy-from arm64**: [ghcr.io/linuxserver/boinc:latest](https://ghcr.io/linuxserver/boinc)

### Dependency containers

- **Dependency containers**: none
