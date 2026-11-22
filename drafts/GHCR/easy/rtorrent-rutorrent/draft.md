# rtorrent-rutorrent

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: rtorrent-rutorrent
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rtorrent-rutorrent
- **Source repository**: https://github.com/thde/rtorrent_exporter

## Potentially relevant resources

- **Container image**: https://ghcr.io/crazy-max/rtorrent-rutorrent
- **Container image**: https://ghcr.io/thde/rtorrent_exporter
- **Source code repository**: https://github.com/crazy-max/docker-rtorrent-rutorrent

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Static Go Prometheus exporter tarball.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: rtorrent_exporter Go release tarball

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (ruTorrent web UI, inferred), 9135/http (rtorrent exporter metrics, inferred), 45000/tcp (BitTorrent peer, inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: rtorrent-rutorrent
- **Role**: sidecar (exportarrImage)

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/thde/rtorrent_exporter:v1.3.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/thde/rtorrent_exporter/blob/e79ce427fd812cb1e9d1b0e3be0a9180f8e69cca/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/thde/rtorrent_exporter)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/thde/rtorrent_exporter/releases/download/v1.3.2/rtorrent_exporter_1.3.2_linux_amd64.tar.gz) · [arm64](https://github.com/thde/rtorrent_exporter/releases/download/v1.3.2/rtorrent_exporter_1.3.2_linux_arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Static Go Prometheus exporter; fetch the release tarball per arch onto containerforge-ubuntu. Stateless, rootless, no writable paths.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/thde/rtorrent_exporter:v1.3.2](https://ghcr.io/thde/rtorrent_exporter)
- **copy-from arm64**: [ghcr.io/thde/rtorrent_exporter:v1.3.2](https://ghcr.io/thde/rtorrent_exporter)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

- **Dependency containers**: -
