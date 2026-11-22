# memcached

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: memcached
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/memcached
- **Source repository**: https://github.com/memcached/memcached
- **Documentation**: https://docs.memcached.org
- **Website**: https://memcached.org/

## Potentially relevant resources

- No additional resources were listed in the TrueCharts chart sources.

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: memcached installed from apt on the ubuntu base.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: memcached
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/bitnamisecure/memcached:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/memcached/memcached)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:memcached`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: The bitnami secure build is closed, but Ubuntu's memcached apt package does the same job and runs as a non-root user on port 11211. A memcache sibling exists to reuse. One process, with no writes beyond /tmp.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [bitnamisecure/memcached:latest](https://hub.docker.com/r/bitnamisecure/memcached)
- **copy-from arm64**: [bitnamisecure/memcached:latest](https://hub.docker.com/r/bitnamisecure/memcached)

### Dependency containers

- **Dependency containers**: none
