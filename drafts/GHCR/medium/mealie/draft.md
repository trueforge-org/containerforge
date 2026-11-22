# mealie

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: mealie
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/mealie
- **Source repository**: https://github.com/mealie-recipes/mealie
- **Documentation**: https://mealie.io/

## Potentially relevant resources

- **Container image**: https://ghcr.io/mealie-recipes/mealie

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: FastAPI app with the wheel installed on the python base.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: uv (inferred, builder stage for wheel); Python deps from the wheel
- node/npm: Nuxt frontend build deps (inferred, yarn/npm)
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9000/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/mealie
- non-root: yes - runAsUser 568 default, no container override
- read-only-rootfs: yes - default true, not overridden
- privileged: no - default false, not overridden
- other-security: none
- extra-persistence: /app/data (pvc); /nltk_data (emptyDir, 5Gi)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the first start downloads NLTK data and other assets, so it needs internet access and is slow on first run (runtime download, inferred).
- caveat: the first user is created through the UI, and PostgreSQL is optional but SQLite is the default (manual setup, inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: mealie
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/mealie-recipes/mealie:v3.31.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/mealie-recipes/mealie/blob/v3.31.0/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/mealie-recipes/mealie)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/mealie-recipes/mealie/releases/tag/v3.31.0)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python FastAPI app with a Nuxt frontend. The wheel is built by uv in a builder stage and installed on the python base into /app, with data in /config. The frontend build and database migrations add moderate effort.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/mealie-recipes/mealie:v3.31.0](https://ghcr.io/mealie-recipes/mealie)
- **copy-from arm64**: [ghcr.io/mealie-recipes/mealie:v3.31.0](https://ghcr.io/mealie-recipes/mealie)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
