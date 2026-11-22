# static-web-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: static-web-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/static-web-server
- **Source repository**: https://github.com/static-web-server/static-web-server
- **Documentation**: https://static-web-server.net/

## Potentially relevant resources

- **Container image**: https://ghcr.io/static-web-server/static-web-server

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Rust static file server binary, not an nginx setup.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: static-web-server Rust release tarball

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (static file server, default)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/static-web-server
- non-root: yes - no securityContext override, common 568 default
- read-only-rootfs: yes - default true, not overridden
- privileged: no - default false, not set
- other-security: none
- extra-persistence: /public (pvc, chart key config); web root for served files
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: static-web-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/static-web-server/static-web-server:2.44.3`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/static-web-server/static-web-server/blob/501cb7fcb6a01a4e73e6d5f541559e3334c39976/docker/scratch/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/static-web-server/static-web-server)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/static-web-server/static-web-server/releases/download/v2.44.3/static-web-server-v2.44.3-x86_64-unknown-illumos.tar.gz) · [arm64](https://github.com/static-web-server/static-web-server/releases/download/v2.44.3/static-web-server-v2.44.3-aarch64-unknown-linux-gnu-fips.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: static-web-server is a Rust binary released as prebuilt linux gnu tarballs for amd64 and arm64. It is one process that serves files on an unprivileged port, so it drops onto containerforge-ubuntu with no compile. The rootless setup is simple.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/static-web-server/static-web-server:2.44.3](https://ghcr.io/static-web-server/static-web-server)
- **copy-from arm64**: [ghcr.io/static-web-server/static-web-server:2.44.3](https://ghcr.io/static-web-server/static-web-server)

### Dependency containers

- **Dependency containers**: none
