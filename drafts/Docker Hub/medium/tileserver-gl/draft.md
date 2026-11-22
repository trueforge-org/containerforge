# tileserver-gl

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: tileserver-gl
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tileserver-gl
- **Source repository**: https://github.com/maptiler/tileserver-gl
- **Documentation**: https://tileserver.readthedocs.io/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/maptiler/tileserver-gl

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node.js tile server installed with npm, so python-node provides node.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: tileserver-gl
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (tiles, styles and web viewer)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/tileserver-gl
- non-root: yes - runAsUser 568 default, no root override
- read-only-rootfs: yes - default readOnlyRootFilesystem true, not overridden
- privileged: no - common default privileged false, not overridden
- other-security: none
- extra-persistence: /data (pvc, chart-defined; map data, styles, fonts)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Map data, styles and fonts must be supplied by the user under /data; the server starts with no usable maps out of the box.
- caveat: Vector tile rendering is CPU and memory heavy, and large map extracts need a lot of RAM (inferred).
- caveat: Upstream image is pinned to v5.7.0 in the chart, so newer releases may change style and font handling.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: tileserver-gl
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `maptiler/tileserver-gl:v5.7.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/maptiler/tileserver-gl/blob/243c4ded51dec62cb715769fd88a6e0846c5a076/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/maptiler/tileserver-gl)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `npm:tileserver-gl`

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node.js tile server installed with npm, and the final stage copies the application from a builder. Port by installing the npm package into /app on the node stack, with map data, styles and fonts stored under /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [maptiler/tileserver-gl:v5.7.0](https://hub.docker.com/r/maptiler/tileserver-gl)
- **copy-from arm64**: [maptiler/tileserver-gl:v5.7.0](https://hub.docker.com/r/maptiler/tileserver-gl)

### Dependency containers

- **Dependency containers**: none
