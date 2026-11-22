# solidping

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: solidping
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql (CNPG))
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/fclairamb/solidping
- **Documentation**: https://solidping.io/docs/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: solidping
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/fclairamb/solidping:0.52.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/fclairamb/solidping/blob/5e35c5e4a02b63f3e15c48ade8e6bbe4b5b4e070/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/fclairamb/solidping)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/fclairamb/solidping/releases/download/v0.52.0/solidping-linux-amd64.gz) · [arm64](https://github.com/fclairamb/solidping/releases/download/v0.52.0/solidping-linux-arm64.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go binary with bun-built UIs produced in earlier stages; upstream runs on distroless nonroot. Use the Go release binary on containerforge-ubuntu as one process, with data in /config or an external database. Upstream already publishes amd64, arm64 and riscv64, which points to clean cross-builds.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/fclairamb/solidping:0.52.0](https://ghcr.io/fclairamb/solidping)
- **copy-from arm64**: [ghcr.io/fclairamb/solidping:0.52.0](https://ghcr.io/fclairamb/solidping)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql (CNPG) ✅
