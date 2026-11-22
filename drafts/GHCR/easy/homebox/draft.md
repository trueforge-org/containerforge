# homebox

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: homebox
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/sysadminsmedia/homebox
- **Documentation**: https://homebox.software/en/
- **Website**: https://homebox.software/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: homebox
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/sysadminsmedia/homebox:0.27.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/sysadminsmedia/homebox/blob/1fd28822634a3d5935c002d569559ef46530d4a0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/sysadminsmedia/homebox)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/sysadminsmedia/homebox/releases/download/v0.27.1/homebox_Linux_x86_64.tar.gz) · [arm64](https://github.com/sysadminsmedia/homebox/releases/download/v0.27.1/homebox_Linux_arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Homebox is a Go binary with the UI embedded, released as linux x86_64 and arm64 tarballs. It runs as one process with SQLite data in /config, and Postgres is optional via CNPG. No sibling is needed.

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

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql (CNPG) ✅
