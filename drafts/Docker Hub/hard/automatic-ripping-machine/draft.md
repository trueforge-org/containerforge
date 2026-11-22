# automatic-ripping-machine

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: automatic-ripping-machine
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/automatic-ripping-machine
- **Source repository**: https://github.com/automatic-ripping-machine/automatic-ripping-machine
- **Documentation**: https://github.com/automatic-ripping-machine/automatic-ripping-machine/wiki

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/automaticrippingmachine/automatic-ripping-machine

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python web app, with native ripping tools installed alongside.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: handbrake-cli, ffmpeg, abcde, lsdvd, eject (inferred)
- python/pip: app requirements from repo (inferred) ([requirements.txt](https://github.com/automatic-ripping-machine/automatic-ripping-machine/blob/HEAD/requirements.txt))
- node/npm: none
- other: MakeMKV built from source (inferred)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/automatic-ripping-machine
- non-root: no - chart sets runAsUser 0 and an install init container chowns dirs as root; optical drive work needs root
- read-only-rootfs: no - chart sets false and the app writes to /home/arm and /etc/arm/config
- privileged: unknown - allowPrivilegeEscalation true is set, privileged is not; draft needs optical device access
- other-security: allowPrivilegeEscalation true (chart); optical drive devices (draft, not in values)
- extra-persistence: /home/arm (pvc, ripped output and state); /etc/arm/config (pvc, chart mount)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: automatic-ripping-machine
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/automaticrippingmachine/automatic-ripping-machine:2.24.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/automatic-ripping-machine/automatic-ripping-machine/blob/a380622a715072a524b7ae17a9736d8b925bb4b4/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/automatic-ripping-machine/automatic-ripping-machine)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Python web app that rips optical discs with MakeMKV and HandBrake. It needs root, optical drive devices and a long list of native tools built in its arm-dependencies image. Hardware-bound, which keeps it hard even though the app is Python.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [automaticrippingmachine/automatic-ripping-machine:2.24.4](https://hub.docker.com/r/automaticrippingmachine/automatic-ripping-machine)
- **copy-from arm64**: [automaticrippingmachine/automatic-ripping-machine:2.24.4](https://hub.docker.com/r/automaticrippingmachine/automatic-ripping-machine)

### Dependency containers

- **Dependency containers**: none
