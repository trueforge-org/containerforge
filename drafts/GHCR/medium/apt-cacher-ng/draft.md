# apt-cacher-ng

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: apt-cacher-ng
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/apt-cacher-ng
- **Website**: https://www.unix-ag.uni-kl.de/~bloch/acng/
- **Documentation**: https://www.unix-ag.uni-kl.de/~bloch/acng/html/

## Potentially relevant resources

- **Container image**: https://ghcr.io/sameersbn/apt-cacher-ng

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: Single daemon installed with apt.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: apt-cacher-ng
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/sameersbn/apt-cacher-ng:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/sameersbn/docker-apt-cacher-ng/blob/6d0816a/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.unix-ag.uni-kl.de/~bloch/acng/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:apt-cacher-ng`

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: apt-cacher-ng is one daemon installed with a single apt command on containerforge-ubuntu. Its cache, log and pid paths must move to /config and /tmp for a read-only rootfs and a non-root run. That config rework is modest but needed.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/sameersbn/apt-cacher-ng:latest](https://ghcr.io/sameersbn/apt-cacher-ng)
- **copy-from arm64**: [ghcr.io/sameersbn/apt-cacher-ng:latest](https://ghcr.io/sameersbn/apt-cacher-ng)

### Dependency containers

- **Dependency containers**: none
