# homarr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: homarr
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/homarr
- **Source repository**: https://github.com/homarr-labs/homarr
- **Documentation**: https://homarr.dev/docs/
- **Website**: https://homarr.dev/

## Potentially relevant resources

- **Container image**: https://ghcr.io/homarr-labs/homarr
- **Source code repository**: https://github.com/ajnart/homarr

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Next.js app on Node.js, with redis and nginx bundled as extra processes.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: redis-server (inferred), nginx (inferred)
- python/pip: none
- node/npm: pnpm (inferred), Next.js app deps and build
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 7575/http (web UI), 6379/tcp (bundled Redis, internal, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/homarr
- non-root: no - chart forces runAsUser 0 and runAsNonRoot false (root entrypoint drops privileges per Reason)
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, default false
- other-security: none in values
- extra-persistence: /appdata (type not set, likely pvc)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: homarr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/homarr-labs/homarr:v2.13.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/homarr-labs/homarr/blob/v2.13.1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/homarr-labs/homarr)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/homarr-labs/homarr/releases/download/v2.13.1/build-alpine-amd64.tar.gz) · [arm64](https://github.com/homarr-labs/homarr/releases/download/v2.13.1/build-alpine-arm64.tar.gz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Next.js app that runs redis-server and nginx alongside node, started by a root entrypoint that drops privileges. The multi-process layout, bundled Redis, sqlite data under /config and the entrypoint rewrite for a read-only rootfs make this a hard port.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/homarr-labs/homarr:v2.13.1](https://ghcr.io/homarr-labs/homarr)
- **copy-from arm64**: [ghcr.io/homarr-labs/homarr:v2.13.1](https://ghcr.io/homarr-labs/homarr)

### Dependency containers

- **Dependency containers**: none
