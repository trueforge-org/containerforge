# goaccess

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: goaccess
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/goaccess
- **Source repository**: https://github.com/allinurl/goaccess
- **Documentation**: https://goaccess.io/man
- **Website**: https://goaccess.io/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/gregyankovoy/goaccess

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Alternative runtime image**: [nginx](https://github.com/trueforge-org/containerforge/tree/main/apps/nginx) (`ghcr.io/trueforge-org/nginx`)
- **Reason**: goaccess is installed from apt on ubuntu, and nginx is the alternative if serving the HTML report becomes the main runtime.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: goaccess; nginx only if the nginx route is chosen (inferred)
- python/pip: none
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 7890/http (real-time HTML report and WebSocket, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/goaccess
- non-root: no - chart sets container runAsUser 0 and runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, no override in values
- other-security: none beyond root override
- extra-persistence: /opt/log (pvc)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: goaccess
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/gregyankovoy/goaccess:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/gregyankovoy/docker-goaccess/blob/efd688be8b6ae2991209e76de4908860a3350297/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/allinurl/goaccess)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:goaccess`

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Log report generator from source in the upstream image, but Ubuntu ships goaccess in apt for both arches. Pair it with nginx to serve the HTML report, which means two processes that need a small supervisor. Logs and reports go to /config or /tmp.

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
