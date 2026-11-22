# radicale

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: radicale
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/radicale
- **Source repository**: https://github.com/Kozea/Radicale
- **Documentation**: https://radicale.org/v3.html

## Potentially relevant resources

- **Source code repository**: https://github.com/tomsquest/docker-radicale
- **Container image**: https://hub.docker.com/r/tomsquest/docker-radicale
- **Website**: https://radicale.org

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Pure Python CalDAV/CardDAV server installed with pip into a venv.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: radicale
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5232/http (CalDAV/CardDAV)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/radicale
- non-root: yes - chart sets runAsUser 2999 and runAsGroup 2999, not root
- read-only-rootfs: yes - default readOnlyRootFilesystem true, no override; writes go to mounts
- privileged: no - not set, common default false
- other-security: capabilities add SETUID, SETGID, KILL (drop ALL otherwise)
- extra-persistence: /data (pvc, chart's own; draft expects data in /config, so mismatch); /config/config and /config/users (configmap)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: radicale
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/tomsquest/docker-radicale:3.9.2.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/tomsquest/docker-radicale/blob/3.9.2.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Kozea/Radicale)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:radicale`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Pure Python CalDAV/CardDAV server installed with pip into a venv under /app, with data under /config. It is a single process with no extra services and runs on the python sibling. Pip wheels cover both architectures.

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
