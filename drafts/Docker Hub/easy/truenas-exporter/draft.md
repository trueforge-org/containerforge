# truenas-exporter

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: truenas-exporter
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/truenas-exporter
- **Source repository**: https://github.com/prometheus/graphite_exporter

## Potentially relevant resources

- **Source code repository**: https://github.com/Supporterino/truenas-graphite-to-prometheus/tree/main
- **Container image**: https://hub.docker.com/r/prom/graphite-exporter

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Prometheus Go exporter binary from the release tarball.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Go release tarball per arch

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9108/http (Prometheus metrics), 9109/tcp (graphite ingest), 9109/udp (graphite ingest)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/truenas-exporter
- non-root: yes - no runAs override, common default 568
- read-only-rootfs: yes - default readOnlyRootFilesystem true, no override
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: /config/graphite_mapping.conf (configmap, chart's own)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: TrueNAS must be configured to send graphite metrics to this container's port 9109, so the TrueNAS side needs manual reporting setup (inferred).
- caveat: the spec names prometheus graphite_exporter as the source and a different community repo as a resource; confirm which binary the image runs before reporting version details (inferred).
- caveat: graphite ingest on 9109 is TCP and UDP, so both must be reachable from TrueNAS (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: truenas-exporter
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/prom/graphite-exporter:v0.17.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/prometheus/graphite_exporter/blob/v0.17.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/prometheus/graphite_exporter)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/prometheus/graphite_exporter/releases/download/v0.17.0/graphite_exporter-0.17.0.dragonfly-amd64.tar.gz) · [arm64](https://github.com/prometheus/graphite_exporter/releases/download/v0.17.0/graphite_exporter-0.17.0.linux-arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Prometheus graphite exporter Go binary, copied from the upstream prebuilt release. It runs as a single process on a non-root port with no state. Wrap it in containerforge-ubuntu with the binary in /app.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [prom/graphite-exporter:v0.17.0](https://hub.docker.com/r/prom/graphite-exporter)
- **copy-from arm64**: [prom/graphite-exporter:v0.17.0](https://hub.docker.com/r/prom/graphite-exporter)

### Dependency containers

- **Dependency containers**: none
