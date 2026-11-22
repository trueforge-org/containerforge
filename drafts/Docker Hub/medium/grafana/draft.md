# grafana

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: grafana
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql, k8s-sidecar)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/grafana
- **Source repository**: https://github.com/grafana/grafana
- **Documentation**: https://grafana.com/docs/grafana/latest/

## Potentially relevant resources

- **Container image**: https://ghcr.io/kiwigrid/k8s-sidecar
- **Source code repository**: https://github.com/bitnami/bitnami-docker-grafana
- **Website**: https://grafana.com
- **Container image**: https://hub.docker.com/r/grafana/grafana

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go app shipped as a per-arch package unpacked into /app, so no language base is needed.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: grafana release package (.deb per arch, unpack into /app)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/grafana
- non-root: yes - no runAs override, common default runAsUser 568 (init container download-dashboards runs on ubuntu image, its security context not checked)
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, no override in values
- other-security: none (common drop ALL, seccomp RuntimeDefault)
- extra-persistence: /var/lib/grafana (pvc); /app/tmp (emptyDir); /tmp/dashboards (emptyDir); /etc/grafana/provisioning/{datasources,alerts,plugins,notifiers} (emptyDir); /etc/grafana/grafana.ini and ldap.toml (configmap)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: grafana
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/grafana/grafana:13.3.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/grafana/grafana/blob/5db6ba887630c7fa12e5bfd063f2fa854025468c/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/grafana/grafana)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/grafana/grafana/releases/download/v13.3.1/grafana-enterprise_13.3.1_42849527790_linux_amd64.deb) · [arm64](https://github.com/grafana/grafana/releases/download/v13.3.1/grafana-enterprise_13.3.1_42849527790_linux_arm64.deb)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Grafana is a large Go app but ships as one official tarball per arch on dl.grafana.com. Unpack into /app, point data, logs and plugins at /config and /tmp, and it runs as one rootless process. Sidecar images are not needed for this main image.

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

- **Dependency containers**: postgresql ✅, k8s-sidecar (sidecarImage) ✅
