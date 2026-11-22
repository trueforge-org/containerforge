# vaultwarden

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: vaultwarden
- **Rows**: 2
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/vaultwarden
- **Source repository**: https://github.com/dani-garcia/vaultwarden
- **Source repository**: https://github.com/timshel/vaultwarden
- **Documentation**: https://github.com/dani-garcia/vaultwarden/wiki

## Potentially relevant resources

- **Container image**: https://ghcr.io/dani-garcia/vaultwarden
- **Container image**: https://ghcr.io/timshel/vaultwarden

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Guess: the draft has no image, binary or reason text, so ubuntu is the default.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: libssl-dev (inferred), pkg-config (inferred), libsqlite3-dev (inferred), libpq-dev (inferred), default-libmysqlclient-dev (inferred)
- python/pip: none
- node/npm: none
- other: Rust toolchain (cargo), web-vault bundle download

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (web vault and API, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/vaultwarden
- non-root: yes - no securityContext override, common default runAsUser 568
- read-only-rootfs: yes - no override, common default true
- privileged: no - not set, common default false
- other-security: none; external PostgreSQL via cnpg
- extra-persistence: none beyond chart's own data at /data
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- Row 1: **Chart**: vaultwarden
- Row 1: **Role**: main
- Row 2: **Chart**: vaultwarden
- Row 2: **Role**: sidecar (betaImage)

### Container

The image and tag the chart uses today.

- Row 1: **Container**: `ghcr.io/dani-garcia/vaultwarden:1.37.5`
- Row 2: **Container**: `ghcr.io/timshel/vaultwarden:1.30.5-9`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- Row 1: **Dockerfile**: [Dockerfile](https://github.com/dani-garcia/vaultwarden/blob/6ed6921cc2b0e03b4d74189574d2a5e71c512e97/docker/Dockerfile.debian)
- Row 2: **Dockerfile**: [Dockerfile](https://github.com/timshel/vaultwarden/blob/39febc27950fece51ded8b85c2d38838fe08237c/docker/Dockerfile.debian)

### Application source

The application's own source repository or project page.

- Row 1: **Application source**: [source](https://github.com/dani-garcia/vaultwarden)
- Row 2: **Application source**: [source](https://github.com/timshel/vaultwarden)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- Row 1: **Application binary**: -
- Row 2: **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- Row 1: **Difficulty**: medium
- Row 2: **Difficulty**: medium

### Reason

- Row 1: **Reason**: Rust server compiled with cargo in a rust stage, with the web vault copied from upstream. No release binary exists, so both arches need a Rust build. The runtime is simple and rootless-friendly, and the beta sidecar uses the same build.
- Row 2: **Reason**: Fork of Vaultwarden with SSO, built from Rust source (cargo) plus a web-vault bundle; no release assets, so build in a rust stage on glibc Ubuntu with openssl and sqlite/mysql/pg libs and copy to /app. Long compile; data to /config.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- Row 1: **amd64**: compile
- Row 1: **arm64**: compile
- Row 2: **amd64**: compile
- Row 2: **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- Row 1: **copy-from amd64**: [ghcr.io/dani-garcia/vaultwarden:1.37.5](https://ghcr.io/dani-garcia/vaultwarden)
- Row 1: **copy-from arm64**: [ghcr.io/dani-garcia/vaultwarden:1.37.5](https://ghcr.io/dani-garcia/vaultwarden)
- Row 2: **copy-from amd64**: [ghcr.io/timshel/vaultwarden:1.30.5-9](https://ghcr.io/timshel/vaultwarden)
- Row 2: **copy-from arm64**: [ghcr.io/timshel/vaultwarden:1.30.5-9](https://ghcr.io/timshel/vaultwarden)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

❌ means it is missing too.

- Row 1: **Dependency containers**: postgresql ✅, vaultwarden (betaImage) ❌
- Row 2: **Dependency containers**: -
