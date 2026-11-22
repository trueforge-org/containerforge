# nginx-proxy-manager

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: nginx-proxy-manager
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (mariadb)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/nginx-proxy-manager
- **Source repository**: https://github.com/NginxProxyManager/nginx-proxy-manager
- **Documentation**: https://nginxproxymanager.com/setup/
- **Website**: https://nginxproxymanager.com

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/jc21/nginx-proxy-manager

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Alternative runtime image**: [nginx](https://github.com/trueforge-org/containerforge/tree/main/apps/nginx) (`ghcr.io/trueforge-org/nginx`)
- **Reason**: Node backend is the app runtime, with OpenResty frontend served by nginx.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: openresty (inferred, needs upstream repo), certbot (inferred), supervisor or s6 (inferred)
- python/pip: none
- node/npm: yarn, backend deps (inferred)
- other: frontend built bundle from v2.17.1 source

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (proxy HTTP), 443/https (proxy HTTPS), 81/http (admin UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/nginx-proxy-manager
- non-root: no - chart sets runAsUser 0, runAsGroup 0, runAsNonRoot false
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: web and websecure services on 80 and 443 (below 1024); mariadb dependency enabled
- extra-persistence: /data (pvc, 256Gi); /etc/letsencrypt (pvc, 256Gi)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The default admin login is created on first start and must be changed right away through the admin UI (inferred).
- caveat: Let's Encrypt certificates need public DNS and inbound ports 80 and 443 reachable from the internet (inferred).
- caveat: Ports 80, 443 and 81 on the host must be free, and a MariaDB database is expected for the normal setup.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: nginx-proxy-manager
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/jc21/nginx-proxy-manager:2.17.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/NginxProxyManager/nginx-proxy-manager/blob/v2.17.1/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/NginxProxyManager/nginx-proxy-manager)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/NginxProxyManager/nginx-proxy-manager/releases/tag/v2.17.1)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Backend is Node with yarn and the frontend is a built bundle, copied onto the nginx-full base that ships OpenResty, certbot and s6. Rebuilding on containerforge-ubuntu means running OpenResty, certbot and Node as several services and moving nginx paths for a read-only rootfs.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [jc21/nginx-proxy-manager:2.17.1](https://hub.docker.com/r/jc21/nginx-proxy-manager)
- **copy-from arm64**: [jc21/nginx-proxy-manager:2.17.1](https://hub.docker.com/r/jc21/nginx-proxy-manager)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: mariadb ✅
