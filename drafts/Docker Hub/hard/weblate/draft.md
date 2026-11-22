# weblate

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: weblate
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql, valkey)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/weblate
- **Source repository**: https://github.com/WeblateOrg/weblate
- **Documentation**: https://docs.weblate.org/

## Potentially relevant resources

- **Website**: https://docs.weblate.org/en/latest
- **Source code repository**: https://github.com/WeblateOrg/docker
- **Source code repository**: https://github.com/WeblateOrg/docker-compose
- **Container image**: https://hub.docker.com/r/weblate/weblate

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python packages installed by pip for a web app, so the python base fits.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: nginx, supervisor (inferred), git, gettext (inferred), libxml2-dev, libxslt1-dev, libldap2-dev, libsasl2-dev (inferred)
- python/pip: Weblate 4.16.4, uwsgi, celery, psycopg (inferred)
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/weblate
- non-root: possible - runAsUser 1000 override, but runAsGroup 0 and fsGroup 1000
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - default false, no override
- other-security: pod fsGroup 1000
- extra-persistence: /app/data (pvc, primary data), /app/cache (emptyDir)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: needs external PostgreSQL and Valkey (redis) services, and both must be running before the first start (inferred)
- caveat: the admin account and initial project setup are done in the web UI after first start (inferred)
- caveat: nginx, uwsgi and celery run as separate processes under supervisor, so rootless operation needs changes to the process setup (inferred)
- caveat: Weblate is pinned to 4.16.4 and upgrades must follow the upstream migration steps (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: weblate
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/weblate/weblate:4.16.4-1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/WeblateOrg/docker/blob/4.16.4-1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/WeblateOrg/weblate)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:Weblate`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Several processes in one image (nginx, uwsgi and celery) with PostgreSQL and Valkey dependencies, so it is a multi-service stack. Making it rootless and read-only means reworking supervisor and writable paths. Python packages install cleanly from pip wheels.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [weblate/weblate:4.16.4-1](https://hub.docker.com/r/weblate/weblate)
- **copy-from arm64**: [weblate/weblate:4.16.4-1](https://hub.docker.com/r/weblate/weblate)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: valkey ✅, postgresql ✅
