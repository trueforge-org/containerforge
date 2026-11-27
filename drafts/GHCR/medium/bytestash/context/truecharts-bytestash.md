# TrueCharts chart: bytestash

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/bytestash/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `bytestash` v5.0.0, `appVersion: 1.6.2`, category `Productivity`, train `stable`.
- Description: self-hosted web app to store, organise and manage code snippets.
- Library dependency: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`).
- Sources: `ghcr.io/jordan-dalby/bytestash`, github jordan-dalby/ByteStash, trueforge chart path.

## Image (values.yaml)
- Repository: `ghcr.io/jordan-dalby/bytestash`
- Tag: `1.6.2@sha256:86d5726ef9a417775cc05120eed04c36915cbc41aea83c5799fc6b8d3ad77db5`
- pullPolicy: IfNotPresent

## Ports
| Name | Port | Protocol |
| --- | --- | --- |
| main | 5000 | http |

## Probes
- Not set in values.yaml.

## Env (workload.main.podSpec.containers.main.env)
| Var | Chart value |
| --- | --- |
| BASE_PATH | "" |
| JWT_SECRET | secretKeyRef `env-secrets`/`JWT_SECRET` |
| TOKEN_EXPIRY | "24h" |
| ALLOW_NEW_ACCOUNTS | "false" |
| DEBUG | "false" |
| DISABLE_ACCOUNTS | "false" |
| DISABLE_INTERNAL_ACCOUNTS | "false" |
| OIDC_ENABLED | "false" |
| OIDC_DISPLAY_NAME | "" |
| OIDC_ISSUER_URL | "" |
| OIDC_CLIENT_ID | "" |
| OIDC_CLIENT_SECRET | secretKeyRef `env-secrets`/`OIDC_CLIENT_SECRET` |
| OIDC_SCOPES | "" |

## Secrets (chart placeholders)
- `env-secrets`: `JWT_SECRET: "bytestash JWT secret"`, `OIDC_CLIENT_SECRET: ""`.

## Persistence
| Name | Mount |
| --- | --- |
| data | /data/snippets |

## Gotchas
- Chart mounts `/data/snippets` (upstream data dir); chart does not set `securityContext` (defaults apply).
