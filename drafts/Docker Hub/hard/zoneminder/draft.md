# zoneminder

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: zoneminder
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/zoneminder
- **Source repository**: https://github.com/ZoneMinder/zoneminder
- **Documentation**: https://zoneminder.readthedocs.io/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/dlandon/zoneminder.unraid
- **Website**: https://zoneminder.com

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: zoneminder
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/dlandon/zoneminder.unraid:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/dlandon/zoneminder.unraid/blob/ee9d87e8d1a6e539206f6412109593847eae2d84/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ZoneMinder/zoneminder)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/ZoneMinder/zoneminder/releases/download/1.38.6/zoneminder-dbg_1.38.6+bookworm1_amd64.deb) · [arm64](https://github.com/ZoneMinder/zoneminder/releases/download/1.38.6/zoneminder-dbg_1.38.6+bookworm1_arm64.deb)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: ZoneMinder installed with apt from a PPA on phusion jammy, alongside Apache, PHP, a database and Tailscale, so several services under root init. Camera device access and multi-service design make this hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [dlandon/zoneminder.unraid:latest](https://hub.docker.com/r/dlandon/zoneminder.unraid)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
