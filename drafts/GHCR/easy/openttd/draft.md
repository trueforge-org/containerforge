# openttd

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: openttd
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/openttd
- **Source repository**: https://github.com/OpenTTD/OpenTTD
- **Documentation**: https://wiki.openttd.org/
- **Documentation**: https://wiki.openttd.org/en/
- **Website**: https://www.openttd.org/

## Potentially relevant resources

- **Container image**: https://ghcr.io/ich777/openttdserver

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Dedicated server from the official linux tarball.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: openttd
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/openttdserver:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-openttd-server/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/OpenTTD/OpenTTD)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://cdn.openttd.org/openttd-releases/15.3/openttd-15.3-linux-generic-amd64.tar.xz) · arm64: `apt:openttd`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: amd64 unpacks the official 15.3 linux-generic tarball; arm64 uses apt openttd 15.1 from Ubuntu, so versions differ unless amd64 also uses apt. Dedicated server with downloaded base graphics under /config; ich777 gotty wrapper is optional.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/openttdserver:latest](https://ghcr.io/ich777/openttdserver)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
