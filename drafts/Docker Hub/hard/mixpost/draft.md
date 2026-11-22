# mixpost

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: mixpost
- **Rows**: 1
- **Hard dependency containers**: yes (mariadb)
- **Soft dependency containers**: yes (valkey)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/inovector/mixpost
- **Documentation**: https://docs.mixpost.app/lite/
- **Documentation**: https://docs.mixpost.app/
- **Website**: https://mixpost.app/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: mixpost
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/inovector/mixpost:v2.6.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/inovector/mixpost)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/inovector/mixpost/releases/tag/2.6.0)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Laravel PHP app with no public Dockerfile in the inventory, and the image's build source was not found. It needs mariadb and valkey, so several services and a PHP stack must be assembled on containerforge-ubuntu.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [inovector/mixpost:v2.6.0](https://hub.docker.com/r/inovector/mixpost)
- **copy-from arm64**: [inovector/mixpost:v2.6.0](https://hub.docker.com/r/inovector/mixpost)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: valkey ✅, mariadb ✅
