# TrueCharts chart: calibre

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/calibre/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `calibre` version 22.0.1, appVersion 9.19.0, train stable, category media.
- Description: "Calibre is a powerful and easy to use e-book manager."
- Dependency: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`); kubeVersion `>=1.33.0-0`.

## Image (values.yaml)
| Key | Value |
| --- | --- |
| repository | `ghcr.io/linuxserver/calibre` |
| tag | `9.19.0@sha256:bbf2b494238d83b51e947e9588d03e19053cd74aaa933a7db89f96ed42cc2d43` |
| pullPolicy | IfNotPresent |

## Ports
| Name | port | targetPort | protocol |
| --- | --- | --- | --- |
| main | 8084 | 8080 | tcp |
| webserver (enabled) | 8081 | 8081 | http |

- Ingress for webserver: disabled.

## Env
| Env | Source |
| --- | --- |
| CLI_ARGS | empty value |
| PASSWORD | secretKeyRef `env-secrets` key `PASSWORD` (secret with empty PASSWORD) |

## Persistence
- `config` enabled, mountPath `/config`.

## Probes
- None declared in values.yaml.

## Security context (chart)
- runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Gotchas
- Chart targets 8080 (GUI HTTP per linuxserver README) and 8081 (calibre webserver, opt-in in GUI settings).
