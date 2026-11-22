# cloudreve

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: cloudreve
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql, valkey)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/cloudreve
- **Source repository**: https://github.com/cloudreve/Cloudreve
- **Documentation**: https://docs.cloudreve.org/en

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/cloudreve/cloudreve

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go binary plus ffmpeg from apt on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: ffmpeg, media tools (names inferred)
- python/pip: none
- node/npm: none
- other: cloudreve release binary (tar.gz)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5212/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/cloudreve
- non-root: no - chart sets container runAsUser 0 and runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, no override in values
- other-security: none beyond root override
- extra-persistence: /cloudreve/data (pvc, config; chart's own mount, not /config)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The overview marks PostgreSQL and Valkey as optional, but the reason says they are needed; confirm whether the default SQLite setup is enough before wiring those dependencies.
- caveat: The chart keeps data at /cloudreve/data, not /config, so the data path must be remapped (inferred).
- caveat: ffmpeg and media tools from apt increase image size and first-start work for thumbnails (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: cloudreve
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/cloudreve/cloudreve:4.19.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/cloudreve/Cloudreve/blob/9f1e0b8333f5c7304a09e1dcb3f9c170dddd63f3/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/cloudreve/Cloudreve)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/cloudreve/cloudreve/releases/download/4.19.1/cloudreve_4.19.1_linux_amd64.tar.gz) · [arm64](https://github.com/cloudreve/cloudreve/releases/download/4.19.1/cloudreve_4.19.1_linux_arm64.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go binary from the Cloudreve release tarball plus ffmpeg and media tools installed with apt, so a moderate set of moving parts. Needs external PostgreSQL and Valkey as dependencies; a single process with data in /config and scratch in /tmp.

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

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: valkey ✅, postgresql ✅
