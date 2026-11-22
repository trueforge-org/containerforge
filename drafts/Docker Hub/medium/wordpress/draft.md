# wordpress

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: wordpress
- **Rows**: 1
- **Hard dependency containers**: yes (mariadb)
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/WordPress/WordPress
- **Documentation**: https://wordpress.org/documentation/
- **Website**: https://wordpress.org

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: wordpress
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/bitnamisecure/wordpress:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/bitnami/containers/blob/9da424411c57f30d7bdc8409eabcce6e5709c9f3/bitnami/wordpress/7/debian-12/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/WordPress/WordPress)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://wordpress.org/latest.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: WordPress on Apache with mod_php (or php-fpm) from Ubuntu apt plus the official wordpress.org tarball, which is arch-neutral PHP. Apache runs as one process on a high port; wp-content must move to /config and PID/log paths to /tmp. Needs the mariadb sibling.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [bitnamisecure/wordpress:latest](https://hub.docker.com/r/bitnamisecure/wordpress)
- **copy-from arm64**: [bitnamisecure/wordpress:latest](https://hub.docker.com/r/bitnamisecure/wordpress)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: mariadb ✅
