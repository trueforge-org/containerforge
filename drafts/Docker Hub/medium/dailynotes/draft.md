# dailynotes

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: dailynotes
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/dailynotes
- **Source repository**: https://github.com/djedi/DailyNotes

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/m0ngr31/dailynotes

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Alternative runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python and Node are both needed, so python-node provides both runtimes.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: server requirements (inferred) ([requirements.txt](https://github.com/djedi/DailyNotes/blob/HEAD/requirements.txt))
- node/npm: client build deps (inferred)
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/dailynotes
- non-root: no - chart sets container runAsUser 0 and runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, no override in values
- other-security: none beyond root override
- extra-persistence: /app/config (pvc)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The chart persists /app/config, while ContainerForge uses /config for state, so the data path must be remapped (inferred).
- caveat: The Node client is built with npm in a builder stage and the Python server uses pip, so build time and image size are both significant (inferred).
- caveat: The upstream source uses a date-based release tag (2026.10.29-00), so pin the release tarball explicitly and verify its checksum.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: dailynotes
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/m0ngr31/dailynotes:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/djedi/DailyNotes/blob/9d1a3a7ea3597d93b2c8c4600437318a59eaa028/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/djedi/DailyNotes)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/djedi/DailyNotes/archive/refs/tags/2026.10.29-00.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python server installed with pip and a Node client built with npm in a builder stage, then copied into python:3.10-slim. On containerforge-ubuntu we would use the python and node siblings and run the npm build into /app, with data under /config. Two runtimes make the build more involved.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [m0ngr31/dailynotes:latest](https://hub.docker.com/r/m0ngr31/dailynotes)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
