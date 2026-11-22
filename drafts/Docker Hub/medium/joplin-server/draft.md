# joplin-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: joplin-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/joplin-server
- **Source repository**: https://github.com/laurent22/joplin
- **Documentation**: https://joplinapp.org/help/
- **Website**: https://joplinapp.org/

## Potentially relevant resources

- **Source code repository**: https://github.com/laurent22/joplin/tree/dev/packages/server
- **Container image**: https://hub.docker.com/r/joplin/server

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node server only, so python-node provides the node runtime.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: yarn (monorepo build, inferred); pm2 and tini (inferred, per upstream image)
- other: Joplin yarn monorepo source (laurent22/joplin v3.7.6), packages/server

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 22300/http (API and web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/joplin-server
- non-root: possible - chart forces runAsUser 0 and runAsNonRoot false; Node server can run non-root
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; pm2 may need a writable home
- privileged: no - common default, not overridden
- other-security: none
- extra-persistence: none beyond /config
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: joplin-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/joplin/server:3.7.6`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/laurent22/joplin/blob/6fcc076/Dockerfile.server)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/laurent22/joplin)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/laurent22/joplin/releases/tag/v3.7.6)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node server from the Joplin yarn monorepo, built in a node:24 builder and run under pm2 and tini. We would reuse the node sibling, build packages/server into /app, and point it at the external PostgreSQL via PostgreSQL. The monorepo build is large but produces arch-neutral JavaScript.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [joplin/server:3.7.6](https://hub.docker.com/r/joplin/server)
- **copy-from arm64**: [joplin/server:3.7.6](https://hub.docker.com/r/joplin/server)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
