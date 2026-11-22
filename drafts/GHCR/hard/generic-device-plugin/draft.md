# generic-device-plugin

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: generic-device-plugin
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/generic-device-plugin
- **Source repository**: https://github.com/squat/generic-device-plugin

## Potentially relevant resources

- **Container image**: https://ghcr.io/squat/generic-device-plugin

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go daemon compiled from source.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Go build from source (go modules)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (metrics, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/generic-device-plugin
- non-root: no - chart forces runAsUser 0 and runAsNonRoot false
- read-only-rootfs: yes - chart sets readOnlyRootFilesystem true
- privileged: yes - chart sets privileged true
- other-security: hostPath /dev and /var/lib/kubelet/device-plugins; device args to the plugin
- extra-persistence: /dev (hostPath /dev), /var/lib/kubelet/device-plugins (hostPath)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: generic-device-plugin
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/squat/generic-device-plugin:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/squat/generic-device-plugin/blob/f7c3291/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/squat/generic-device-plugin)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: The generic device plugin is a Go daemon that needs privileged access to /dev and the kubelet device-plugin socket. It is hardware and host access by design. Releases only ship a helm chart, so the binary has to be compiled.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/squat/generic-device-plugin:latest](https://ghcr.io/squat/generic-device-plugin)
- **copy-from arm64**: [ghcr.io/squat/generic-device-plugin:latest](https://ghcr.io/squat/generic-device-plugin)

### Dependency containers

- **Dependency containers**: none
