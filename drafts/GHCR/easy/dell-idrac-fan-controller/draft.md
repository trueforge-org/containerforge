# dell-idrac-fan-controller

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: dell-idrac-fan-controller
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/tigerblue77/Dell_iDRAC_fan_controller_Docker

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: dell-idrac-fan-controller
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/tigerblue77/dell_idrac_fan_controller:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/tigerblue77/Dell_iDRAC_fan_controller_Docker/blob/24fa182fa86f5c247466f023316939096b96042d/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/tigerblue77/Dell_iDRAC_fan_controller_Docker)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/tigerblue77/Dell_iDRAC_fan_controller_Docker/releases/tag/v1.108)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: The controller is a bash loop that calls ipmitool over the LAN against the iDRAC, so it needs no local device access and no root. Ubuntu apt provides ipmitool for both arches. It is one process with config from environment variables.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/tigerblue77/dell_idrac_fan_controller:latest](https://ghcr.io/tigerblue77/dell_idrac_fan_controller)
- **copy-from arm64**: [ghcr.io/tigerblue77/dell_idrac_fan_controller:latest](https://ghcr.io/tigerblue77/dell_idrac_fan_controller)

### Dependency containers

- **Dependency containers**: none
