# adguard-home

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: adguard-home
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/adguard-home
- **Source repository**: https://github.com/AdguardTeam/AdGuardHome
- **Documentation**: https://adguard-dns.io/kb/adguard-home/overview/
- **Documentation**: https://adguard-dns.io/kb/adguard-home/getting-started/
- **Website**: https://adguard.com/en/adguard-home/overview.html

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/adguard/adguardhome

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: Go binary from upstream release tarballs on ubuntu.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: adguard-home
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/adguard/adguardhome:v0.107.80`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/AdguardTeam/AdGuardHome/blob/003d6e1e15e04127f6d6d5e2f5c1aa843130752a/docker/build.Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/AdguardTeam/AdGuardHome)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/AdguardTeam/AdGuardHome/releases/download/v0.107.80/AdGuardHome_linux_amd64.tar.gz) · [arm64](https://github.com/AdguardTeam/AdGuardHome/releases/download/v0.107.80/AdGuardHome_linux_arm64.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go binary from upstream release tarballs, so the build stage is avoidable. The main effort is that DNS listens on port 53, which a non-root container cannot bind without a capability or a remapped port, and config and data must move to /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
