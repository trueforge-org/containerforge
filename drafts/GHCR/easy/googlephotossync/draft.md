# googlephotossync

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: googlephotossync
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: googlephotossync
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/gilesknap/gphotos-sync:3.2.5`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/gilesknap/gphotos-sync/blob/b50baadcd769c09f32b5f9c1020dc3b75540c6f1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/gilesknap/gphotos-sync)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/gilesknap/gphotos-sync/releases/download/3.2.5/gphotos_sync-3.2.5-py3-none-any.whl)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Python tool gphotos-sync installed by pip into a venv under /app; reuse the python sibling. One command and one process, with OAuth tokens and downloads kept under /config. The Google OAuth client is a user setup step, not an image issue.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/gilesknap/gphotos-sync:3.2.5](https://ghcr.io/gilesknap/gphotos-sync)
- **copy-from arm64**: [ghcr.io/gilesknap/gphotos-sync:3.2.5](https://ghcr.io/gilesknap/gphotos-sync)

### Dependency containers

- **Dependency containers**: none
