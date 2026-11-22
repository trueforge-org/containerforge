# misskey

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: misskey
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql, valkey)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/misskey
- **Source repository**: https://github.com/misskey-dev/misskey
- **Documentation**: https://misskey-hub.net/docs/
- **Website**: https://misskey-hub.net/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/misskey/misskey

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: python-node
- **Reason**: Node pnpm monorepo.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: misskey
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/misskey/misskey:2026.11.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/misskey-dev/misskey/blob/dd7b4905d715d2587fa2f2cb6a88ecac8878ef0d/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/misskey-dev/misskey)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: A large pnpm monorepo that builds the backend and a Vue frontend in a native-builder stage, with several services: web, streaming, workers, plus Postgres and Valkey. Node sibling covers the runtime, but the build is large and there is no release artifact.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [misskey/misskey:2026.11.0](https://hub.docker.com/r/misskey/misskey)
- **copy-from arm64**: [misskey/misskey:2026.11.0](https://hub.docker.com/r/misskey/misskey)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: valkey ✅, postgresql ✅
