# node-red

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: node-red
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/node-red
- **Source repository**: https://github.com/node-red/node-red
- **Documentation**: https://nodered.org/docs/

## Potentially relevant resources

- **Container image**: https://ghcr.io/node-red/node-red
- **Source code repository**: https://github.com/node-red/node-red-docker

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node.js app installed with npm, with no Python needs.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: node-red
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 1880/http (web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/node-red
- non-root: yes - no securityContext override, common runAsUser 568; draft runs one non-root Node process
- read-only-rootfs: yes - common default readOnlyRootFilesystem true; flows and palette installs go to a volume
- privileged: no - no privileged key in values; common default false
- other-security: none
- extra-persistence: none for the draft (flows in /config); chart mounts /data (pvc default)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: flows, settings and palette installs are written to /config; a read-only config volume breaks palette installs (inferred).
- caveat: the draft installs node-red with an unpinned `npm install`, while the chart uses 5.0.10; pin the version in the build to match the chart.
- caveat: Node-RED ships with no login by default; the web UI on 1880 should be protected by a reverse proxy or the editor auth settings (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: node-red
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/node-red/node-red:5.0.10`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/node-red/node-red-docker/blob/69e4248/.docker/Dockerfile.debian)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/node-red/node-red)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `npm:node-red`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Node-RED flow editor installed with one npm command (npm install node-red) on the ContainerForge node base. Flows and settings live in /config, and palette nodes install there too. Runs as one non-root Node process.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/node-red/node-red:5.0.10](https://ghcr.io/node-red/node-red)
- **copy-from arm64**: [ghcr.io/node-red/node-red:5.0.10](https://ghcr.io/node-red/node-red)

### Dependency containers

- **Dependency containers**: none
