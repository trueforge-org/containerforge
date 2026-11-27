# TrueCharts chart: authentik (fetched 2026-11-27)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/authentik/values.yaml , .../Chart.yaml

## What it is
- Chart `authentik` version 43.0.8, appVersion 2026.8.7, dep `common` 32.8.5
- Description: "Authentik is an open-source Identity Provider focused on flexibility and versatility."
- Sources: ghcr.io/goauthentik/{ldap,proxy,radius,server}, ghcr.io/kiwigrid/k8s-sidecar, ghcr.io/maxmind/geoipupdate, github goauthentik/authentik, https://goauthentik.io/docs/

## Images (values.yaml)
| Role | Repository | Tag |
| --- | --- | --- |
| server | ghcr.io/goauthentik/server | 2026.8.7@sha256:1675a017... |
| geoip | ghcr.io/maxmind/geoipupdate | v8.0.0@sha256:51e70dd6... |
| ldap | ghcr.io/goauthentik/ldap | 2026.8.7@sha256:b0400c19... |
| radius | ghcr.io/goauthentik/radius | 2026.8.7@sha256:92745ace... |
| proxy | ghcr.io/goauthentik/proxy | 2026.8.7@sha256:fb5173f4... |
| sidecar | ghcr.io/kiwigrid/k8s-sidecar | 2.14.3@sha256:52d311dc... |

## Server workload (values.yaml)
- `workload.main`: Deployment, container `main`, runAsUser 1000, runAsGroup 1000
- envFrom: configMap `server`, secret `server-worker`, configMap `server-worker`
- args: `server`
- probes (liveness/readiness/startup): exec `/lifecycle/ak healthcheck`
- authentik config values: secretKey (placeholder, must change), bootstrap credentials (email/password), general/email/ldap/geoip/outposts settings
- Blueprints serviceAccount + RBAC (configmaps/secrets get/watch/list) for worker

## Gotchas
- Chart runs five images from one app; plan splits them into one app per image
- Secret key must be >= 32 chars (values comment)
