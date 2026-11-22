# threadfin

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: threadfin
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/threadfin
- **Source repository**: https://github.com/Threadfin/Threadfin
- **Documentation**: https://github.com/Threadfin/Threadfin/wiki

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/fyb3roptik/threadfin

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go binary from the release downloads.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: ffmpeg (optional)
- python/pip: none
- node/npm: none
- other: Go release binary per arch

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 34400/http (web UI and playlist API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/threadfin
- non-root: yes - no runAs override, common default 568; draft says it runs non-root
- read-only-rootfs: yes - default readOnlyRootFilesystem true, no override
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: /home/threadfin/conf (pvc, chart's own; draft expects /config, so mismatch); /tmp/threadfin (emptyDir)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: threadfin
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/fyb3roptik/threadfin:1.2.37`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Threadfin/Threadfin/blob/c459dd5a3a3227dfe08143183370a9898185203a/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Threadfin/Threadfin)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/Threadfin/Threadfin/releases/download/1.2.37/Threadfin_linux_amd64) · [arm64](https://github.com/Threadfin/Threadfin/releases/download/1.2.37/Threadfin_linux_arm64)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go binary with release downloads per arch, so copy Threadfin_linux_amd64 or arm64 into /app on containerforge-ubuntu. Config and cache go to /config and /tmp. It runs as one non-root process, and ffmpeg is optional.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [fyb3roptik/threadfin:1.2.37](https://hub.docker.com/r/fyb3roptik/threadfin)
- **copy-from arm64**: [fyb3roptik/threadfin:1.2.37](https://hub.docker.com/r/fyb3roptik/threadfin)

### Dependency containers

- **Dependency containers**: none
