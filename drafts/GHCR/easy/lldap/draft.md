# lldap

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: lldap
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/lldap/lldap
- **Documentation**: https://github.com/lldap/lldap/tree/main/docs

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: lldap
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/lldap/lldap:v0.6.3-debian`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/lldap/lldap/blob/48a0a8d961f32bd8e3263b202053ce49a6c94781/.github/workflows/Dockerfile.ci.debian)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/lldap/lldap)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/lldap/lldap/releases/download/v0.6.3/amd64-lldap.tar.gz) · [arm64](https://github.com/lldap/lldap/releases/download/v0.6.3/aarch64-lldap.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Rust LDAP server. Upstream publishes amd64 and aarch64 tarballs that contain the binary, so copy it into /app and keep the database in /config. The gosu and root wrapper from the Debian image are not needed in ContainerForge. Single process, no extra services.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/lldap/lldap:v0.6.3-debian](https://ghcr.io/lldap/lldap)
- **copy-from arm64**: [ghcr.io/lldap/lldap:v0.6.3-debian](https://ghcr.io/lldap/lldap)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql (CNPG) ✅
