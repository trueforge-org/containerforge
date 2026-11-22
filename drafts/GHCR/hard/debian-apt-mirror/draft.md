# debian-apt-mirror

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: debian-apt-mirror
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/debian-apt-mirror
- **Source repository**: https://github.com/apt-mirror/apt-mirror
- **Documentation**: https://manpages.debian.org/trixie/apt-mirror/apt-mirror.1.en.html

## Potentially relevant resources

- **Container image**: https://ghcr.io/ich777/debian-mirror
- **Website**: https://www.debian.org

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: apt-mirror with apache2 and cron, all apt packages.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: debian-apt-mirror
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/debian-mirror:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-debian-mirror/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/apt-mirror/apt-mirror)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:apt-mirror`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Runs apt-mirror with apache2 and cron in one container to serve a Debian mirror, so there are several services and very large storage under /config. Apache and cron need rootless rework on a read-only rootfs; the apt-mirror package itself is simple.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/debian-mirror:latest](https://ghcr.io/ich777/debian-mirror)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
