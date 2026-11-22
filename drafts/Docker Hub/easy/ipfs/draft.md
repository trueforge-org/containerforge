# ipfs

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: ipfs
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ipfs
- **Source repository**: https://github.com/ipfs/kubo
- **Documentation**: https://docs.ipfs.tech/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/ipfs/kubo

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go daemon unpacked from the official release tarball.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: kubo release tarball (Go binary)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 4001/tcp (swarm), 4001/udp (swarm QUIC), 5001/http (API), 8080/http (gateway)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: ipfs
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/ipfs/kubo:v0.43.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ipfs/kubo/blob/v0.43.1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ipfs/kubo)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/ipfs/kubo/releases/download/v0.43.1/kubo_v0.43.1_linux-amd64.tar.gz) · [arm64](https://github.com/ipfs/kubo/releases/download/v0.43.1/kubo_v0.43.1_linux-arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go kubo daemon shipped as an official release tarball, so the linux build can be unpacked into /app with no compile. Repo and config go under /config and temp under /tmp, and the upstream root use is only for gosu and fusermount helpers, so a rootless run is feasible.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ipfs/kubo:v0.43.1](https://hub.docker.com/r/ipfs/kubo)
- **copy-from arm64**: [ipfs/kubo:v0.43.1](https://hub.docker.com/r/ipfs/kubo)

### Dependency containers

- **Dependency containers**: none
