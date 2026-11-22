# icloudpd

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: icloudpd
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/icloudpd
- **Source repository**: https://github.com/icloud-photos-downloader/icloud_photos_downloader
- **Documentation**: https://icloud-photos-downloader.github.io/icloud_photos_downloader/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/boredazfcuk/icloudpd

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python CLI installed from PyPI with pip.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: icloudpd
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: none

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/icloudpd
- non-root: possible - chart sets runAsUser 0 and runAsNonRoot false, and passes user_id 0 to the app; app may run non-root
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, not overridden
- other-security: capabilities add NET_RAW, NET_ADMIN
- extra-persistence: /home/apps/iCloud (pvc, data); /config is the chart's own
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the first run needs an interactive Apple ID login with two-factor code entry, and the session must be kept in /config (inferred)
- caveat: sessions expire, so re-authentication will be needed from time to time (inferred)
- caveat: the initial download of a large iCloud library can take a very long time and needs a lot of disk in the mounted path (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: icloudpd
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/boredazfcuk/icloudpd:1.0.826`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/boredazfcuk/docker-icloudpd/blob/master/icloudpd.dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/icloud-photos-downloader/icloud_photos_downloader)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/icloud-photos-downloader/icloud_photos_downloader/releases/download/v1.33.1/icloud-1.33.1-linux-amd64) · [arm64](https://github.com/icloud-photos-downloader/icloud_photos_downloader/releases/download/v1.33.1/icloud-1.33.1-linux-arm64)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Single Python CLI installed from PyPI (icloudpd 1.32.x) into a venv with one process and no extra services. On containerforge-ubuntu, pip install into /app on the python sibling, keep session and config in /config and use /tmp for cache.

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
