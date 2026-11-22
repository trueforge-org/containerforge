# joplin-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: joplin-server
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/joplin-server
- **Source repository**: https://github.com/laurent22/joplin
- **Documentation**: https://joplinapp.org/help/
- **Website**: https://joplinapp.org/

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
