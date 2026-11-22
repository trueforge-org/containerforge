# redmine

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: redmine
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/redmine
- **Source repository**: https://github.com/redmine/redmine
- **Documentation**: https://www.redmine.org/projects/redmine/wiki
- **Website**: https://www.redmine.org/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/_/redmine

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Ruby on Rails app with Ruby added on ubuntu, since no Ruby base exists.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: ruby-full (inferred); build-essential (inferred); libpq-dev (inferred); libyaml-dev (inferred)
- python/pip: none
- node/npm: none
- other: bundler and gems with native extensions (inferred)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (Rails web app)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/redmine
- non-root: yes - runAsUser and runAsGroup 999, fsGroup 999 in values
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, not overridden
- other-security: fsGroup 999 (pod)
- extra-persistence: /usr/src/redmine/files (pvc default); bundle and tmp per draft under /tmp
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: redmine
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/redmine:6.1.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/docker-library/redmine/blob/49a27f29f1d214a4226af75b55578e36d3474c4c/6.1/bookworm/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/redmine/redmine)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://www.redmine.org/releases/redmine-6.1.0.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Ruby on Rails app from the official redmine tarball, so ruby and bundler must be added on ubuntu. It needs PostgreSQL via CloudNativePG and gem native extensions at install. Keep bundle and tmp under /tmp and files under /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

`no*` means the registry could not be queried, so the architecture is unconfirmed.

- **copy-from amd64**: [redmine:6.1.0](https://hub.docker.com/_/redmine)
- **copy-from arm64**: no*

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
