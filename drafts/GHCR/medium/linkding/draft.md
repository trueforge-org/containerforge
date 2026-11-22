# linkding

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: linkding
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/linkding
- **Source repository**: https://github.com/sissbruecker/linkding
- **Documentation**: https://linkding.link/

## Potentially relevant resources

- **Container image**: https://ghcr.io/sissbruecker/linkding

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Django app installed from pip on the python base.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: linkding requirements incl. Django, gunicorn (inferred)
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9090/http (web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/linkding
- non-root: no - runAsUser 0, runAsGroup 0, runAsNonRoot false
- read-only-rootfs: no - readOnlyRootFilesystem false
- privileged: no - default false, not overridden
- other-security: none
- extra-persistence: /etc/linkding/data (pvc)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the first admin account has to be created from a shell inside the container (manual setup, inferred).
- caveat: gunicorn and the background task runner are two processes, so a small supervisor or start script is needed; a single-process start hides one of them (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: linkding
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/sissbruecker/linkding:1.47.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/sissbruecker/linkding/blob/24b5ad6/docker/default.Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/sissbruecker/linkding)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/sissbruecker/linkding/releases/tag/v1.47.0)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Linkding is a Django app installed from pip on the python base, with SQLite data in /config. Upstream runs gunicorn and background tasks together, so a small start script or supervisor is needed for the two processes. The Python side is straightforward.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/sissbruecker/linkding:1.47.0](https://ghcr.io/sissbruecker/linkding)
- **copy-from arm64**: [ghcr.io/sissbruecker/linkding:1.47.0](https://ghcr.io/sissbruecker/linkding)

### Dependency containers

- **Dependency containers**: none
