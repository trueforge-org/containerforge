# dashmachine

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: dashmachine
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/dashmachine
- **Source repository**: https://github.com/rmountjoy92/DashMachine

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/rmountjoy/dashmachine

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python web app with gunicorn from pip, so python fits.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: flask, gunicorn
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5000/http (web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/dashmachine
- non-root: no - chart sets container runAsUser 0 and runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, no override in values
- other-security: none beyond root override
- extra-persistence: /dashmachine/dashmachine/user_data (pvc)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The app writes its config and SQLite database inside its own folder, so paths must move to /config and /tmp to work with a read-only rootfs (noted in the draft, unverified).
- caveat: Dashboard content is created through the web UI (manual setup, inferred).
- caveat: The chart persists /dashmachine/dashmachine/user_data, which differs from the /config layout, so the mapping must be updated.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: dashmachine
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/rmountjoy/dashmachine:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/rmountjoy92/DashMachine/blob/be50c2e763ae4e18f95855c18ba31c42199a4b3e/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/rmountjoy92/DashMachine)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/rmountjoy92/DashMachine/archive/refs/tags/v0.5-4.2.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Flask app run with gunicorn from pip requirements on a python base. The app writes its config and database into its own folder, so paths must move to /config and /tmp for read-only rootfs. Otherwise a single process.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [rmountjoy/dashmachine:latest](https://hub.docker.com/r/rmountjoy/dashmachine)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
