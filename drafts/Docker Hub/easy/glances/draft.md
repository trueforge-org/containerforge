# glances

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: glances
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/glances
- **Source repository**: https://github.com/nicolargo/glances
- **Documentation**: https://glances.readthedocs.io/en/develop/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/nicolargo/glances

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Single pip install of glances in a venv under /app.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: glances
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 61208/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/glances
- non-root: yes - securityContext.container sets runAsUser 1000, runAsGroup 1000, PUID 1000 with no root override
- read-only-rootfs: yes - no override, common default true (Glances writes only to /tmp, which is a common default)
- privileged: no - not set, common default false
- other-security: hostPID and hostNetwork are commented out in values, so not enabled; enabling them would be needed for task and network stats
- extra-persistence: none
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: glances
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/nicolargo/glances:ubuntu-4.3.0.8-full`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/nicolargo/glances/blob/e907519c4a446da33b6968dba8f1c3b84a3379df/docker-files/ubuntu.Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/nicolargo/glances)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:glances`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Glances is one pip install into a venv under /app, with no extra services. Use the python sibling and read host metrics read-only, with state and cache in /tmp and /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [nicolargo/glances:ubuntu-4.3.0.8-full](https://hub.docker.com/r/nicolargo/glances)
- **copy-from arm64**: [nicolargo/glances:ubuntu-4.3.0.8-full](https://hub.docker.com/r/nicolargo/glances)

### Dependency containers

- **Dependency containers**: none
