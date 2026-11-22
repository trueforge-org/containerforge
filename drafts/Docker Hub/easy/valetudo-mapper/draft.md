# valetudo-mapper

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: valetudo-mapper
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/valetudo-mapper
- **Source repository**: https://github.com/rand256/valetudo-mapper
- **Documentation**: https://valetudo.cloud/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/rand256/valetudo-mapper

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node.js app run with npm start and no Python needs.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: unzip (inferred)
- python/pip: none
- node/npm: npm install from repo package.json (inferred)
- other: upstream repo master zip

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/valetudo-mapper
- non-root: possible - chart sets runAsUser 0 and runAsGroup 0; draft says it runs as the apps user
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; cache goes to /tmp
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: none
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: valetudo-mapper
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/rand256/valetudo-mapper:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/rand256/valetudo-mapper/blob/54aba3534e9e797b9a22c0e134fa2706effd2e9d/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/rand256/valetudo-mapper)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/rand256/valetudo-mapper/archive/refs/heads/master.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Node.js app installed from npm and started with npm start, with no build step and no extra services. Reuse the node sibling and place the app in /app with cache under /tmp. Runs as apps user.

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
