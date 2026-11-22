# obsidian

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: obsidian
- **Rows**: 1
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/obsidianmd/obsidian-releases
- **Documentation**: https://help.obsidian.md/
- **Website**: https://obsidian.md/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: obsidian
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/sytone/obsidian-remote:0.1.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/sytone/obsidian-remote/blob/ac1c8e6c956b252782a0a6acf2aa3172cd4105a3/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/obsidianmd/obsidian-releases)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/obsidianmd/obsidian-releases/releases/download/v1.15.1/obsidian_1.15.1_amd64.deb) · [arm64](https://github.com/obsidianmd/obsidian-releases/releases/download/v1.15.1/Obsidian-1.15.1-arm64.AppImage)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Obsidian is a closed-source Electron desktop app, distributed as an AppImage, so there is a redistributable artifact. It needs a desktop and VNC or web stack from the linuxserver rdesktop base with s6 and a browser front end. The GUI and rootless or read-only work make it hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/sytone/obsidian-remote:0.1.1](https://ghcr.io/sytone/obsidian-remote)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
