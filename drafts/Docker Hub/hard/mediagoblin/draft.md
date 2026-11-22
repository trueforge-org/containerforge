# mediagoblin

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: mediagoblin
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/mediagoblin
- **Website**: https://mediagoblin.org/
- **Documentation**: https://docs.mediagoblin.org/en/stable/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: mediagoblin
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/mtlynch/mediagoblin:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/mtlynch/mediagoblin/blob/master/Dockerfile-python3)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://mediagoblin.org/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://git.sr.ht/~mediagoblin/mediagoblin/archive/v0.15.0.tar.gz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Pure Python 0.15.0 source from sr.ht installed into a venv on the python sibling (no Debian buster or Python 2). Needs ffmpeg, gstreamer and image libraries, a database and a celery worker, and writable media storage under /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [mtlynch/mediagoblin:latest](https://hub.docker.com/r/mtlynch/mediagoblin)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
