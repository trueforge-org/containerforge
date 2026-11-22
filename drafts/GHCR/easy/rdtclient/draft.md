# rdtclient

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: rdtclient
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rdtclient
- **Source repository**: https://github.com/aria2/aria2

## Potentially relevant resources

- **Container image**: https://ghcr.io/p3terx/aria2-pro
- **Container image**: https://ghcr.io/rogerfar/rdtclient
- **Source code repository**: https://github.com/rogerfar/rdt-client

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: The aria2c daemon is an apt package on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: aria2
- python/pip: none
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 6500/http (rdtclient web UI, inferred), 6800/http (aria2 RPC), 6888/tcp (BitTorrent)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/rdtclient
- non-root: no - chart sets runAsUser 0, runAsGroup 0, runAsNonRoot false (container and workload securityContext)
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, default false
- other-security: none
- extra-persistence: /data/db (pvc)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: rdtclient
- **Role**: sidecar (aria2Image)

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/p3terx/aria2-pro:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/P3TERX/Aria2-Pro-Docker/blob/4ec58da/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/aria2/aria2)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: The aria2c daemon is a single process that Ubuntu packages as an apt package, so one apt install on containerforge-ubuntu covers the binary. Config and session files go in /config, and downloads go to a mounted path. The s6 supervision and the curl-piped installer in upstream can be dropped.

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

- **Dependency containers**: -
