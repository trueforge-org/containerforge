# signal-cli-rest-api

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: signal-cli-rest-api
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/signal-cli-rest-api
- **Source repository**: https://github.com/bbernhard/signal-cli-rest-api
- **Documentation**: https://bbernhard.github.io/signal-cli-rest-api/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/bbernhard/signal-cli-rest-api

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java25](https://github.com/trueforge-org/containerforge/tree/main/apps/java25) (`ghcr.io/trueforge-org/java25`)
- **Alternative runtime image**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`)
- **Reason**: The input names the java25 sibling for the JVM child process; the Go REST server makes ubuntu the alternative.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Go toolchain (build stage), Go modules, signal-cli tarball (JVM from java25 sibling)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (REST API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/signal-cli-rest-api
- non-root: no - runAsUser 0, runAsGroup 0 overrides
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default privileged false, not overridden
- other-security: none
- extra-persistence: /home/.local/share/signal-cli (pvc, chart config via targetSelector)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: signal-cli-rest-api
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/bbernhard/signal-cli-rest-api:0.101`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/bbernhard/signal-cli-rest-api/blob/0.101/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/bbernhard/signal-cli-rest-api)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go REST server built from source, plus the signal-cli Java tarball on openjdk 25. ContainerForge has a java25 sibling. We would add a Go build stage, and the JVM runs as a child process in one container with state under /config.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [bbernhard/signal-cli-rest-api:0.101](https://hub.docker.com/r/bbernhard/signal-cli-rest-api)
- **copy-from arm64**: [bbernhard/signal-cli-rest-api:0.101](https://hub.docker.com/r/bbernhard/signal-cli-rest-api)

### Dependency containers

- **Dependency containers**: none
