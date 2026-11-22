# outline

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: outline
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql, valkey)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/outline
- **Source repository**: https://github.com/outline/outline
- **Documentation**: https://docs.getoutline.com/
- **Website**: https://www.getoutline.com/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/outlinewiki/outline

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node monorepo with a frontend build, so the Node runtime in python-node fits.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: node runtime from python-node, yarn (inferred)
- other: outline monorepo source build (large frontend build)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (web app and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/outline
- non-root: no - runAsUser 0, runAsNonRoot false, no override
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set in values (default false)
- other-security: none
- extra-persistence: /var/lib/outline/data (pvc)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: outline
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/outlinewiki/outline:1.13.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/outline/outline/blob/f1f5fd364842916af8c4996c75ee3bed3b30aad4/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/outline/outline)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: A large Node monorepo built in a base stage with a big frontend build, and it needs Postgres, Valkey and object storage. There is no release artifact, so the build is large and the stack is several services.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [outlinewiki/outline:1.13.0](https://hub.docker.com/r/outlinewiki/outline)
- **copy-from arm64**: [outlinewiki/outline:1.13.0](https://hub.docker.com/r/outlinewiki/outline)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: valkey ✅, postgresql ✅
