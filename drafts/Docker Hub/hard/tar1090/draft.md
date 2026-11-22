# tar1090

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: tar1090
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tar1090
- **Source repository**: https://github.com/wiedehopf/tar1090

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/mikenye/tar1090

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Native decoder compiled on ubuntu with a web server and an aircraft database.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: build-essential, librtlsdr-dev, libusb-1.0-0-dev, libncurses-dev, nginx (inferred)
- python/pip: none
- node/npm: none
- other: git clone of wiedehopf/tar1090 and readsb source (compiled)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/tar1090
- non-root: no - chart sets runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - default false, no override in values
- other-security: none in values; SDR device access (Reason) is not declared, so it is unknown how the chart would provide it
- extra-persistence: none (persistence {}); readsb decoder and aircraft database may need writable paths (not shown in values)
- confidence: low

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: needs an SDR receiver (RTL-SDR or similar) plugged into the host and passed to the container; without it there is no data (inferred)
- caveat: the aircraft database download and readsb decoder need writable paths and internet access on first start (inferred)
- caveat: the decoder is compiled from source, so the build is slow and needs build tools (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: tar1090
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/mikenye/tar1090:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/sdr-enthusiasts/docker-tar1090/blob/d89fb2efbe182198a0b9cde4d537b3ccd3250253/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/wiedehopf/tar1090)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: The tar1090 web UI needs the readsb decoder, which the upstream image compiles, plus nginx and an aircraft database in several processes. It needs SDR device access and s6 services, so it is a hardware-bound multi-service image.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [mikenye/tar1090:latest](https://hub.docker.com/r/mikenye/tar1090)
- **copy-from arm64**: [mikenye/tar1090:latest](https://hub.docker.com/r/mikenye/tar1090)

### Dependency containers

- **Dependency containers**: none
