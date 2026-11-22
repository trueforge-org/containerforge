# tasmobackup

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: tasmobackup
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tasmobackup
- **Source repository**: https://github.com/danmed/TasmoBackupV1

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/danmed/tasmobackupv1

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Alternative runtime image**: [nginx](https://github.com/trueforge-org/containerforge/tree/main/apps/nginx) (`ghcr.io/trueforge-org/nginx`)
- **Reason**: Pure PHP app with PHP from apt on ubuntu; nginx is the alternative web server.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: php-fpm, php-cli, php-curl, php-xml (inferred), nginx (alternative, inferred)
- python/pip: none
- node/npm: none
- other: TasmoBackupV1 1.08.01 release source

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/tasmobackup
- non-root: no - chart sets runAsUser 0, runAsGroup 0, runAsNonRoot false
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - default false, no override
- other-security: none
- extra-persistence: /var/www/html/data (pvc, sqlite DB and backups)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the backup database is SQLite under the data path, so the data volume must be backed up together with the devices it manages (inferred)
- caveat: the app connects to Tasmota devices over the local network and needs them reachable from the container (inferred)
- caveat: nginx and php-fpm run as separate processes in one container, which needs rework to run rootless (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: tasmobackup
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/danmed/tasmobackupv1:1.08.01`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/danmed/TasmoBackupV1/blob/59f8a66bafdc3cf5eb8255d58ceacbba33cd3bd1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/danmed/TasmoBackupV1)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/danmed/TasmoBackupV1/releases/tag/1.08.01)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: PHP backup manager on the docker-php-nginx base, which runs nginx and php-fpm together, so several processes in one container. Needs rootless rework of nginx and php-fpm on a read-only rootfs; the app itself is pure PHP copied from the repo.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [danmed/tasmobackupv1:1.08.01](https://hub.docker.com/r/danmed/tasmobackupv1)
- **copy-from arm64**: [danmed/tasmobackupv1:1.08.01](https://hub.docker.com/r/danmed/tasmobackupv1)

### Dependency containers

- **Dependency containers**: none
