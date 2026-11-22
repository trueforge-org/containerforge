# mattermost

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: mattermost
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/mattermost
- **Source repository**: https://github.com/mattermost/mattermost
- **Documentation**: https://docs.mattermost.com
- **Website**: https://mattermost.com

## Potentially relevant resources

- **Source code repository**: https://github.com/mattermost/docker
- **Source code repository**: https://github.com/mattermost/mattermost-server
- **Container image**: https://hub.docker.com/r/mattermost/mattermost-enterprise-edition

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go server from an official release tarball unpacked into /app.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: ca-certificates (inferred)
- python/pip: none
- node/npm: none
- other: mattermost-9.6.3 release tarball (amd64 / arm64)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8065/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/mattermost
- non-root: yes - no securityContext override, common runAsUser 568 default
- read-only-rootfs: yes - common readOnlyRootFilesystem true default; all writable state is on chart volumes
- privileged: no - common default, not overridden
- other-security: none
- extra-persistence: /mattermost/config (pvc, instead of /config), /mattermost/data (pvc), /mattermost/logs (pvc), /mattermost/plugins (pvc), /mattermost/client/plugins (pvc), /mattermost/bleve-indexes (pvc)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: PostgreSQL is a hard dependency and must run as an external container before Mattermost will start (from draft).
- caveat: the Docker Hub reference is the Enterprise Edition image while the build uses the release tarball, so confirm which edition and license terms apply (inferred).
- caveat: the site URL must be set correctly or links and integrations will break (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: mattermost
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/mattermost/mattermost-enterprise-edition:release-9.6`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/mattermost/mattermost/blob/release-9.6/server/build/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/mattermost/mattermost)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://releases.mattermost.com/9.6.3/mattermost-9.6.3-linux-amd64.tar.gz) · [arm64](https://releases.mattermost.com/9.6.3/mattermost-9.6.3-linux-arm64.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go server with bundled webapp shipped as an official release tarball, so unpack it into /app on containerforge-ubuntu with data and plugins under /config. PostgreSQL comes externally via PostgreSQL; the bundled enterprise features and plugin dirs need writable paths redirected.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [mattermost/mattermost-enterprise-edition:release-9.6](https://hub.docker.com/r/mattermost/mattermost-enterprise-edition)
- **copy-from arm64**: no

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
