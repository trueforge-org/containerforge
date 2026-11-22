# drawio

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: drawio
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/drawio
- **Source repository**: https://github.com/jgraph/drawio
- **Website**: https://www.drawio.com

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/jgraph/drawio

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java11](https://github.com/trueforge-org/containerforge/tree/main/apps/java11) (`ghcr.io/trueforge-org/java11`)
- **Reason**: Java war deployed in a servlet container on JDK 11.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: tomcat9 (inferred), chromium (inferred, export server headless browser)
- python/pip: none
- node/npm: node, npm (inferred, to build draw.war from source)
- other: jgraph/drawio v32.7.4 source build (draw.war); JDK 11 from java11 runtime image

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (Tomcat, draw.io web app), 8000/http (inferred, export server)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/drawio
- non-root: no - runAsUser 0, runAsGroup 0, runAsNonRoot false
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none in values
- extra-persistence: none in values
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the export server needs a headless Chromium, which usually needs extra shared memory (inferred).
- caveat: Tomcat writes work and temp files, so a read-only rootfs will break the web app unless those paths are writable (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: drawio
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/jgraph/drawio:32.7.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/jgraph/docker-drawio/blob/d2e740b/main/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/jgraph/drawio)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/jgraph/drawio/releases/tag/v32.7.4)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Java war (draw.war) built from jgraph/drawio source with Node and npm, then deployed in Tomcat 9 on JDK 11, plus an export server that needs a headless browser. Reproducing the multi-stage source build and running Tomcat rootless on a read-only root is substantial rework.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [jgraph/drawio:32.7.4](https://hub.docker.com/r/jgraph/drawio)
- **copy-from arm64**: [jgraph/drawio:32.7.4](https://hub.docker.com/r/jgraph/drawio)

### Dependency containers

- **Dependency containers**: none
