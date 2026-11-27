# TrueCharts muximux (chart 17.0.1, appVersion 3.7.4)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/muximux/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Lightweight portal for HTPC apps; needs only a PHP-enabled webserver (per chart description).
- Chart sources listed: ghcr.io/mescon/muximux, github.com/mescon/Muximux.
- Category: media, train: stable, not deprecated.
- Kubernetes >=1.33.0-0 (max tested 1.35.0); Helm min 3.14, max 4.1.
- Dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
| Field | Value |
| --- | --- |
| Repository | ghcr.io/mescon/muximux |
| Tag | 3.7.4 (digest pinned) |
| Pull policy | IfNotPresent |

## Ports
| Scope | Port |
| --- | --- |
| Service (main) | 10019 |
| Container targetPort | 8080 |

## Probes
- startup, readiness, liveness: all http, port 8080, path `/api/health`.

## Persistence / paths
- config volume mounted at `/app/data` (enabled).

## Security context (chart default)
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.
- Note: chart runs as root; upstream image does not set USER.

## Env vars
- None defined in values.yaml.

## Gotchas
- values.yaml has no env, so PUID/PGID defaults from image apply (see upstream file).
