# venstar2mqtt

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: venstar2mqtt
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/venstar2mqtt
- **Source repository**: https://github.com/terafin/mqtt-venstar-bridge

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/terafin/mqtt-venstar-bridge

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Pure JavaScript Node MQTT bridge installed with npm.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: project deps from package.json via npm install --production (inferred)
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: none (inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/venstar2mqtt
- non-root: possible - chart forces runAsUser 0, but a Node MQTT client needs no root
- read-only-rootfs: possible - chart sets false; draft writes only to /config
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: none
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Upstream is a GitHub master-branch zip with no release tags, so the build is not reproducible and can change without notice.
- caveat: Needs a reachable Venstar thermostat on the LAN and a reachable MQTT broker, which the container does not provide (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: venstar2mqtt
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/terafin/mqtt-venstar-bridge:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/terafin/mqtt-venstar-bridge/blob/423f9bd/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/terafin/mqtt-venstar-bridge)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/terafin/mqtt-venstar-bridge/archive/refs/heads/master.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Node MQTT bridge installed with one npm install --production and no extra services. It runs on the ContainerForge node sibling with the app in /app and state in /config. Pure JavaScript, so nothing needs compiling per architecture.

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
