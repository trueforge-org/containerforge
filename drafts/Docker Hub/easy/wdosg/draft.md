# wdosg

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: wdosg
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/wdosg
- **Source repository**: https://github.com/SoulRaven80/wdosg

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/soulraven1980/wdosg

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node.js app installed with npm and no build step.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: app deps via npm install (inferred)
- other: source tarball v1.3.9

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/wdosg
- non-root: yes - runAsUser 568 default, no root override
- read-only-rootfs: yes - default readOnlyRootFilesystem true
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: /app/database and /app/wdosglibrary (pvc, both mounted by chart) unless the app is pointed at /config
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Draft downloads a source tarball at build time, so the build needs internet access and a pinned tag (v1.3.9).
- caveat: Upstream app paths /app/database and /app/wdosglibrary are not under /config by default; they must be redirected or they will be lost on read-only or non-persistent setups (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: wdosg
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/soulraven1980/wdosg:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/SoulRaven80/wdosg/blob/db267e9/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/SoulRaven80/wdosg)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/SoulRaven80/wdosg/archive/refs/tags/v1.3.9.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Node.js app installed with npm into /app on a node base, with no build step and no extra services. Reuse the node sibling and keep state under /config. Runs as one process.

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
