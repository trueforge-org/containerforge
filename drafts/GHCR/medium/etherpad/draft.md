# etherpad

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: etherpad
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/etherpad
- **Source repository**: https://github.com/ether/etherpad

## Potentially relevant resources

- **Website**: https://etherpad.org
- **Container image**: https://ghcr.io/ether/etherpad
- **Source code repository**: https://github.com/ether/etherpad-lite

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: etherpad
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ether/etherpad:3.3.20`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ether/etherpad/blob/844729c6b9e68d593da9928141e6e2daced53ec9/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ether/etherpad)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/ether/etherpad/releases/download/v3.3.20/etherpad-latest_amd64.deb) · [arm64](https://github.com/ether/etherpad/releases/download/v3.3.20/etherpad-latest_arm64.deb)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node.js server (pnpm) with an admin UI built in the Dockerfile; reuse the node sibling and build into /app. Needs a database (typically Postgres via PostgreSQL) and writes settings and session data under /config. Several pnpm build stages make it a moderate effort.

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

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
