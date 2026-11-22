# homebridge

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: homebridge
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/homebridge
- **Source repository**: https://github.com/homebridge/homebridge
- **Documentation**: https://homebridge.io/docs/
- **Website**: https://homebridge.io/

## Potentially relevant resources

- **Container image**: https://ghcr.io/homebridge/homebridge
- **Source code repository**: https://github.com/oznu/docker-homebridge

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node.js homebridge run under a process supervisor, so Node is the main runtime.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: homebridge (inferred plugins)
- other: homebridge-apt-pkg .deb (vendor), s6-overlay (inferred)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8581/http (web UI), 51826/tcp (HomeKit HAP, inferred), 5353/udp (mDNS, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/homebridge
- non-root: no - chart forces runAsUser 0 and runAsNonRoot false (s6 init)
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, default false
- other-security: none in values
- extra-persistence: /homebridge (config dir, not /config; type not set, likely pvc)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: homebridge
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/homebridge/homebridge:2026-11-15`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/homebridge/docker-homebridge/blob/2026-11-15/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/homebridge/homebridge)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `npm:homebridge`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Node.js homebridge installed from the homebridge-apt-pkg .deb and run under s6-overlay (/init), so it is several supervised services. The image is root-owned under /opt, so rootless and read-only-rootfs rework of the s6 services and the plugin directory is needed.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/homebridge/homebridge:2026-11-15](https://ghcr.io/homebridge/homebridge)
- **copy-from arm64**: [ghcr.io/homebridge/homebridge:2026-11-15](https://ghcr.io/homebridge/homebridge)

### Dependency containers

- **Dependency containers**: none
