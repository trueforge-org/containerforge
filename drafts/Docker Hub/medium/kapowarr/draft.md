# kapowarr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: kapowarr
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/kapowarr
- **Source repository**: https://github.com/Casvt/Kapowarr
- **Documentation**: https://casvt.github.io/Kapowarr

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/mrcas/kapowarr

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python app installed with pip into /app, which the input says fits the python sibling.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: build-essential (inferred, for wheels with a Rust stage)
- python/pip: requirements from Kapowarr release zip (inferred) ([requirements.txt](https://github.com/Casvt/Kapowarr/blob/HEAD/requirements.txt))
- node/npm: none
- other: Kapowarr-release.zip (v1.3.2) release download

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5656/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/kapowarr
- non-root: possible - chart forces runAsUser 0 and runAsGroup 0; python app could run as non-root
- read-only-rootfs: yes - readOnlyRootFilesystem not overridden, so common default true; writes go to volumes
- privileged: no - common default, not overridden
- other-security: none
- extra-persistence: /app/temp_downloads (pvc), /comics-1 (pvc, media), /app/db (pvc, state path instead of /config)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: metadata lookups use ComicVine and usually need an API key set in the UI or config (inferred).
- caveat: the app writes its database and state under its install folder on some paths, which may conflict with a read-only rootfs; verify the data path is /config (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: kapowarr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/mrcas/kapowarr:v1.0.0-beta-4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Casvt/Kapowarr/blob/V1.0.0-beta-4/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Casvt/Kapowarr)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Casvt/Kapowarr/releases/download/V1.3.2/Kapowarr-release.zip)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python app installed with pip into /app, which fits the python sibling. The upstream image builds some wheels in a Rust stage, so the runtime needs a wheel that matches each arch. State goes in /config and the app has no extra services.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [mrcas/kapowarr:v1.0.0-beta-4](https://hub.docker.com/r/mrcas/kapowarr)
- **copy-from arm64**: [mrcas/kapowarr:v1.0.0-beta-4](https://hub.docker.com/r/mrcas/kapowarr)

### Dependency containers

- **Dependency containers**: none
