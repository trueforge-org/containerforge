# shiori

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: shiori
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/shiori
- **Source repository**: https://github.com/go-shiori/shiori
- **Documentation**: https://github.com/go-shiori/shiori/blob/master/docs/index.md

## Potentially relevant resources

- **Container image**: https://ghcr.io/go-shiori/shiori
- **Source code repository**: https://github.com/go-shiori/shiori/pkgs/container/shiori

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go binary from the goreleaser release.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: shiori Go release tarball

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/shiori
- non-root: yes - no securityContext override, common 568 default
- read-only-rootfs: yes - default true, not overridden
- privileged: no - default false, not set
- other-security: none
- extra-persistence: /data (pvc); chart mounts /data, draft keeps data in /config
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: shiori
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/go-shiori/shiori:v1.8.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/go-shiori/shiori/blob/v1.8.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/go-shiori/shiori)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/go-shiori/shiori/releases/download/v1.8.0/shiori_Linux_x86_64_1.8.0.tar.gz) · [arm64](https://github.com/go-shiori/shiori/releases/download/v1.8.0/shiori_Linux_aarch64_1.8.0.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go binary from the goreleaser pipeline; the upstream image is scratch with a prebuilt dist binary. Use the release binary on containerforge-ubuntu, keep the SQLite database and archives under /config. One process and no external services.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/go-shiori/shiori:v1.8.0](https://ghcr.io/go-shiori/shiori)
- **copy-from arm64**: [ghcr.io/go-shiori/shiori:v1.8.0](https://ghcr.io/go-shiori/shiori)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
