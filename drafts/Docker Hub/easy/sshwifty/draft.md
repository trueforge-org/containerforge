# sshwifty

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: sshwifty
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/sshwifty
- **Source repository**: https://github.com/niruix/sshwifty

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/niruix/sshwifty

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go binary with embedded UI from the release tarball.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Go release tarball per arch

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8182/http (web SSH client)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/sshwifty
- non-root: possible - chart sets runAsNonRoot false and runAsUser 0; draft runs a high port, which needs no root
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: none
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: sshwifty
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/niruix/sshwifty:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/niruix/sshwifty/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/niruix/sshwifty)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/nirui/sshwifty/releases/download/0.4.12-beta-release-prebuild/sshwifty_0.4.12-beta-release_linux_amd64.tar.gz) · [arm64](https://github.com/nirui/sshwifty/releases/download/0.4.12-beta-release-prebuild/sshwifty_0.4.12-beta-release_linux_arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Sshwifty is a Go binary with an embedded web UI, and upstream publishes release tarballs for each arch. Copy the binary into /app and run it as apps on a high port, with no state beyond optional config in /config.

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
