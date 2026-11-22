# fabulinus

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: fabulinus
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fabulinus
- **Source repository**: https://github.com/titanml/takeoff-community
- **Documentation**: https://docs.titanml.co/
- **Website**: https://www.titanml.co/

## Potentially relevant resources

- **Source code repository**: https://github.com/titanml/takeoff-communitys
- **Container image**: https://hub.docker.com/r/tytn/fabulinus

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Guess: closed-source inference server with no redistributable artifact.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: none (closed-source TitanML Takeoff server, no redistributable artifact)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (inferred, Takeoff inference server), 8000/http (inferred, Takeoff management API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/fabulinus
- non-root: no - runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: gpuImage variant needs GPU device access (not in values)
- extra-persistence: /code/models (chart persistence, type not shown)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the TitanML Takeoff server is closed source, so the image can only be pulled, not rebuilt, and an account or license may apply (licensing, inferred).
- caveat: the GPU variant needs an NVIDIA runtime and device access.
- caveat: models are stored in /code/models, and first start may download large model files (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: fabulinus
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/tytn/fabulinus:latest-cpu, latest-gpu`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/titanml/takeoff-community)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Community wrapper around the closed-source TitanML Takeoff inference server, with GPU variants and no public Dockerfile. Without a redistributable server artifact, ContainerForge cannot rebuild the image. GPU support adds a further blocker.

### amd64 / arm64

How we get the application for that architecture.

- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: no
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [tytn/fabulinus:latest-cpu](https://hub.docker.com/r/tytn/fabulinus)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
