# cannery

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: cannery
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/cannery
- **Source repository**: https://gitlab.com/shibaobun/cannery

## Potentially relevant resources

- **Website**: https://gitea.bubbletea.dev/shibao/cannery
- **Container image**: https://hub.docker.com/r/shibaobun/cannery

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: Guess: Elixir app with no Elixir base, so ubuntu is the fallback.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: cannery
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/shibaobun/cannery:1.5.8`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://gitlab.com/shibaobun/cannery/-/blob/1.5.8/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://gitlab.com/shibaobun/cannery)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Elixir/Phoenix app with no public Dockerfile found, since raw GitLab probes returned 404. It also needs PostgreSQL. Building from source requires the Elixir toolchain and reconstructing the release.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
