# sinusbot

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: sinusbot
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/sinusbot
- **Source repository**: https://github.com/gamer92000/sinusbot-docker
- **Documentation**: https://sinusbot.github.io/docs/faq/general

## Potentially relevant resources

- **Website**: https://forum.sinusbot.com
- **Container image**: https://ghcr.io/gamer92000/sinusbot-docker

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Closed-source bot installed from a vendor tarball with its own Qt runtime.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: bzip2, libglib2.0-0, libnss3, libxcomposite1, libxdamage1, libxtst6, libxkbcommon0, libpulse0 (inferred)
- python/pip: none
- node/npm: none
- other: vendor tarball (sinusbot-1.1f-amd64.tar.bz2) with its install script, amd64 only

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8087/http (web UI, inferred), 9987/udp (TeamSpeak voice, inferred), 10101/tcp (TeamSpeak query, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/sinusbot
- non-root: no - runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: /opt/sinusbot/data, /opt/sinusbot/scripts (chart paths, type not set)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: sinusbot
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/gamer92000/sinusbot-docker:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/gamer92000/sinusbot-docker/blob/966f042fce2ab6a93c7fa50e39aff335ebd81e9a/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/gamer92000/sinusbot-docker)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://michael.frie.se/sinusbot-1.1f-amd64.tar.bz2)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Closed-source TeamSpeak bot installed from the vendor download with its own install script and a Qt/TeamSpeak runtime stack. The upstream image runs as root and is published for amd64 only. An arm64 build is not possible, and the amd64 image needs rework for rootless use and writable paths.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: no*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/gamer92000/sinusbot-docker:latest](https://ghcr.io/gamer92000/sinusbot-docker)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
