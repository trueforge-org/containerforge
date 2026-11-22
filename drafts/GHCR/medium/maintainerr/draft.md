# maintainerr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: maintainerr
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/maintainerr
- **Source repository**: https://github.com/Maintainerr/Maintainerr
- **Documentation**: https://docs.maintainerr.info/
- **Website**: https://maintainerr.info

## Potentially relevant resources

- **Container image**: https://ghcr.io/maintainerr/maintainerr

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node.js and TypeScript app run with node.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: build-essential (inferred, native node modules)
- python/pip: none
- node/npm: yarn (explicit), turbo (inferred)
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 6246/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/maintainerr
- non-root: no - runAsUser 0, runAsGroup 0
- read-only-rootfs: no - readOnlyRootFilesystem false
- privileged: no - default false, not overridden
- other-security: none
- extra-persistence: /opt/data (pvc)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: it needs API keys and URLs for Plex, Sonarr, Radarr or similar services, entered in the UI (external service, account).
- caveat: its rules can delete media files, so a misconfigured rule can remove content; dry-run or review should be used first (inferred).
- caveat: native node modules are built during install, which may fail on arm64 until verified (architecture, inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: maintainerr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/maintainerr/maintainerr:3.32.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Maintainerr/Maintainerr/blob/e6327bbb68b9/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Maintainerr/Maintainerr)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Maintainerr/Maintainerr/releases/tag/v3.32.0)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node.js and TypeScript monorepo built with yarn turbo in a builder stage, then run with node from the copied dist and node_modules. Use the ContainerForge node base; native modules in node_modules are the main risk. One process, with state in /config.

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
