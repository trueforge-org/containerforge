# friendica

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: friendica
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/friendica/friendica
- **Website**: https://friendi.ca

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: friendica
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `friendica:2026.05`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/friendica/docker/blob/91cb08d73a60af3dc355b0e6ebeaa898389cea5b/2026.05/apache/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/friendica/friendica)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/friendica/friendica/releases/tag/2026.05)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: PHP 8.4 web app served by Apache, unpacked from the official all-in-one tarball, with mariadb and valkey as chart dependencies. ContainerForge has no PHP base, and Apache, cron and PHP make a multi-process stack that must run rootless with writes limited to /config and /tmp.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [friendica:2026.05](https://hub.docker.com/_/friendica)
- **copy-from arm64**: [friendica:2026.05](https://hub.docker.com/_/friendica)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: mariadb ✅, valkey ✅
