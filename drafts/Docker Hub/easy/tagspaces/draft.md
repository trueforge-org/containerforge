# tagspaces

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: tagspaces
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tagspaces
- **Source repository**: https://github.com/tagspaces/tagspaces
- **Documentation**: https://docs.tagspaces.org/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/fardjad/tagspaces-lite-web

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [nginx](https://github.com/trueforge-org/containerforge/tree/main/apps/nginx) (`ghcr.io/trueforge-org/nginx`)
- **Alternative runtime image**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`)
- **Reason**: Static web bundle served by nginx.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: tagspaces
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/fardjad/tagspaces-lite-web:6.0.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/fardjad/tagspaces-lite-docker/blob/495b1805d716d826fdd70ddc558df4a700b364be/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/tagspaces/tagspaces)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/tagspaces/tagspaces/releases/download/v6.0.2/tagspaces-linux-amd64-6.0.2.deb) · [arm64](https://github.com/tagspaces/tagspaces/releases/download/v6.0.2/tagspaces-mac-arm64-6.0.2.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Static tagspaces-lite web bundle served by nginx, so reuse the ContainerForge nginx app and place the bundle in /app. No runtime processes beyond nginx and no native code. Writes go to /tmp, and the wrapper only copies files.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [fardjad/tagspaces-lite-web:6.0.2](https://hub.docker.com/r/fardjad/tagspaces-lite-web)
- **copy-from arm64**: [fardjad/tagspaces-lite-web:6.0.2](https://hub.docker.com/r/fardjad/tagspaces-lite-web)

### Dependency containers

- **Dependency containers**: none
