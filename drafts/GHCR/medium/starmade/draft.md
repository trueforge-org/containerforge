# starmade

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: starmade
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/starmade
- **Website**: https://www.star-made.org/
- **Documentation**: https://starmadepedia.net

## Potentially relevant resources

- **Container image**: https://ghcr.io/ich777/starmade-server

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java17](https://github.com/trueforge-org/containerforge/tree/main/apps/java17) (`ghcr.io/trueforge-org/java17`)
- **Reason**: Java jar from the vendor; the draft gives no version, so java17 is used by default.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: curl (inferred), unzip (inferred)
- python/pip: none
- node/npm: none
- other: StarMade server jar downloaded from vendor at runtime (java17 base)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 4242/tcp (game server, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/starmade
- non-root: no - container override runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: none beyond chart's own serverfiles at /starmade
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: starmade
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/starmade-server:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-starmade/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.star-made.org/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://www.star-made.org/download)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: StarMade dedicated server is a Java jar downloaded from the vendor at runtime; reuse the java sibling. Single process with data under /config. The work is the download step and start script, since the ich777 wrapper is thin.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/starmade-server:latest](https://ghcr.io/ich777/starmade-server)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
