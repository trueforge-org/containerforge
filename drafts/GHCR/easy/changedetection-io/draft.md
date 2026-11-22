# changedetection-io

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: changedetection-io
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/dgtlmoon/changedetection.io

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: changedetection-io
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/dgtlmoon/changedetection.io:0.70.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/dgtlmoon/changedetection.io/blob/3316f256acc5bc01708c85da83b3ee7347c503d8/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/dgtlmoon/changedetection.io)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:changedetection.io`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Python Flask app installed with uv pip into a python slim image, and a changedetection sibling already exists in ContainerForge. Easy because the main image is one process with pure python deps. Browser fetchers are separate and not part of this image.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/dgtlmoon/changedetection.io:0.70.4](https://ghcr.io/dgtlmoon/changedetection.io)
- **copy-from arm64**: [ghcr.io/dgtlmoon/changedetection.io:0.70.4](https://ghcr.io/dgtlmoon/changedetection.io)

### Dependency containers

- **Dependency containers**: none
