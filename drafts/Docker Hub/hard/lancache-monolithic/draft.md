# lancache-monolithic

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: lancache-monolithic
- **Rows**: 1
- **Hard dependency containers**: no
- **Soft dependency containers**: yes (lancache-prefill (prefillImage))
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/lancachenet/monolithic
- **Documentation**: http://lancache.net/docs/containers/monolithic/
- **Documentation**: https://lancache.net/docs/
- **Website**: https://lancache.net/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: lancache-monolithic
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/lancachenet/monolithic:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/lancachenet/monolithic/blob/3f43cc7/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/lancachenet/monolithic)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:nginx`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Wrapper over lancachenet/ubuntu-nginx with nginx, overlay config, a git-cloned cache-domains list, and a second prefill image. Running nginx and cache services on ContainerForge needs port and temp path rework for a read-only root, and the prefill tool is fetched at runtime from unverified sources.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [lancachenet/monolithic:latest](https://hub.docker.com/r/lancachenet/monolithic)
- **copy-from arm64**: no

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

❌ means it is missing too.

- **Dependency containers**: lancache-prefill (prefillImage) ❌
