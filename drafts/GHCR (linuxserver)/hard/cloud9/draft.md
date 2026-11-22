# cloud9

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: hard
- **Chart**: cloud9
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/cloud9
- **Source repository**: https://github.com/c9/core
- **Website**: https://c9.github.io/core/

## Potentially relevant resources

- **Website**: https://aws.amazon.com/cloud9
- **Container image**: https://ghcr.io/linuxserver/cloud9

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node.js IDE with a native node-pty build, so python-node provides the node runtime and build tools.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none (python-node base provides build tools) | none
- python/pip: none | none
- node/npm: c9/core deps and node-pty native build (inferred)
- other: source build of c9/core

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8000/http (Cloud9 web IDE, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/cloud9
- non-root: no - chart runAsUser 0; draft keeps linuxserver cloud9 base
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: unknown - draft adds docker-ce and compose tooling that may need privileges; chart does not set privileged
- other-security: root, so common root caps added; docker socket access per draft only
- extra-persistence: /code (pvc, chart code)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: cloud9
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/cloud9:version-1.29.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-cloud9/blob/e8b635534987561f47ab7cc1c48e57c74f1c6d8a/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/c9/core)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Cloud9 web IDE (c9/core), a large older Node app with a native node-pty build, delivered by the linuxserver cloud9 base. The wrapper adds docker-ce and compose tooling, which needs privileges. The native compile and privilege needs make it hard.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/linuxserver/cloud9:version-1.29.2](https://ghcr.io/linuxserver/cloud9)
- **copy-from arm64**: [ghcr.io/linuxserver/cloud9:version-1.29.2](https://ghcr.io/linuxserver/cloud9)

### Dependency containers

- **Dependency containers**: none
