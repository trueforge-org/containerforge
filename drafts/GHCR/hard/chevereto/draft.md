# chevereto

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: chevereto
- **Rows**: 1
- **Hard dependency containers**: yes (mariadb)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/chevereto
- **Source repository**: https://github.com/rodber/chevereto-free
- **Documentation**: https://v4-docs.chevereto.com/
- **Website**: https://chevereto.com/

## Potentially relevant resources

- **Website**: https://chevereto-free.github.io/setup/stable/environment.html#image-handling-variables
- **Container image**: https://ghcr.io/rodber/chevereto-free

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: PHP via apt on ubuntu per the PHP rule.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: apache2, libapache2-mod-php, php-cli, php-fpm, php-gd, php-mysql, php-curl, php-mbstring, php-xml, php-zip (inferred)
- python/pip: none
- node/npm: none
- other: composer (inferred), release zip 1.6.2

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (Apache web app, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/chevereto
- non-root: no - chart forces runAsUser 0 and runAsNonRoot false (Apache and PHP)
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, default false
- other-security: fsGroup 33 at pod level; none otherwise
- extra-persistence: /var/www/html/images/, /var/www/html/content/ (type not set, likely pvc)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: MariaDB must be reachable before the first start, and the admin account is created in the browser setup (inferred).
- caveat: the app is PHP 7.4 (end of life) and the upstream project is small, so security fixes and PHP updates are unlikely to arrive (upstream status).
- caveat: uploaded images and content grow without limit, so the mounted image and content paths need enough disk and a backup plan (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: chevereto
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/rodber/chevereto-free:1.6.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/rodber/chevereto-free/blob/1171863/httpd-php.Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/rodber/chevereto-free)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/rodber/chevereto-free/releases/download/1.6.2/1.6.2.zip)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Chevereto is a PHP 7.4 app (end of life) that runs under Apache with composer dependencies and a MariaDB dependency from the chart. PHP is not a ContainerForge runtime, and Apache plus PHP is a multi-process setup with upload paths that must move to /config. Source is interpreted, so no compile is needed.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/rodber/chevereto-free:1.6.2](https://ghcr.io/rodber/chevereto-free)
- **copy-from arm64**: [ghcr.io/rodber/chevereto-free:1.6.2](https://ghcr.io/rodber/chevereto-free)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: mariadb ✅
