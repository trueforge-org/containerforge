# tt-rss

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: tt-rss
- **Rows**: 2
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tt-rss
- **Source repository**: https://github.com/tt-rss/tt-rss
- **Website**: https://tt-rss.org/

## Potentially relevant resources

- **Container image**: https://ghcr.io/tt-rss/tt-rss
- **Container image**: https://ghcr.io/tt-rss/tt-rss-web-nginx
- **Website**: https://git.tt-rss.org/fox/tt-rss

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Guess: the draft has no image, binary or reason text, so ubuntu is the default.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: php-fpm, php-pgsql (inferred), php-curl (inferred), php-gd (inferred), php-mbstring (inferred), php-xml (inferred), php-intl (inferred), git (inferred), nginx (row 2 sidecar)
- python/pip: none
- node/npm: none
- other: git clone of plugins at build time, tt-rss source (tarball or git)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9000/tcp (php-fpm FastCGI, internal), 80/http (nginx web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/tt-rss
- non-root: no - top-level container override runAsUser 0 applies to app, nginx and updater
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: nginx-conf configmap mount; external PostgreSQL (cnpg)
- extra-persistence: none beyond chart's own html at /var/www/html and config at /opt/tt-rss/config.d
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The chart needs external PostgreSQL and a separate nginx image, so two containers and a database must be deployed together (from the draft).
- caveat: Plugins are git-cloned at build time, so plugin updates require a rebuild of the image (from the draft).
- caveat: The web tier source is a master-branch archive, so the version is not pinned (from the draft).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- Row 1: **Chart**: tt-rss
- Row 1: **Role**: main
- Row 2: **Chart**: tt-rss
- Row 2: **Role**: sidecar (nginxImage)

### Container

The image and tag the chart uses today.

- Row 1: **Container**: `ghcr.io/tt-rss/tt-rss:latest`
- Row 2: **Container**: `ghcr.io/tt-rss/tt-rss-web-nginx:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- Row 1: **Dockerfile**: [Dockerfile](https://github.com/tt-rss/tt-rss/blob/03628f0aa3c4a86e960ddd61b5ba372cd3a27b50/.docker/app/Dockerfile)
- Row 2: **Dockerfile**: [Dockerfile](https://github.com/tt-rss/tt-rss/blob/d62bcf96d01a7a2e750f6c9581ca462556e57281/.docker/web-nginx/Dockerfile)

### Application source

The application's own source repository or project page.

- Row 1: **Application source**: [source](https://github.com/tt-rss/tt-rss)
- Row 2: **Application source**: [source](https://github.com/tt-rss/tt-rss)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- Row 1: **Application binary**: [binary](https://github.com/tt-rss/tt-rss/archive/refs/heads/master.zip)
- Row 2: **Application binary**: binary: `apt:nginx (tt-rss source: https://gitlab.tt-rss.org/tt-rss/tt-rss)`

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- Row 1: **Difficulty**: medium
- Row 2: **Difficulty**: medium

### Reason

- Row 1: **Reason**: PHP application with php-fpm and an update daemon, installed via Alpine apk and plugins cloned with git at build time. Port to Ubuntu apt PHP and fold the nginx sidecar onto the nginx sibling; the app itself is pure PHP with no compile step.
- Row 2: **Reason**: Nginx config plus tt-rss PHP static files copied in; reuse the ContainerForge nginx base and fetch the tt-rss source (tarball). Needs nginx temp dirs redirected for rootless/read-only, and it is only the web half of a php-fpm pair.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- Row 1: **amd64**: yes
- Row 1: **arm64**: yes
- Row 2: **amd64**: yes
- Row 2: **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- Row 1: **copy-from amd64**: no
- Row 1: **copy-from arm64**: no
- Row 2: **copy-from amd64**: no
- Row 2: **copy-from arm64**: no

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

❌ means it is missing too.

- Row 1: **Dependency containers**: postgresql ✅, tt-rss-web-nginx (nginxImage) ❌
- Row 2: **Dependency containers**: -
