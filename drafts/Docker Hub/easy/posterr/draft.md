# posterr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: posterr
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/posterr
- **Source repository**: https://github.com/petersem/posterr

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/petersem/posterr

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node app installed with npm, so the python-node base provides the runtime.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: npm install --production of repo dependencies (inferred)
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/posterr
- non-root: possible - chart sets runAsUser 0 and runAsNonRoot false; Node app likely needs no root
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, not overridden
- other-security: none
- extra-persistence: /usr/src/app/public/custom (pvc), /usr/src/app/config (pvc)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: posterr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/petersem/posterr:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/petersem/posterr/blob/4609d7e2ef2ce37bac78349b3978e61a706d0180/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/petersem/posterr)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/petersem/posterr/releases/download/v1.15.0/poster-binaries.zip) · [arm64](https://github.com/petersem/posterr/releases/tag/v1.15.0)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Node app that runs npm install --production on the node sibling and needs no other services. It is a single process with its data written to /config, so it is a simple npm install.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
