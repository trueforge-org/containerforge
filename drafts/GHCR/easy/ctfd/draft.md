# ctfd

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: ctfd
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (valkey)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ctfd
- **Source repository**: https://github.com/CTFd/CTFd
- **Documentation**: https://docs.ctfd.io

## Potentially relevant resources

- **Container image**: https://ghcr.io/ctfd/ctfd

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: ctfd
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ctfd/ctfd:3.8.9`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/CTFd/CTFd/blob/5f345fbaa424e6a22b51addf7f27430927879ae2/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/CTFd/CTFd)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/CTFd/CTFd/archive/refs/tags/3.8.9.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Python Flask app installed by pip from requirements, run by gunicorn on python slim. The python sibling covers the runtime, valkey is external, and uploads go to /config. Easy as a single pip install with one process.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/ctfd/ctfd:3.8.9](https://ghcr.io/ctfd/ctfd)
- **copy-from arm64**: [ghcr.io/ctfd/ctfd:3.8.9](https://ghcr.io/ctfd/ctfd)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: valkey ✅
