# ddns-go

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: ddns-go
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ddns-go
- **Source repository**: https://github.com/jeessy2/ddns-go
- **Documentation**: https://github.com/jeessy2/ddns-go/wiki

## Potentially relevant resources

- **Container image**: https://ghcr.io/jeessy2/ddns-go

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go binary from the release tarball run directly on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: ddns-go release tarball (linux amd64/arm64)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9876/http (web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/ddns-go
- non-root: no - chart sets runAsUser 0, runAsGroup 0, runAsNonRoot false
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, not overridden
- other-security: none in values
- extra-persistence: /root (pvc, chart-defined; draft expects /config)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The DNS provider account and its API token or key must be set up by the user before any record can be updated (inferred).
- caveat: Initial settings are normally entered through the web UI on port 9876, so manual setup is expected unless a config file is supplied (inferred).
- caveat: The image is built from a release tarball and the draft config path is /config, but upstream writes its default config under the home directory, so the config path needs setting explicitly (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: ddns-go
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/jeessy2/ddns-go:v6.17.9`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/jeessy2/ddns-go/blob/9d83c48bfa8a4cac6c6f58a00dedb49e9f848623/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/jeessy2/ddns-go)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/jeessy2/ddns-go/releases/download/v6.17.9/ddns-go_6.17.9_linux_x86_64.tar.gz) · [arm64](https://github.com/jeessy2/ddns-go/releases/download/v6.17.9/ddns-go_6.17.9_linux_arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Single Go binary released as linux tarballs per arch, currently copied onto alpine by the Dockerfile. On ubuntu, extract the release into /app and run rootless with config in /config. No services, no compile, no extra runtime. Easy.

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
