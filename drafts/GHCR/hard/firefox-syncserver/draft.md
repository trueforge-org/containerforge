# firefox-syncserver

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: firefox-syncserver
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/firefox-syncserver
- **Source repository**: https://github.com/mozilla-services/syncserver
- **Documentation**: https://mozilla-services.github.io/syncstorage-rs/

## Potentially relevant resources

- **Container image**: https://ghcr.io/crazy-max/firefox-syncserver
- **Website**: https://moz-services-docs.readthedocs.io/en/latest/howtos/run-sync-1.5.html

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python 2.7 app, so the python base is the closest runtime; not portable as is.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: firefox-syncserver
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/crazy-max/firefox-syncserver:1.8.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/crazy-max/docker-firefox-syncserver/blob/45fc9e0a5fa863fb109d5f4ae34b5d5e4656ee11/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/mozilla-services/syncserver)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Python 2.7 end-of-life app with no runtime on Ubuntu 26.04 and a musl-only upstream image. Not portable as is; the practical path is switching to the Rust successor syncstorage-rs as a different application.

### amd64 / arm64

How we get the application for that architecture.

- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: no
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
