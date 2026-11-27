# TrueCharts chart: audacity

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/audacity/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `audacity`, appVersion 3.0.2, train stable, category media.
- Description: "An easy-to-use, multi-track audio editor and recorder".
- Dependency: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`); kubeVersion `>=1.33.0-0`.

## Image (values.yaml)
| Key | Value |
| --- | --- |
| repository | `ghcr.io/linuxserver/audacity` |
| tag | `version-3.0.2@sha256:cdf203db1e50e18349f16c5958f7061b18625501f5e2f7a15cd69262185e3e84` |
| pullPolicy | IfNotPresent |

## Ports
| Name | port | targetPort | protocol |
| --- | --- | --- | --- |
| main | 10032 | 3000 | http |

- Chart targets 3000; upstream master Dockerfile EXPOSEs 3001 (see dockerfile file).

## Probes
- liveness, readiness, startup: `http` on `/`.

## Persistence
- `config` enabled, mountPath `/config`.

## Env
- `env: {}` (none set in chart).

## Security context (chart)
- runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Gotchas
- Chart pins the 3.0.2 image; the current Hub tags are 4.0.x (see dockerhub file).
- Chart port 3000 vs upstream 3001: mismatch to resolve when porting.
