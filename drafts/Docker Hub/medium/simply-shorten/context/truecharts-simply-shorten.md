# truecharts simply-shorten (chart version 14.0.0)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/simply-shorten/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/simply-shorten/Chart.yaml
- Fetched 2026-11-27

## What it is
- Chart `name: simply-shorten`, `appVersion: 1.1.0`, `version: 14.0.0`, `type: application`
- Description: "A dead simple URL shortener."
- Sources listed: GitHub chart dir, gitlab.com/draganczukp/simply-shorten, hub.docker.com/r/draganczukp/simply-shorten
- Dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`
- kubeVersion `>=1.33.0-0`

## Image (values.yaml)
- repository: `docker.io/draganczukp/simply-shorten`
- tag: `1.1@sha256:97b2726a0a443d6d41dfb0988dcb377b1b3960d32b3fd917fd74806e03ac145f`
- pullPolicy: IfNotPresent

## Ports
| name | port | targetPort | protocol |
| --- | --- | --- | --- |
| main | 4567 | 4567 | http |

## Persistence
- `config`: enabled, mountPath `/config/db`

## Env (workload.main container `main`)
| key | value |
| --- | --- |
| db_url | `/config/db/urls.sqlite` |
| username | `pass` (literal) |
| password | secretKeyRef `env-secrets` / key `password` |

Secret `env-secrets` (enabled): data `password: "user"` (chart default, not a real secret).

## Security context
- readOnlyRootFilesystem: false
- runAsNonRoot: false, runAsUser: 0, runAsGroup: 0 (chart runs as root)

## Probes
- Not set in values.yaml (chart defaults apply).

## Gotchas
- Chart pins tag 1.1 by digest; `username` env is the literal value `pass`, while only `password` comes from the secret.
- Chart runs the container as root with a writable rootfs.
