# TrueCharts watcharr (charts/stable/watcharr)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/watcharr/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `watcharr` v13.0.0, appVersion 4.4.0, train stable, depends on `common` 32.8.5.
- Sources: ghcr.io/sbondco/watcharr, github.com/sbondCo/Watcharr.

## Image
- `ghcr.io/sbondco/watcharr`, tag `v4.4.0@sha256:28673ff5...`, pullPolicy IfNotPresent.

## Ports
- service.main.ports.main: protocol http, port **10684** -> targetPort **3080**.

## Env
| Var | Value |
| --- | --- |
| JELLYFIN_HOST | watcharr.jellyfin_host (default "") |
| SIGNUP_ENABLED | watcharr.signup_enabled (default true) |
| TMDB_KEY | secretKeyRef env-secrets/TMDB_KEY (value from watcharr.tmdb_key, default "") |
| DEBUG | watcharr.debug (default false) |
| MODE | watcharr.mode (default prod) |
| JWT_SECRET | secretKeyRef watcharr-secrets/JWT_SECRET (value from watcharr.jwtSecret, placeholder "PLACEHOLDERJWTSECRETCHANGEME...") |

## Volumes
| Name | Mount |
| --- | --- |
| data | /data |

## Security
- securityContext.container: readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0.

## Probes
- None overridden.
