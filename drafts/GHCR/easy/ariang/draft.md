# ariang

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: ariang
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ariang
- **Source repository**: https://github.com/mayswind/AriaNg
- **Documentation**: http://ariang.mayswind.net
- **Website**: http://ariang.mayswind.net

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: ariang
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/leonismoe/ariang:1.3.13`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/leonismoe/docker-images/blob/3b6bca6db6513787ad225d555778f7f31c7d3f36/ariang/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/mayswind/AriaNg)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/mayswind/AriaNg/releases/download/1.3.13/AriaNg-1.3.13.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: AriaNg is a static JS web UI shipped as a release zip, with darkhttpd built from C source in the image. On ubuntu, unpack the zip into /app and serve it with the nginx sibling from /tmp or /app. No services and no state beyond browser settings. Easy.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/leonismoe/ariang:1.3.13](https://ghcr.io/leonismoe/ariang)
- **copy-from arm64**: [ghcr.io/leonismoe/ariang:1.3.13](https://ghcr.io/leonismoe/ariang)

### Dependency containers

- **Dependency containers**: none
