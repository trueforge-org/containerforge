# TrueCharts chart: odoo

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/odoo/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/odoo/values.yaml (fetched 2026-11-27)

## What it is
- Chart `odoo` version 26.0.1, appVersion 20.0.0, category `productivity`.
- Depends on `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`) and a postgresql dependency (enabled, `postgresqlUsername: odoo`, `postgresqlDatabase: odoo`).
- kubeVersion `>=1.33.0-0`; min helm 3.14, max helm 4.1.

## Image
- `public.ecr.aws/docker/library/odoo` tag `20.0@sha256:6709a38456a588273462c83400a0b6dbe09038deefc05846a8d3d25231dbb82e`, pullPolicy IfNotPresent.

## Security context
- Container: `readOnlyRootFilesystem: false`, `runAsUser: 1000`, `runAsGroup: 1000`.

## Ports
- `service.main.ports.main.port: 8069`.

## Init container (`init-db`)
- `type: install`, enabled, `imageSelector: image`.
- env `ODOO_RC: /etc/odoo/odoo.conf`.
- command `/bin/bash -c`: `/usr/bin/odoo --config=/etc/odoo/odoo.conf --stop-after-init --without-demo=all --init=base`.
- Note: `/usr/bin/odoo` path (upstream Dockerfile installs odoo via .deb).

## Main container
- env `ODOO_RC: /etc/odoo/odoo.conf`.
- Probes liveness/readiness/startup: `http`, path `/web/health`, enabled.

## Persistence
| Name | Mount (main + init-db) | Notes |
| --- | --- | --- |
| odoo | `/var/lib/odoo` | filestore |
| addons | `/mnt/extra-addons` | custom addons |
| odoo-config | `/etc/odoo/odoo.conf` (subPath `odoo.conf`, readOnly) | secret `odoo-config` |

## Other values
- `odoo.additionalConf: []`.

## Gotchas
- Chart uses init-db as a one-shot `--init=base` install before main starts.
- Config comes from secret mounted read-only at `/etc/odoo/odoo.conf`; the upstream image's own `odoo.conf` is replaced by this mount.
- Upstream entrypoint adds db_host/db_port/db_user/db_password args unless present in config (see github-odoo-docker.md).
