# phpldapadmin

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: phpldapadmin
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/phpldapadmin
- **Source repository**: https://github.com/leenooks/phpLDAPadmin
- **Documentation**: https://github.com/leenooks/phpLDAPadmin/wiki
- **Website**: https://phpldapadmin.org/

## Potentially relevant resources

- **Website**: https://gitlab.v2.rancher.geohub.space/g3s/i3s/i3s-helm-catalog
- **Container image**: https://hub.docker.com/r/osixia/phpldapadmin

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: PHP source installed on ubuntu with PHP from apt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: php-cli, php-fpm (inferred), php-ldap (inferred), php-xml (inferred), php-mbstring (inferred), nginx (inferred)
- python/pip: none
- node/npm: none
- other: phpLDAPadmin source archive

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (web UI), 443/https (web UI TLS, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/phpldapadmin
- non-root: no - runAsUser 0, runAsNonRoot false, no override
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set in values (default false)
- other-security: none
- extra-persistence: none (varrun disabled, common default only)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: phpLDAPadmin needs an LDAP server to connect to; the container has no directory of its own (inferred).
- caveat: the source comes from the phpLDAPadmin archive, so the osixia s6 init and config layout must be rebuilt for rootless use, and the upstream project has had slow maintenance (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: phpldapadmin
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/osixia/phpldapadmin:0.9.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/osixia/docker-phpLDAPadmin/blob/master/image/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/leenooks/phpLDAPadmin)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:phpldapadmin`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: PHP source archive installed on the osixia web baseimage, which is an s6 image with nginx, php-fpm and init scripts under root. Rebuilding on ubuntu needs a PHP stack from apt and a rewrite of the service layout for rootless use.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [osixia/phpldapadmin:0.9.0](https://hub.docker.com/r/osixia/phpldapadmin)
- **copy-from arm64**: [osixia/phpldapadmin:0.9.0](https://hub.docker.com/r/osixia/phpldapadmin)

### Dependency containers

- **Dependency containers**: none
