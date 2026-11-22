# restic-rest-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: restic-rest-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/restic-rest-server
- **Source repository**: https://github.com/restic/rest-server
- **Documentation**: https://restic.readthedocs.io/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/restic/rest-server

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go REST server from the release tarball.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Go release tarball per arch

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8000/http (REST API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/restic-rest-server
- non-root: possible - chart sets runAsUser 0 and runAsGroup 0; draft is a single Go process
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; draft writes repos to /config
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: /data (pvc, chart's own; draft expects repositories in /config, so mismatch)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: restic-rest-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/restic/rest-server:0.14.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/restic/rest-server/blob/v0.14.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/restic/rest-server)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/restic/rest-server/releases/download/v0.14.0/rest-server_0.14.0_dragonfly_amd64.tar.gz) · [arm64](https://github.com/restic/rest-server/releases/download/v0.14.0/rest-server_0.14.0_linux_arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go REST server (0.14.0). Install the upstream release tarball on containerforge-ubuntu with the binary in /app and repositories in /config; single process on one port, no services.

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
