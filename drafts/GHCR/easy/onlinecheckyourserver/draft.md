# onlinecheckyourserver

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: onlinecheckyourserver
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/onlinecheckyourserver
- **Source repository**: https://github.com/ich777/docker-online-check-pushover
- **Documentation**: https://github.com/ich777/docker-online-check-pushover/blob/master/README.md

## Potentially relevant resources

- **Container image**: https://ghcr.io/ich777/online-check-pushover

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Shell script wrapper that needs only curl and the script itself.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: curl (inferred)
- python/pip: none
- node/npm: none
- other: shell script from repo (ich777/docker-online-check-pushover)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: none

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/onlinecheckyourserver
- non-root: possible - chart sets runAsUser 0 and runAsGroup 0; the draft runs a shell script as apps
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; the script writes little beyond /config
- privileged: no - no privileged key in values; common default false
- other-security: none
- extra-persistence: none (chart has persistence: {} and the draft uses /config)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: onlinecheckyourserver
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/online-check-pushover:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-online-check-pushover/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ich777/docker-online-check-pushover)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/ich777/docker-online-check-pushover)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Shell-script wrapper that checks online status and sends Pushover notifications; the ich777 image is a thin wrapper on the debian base. Install curl and the script on containerforge-ubuntu, run as apps and keep config under /config. Trivial scope.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/online-check-pushover:latest](https://ghcr.io/ich777/online-check-pushover)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
