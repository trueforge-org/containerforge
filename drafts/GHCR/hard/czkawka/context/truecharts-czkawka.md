# TrueCharts chart: czkawka

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/czkawka/values.yaml and .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `czkawka` version 17.1.1, appVersion 26.11.2, train stable, category duplicates.
- Image: `ghcr.io/jlesage/czkawka` tag `v26.11.2@sha256:98ac101b46ebff18503f43cef82dc7f1eb0c7ce46e80581f3b43ddf2158e0dd0`, pullPolicy IfNotPresent.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion >=1.33.0-0.

## Ports
| Name | Container port | Protocol | Service port |
| --- | --- | --- | --- |
| main (web GUI) | 5800 | http | 10258 |
| vnc (enabled) | 5900 | tcp | 10259 |

## Env vars (chart-set)
| Var | Value |
| --- | --- |
| KEEP_APP_RUNNING | from `czkawka.KEEP_APP_RUNNING` (false -> "0") |
| DISPLAY_WIDTH | 1280 |
| DISPLAY_HEIGHT | 768 |
| SECURE_CONNECTION | from `czkawka.SECURE_CONNECTION` (false -> "0") |
| ENABLE_CJK_FONT | from `czkawka.ENABLE_CJK_FONT` (false -> "0") |
| VNC_PASSWORD | secret `env-secrets` key `VNC_PASSWORD` (empty default) |

## Volumes/paths
| Persistence | Mount path | Enabled |
| --- | --- | --- |
| config | /config | yes |
| storage | /storage | yes |
| trash | /trash | yes |
| varrun | (n/a) | no |

## User/UID
- securityContext.container: runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.
- Container capabilities add: NET_BIND_SERVICE, KILL.

## Probes
- liveness, readiness, startup: all `type: http`, path `/`.

## Gotchas
- Chart mounts trash at `/trash`, but upstream README says trash lives at `/config/xdg/data/Trash` (see github-jlesage-docker-czkawka-readme.md).
- Chart tag is v26.11.2; plan.md draft uses v26.09.2 (see README.md in this folder for the conflict).
- Chart sets `KEEP_APP_RUNNING` and `SECURE_CONNECTION` via ternary on booleans.
