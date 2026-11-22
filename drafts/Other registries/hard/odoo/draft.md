# odoo

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Other registries
- **Difficulty**: hard
- **Chart**: odoo
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql (CNPG))
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/odoo/odoo
- **Documentation**: https://www.odoo.com/documentation
- **Website**: https://www.odoo.com/

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

- **Reason**: Large Python business suite installed from the nightly .deb on Ubuntu noble, with PostgreSQL via CNPG and many native Python dependencies. The app is big and its file and addon paths need work for read-only /app, so it is a heavy port.

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

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql (CNPG) ✅
