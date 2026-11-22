# v-rising

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: v-rising
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/v-rising
- **Website**: https://playvrising.com/
- **Documentation**: https://github.com/StunlockStudios/vrising-dedicated-server-instructions

## Potentially relevant resources

- **Container image**: https://ghcr.io/ich777/steamcmd
- **Steam store page**: https://steampowered.com

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [steamcmd](https://github.com/trueforge-org/containerforge/tree/main/apps/steamcmd) (`ghcr.io/trueforge-org/steamcmd`)
- **Alternative runtime image**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`)
- **Reason**: Steam dedicated server through SteamCMD, with Wine added.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: v-rising
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/steamcmd:vrising`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-steamcmd-server/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://playvrising.com/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://store.steampowered.com/app/1829350/)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Steam dedicated server for v-rising is Windows-only; ich777 runs it under Wine (WINEPREFIX, Xvfb) on a root wrapper. On containerforge-ubuntu this means reusing apps/steamcmd plus adding Wine/Xvfb, a writable prefix in /config or /tmp, and USER apps rework; no native build.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/steamcmd:vrising](https://ghcr.io/ich777/steamcmd)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
