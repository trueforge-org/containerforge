# TrueCharts chart: boinc

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/boinc/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `boinc` version 15.0.1, appVersion `latest` (rolling), train stable, category incubator.
- Description: "BOINC is a platform for high-throughput computing on a large scale (thousands or millions of computers)."
- Dependency: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`); kubeVersion `>=1.33.0-0`.

## Image (values.yaml)
| Key | Value |
| --- | --- |
| repository | `ghcr.io/linuxserver/boinc` |
| tag | `latest@sha256:c6c6997286e92ca1231e737673650b7f77ace777779cbcedf4f5a18296e16e54` |
| pullPolicy | IfNotPresent |

## Ports
| Name | port | targetPort | protocol |
| --- | --- | --- | --- |
| main | 10142 | 8080 | tcp |

## Env
| Env | Source |
| --- | --- |
| PASSWORD | secretKeyRef `env-secrets` key `PASSWORD` (secret `env-secrets` defined with empty PASSWORD) |

## Persistence
- `config` enabled, mountPath `/config`.

## Probes
- None declared in values.yaml.

## Security context (chart)
- runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Gotchas
- Chart targets 8080 (the HTTP GUI port); HTTPS 8181 is not exposed by the chart.
- Chart uses rolling `latest` tag (digest pinned). Chart appVersion is `latest`.
