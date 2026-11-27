# TrueCharts notifiarr (chart 10.0.0, appVersion 0.10.0)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/notifiarr/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Unified client for Notifiarr.com: Discord Media Bot content requests, Plex usage reports, system health reporting.
- Chart sources: ghcr.io/notifiarr/notifiarr, github.com/Notifiarr/notifiarr.
- Category MediaApp-Other, train stable, not deprecated. Keywords: plex, discord, notification.
- Kubernetes >=1.33.0-0 (max 1.35.0); Helm min 3.14, max 4.1.
- Dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
| Field | Value |
| --- | --- |
| Repository | ghcr.io/notifiarr/notifiarr |
| Tag | v0.10.0 (digest pinned) |
| Pull policy | IfNotPresent |

## Ports
| Scope | Value |
| --- | --- |
| service main port main | 5454 (http) |
| Container port | not set; bind addr uses service port `0.0.0.0:5454` |

## Env vars (main container)
| Var | Value |
| --- | --- |
| TMPDIR | /tmpdir |
| DN_API_KEY | secretKeyRef: secret env-secrets, key DN_API_KEY (value from notifiarr.apikey, default "test") |
| DN_BIND_ADDR | `0.0.0.0:5454` (templated from service port) |
| DN_UPSTREAMS_0 | notifiarr.upstreams joined by space (default 172.16.0.0/16) |

## Chart values
- notifiarr.apikey: "test" (also the admin password for first login, username `admin`; change in UI after login).
- notifiarr.upstreams: [172.16.0.0/16].
- Secret env-secrets (enabled): DN_API_KEY = notifiarr.apikey.

## Persistence / paths
| Name | Type | Mount | Notes |
| --- | --- | --- | --- |
| config | pvc (default) | /config (main + init-conf) | enabled |
| machine-id | hostPath /etc/machine-id | /etc/machine-id | readOnly |
| tmpdir | emptyDir (Memory) | /tmpdir | |

## Init container init-conf
- type init, imageSelector ubuntuImage, command `/bin/sh -c <script>`.
- Script: CONF=/config/notifiarr.conf; exit 0 if exists; else writes `# Dummy comment`; prints "Finished.".
- Runs every boot. Purpose: prevents Notifiarr generating a default password, so the API key and `admin` user are used.

## Not specified
- Probes, securityContext (runAsUser/runAsGroup/readOnlyRootFilesystem), main container command/args.

## Gotchas
- Chart DN_API_KEY default "test" is a placeholder; must be overridden.
