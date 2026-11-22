# spoolman

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: spoolman
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/spoolman
- **Source repository**: https://github.com/Donkie/Spoolman
- **Documentation**: https://donkie.github.io/Spoolman/

## Potentially relevant resources

- **Container image**: https://ghcr.io/donkie/spoolman

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python app installed with pip into /app; the draft names the python sibling.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: uv (inferred), app install from spoolman.zip (pure-Python deps)
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8000/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/spoolman
- non-root: no - container override runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: external PostgreSQL via cnpg block; no capabilities or host access
- extra-persistence: /logs (pvc, chart's own, default type); data at /data is the chart's own
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The chart can use either SQLite (under /config, default) or external PostgreSQL, and the choice must be made and documented; the PostgreSQL option needs its own service (from the draft).
- caveat: The logs path is a persistent volume in the chart and must be mapped to a writable location in the image (inferred).
- caveat: The upstream root entrypoint needs a path change to run as a non-root user (from the draft).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: spoolman
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/donkie/spoolman:0.27.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Donkie/Spoolman/blob/ff8efd517b76a4b2783f29c89e9b9fbcd8cd167b/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Donkie/Spoolman)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Donkie/Spoolman/releases/download/v0.27.1/spoolman.zip)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python 3.14 app installed by pip (uv venv) into /app; reuse the python ContainerForge sibling and keep SQLite data under /config, or use external Postgres via PostgreSQL. Mostly pure-Python dependencies, one process, and the upstream root entrypoint needs a small path change for non-root use.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/donkie/spoolman:0.27.1](https://ghcr.io/donkie/spoolman)
- **copy-from arm64**: [ghcr.io/donkie/spoolman:0.27.1](https://ghcr.io/donkie/spoolman)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
