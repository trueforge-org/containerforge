# jellystat

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: jellystat
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/jellystat
- **Source repository**: https://github.com/CyferShepard/Jellystat

## Potentially relevant resources

- **Container image**: https://ghcr.io/cyfershepard/jellystat

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node app built with npm and run on the node runtime.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: npm packages (builder stage)
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/jellystat
- non-root: no - runAsUser 0, runAsGroup 0, runAsNonRoot false
- read-only-rootfs: no - readOnlyRootFilesystem false
- privileged: no - default false, not overridden
- other-security: none
- extra-persistence: /app/backend/backup-data (pvc)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: needs an external PostgreSQL database and secrets set through environment variables before first start (external service, inferred).
- caveat: the chart uses the untagged `latest` image, so the build is not reproducible and the upstream tag 1.1.12 may not match what is pulled (upstream status).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: jellystat
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/cyfershepard/jellystat:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/CyferShepard/Jellystat/blob/e0a38eeeff4c4bbaba60abad5f76e8a54415d1a8/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/CyferShepard/Jellystat)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/CyferShepard/Jellystat/releases/tag/1.1.12)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node app built with npm in a builder stage, then /app copied into node:26-bookworm-slim. The node sibling covers the runtime, and postgres is external. The npm build and the untagged latest image make it medium.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/cyfershepard/jellystat:latest](https://ghcr.io/cyfershepard/jellystat)
- **copy-from arm64**: [ghcr.io/cyfershepard/jellystat:latest](https://ghcr.io/cyfershepard/jellystat)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
