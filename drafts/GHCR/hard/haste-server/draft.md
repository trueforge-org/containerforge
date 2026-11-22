# haste-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: haste-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/haste-server
- **Source repository**: https://github.com/nzzane/haste-server

## Potentially relevant resources

- **Container image**: https://ghcr.io/k8s-at-home/haste-server
- **Source code repository**: https://github.com/k8s-at-home/container-images
- **Source code repository**: https://github.com/seejohnrun/haste-server

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node.js app with no Python needs, so python-node provides the runtime.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: haste-server
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 7777/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/haste-server
- non-root: yes - no securityContext override, defaults 568 apply
- read-only-rootfs: yes - default readOnlyRootFilesystem true, no override
- privileged: no - not set, default false
- other-security: none in values
- extra-persistence: none beyond /config
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: haste-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/k8s-at-home/haste-server:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/nzzane/haste-server)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `npm:haste-server`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Upstream seejohnrun/haste-server is a small Node app, but no Dockerfile for this image was found and the k8s-at-home repo is gone. Wrapper config and storage layout must be reverse engineered. The missing Dockerfile makes it hard, though the app itself is simple.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/k8s-at-home/haste-server:latest](https://ghcr.io/k8s-at-home/haste-server)
- **copy-from arm64**: [ghcr.io/k8s-at-home/haste-server:latest](https://ghcr.io/k8s-at-home/haste-server)

### Dependency containers

- **Dependency containers**: none
