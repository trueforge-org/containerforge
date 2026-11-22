# teedy-docs

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: teedy-docs
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/teedy-docs
- **Source repository**: https://github.com/sismics/docs

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/sismics/docs

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java11](https://github.com/trueforge-org/containerforge/tree/main/apps/java11) (`ghcr.io/trueforge-org/java11`)
- **Reason**: The input names java11 for a Java WAR run on Jetty.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: ffmpeg, tesseract-ocr (inferred tesseract-ocr-eng)
- python/pip: none
- node/npm: none
- other: maven (inferred, build step)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/teedy-docs
- non-root: no - runAsUser 0, runAsGroup 0 overrides
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default privileged false, not overridden
- other-security: none
- extra-persistence: /data (pvc, chart-defined)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Uses a PostgreSQL database through CloudNativePG in the chart; running without it is not supported.
- caveat: ffmpeg and tesseract add large OCR and video tooling, so image size and first-start time grow with OCR language packs (inferred).
- caveat: Maven build runs outside the Dockerfile, so the upstream build must succeed before the image can be made.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: teedy-docs
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/sismics/docs:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/sismics/docs/blob/5b39c46/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/sismics/docs)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/sismics/docs/archive/refs/tags/v1.11.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Same upstream and Dockerfile as teedy: a Java WAR built with Maven, run on Jetty with ffmpeg and tesseract. Reuse java11 and PostgreSQL via CloudNativePG, with a Maven build step.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [sismics/docs:latest](https://hub.docker.com/r/sismics/docs)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
