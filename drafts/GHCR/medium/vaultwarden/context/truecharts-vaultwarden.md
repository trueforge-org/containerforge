# TrueCharts vaultwarden (charts/stable/vaultwarden)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/vaultwarden/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `vaultwarden` v32.0.0, appVersion 1.37.5, train stable, depends on `common` 32.8.5 and PostgreSQL (`dependencies.postgresql.enabled: true`, user/db `vaultwarden`).
- Sources: ghcr.io/dani-garcia/vaultwarden, ghcr.io/timshel/vaultwarden, github.com/dani-garcia/vaultwarden.

## Images
| Key | Repository | Tag |
| --- | --- | --- |
| image | ghcr.io/dani-garcia/vaultwarden | 1.37.5@sha256:4fe17f41... |
| betaImage | ghcr.io/timshel/vaultwarden | 1.30.5-9@sha256:56e27907... |

## Ports
- service.main.ports.main: **10102** -> targetPort **8080**.

## Env
| Var | Value |
| --- | --- |
| DOMAIN | https://<ingress host 0> or https://placeholder.com |
| DATABASE_URL | secretKeyRef `<release>-postgresqlcreds` key `url` |
| envFrom | configMap `vaultwardenconfig`, secret `vaultwardensecret` (rendered from chart `vaultwarden.*` values) |

## Chart values (vaultwarden.*, rendered into configmap/secret)
- allowSignups true, verifySignup false, requireEmail false, allowInvitation true, showPasswordHint true, enableWebVault true, orgCreationUsers all.
- admin.enabled false, admin.token "PLACEHOLDERADMINTOKEN", admin.disableAdminToken false.
- smtp.enabled false; yubico.enabled false; push.enabled false.
- log.level "trace"; icons.disableDownload false.
- database.type postgresql, database.wal true.

## Volumes
| Name | Mount |
| --- | --- |
| data | /data |

## Ingress
- ingress.main.required true.

## Probes / security
- No probe overrides in values (defaults from common). No securityContext override in values.
