# actualserver

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: actualserver
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/actualserver
- **Source repository**: https://github.com/actualbudget/actual
- **Documentation**: https://actualbudget.org/docs/
- **Website**: https://actualbudget.org/

## Potentially relevant resources

- **Container image**: https://ghcr.io/actualbudget/actual
- **Source code repository**: https://github.com/Kippenhof/docker-templates

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node.js sync server with npm deps.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: yarn workspace deps for sync-server (inferred)
- other: yarn; Actual AppImage per arch as an alternative binary

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5006/http (sync server, web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/actualserver
- non-root: possible - chart sets runAsUser/runAsGroup 0 and runAsNonRoot false; Node server on 5006
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; chart mounts /data while draft keeps data in /config
- privileged: no - common default false, no chart override
- other-security: none
- extra-persistence: /data (pvc, chart-level mount; draft says /config)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the sync server is a web app that needs its own first-run setup in the browser (budget file and server password) (inferred).
- caveat: upstream publishes per-arch AppImage binaries, so an alternative binary-based build exists if the yarn workspace build proves hard (inferred).
- caveat: the chart tag is a specific calendar-style version (26.11.0), so upgrades must be tracked against the upstream release cadence (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: actualserver
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/actualbudget/actual:26.11.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/actualbudget/actual/blob/1766241e3f4b3c578e424c4fa15f1eb83c0da17d/packages/sync-server/docker/alpine.Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/actualbudget/actual)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/actualbudget/actual/releases/download/v26.11.0/Actual-linux-x86_64.AppImage) · [arm64](https://github.com/actualbudget/actual/releases/download/v26.11.0/Actual-linux-arm64.AppImage)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node sync-server from the actual yarn workspace, copied into a prod stage with npm deps. The node sibling covers the runtime, and data stays in /config as one process. The build spans a yarn workspace, so it is more than a single npm install.

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
