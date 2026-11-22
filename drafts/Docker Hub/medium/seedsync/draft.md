# seedsync

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: seedsync
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/seedsync
- **Source repository**: https://github.com/ipsingh06/seedsync

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/ipsingh06/seedsync

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python app installed with pip into /app, and the input names the python sibling.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: poetry (inferred), seedsync package installed into /app
- node/npm: nodejs, npm (inferred) for Angular frontend build
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8800/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/seedsync
- non-root: no - runAsUser 0, runAsGroup 0 overrides
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default privileged false, not overridden
- other-security: none
- extra-persistence: /downloads (pvc, chart-defined)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Upstream binary is an amd64 .deb only; arm64 requires a compile from source, which is not yet tested.
- caveat: Background scan daemon polls the download share continuously, so it can be CPU and I/O heavy on large libraries (inferred).
- caveat: Requires a seedbox or remote source (SFTP/SSH) with credentials configured in the UI before it does anything useful.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: seedsync
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/ipsingh06/seedsync:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ipsingh06/seedsync/blob/ff2a103/src/docker/build/docker-image/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ipsingh06/seedsync)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/ipsingh06/seedsync/releases/download/v0.8.6/seedsync_0.8.6_amd64.deb)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python app installed with poetry plus a prebuilt Angular frontend pulled from staging-registry images, which we would rebuild with Node. Run it on the python sibling with a pip install into /app and move state to /config. Background scan daemon adds some moving parts.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: yes
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ipsingh06/seedsync:latest](https://hub.docker.com/r/ipsingh06/seedsync)
- **copy-from arm64**: [ipsingh06/seedsync:latest](https://hub.docker.com/r/ipsingh06/seedsync)

### Dependency containers

- **Dependency containers**: none
