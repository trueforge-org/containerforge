# tdarr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: tdarr
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tdarr
- **Source repository**: https://github.com/HaveAGitGat/Tdarr
- **Documentation**: https://docs.tdarr.io/

## Potentially relevant resources

- **Container image**: https://ghcr.io/haveagitgat/tdarr

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Server, web UI and bundled ffmpeg and HandBrake tools on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: ffmpeg, handbrake-cli (inferred)
- python/pip: none
- node/npm: bundled Node runtime from the Tdarr zip (inferred)
- other: Tdarr server zip from tdarr.io/downloads

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8265/http (web UI), 8266/tcp (server to node communication)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/tdarr
- non-root: no - runAsUser 0, runAsGroup 0, runAsNonRoot false
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: /app/configs, /app/server, /app/logs, /temp (transcode-cache), /media (chart paths, type not set)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: transcoding needs CPU or GPU headroom and a large scratch path in /temp, and the server and internal node share one image (inferred).
- caveat: plugin and ffmpeg downloads may happen at runtime, so an offline host can fail on first use (inferred).
- caveat: the Tdarr zip is fetched from tdarr.io at build time, so the build depends on that site being up (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: tdarr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/haveagitgat/tdarr:3.08.00`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/HaveAGitGat/Tdarr/blob/9ec31178f6807861c207f8a65a1b8156e46c5b85/docker/Dockerfile.final)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/HaveAGitGat/Tdarr)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://tdarr.io/downloads)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: The Tdarr server, its internal node, the web UI and ffmpeg/HandBrake tools run as several processes from one image, and the upstream image runs as root. Making it rootless needs cache paths moved to /tmp or /config, a supervisor layout for the processes and optional GPU variants.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/haveagitgat/tdarr:3.08.00](https://ghcr.io/haveagitgat/tdarr)
- **copy-from arm64**: [ghcr.io/haveagitgat/tdarr:3.08.00](https://ghcr.io/haveagitgat/tdarr)

### Dependency containers

- **Dependency containers**: none
