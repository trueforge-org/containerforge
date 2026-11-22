# auto-yt-dl

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: auto-yt-dl
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/auto-yt-dl
- No application links recorded in `docs/project-fireball.md`.

## Potentially relevant resources

- **Source code repository**: https://github.com/xXGuhuXx/auto-yt-dl
- **Container image**: https://hub.docker.com/r/guhu007/auto-yt-dl

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Guess: no source or Dockerfile is available, so the runtime is unknown.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: yt-dlp (inferred, unverified)
- node/npm: none
- other: no source or Dockerfile available, runtime unknown

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: none (inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/auto-yt-dl
- non-root: possible - chart sets runAsUser 0; runtime unknown because no upstream source
- read-only-rootfs: possible - chart sets false; runtime unknown
- privileged: no - not set, common default false
- other-security: hostpath1 mount to /app/Downloads (chart; type not stated in values)
- extra-persistence: /app/data (pvc); /app/Downloads (hostPath or pvc, type not set in values)
- confidence: low

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: auto-yt-dl
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/guhu007/auto-yt-dl:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: -

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: The GitHub repo returns 404 and the Docker Hub page names a different image, so there is no public Dockerfile or source. The app's behaviour and runtime cannot be verified, so a port would start from scratch.

### amd64 / arm64

How we get the application for that architecture.

- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: no*
- **arm64**: no*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

A path in backticks is where the binary sits inside the image.

- **copy-from amd64**: [guhu007/auto-yt-dl:latest](https://hub.docker.com/r/guhu007/auto-yt-dl) (`app directory, path unknown`)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
