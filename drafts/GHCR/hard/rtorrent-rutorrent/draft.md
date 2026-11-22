# rtorrent-rutorrent

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: rtorrent-rutorrent
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (rtorrent_exporter)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rtorrent-rutorrent
- **Source repository**: https://github.com/rakshasa/rtorrent

## Potentially relevant resources

- **Container image**: https://ghcr.io/crazy-max/rtorrent-rutorrent
- **Container image**: https://ghcr.io/thde/rtorrent_exporter
- **Source code repository**: https://github.com/crazy-max/docker-rtorrent-rutorrent

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Alternative runtime image**: [nginx](https://github.com/trueforge-org/containerforge/tree/main/apps/nginx) (`ghcr.io/trueforge-org/nginx`)
- **Reason**: Reason names ubuntu with apt rtorrent, PHP-FPM and nginx.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: rtorrent, nginx, php-fpm (inferred for nginx/php-fpm)
- python/pip: none
- node/npm: none
- other: ruTorrent web UI files (git clone or release download, inferred)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (ruTorrent web UI via nginx, inferred), 5000/tcp (rTorrent SCGI, inferred), 50000/tcp (BitTorrent peer, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/rtorrent-rutorrent
- non-root: no - runAsUser 0, runAsGroup 0, runAsNonRoot false (PUID 33 does not change this)
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: /data, /downloads, /passwd (chart paths, type not set)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: rtorrent-rutorrent
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/crazy-max/rtorrent-rutorrent:4.2.9-0.9.8_2-0.13.8_1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/crazy-max/docker-rtorrent-rutorrent/blob/1efb9e087f90f68ed132b3ffd419b29145a1838e/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/rakshasa/rtorrent)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:rtorrent`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: rtorrent and ruTorrent with nginx and PHP under s6 on alpine/musl; on ubuntu use apt rtorrent plus PHP-FPM and nginx. Several services need a supervisor and rootless rework, and the Go exporter sidecar needs a compile.

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

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

❌ means it is missing too.

- **Dependency containers**: rtorrent_exporter (exportarrImage) ❌
