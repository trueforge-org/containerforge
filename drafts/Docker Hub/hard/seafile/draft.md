# seafile

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: seafile
- **Rows**: 1
- **Hard dependency containers**: yes (mariadb)
- **Optional dependency containers**: yes (valkey)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/seafile
- **Source repository**: https://github.com/haiwen/seafile-server
- **Documentation**: https://manual.seafile.com/
- **Website**: https://www.seafile.com/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/seafileltd/seafile-mc
- **Website**: https://seafile.com

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Alternative runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Guess: a multi-process Python web stack described only as an ubuntu base, so ubuntu is the default.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: python3 (inferred)
- python/pip: seafile Python stack (inferred)
- node/npm: none
- other: seafile-server source compile (ccnet, seafile, seahub), x86_64 tarball only upstream

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (seahub web UI), 443/https (TLS, inferred), 8082/http (fileserver, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/seafile
- non-root: no - runAsUser 0, runAsNonRoot false, no override
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set in values (default false)
- other-security: none
- extra-persistence: /shared/seafile (pvc, under the common /shared mount)
- confidence: low

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: MariaDB is required, and an initial admin account must be created through the web UI or CLI on first run (inferred).
- caveat: the official tarball is x86_64 only, so arm64 needs a source compile of ccnet, seafile and seahub (spec).
- caveat: user files live under /shared/seafile, so that volume must be persistent and backed up.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: seafile
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/seafileltd/seafile-mc:14.0.9`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/haiwen/seafile-docker/blob/7880bf35bc8e66ee82237b6f6052ebe9803eeace/image/seafile_14.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/haiwen/seafile-server)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Seafile is several services in one image (ccnet, seafile server, seahub, fileserver) plus MariaDB and valkey dependencies, with an ubuntu base and root setup. Rootless operation and split processes are substantial rework. Official tarball is x86_64 only.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [seafileltd/seafile-mc:14.0.9](https://hub.docker.com/r/seafileltd/seafile-mc)
- **copy-from arm64**: [seafileltd/seafile-mc:14.0.9](https://hub.docker.com/r/seafileltd/seafile-mc)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: mariadb ✅, valkey ✅
