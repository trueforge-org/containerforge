# jts3servermod

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: jts3servermod
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/jts3servermod
- **Source repository**: https://github.com/galexrt/container-jts3servermod

## Potentially relevant resources

- **Container image**: https://ghcr.io/galexrt/jts3servermod
- **Website**: https://www.stefan1200.de/documentation/jts3servermod/readme.html
- **Website**: https://www.stefan1200.de/forum/index.php?PHPSESSID=r0m44032akt9jk7903ru9ejv2f&topic=2.0

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java8](https://github.com/trueforge-org/containerforge/tree/main/apps/java8) (`ghcr.io/trueforge-org/java8`)
- **Reason**: Draft says it runs on Java 8.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: unzip (inferred)
- python/pip: none
- node/npm: none
- other: vendor zip from stefan1200.de at build time (pinned URL + checksum); Java runtime comes from java8 sibling

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9987/udp (TeamSpeak voice), 10011/tcp (ServerQuery), 30033/tcp (file transfer)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/jts3servermod
- non-root: yes - runAsUser and runAsGroup 3000 override, no root
- read-only-rootfs: no - readOnlyRootFilesystem false
- privileged: no - default false, not overridden
- other-security: none
- extra-persistence: /jts3servermod/logs (pvc)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: jts3servermod
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/galexrt/jts3servermod:v20240301-172535-248`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/galexrt/container-jts3servermod/blob/4ecf611553251cdafcb9176aeff42c2edaa609e0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/galexrt/container-jts3servermod)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/galexrt/container-jts3servermod/releases/tag/v20240301-172535-248)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Java application zip downloaded from the vendor site at build time and run on Java 8 (openjdk:8 base). Reuse the java8 ContainerForge sibling, unpack the jar into /app and keep config and data in /config. One process and no extra services; the vendor download needs a pinned URL and checksum.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/galexrt/jts3servermod:v20240301-172535-248](https://ghcr.io/galexrt/jts3servermod)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
