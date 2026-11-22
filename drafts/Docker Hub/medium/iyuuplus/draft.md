# iyuuplus

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: iyuuplus
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/iyuuplus
- **Source repository**: https://github.com/ledccn/iyuuplus-dev
- **Documentation**: http://doc.iyuu.cn/
- **Website**: https://www.iyuu.cn/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/iyuucn/iyuuplus

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: PHP app that installs PHP via apt on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: php-cli, php-curl, php-mbstring, php-xml, php-zip, php-sqlite3 (inferred)
- python/pip: none
- node/npm: none
- other: composer (PHP deps, inferred); source archive ledccn/iyuuplus-dev (HEAD, unpinned)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8787/http (web UI) (inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/iyuuplus
- non-root: possible - chart forces runAsUser 0 and runAsNonRoot false; PHP app could run as non-root
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false
- privileged: no - common default, not overridden
- other-security: none
- extra-persistence: /IYUU/db (pvc, config path used by chart instead of /config), /torrents (pvc), /BT_backup (pvc)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the source is an unpinned HEAD archive, so rebuilds can change behavior without a version bump (from draft).
- caveat: pushing and downloader integration need an IYUU account or token from iyuu.cn (inferred).
- caveat: composer packages are fetched at build time; the build needs internet access (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: iyuuplus
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/iyuucn/iyuuplus:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ledccn/iyuuplus-dev/blob/HEAD/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ledccn/iyuuplus-dev)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/ledccn/iyuuplus-dev/archive/HEAD.zip)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Open-source PHP (workerman) app ledccn/iyuuplus-dev, installed from a source checkout on alpine 3.21. On containerforge-ubuntu apt install php-cli with extensions and copy the code into /app, with config under /config. No PHP base exists yet, and the unpinned source is a risk.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
