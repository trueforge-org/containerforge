# TrueCharts chart: semaphore

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/semaphore/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts `semaphore`, category productivity. Chart version 9.0.0, appVersion 2.20.24.
- Description: open-source web UI for Ansible (alternative to Ansible Tower).
- Library dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`.
- Chart `sources:` list: github ansible-semaphore/semaphore, truecharts chart path, hub.docker.com/r/semaphoreui/semaphore.

## Image (values.yaml)
- repository `docker.io/semaphoreui/semaphore`, tag `v2.20.24@sha256:c547d31cba238bee4a9f2b5eec9d0f42b2d5ecb399377a2e63008500d74fbf3a`, pullPolicy IfNotPresent.

## Ports
- service.main.ports.main: port 3000, protocol http, targetPort 3000.

## Chart config (`semaphore:` block)
- accessKeyEncryption: "PLACEHOLDERSECRETKEYXXXXXXXXXXXX" (must change; 32 bytes base64 recommended). Consumed as env SEMAPHORE_ACCESS_KEY_ENCRYPTION from secret `semaphore-secrets`.

## Env (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| SEMAPHORE_DB_DIALECT | postgres |
| SEMAPHORE_DB_USER | dependencies.postgresql.depconfig.postgresqlUsername (semaphore) |
| SEMAPHORE_DB | dependencies.postgresql.depconfig.postgresqlDatabase (semaphore) |
| SEMAPHORE_DB_PORT | 5432 |
| SEMAPHORE_DB_HOST | secretKeyRef `<release>-postgresqlcreds` key `plainhost` |
| SEMAPHORE_DB_PASS | secretKeyRef `<release>-postgresqlcreds` key `postgresql-password` |
| SEMAPHORE_ACCESS_KEY_ENCRYPTION | secretKeyRef semaphore-secrets/SEMAPHORE_ACCESS_KEY_ENCRYPTION |
| SEMAPHORE_PLAYBOOK_PATH | `{{ persistence.data.mountPath }}` (/data) |
| SEMAPHORE_ADMIN | admin |
| SEMAPHORE_ADMIN_NAME | admin |
| SEMAPHORE_ADMIN_PASSWORD | secretKeyRef env-secrets/SEMAPHORE_ADMIN_PASSWORD (default `changeme` in secret data) |
| SEMAPHORE_ADMIN_EMAIL | admin@localhost |
| SEMAPHORE_LDAP_ACTIVATED | "no" |
| SEMAPHORE_LDAP_NEEDTLS | "no" |
- LDAP host/port/DN/search lines are commented out in values.

## Persistence
- persistence.config: enabled, mountPath `/etc/semaphore`.
- persistence.data: enabled, mountPath `/data`.

## Dependencies
- `postgresql` enabled; depconfig user `semaphore`, database `semaphore`.

## Secrets
- secret.env-secrets: SEMAPHORE_ADMIN_PASSWORD = 'changeme'.

## Security
- securityContext.container: runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Gotchas
- Chart runs as root; upstream image runs as UID 1001.
- Chart maps playbook path to `/data`, whereas upstream image writes to `/etc/semaphore`, `/var/lib/semaphore`, `/tmp/semaphore`, `/opt/semaphore` (see github file).
- Default admin password `changeme` is in the chart secret.
