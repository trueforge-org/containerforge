# ntfy

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: ntfy
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ntfy
- **Source repository**: https://github.com/binwiederhier/ntfy
- **Documentation**: https://docs.ntfy.sh/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/binwiederhier/ntfy

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go single binary from upstream release packages.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: ntfy
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/binwiederhier/ntfy:v2.38.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/binwiederhier/ntfy/blob/v2.38.1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/binwiederhier/ntfy)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/binwiederhier/ntfy/releases/download/v2.38.1/ntfy_2.38.1_linux_amd64.deb) · [arm64](https://github.com/binwiederhier/ntfy/releases/download/v2.38.1/ntfy_2.38.1_linux_arm64.deb)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go single binary from upstream. ntfy publishes linux amd64 and arm64 tarballs, so unpack into /app on containerforge-ubuntu, keep config and cache under /config and /tmp, and run one process. No services.

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
