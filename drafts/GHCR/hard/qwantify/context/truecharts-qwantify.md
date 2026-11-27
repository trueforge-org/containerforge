# TrueCharts chart: qwantify

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/qwantify/values.yaml , .../Chart.yaml · fetched 2026-11-27

## What it is
- Chart `qwantify` (appVersion 20.04.0), train stable, category games. Description: play games with friends from the browser.
- Dependency: `common` 32.8.5. kubeVersion >=1.33.0-0.

## Image
- repository: `ghcr.io/wanjohiryan/qwantify`
- tag: `20.04@sha256:008fae84dc4d9c80eeddb9b2dc2438c0ba92a8c3a3776835a7a24321f7ea6ce1` (pullPolicy IfNotPresent)

## Ports
| name | port | target | proto |
| --- | --- | --- | --- |
| main | 10603 | 8080 | http |

## Env (chart-set)
| var | value |
| --- | --- |
| APPFILE | /game.exe |
| APPPATH | /games |

## Persistence
| name | mountPath |
| --- | --- |
| games | /games |

## Security context (chart)
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Gotchas
- No probes or other env in values. The game binary is user-supplied (APPFILE), not shipped in the image.
