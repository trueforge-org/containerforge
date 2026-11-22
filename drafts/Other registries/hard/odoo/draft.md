# odoo

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Other registries
- **Difficulty**: hard
- **Chart**: odoo
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/odoo
- **Source repository**: https://github.com/odoo/odoo
- **Documentation**: https://www.odoo.com/documentation
- **Website**: https://www.odoo.com/

## Potentially relevant resources

- **Container image**: https://gallery.ecr.aws/docker/library/odoo
- **Source code repository**: https://github.com/odoo/docker

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Alternative runtime image**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`)
- **Reason**: Python business suite installed from a .deb with many Python dependencies.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: postgresql-client, wkhtmltopdf, fonts-noto-cjk, libpq-dev (inferred)
- python/pip: odoo 20.0 Python dependencies (inferred)
- node/npm: less, rtlcss (inferred, asset build)
- other: nightly odoo_20.0.latest_all.deb; PostgreSQL is a separate dependency

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8069/http (web UI), 8072/http (websocket and longpolling, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/odoo
- non-root: yes - chart sets runAsUser 1000, runAsGroup 1000 (not 568, but not root)
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none in values; odoo.conf mounted read-only from a configmap; CNPG postgres dependency
- extra-persistence: /var/lib/odoo and /mnt/extra-addons (chart-added, pvc); odoo.conf (configmap, read-only)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: requires a running PostgreSQL server; the database must exist before Odoo starts (manual setup)
- caveat: the draft uses a nightly .deb, not a pinned release, so builds may not be reproducible and can break without notice (inferred)
- caveat: Odoo 20.0 is a pre-release line, so verify it is stable enough before relying on it (inferred)
- caveat: first start initialises the database and needs the web setup to be completed; the initial master password must be set (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: odoo
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `public.ecr.aws/docker/library/odoo:20.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/odoo/docker/blob/0ea197eb3852ca500e38fd72074b314833ee7dc8/20.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/odoo/odoo)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://nightly.odoo.com/20.0/nightly/deb/odoo_20.0.latest_all.deb)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Large Python business suite installed from the nightly .deb on Ubuntu noble, with PostgreSQL via PostgreSQL and many native Python dependencies. The app is big and its file and addon paths need work for read-only /app, so it is a heavy port.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [public.ecr.aws/docker/library/odoo:20.0](https://gallery.ecr.aws/docker/library/odoo)
- **copy-from arm64**: [public.ecr.aws/docker/library/odoo:20.0](https://gallery.ecr.aws/docker/library/odoo)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
