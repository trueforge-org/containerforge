# redisinsight

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: redisinsight
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/redisinsight
- **Source repository**: https://github.com/redis/RedisInsight
- **Documentation**: https://redis.io/docs/latest/operate/redisinsight/
- **Website**: https://redis.io/insight/

## Potentially relevant resources

- No additional resources were listed in the TrueCharts chart sources.

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node.js server with a React UI built in a node stage, so python-node provides node.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: redisinsight
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/redislabs/redisinsight:3.10.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/RedisInsight/RedisInsight/blob/ecd3e7452cac2438bf1a69df8b4e38fc973383dd/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/redis/RedisInsight)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/redis/RedisInsight/releases/download/3.10.0/Redis-Insight-linux-x86_64.AppImage) · [arm64](https://github.com/redis/RedisInsight/releases/download/3.10.0/Redis-Insight-linux-arm64.AppImage)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node.js server plus React UI built in a two-stage build, so a modest source build is needed. Reuse the node sibling, copy the built dist into /app, and keep the state directory on /config. No extra services.

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
