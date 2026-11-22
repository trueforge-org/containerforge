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

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/mtlynch/mediagoblin

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Pure Python app installed into a venv.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: ffmpeg, gstreamer1.0-plugins-base, gstreamer1.0-plugins-good, libjpeg-dev, libpng-dev, libffi-dev (inferred)
- python/pip: mediagoblin 0.15.0 requirements in venv (inferred)
- node/npm: none
- other: sr.ht source tarball v0.15.0

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 6543/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/mediagoblin
- non-root: no - chart sets runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none in values
- extra-persistence: /var/lib/mediagoblin (pvc, chart default)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: MediaGoblin needs a database and a separate celery worker process next to the web app (inferred).
- caveat: Media processing (ffmpeg, gstreamer) is heavy, so large uploads take CPU and time (inferred).
- caveat: The source is a 0.15.0 tarball from sr.ht, not a registry image, so the build depends on that host being reachable.

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
