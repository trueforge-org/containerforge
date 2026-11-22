# cryptpad

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: cryptpad
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/cryptpad
- **Source repository**: https://github.com/cryptpad/cryptpad
- **Documentation**: https://docs.cryptpad.org/en/

## Potentially relevant resources

- **Website**: https://cryptpad.fr
- **Container image**: https://hub.docker.com/r/cryptpad/cryptpad

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node.js server, so python-node fits.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: app npm deps and frontend build (inferred)
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (web UI), 3001/http (sandbox origin, inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: cryptpad
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/cryptpad/cryptpad:version-5.5.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/cryptpad/cryptpad/blob/cbeb1b76a778db9ba6c512c24f71b6186525d4d3/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/cryptpad/cryptpad)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/cryptpad/cryptpad/archive/refs/tags/5.5.0.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node.js CryptPad server with a sizeable frontend build (npm install and build steps) copied onto node:lts-slim. Fits the node sibling; data goes to /config and the server runs as a single main process.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [cryptpad/cryptpad:version-5.5.0](https://hub.docker.com/r/cryptpad/cryptpad)
- **copy-from arm64**: [cryptpad/cryptpad:version-5.5.0](https://hub.docker.com/r/cryptpad/cryptpad)

### Dependency containers

- **Dependency containers**: none
