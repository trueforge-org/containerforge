# novnc

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: novnc
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/novnc
- **Source repository**: https://github.com/novnc/noVNC
- **Documentation**: https://github.com/novnc/noVNC/wiki

## Potentially relevant resources

- **Container image**: https://ghcr.io/nicholaswilde/novnc
- **Website**: https://novnc.com

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [nginx](https://github.com/trueforge-org/containerforge/tree/main/apps/nginx) (`ghcr.io/trueforge-org/nginx`)
- **Alternative runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Static noVNC files served by nginx; websockify is an optional Python proxy.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: websockify
- node/npm: none
- other: noVNC release tarball (v1.7.0)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (nginx static files, inferred), 6080/http (websockify, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/novnc
- non-root: possible - chart sets runAsUser 0 and runAsNonRoot false; nginx and websockify can run on unprivileged ports without root
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; nginx needs writable cache and run paths, covered by the common /var/run and /tmp mounts
- privileged: no - no privileged key in values; common default false
- other-security: none
- extra-persistence: none beyond common defaults (varrun is a common default)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: novnc
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/nicholaswilde/novnc:version-1.2.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/nicholaswilde/docker-novnc/blob/caa724f/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/novnc/noVNC)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/novnc/noVNC/releases/tag/v1.7.0)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: noVNC is a static JavaScript web client from its release tarball, served by nginx. The websockify proxy is one pip package. Copy the files to /app and run websockify as one process on an unprivileged port, with no compile.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
