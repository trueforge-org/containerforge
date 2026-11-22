# shlink

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: shlink
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql, valkey)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/shlink
- **Source repository**: https://github.com/shlinkio/shlink
- **Documentation**: https://shlink.io/documentation/
- **Website**: https://shlink.io/

## Potentially relevant resources

- **Container image**: https://ghcr.io/shlinkio/shlink

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: PHP 8.5 app with composer deps and PHP extensions installed via apt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: php8.5-cli, php8.5-fpm, php8.5-pgsql, php8.5-intl, php8.5-bcmath, php8.5-mbstring, php8.5-xml, php8.5-zip, php8.5-curl (inferred)
- python/pip: none
- node/npm: none
- other: none (dist zip with vendor, composer only if building from source)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (API and redirect server, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/shlink
- non-root: no - runAsUser 0, runAsGroup 0, runAsNonRoot false
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: none (Postgres and Valkey are separate chart dependencies, not persistence)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: a working install needs an external PostgreSQL and Valkey; the app will not run normally without them.
- caveat: the first API key must be generated with the shlink CLI inside the container after the first start (inferred).
- caveat: visit geolocation needs a MaxMind GeoLite2 license key supplied by the user (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: shlink
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/shlinkio/shlink:5.1.8`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/shlinkio/shlink/blob/v5.1.8/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/shlinkio/shlink)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/shlinkio/shlink/releases/download/v5.1.8/shlink5.1.8_php8.5_dist.zip)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Shlink is a PHP 8.5 app with composer dependencies that needs pgsql and other PHP extensions, plus Postgres and Valkey from the chart. PHP is not a ContainerForge runtime, and the web entrypoint and workers add moving parts. The stack is large for a port.

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

- **Dependency containers**: valkey ✅, postgresql ✅
