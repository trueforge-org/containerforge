# cloudflared

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: cloudflared
- **Rows**: 1
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/cloudflare/cloudflared
- **Documentation**: https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: cloudflared
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/cloudflare/cloudflared:2026.11.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/cloudflare/cloudflared/blob/518d7f7969b764df628bb4b1088f0f154901dc4e/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/cloudflare/cloudflared)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/cloudflare/cloudflared/releases/download/2026.11.1/cloudflared-amd64.pkg) · [arm64](https://github.com/cloudflare/cloudflared/releases/download/2026.11.1/cloudflared-arm64.pkg)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Single Go binary used as a Cloudflare tunnel client, configured with a token in the environment. Install the release binary on containerforge-ubuntu, run rootless, and use /tmp for cache; no other services.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [cloudflare/cloudflared:2026.11.1](https://hub.docker.com/r/cloudflare/cloudflared)
- **copy-from arm64**: [cloudflare/cloudflared:2026.11.1](https://hub.docker.com/r/cloudflare/cloudflared)

### Dependency containers

- **Dependency containers**: none
