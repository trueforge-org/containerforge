# piaware

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: piaware
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/flightaware/piaware
- **Documentation**: https://www.flightaware.com/adsb/piaware/
- **Website**: https://www.flightaware.com/adsb/piaware/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: piaware
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/mikenye/piaware:v10.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/sdr-enthusiasts/docker-piaware/blob/bedde2040fd15c25cf001e1575915593124c34a7/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/flightaware/piaware)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/flightaware/piaware/releases/tag/v10.0)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Several services in one image (piaware, dump1090, s6 base) and it needs RTL-SDR USB device access, so it is a hardware-bound image. Packages are available as FlightAware apt .debs, but the feeder stack is a multi-process s6 layout that would need rework.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [mikenye/piaware:v10.0](https://hub.docker.com/r/mikenye/piaware)
- **copy-from arm64**: [mikenye/piaware:v10.0](https://hub.docker.com/r/mikenye/piaware)

### Dependency containers

- **Dependency containers**: none
