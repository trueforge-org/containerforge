# photostructure

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: photostructure
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/photostructure/photostructure-for-servers

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: photostructure
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/photostructure/server:2026.9.4-beta`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/photostructure/photostructure-for-servers/blob/42bd6d0e2f7c2a5abaaa1948cb9591c591163467/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/photostructure/photostructure-for-servers)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `npm:photostructure`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: PhotoStructure is a Node server whose npm install compiles native modules in a base-tools builder stage that carries build libraries. It also copies a set of bundled helper tools into the image. Many moving parts and a large writable library cache make rootless, read-only runs harder.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/photostructure/server:2026.9.4-beta](https://ghcr.io/photostructure/server)
- **copy-from arm64**: [ghcr.io/photostructure/server:2026.9.4-beta](https://ghcr.io/photostructure/server)

### Dependency containers

- **Dependency containers**: none
