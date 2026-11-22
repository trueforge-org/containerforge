# omada-controller

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: omada-controller
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/omada-controller
- **Website**: https://www.tp-link.com/en/omada-sdn/
- **Documentation**: https://www.omadanetworks.com/en/support/
- **Website**: https://www.omadanetworks.com/

## Potentially relevant resources

- **Source code repository**: https://github.com/mbentley/docker-omada-controller
- **Container image**: https://hub.docker.com/r/mbentley/omada-controller

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java17](https://github.com/trueforge-org/containerforge/tree/main/apps/java17) (`ghcr.io/trueforge-org/java17`)
- **Alternative runtime image**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`)
- **Reason**: Java controller installed from a vendor package on ubuntu; no Java version is named, so java17 is used.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: TP-Link Omada controller .deb (vendor, installed by install.sh), Java 17 (java17 base), MongoDB service (inferred)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8043/https (controller web UI), 8088/http (controller HTTP, inferred), 8843/https (portal HTTPS, inferred), 29810/udp (device discovery, inferred), 29811/tcp (device adoption, inferred), 29812/tcp (device management, inferred), 29813/tcp (device upgrade, inferred), 29814/tcp (device management, inferred), 27017/tcp (bundled MongoDB, inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: omada-controller
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/mbentley/omada-controller:6.3`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/mbentley/docker-omada-controller/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.tp-link.com/en/omada-sdn/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://www.tp-link.com/en/support/download/omada-software-controller/)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Java controller with MongoDB, installed from TP-Link's vendor Omada .deb by install.sh at build time on the mbentley ubuntu base. It needs a MongoDB service and Java, runs several processes and uses privileged ports, so rootless rework is significant. Depends on a vendor artifact.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [mbentley/omada-controller:6.3](https://hub.docker.com/r/mbentley/omada-controller)
- **copy-from arm64**: [mbentley/omada-controller:6.3](https://hub.docker.com/r/mbentley/omada-controller)

### Dependency containers

- **Dependency containers**: none
