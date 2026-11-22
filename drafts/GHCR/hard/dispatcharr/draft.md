# dispatcharr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: dispatcharr
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (alpine)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/dispatcharr
- **Source repository**: https://github.com/Dispatcharr/Dispatcharr
- **Documentation**: https://dispatcharr.github.io/Dispatcharr-Docs

## Potentially relevant resources

- **Container image**: https://ghcr.io/dispatcharr/dispatcharr
- **Source code repository**: https://github.com/Dispatcharr/Dispatcharr/blob/main/docker/docker-compose.aio.yml
- **Container image**: https://hub.docker.com/_/alpine

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Alternative runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Python Django runtime; node is needed only for the frontend build.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: ffmpeg, nginx (inferred), redis-server (inferred), supervisor (inferred)
- python/pip: Django project requirements (inferred)
- node/npm: frontend build (inferred)
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9191/http (web UI and API, nginx, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/dispatcharr
- non-root: no - chart forces runAsUser 0 and runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, default false
- other-security: none in values
- extra-persistence: /var/run/postgresql (socket dir, type not set); /data is the common app path
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the chart's alpine dependency is missing from ContainerForge, so the companion container must be rebuilt or replaced before the stack runs.
- caveat: the app runs several processes (web, Celery, nginx, Redis or database helpers) and needs ffmpeg, so memory and CPU use are higher than a single Python service (inferred).
- caveat: the upstream app depends on a project-owned base image that is not in this repo, so the base must be recreated locally before the first build.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: dispatcharr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/dispatcharr/dispatcharr:0.34.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Dispatcharr/Dispatcharr/blob/83f82bf388b72ec1e6cc356f1015a9812228b424/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Dispatcharr/Dispatcharr)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Dispatcharr/Dispatcharr/releases/tag/v0.34.1)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Python and Django app with a node frontend build, running several processes (web, celery, nginx) from a project-owned base image that is not in this repo. It needs ffmpeg and multi-process supervision, so it is a multi-service image to rebuild rootless.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/dispatcharr/dispatcharr:0.34.1](https://ghcr.io/dispatcharr/dispatcharr)
- **copy-from arm64**: [ghcr.io/dispatcharr/dispatcharr:0.34.1](https://ghcr.io/dispatcharr/dispatcharr)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

❌ means it is missing too.

- **Dependency containers**: alpine (alpineImage) ❌
