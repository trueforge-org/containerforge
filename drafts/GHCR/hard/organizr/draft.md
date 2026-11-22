# organizr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: organizr
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/organizr
- **Source repository**: https://github.com/causefx/Organizr
- **Documentation**: https://docs.organizr.app/

## Potentially relevant resources

- **Container image**: https://ghcr.io/organizr/organizr

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Alternative runtime image**: [nginx](https://github.com/trueforge-org/containerforge/tree/main/apps/nginx) (`ghcr.io/trueforge-org/nginx`)
- **Reason**: PHP web app, so PHP via apt on ubuntu with nginx as the web server.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: organizr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/organizr/organizr:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Organizr/docker-organizr/blob/53b8b05/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/causefx/Organizr)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/causefx/Organizr/releases/tag/1.90)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Organizr is a PHP web app that the wrapper Dockerfile gets from an untraced ghcr.io/organizr/base image, so the real runtime is unknown. We would need to supply PHP-FPM and nginx ourselves, which means two cooperating processes with root-era config paths. Source is interpreted, so no compile is needed.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/organizr/organizr:latest](https://ghcr.io/organizr/organizr)
- **copy-from arm64**: [ghcr.io/organizr/organizr:latest](https://ghcr.io/organizr/organizr)

### Dependency containers

- **Dependency containers**: none
