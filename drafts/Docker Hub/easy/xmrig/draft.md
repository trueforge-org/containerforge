# xmrig

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: xmrig
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/xmrig
- **Source repository**: https://github.com/xmrig/xmrig
- **Documentation**: https://xmrig.com/docs

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/cooleye72/xmrig

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Single apt package on the ubuntu base.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: xmrig
- python/pip: none
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (optional HTTP API, off by default, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/xmrig
- non-root: possible - chart sets runAsUser 0, but xmrig runs unprivileged and draft keeps config in /config
- read-only-rootfs: possible - chart sets false; draft writes only to /config
- privileged: no - not set, common default false
- other-security: none in values (huge-page tuning would need extra settings, not set)
- extra-persistence: none beyond /config
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: xmrig
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/cooleye72/xmrig:6.21`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/xmrig/xmrig)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:xmrig`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Install xmrig with apt on containerforge-ubuntu for both arches, no build needed. Config goes in /config. It is a cryptominer, so flag for policy review before adding; the Docker Hub image has no public Dockerfile.

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
