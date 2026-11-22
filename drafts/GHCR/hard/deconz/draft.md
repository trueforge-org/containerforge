# deconz

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: deconz
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/deconz
- **Website**: https://www.dresden-elektronik.de/funk/software/deconz.html
- **Documentation**: http://phoscon.de/rest/
- **Website**: https://phoscon.de/

## Potentially relevant resources

- **Container image**: https://ghcr.io/deconz-community/deconz-docker
- **Source code repository**: https://github.com/dresden-elektronik/deconz-rest-plugin
- **Source code repository**: https://github.com/marthoc/docker-deconz

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Vendor deb package installed on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: deconz (vendor .deb, amd64 qt5 build; arm64 buster deb)
- python/pip: none
- node/npm: none
- other: vendor .deb download (no source build)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (REST API and Phoscon web app), 443/https (inferred), 8080/http (WebSocket, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/deconz
- non-root: no - chart forces runAsUser 0 and runAsGroup 0 (vendor package runs as root)
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, default false
- other-security: capabilities add NET_BIND_SERVICE; USB or serial radio device from the Reason is not shown in values
- extra-persistence: /opt/deCONZ (type not set, likely pvc)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: a USB ConBee or RaspBee radio, or its serial device, must be passed into the container, and without it the gateway has no radio (inferred).
- caveat: the API and Phoscon web app need first-run unlock through the web UI, and the gateway may ask for a physical button press to pair (inferred).
- caveat: the arm64 package is a Debian buster build, so compatibility with Ubuntu 26.04 is not tested (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: deconz
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/deconz-community/deconz-docker:2.33.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/deconz-community/deconz-docker/blob/f23db7e09be257f35e3e753e69fda7494ea94d52/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.dresden-elektronik.de/funk/software/deconz.html)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](http://deconz.dresden-elektronik.de/ubuntu/stable/deconz-2.33.2-qt5.deb) · [arm64](http://deconz.dresden-elektronik.de/debian/stable/deconz_2.33.2-debian-buster-stable_arm64.deb)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: deCONZ gateway installed from the vendor deb download, and it runs as root with a USB ConBee or RaspBee radio or serial device. Device passthrough and root make it a hardware access case. The vendor package installs easily on ubuntu.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/deconz-community/deconz-docker:2.33.2](https://ghcr.io/deconz-community/deconz-docker)
- **copy-from arm64**: [ghcr.io/deconz-community/deconz-docker:2.33.2](https://ghcr.io/deconz-community/deconz-docker)

### Dependency containers

- **Dependency containers**: none
