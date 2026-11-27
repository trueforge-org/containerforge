# TrueCharts chart: socials (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/socials/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `socials` v11.0.0, library `common` 32.8.5, appVersion `main`.
- Description: single-page site listing social/personal links (Typescript, Sass, Express, EJS).

## Image (values.yaml)
- repository: `ghcr.io/diamkil/socials`
- tag: `main@sha256:ec22a94aad6850b2667c506dfec53cdd39b241f039c5a1187b569f3aefc2c75b`
- pullPolicy: IfNotPresent

## Ports
| name | port | targetPort | proto |
| --- | --- | --- | --- |
| main | 7574 | 7574 | tcp |

## Persistence
- `socials`: enabled, mountPath `/app/people`

## Env (workload.main.podSpec.containers.main.env)
| var | value |
| --- | --- |
| LOG_LEVEL | info |

## Security context (chart defaults in values)
- readOnlyRootFilesystem: false, runAsUser: 0, runAsGroup: 0

## Other
- Chart sources: ghcr.io/diamkil/socials, github.com/diamkil/socials, registry.hub.docker.com/r/diamkil/socials
- Kubernetes: kubeVersion >=1.33.0-0; no probes/healthcheck overrides in values.
