# ring-mqtt

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: ring-mqtt
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ring-mqtt
- **Source repository**: https://github.com/tsightler/ring-mqtt
- **Documentation**: https://github.com/tsightler/ring-mqtt/wiki

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/tsightler/ring-mqtt

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node app with a service manager and a streaming binary, so python-node covers the Node runtime.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: ffmpeg (inferred)
- python/pip: none
- node/npm: ring-mqtt npm app (interpreted), node runtime from python-node
- other: go2rtc binary (streaming), s6-overlay, bashio

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 55123/http (web UI), 1984/http (go2rtc API and web, inferred), 8554/tcp (RTSP streaming, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/ring-mqtt
- non-root: no - runAsUser 0, runAsNonRoot false, no override
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set in values (default false)
- other-security: none
- extra-persistence: /data (pvc), /data/config.json (configmap)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: a Ring account login, including the 2FA code, is needed on first start, and the token is stored in the data volume (inferred).
- caveat: the image runs s6-overlay, go2rtc and bashio together, so making it rootless and read-only means reworking the startup scripts.
- caveat: streaming uses go2rtc on 1984 and RTSP on 8554, so those ports must be reachable if camera streams are used (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: ring-mqtt
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/tsightler/ring-mqtt:5.9.3`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/tsightler/ring-mqtt/blob/59aab41/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/tsightler/ring-mqtt)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/tsightler/ring-mqtt/releases/tag/v5.9.3)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Node app that runs alongside s6-overlay, go2rtc and bashio, so the image is several services. Making it rootless and read-only means reworking the s6 startup. The npm app itself is interpreted and easy to package.

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
