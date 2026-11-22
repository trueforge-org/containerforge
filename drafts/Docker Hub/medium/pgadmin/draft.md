# pgadmin

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: pgadmin
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/pgadmin
- **Source repository**: https://github.com/pgadmin-org/pgadmin4
- **Documentation**: https://www.pgadmin.org/docs/
- **Website**: https://www.pgadmin.org

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/dpage/pgadmin4

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python web app installed from PyPI on the python base.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: libpq5 (inferred); libmagic1 (inferred)
- python/pip: pgadmin4; gunicorn (inferred)
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (web UI, inferred), 443/https (web UI TLS, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/pgadmin
- non-root: yes - runAsNonRoot true, runAsUser and runAsGroup 5050 in values
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, not overridden
- other-security: fsGroup 5050 (pod)
- extra-persistence: none beyond chart's config mount at /var/lib/pgadmin
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: pgadmin
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/dpage/pgadmin4:9.19`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/pgadmin-org/pgadmin4/blob/REL-9_19/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/pgadmin-org/pgadmin4)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:pgadmin4`

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: pgAdmin 4 web app: a large Python dependency set plus built frontend assets, run by gunicorn as one process on python:3-alpine. Can be installed from PyPI on the python sibling, but storage paths must move to /config and /tmp.

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
