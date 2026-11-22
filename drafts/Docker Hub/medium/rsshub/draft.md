# rsshub

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: rsshub
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (valkey, chrome)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rsshub
- **Source repository**: https://github.com/DIYgod/RSSHub
- **Documentation**: https://docs.rsshub.app/

## Potentially relevant resources

- **Website**: https://docs.rsshub.app/en/install
- **Container image**: https://hub.docker.com/r/browserless/chrome
- **Container image**: https://hub.docker.com/r/diygod/rsshub

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node.js app built with pnpm, so python-node provides node.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: pnpm (inferred)
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 1200/http (web UI and feeds)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/rsshub
- non-root: no - runAsUser 0, runAsGroup 0, runAsNonRoot false overrides
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default privileged false, not overridden
- other-security: none
- extra-persistence: none (no persistence block in values)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: rsshub
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/diygod/rsshub:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/DIYgod/RSSHub/blob/c566e920fd386c19935954e1969ac8d7d3c8b5c4/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/DIYgod/RSSHub)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/DIYgod/RSSHub/releases/tag/v2026.11.20-8704.fcfe5ae)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Large Node.js RSS generator built with pnpm in node stages and copied onto node:26 slim, one main process. Uses the node sibling plus a build step; the browserless Chrome sidecar and valkey cache are optional companions.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [diygod/rsshub:latest](https://hub.docker.com/r/diygod/rsshub)
- **copy-from arm64**: [diygod/rsshub:latest](https://hub.docker.com/r/diygod/rsshub)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

❌ means it is missing too.

- **Dependency containers**: valkey ✅, chrome (browserlessImage) ❌
