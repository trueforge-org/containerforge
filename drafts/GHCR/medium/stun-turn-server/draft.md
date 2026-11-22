# stun-turn-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: stun-turn-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/stun-turn-server
- **Source repository**: https://github.com/coturn/coturn
- **Website**: https://coturn.github.io/
- **Documentation**: https://github.com/coturn/coturn/wiki
- **Website**: https://coturn.net/

## Potentially relevant resources

- **Container image**: https://ghcr.io/ich777/stun-turn-server

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: stun-turn-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/stun-turn-server:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-stun-turn-server/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/coturn/coturn)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:coturn`

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Coturn is a C TURN/STUN server installed from the Ubuntu apt package, so no compile on containerforge-ubuntu and amd64 plus arm64 both work. Needs a USER apps start script, config and TLS certs in /config, and listening ports above 1024 or relay port range exposed.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/stun-turn-server:latest](https://ghcr.io/ich777/stun-turn-server)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
