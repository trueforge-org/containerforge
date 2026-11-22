# cloudcommander

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: cloudcommander
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/cloudcommander
- **Source repository**: https://github.com/coderaiser/cloudcmd

## Potentially relevant resources

- **Container image**: https://ghcr.io/coderaiser/cloudcmd

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node.js file manager installed from npm.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: build-essential, python3 (inferred, node-pty may compile)
- python/pip: none
- node/npm: cloudcmd
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8000/http (web file manager)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/cloudcommander
- non-root: possible - chart sets runAsUser/runAsGroup 0 and readOnlyRootFilesystem false; /root is mounted as appdata, which a uid 568 process may not be able to write
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; file manager needs writable mounts
- privileged: no - common default false, no chart override
- other-security: none
- extra-persistence: /root (pvc, chart-level appdata); /UNRAID (pvc, chart-level mountpath for user files)
- confidence: low

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: cloudcommander
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/coderaiser/cloudcmd:19.23.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/coderaiser/cloudcmd/blob/ddf4726e4565ad8151aa391294a60ef3385d26b7/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/coderaiser/cloudcmd)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `npm:cloudcmd`

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node file manager installed from npm packages, with bun used in the upstream image and an unpinned node base that needs pinning. The optional terminal uses node-pty, which may compile during install. The node sibling covers the runtime.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/coderaiser/cloudcmd:19.23.2](https://ghcr.io/coderaiser/cloudcmd)
- **copy-from arm64**: [ghcr.io/coderaiser/cloudcmd:19.23.2](https://ghcr.io/coderaiser/cloudcmd)

### Dependency containers

- **Dependency containers**: none
