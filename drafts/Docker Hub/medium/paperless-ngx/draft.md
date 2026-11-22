# paperless-ngx

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: paperless-ngx
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/paperless-ngx
- **Source repository**: https://github.com/apache/tika

## Potentially relevant resources

- **Container image**: https://ghcr.io/paperless-ngx/paperless-ngx
- **Source code repository**: https://github.com/paperless-ngx/paperless-ngx
- **Container image**: https://hub.docker.com/r/apache/tika
- **Container image**: https://hub.docker.com/r/gotenberg/gotenberg
- **Website**: https://paperless-ngx.readthedocs.io/en/latest

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java21](https://github.com/trueforge-org/containerforge/tree/main/apps/java21) (`ghcr.io/trueforge-org/java21`)
- **Alternative runtime image**: [java25](https://github.com/trueforge-org/containerforge/tree/main/apps/java25) (`ghcr.io/trueforge-org/java25`)
- **Reason**: Java tika-server jar; the input allows java21 or java25 and java21 is the conservative pick.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Apache Tika tika-server jar download

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9998/http (Tika server, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/paperless-ngx
- non-root: no - runAsUser 0, runAsNonRoot false in values (USERMAP_UID env is derived from PUID)
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, not overridden
- other-security: none
- extra-persistence: /data, /consume, /media (pvc default, chart's own); the draft needs only /tmp beyond these
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: This is only the Tika sidecar; paperless-ngx itself is a separate container and must be set up to reach it.
- caveat: The minimal tika-server jar has no OCR; the full variant needs tesseract and gdal/fonts, which change the image size and build (inferred).
- caveat: Parsing large documents uses significant RAM and CPU (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: paperless-ngx
- **Role**: sidecar (tikaImage)

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/apache/tika:3.3.3.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/apache/tika-docker/blob/master/minimal/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/apache/tika)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://dlcdn.apache.org/tika/3.3.3/tika-server-standard-3.3.3.jar)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Java tika-server jar on Ubuntu; reuse ContainerForge java21/java25 base and download the jar from Apache. Minimal variant is easy, but the full variant needs tesseract and gdal/fonts. Runs rootless; needs only /tmp writable.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [apache/tika:3.3.3.1](https://hub.docker.com/r/apache/tika)
- **copy-from arm64**: [apache/tika:3.3.3.1](https://hub.docker.com/r/apache/tika)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

- **Dependency containers**: -
