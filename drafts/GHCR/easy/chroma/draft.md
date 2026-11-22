# chroma

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: chroma
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/chroma
- **Source repository**: https://github.com/chroma-core/chroma
- **Documentation**: https://docs.trychroma.com/

## Potentially relevant resources

- **Container image**: https://ghcr.io/chroma-core/chroma

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python server installed with pip, using prebuilt wheels.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: chromadb
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8000/http (API, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/chroma
- non-root: no - chart sets runAsUser 0, runAsGroup 0, runAsNonRoot false
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, not overridden
- other-security: none in values
- extra-persistence: none beyond chart's own config mount /chroma/chroma (pvc); draft expects /config
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: chroma
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/chroma-core/chroma:1.5.9`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/chroma-core/chroma/blob/11f3c7435e71024aa0a2b53710a28d3289d922d1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/chroma-core/chroma)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:chromadb`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Python chroma server installed by pip, with its rust extension shipped as prebuilt wheels. The python sibling covers the runtime, and data goes to /config. One pip install with no extra services makes it easy.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/chroma-core/chroma:1.5.9](https://ghcr.io/chroma-core/chroma)
- **copy-from arm64**: [ghcr.io/chroma-core/chroma:1.5.9](https://ghcr.io/chroma-core/chroma)

### Dependency containers

- **Dependency containers**: none
