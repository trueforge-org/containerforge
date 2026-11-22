# twofauth

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: twofauth
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/twofauth
- **Source repository**: https://github.com/Bubka/2FAuth
- **Documentation**: https://docs.2fauth.app/
- **Website**: https://2fauth.app/

## Potentially relevant resources

- **Source code repository**: https://github.com/Bubka/2fauth
- **Container image**: https://hub.docker.com/r/2fauth/2fauth

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: PHP app with PHP and extensions installed via apt on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: php-cli, php-pgsql, php-mbstring, php-xml, php-curl, php-zip, php-bcmath, php-gd, php-intl (inferred)
- python/pip: none
- node/npm: none
- other: composer (inferred)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/twofauth
- non-root: yes - runAsUser 1000, runAsGroup 1000 override (non-root, not 568)
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default privileged false, not overridden
- other-security: none
- extra-persistence: /2fauth (pvc, chart config volume)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Laravel app needs an APP_KEY and a database set up on first run; without them the web UI will not load.
- caveat: Uses an external PostgreSQL database, so the database must exist and be reachable before the app starts (inferred).
- caveat: Two-factor secrets are sensitive data; the /2fauth volume must be backed up or the stored codes are lost.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: twofauth
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/2fauth/2fauth:9.0.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Bubka/2FAuth/blob/2a19734/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Bubka/2FAuth)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Bubka/2FAuth/releases/tag/v9.0.1)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Laravel PHP app: composer builds the vendor tree and the app is copied in. On containerforge-ubuntu we would apt install PHP with the needed extensions, run composer in a build stage, and keep storage writable under /config and /tmp. External Postgres via PostgreSQL.

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

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
