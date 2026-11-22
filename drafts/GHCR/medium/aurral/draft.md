# aurral

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: aurral
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: aurral
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/lklynet/aurral:3.0.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/lklynet/aurral/blob/84535c99df51/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/lklynet/aurral)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/lklynet/aurral/releases/tag/v3.0.0)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node.js pnpm monorepo with separate frontend and backend builds, plus ffmpeg and cloudflared. Use the ContainerForge node base, apt ffmpeg, and the cloudflared release binary for each arch. Writes must go to /config and /tmp, and the several moving parts put it at medium.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/lklynet/aurral:3.0.0](https://ghcr.io/lklynet/aurral)
- **copy-from arm64**: [ghcr.io/lklynet/aurral:3.0.0](https://ghcr.io/lklynet/aurral)

### Dependency containers

- **Dependency containers**: none
