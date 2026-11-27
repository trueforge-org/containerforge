# TrueCharts chart: dontstarvetogether

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dontstarvetogether/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dontstarvetogether/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `dontstarvetogether` version 11.0.0, appVersion `dontstare`, train stable.
- Description: installs SteamCMD, then installs and runs Don't Starve Together.
- Chart sources: `https://ghcr.io/ich777/steamcmd`, the TrueCharts chart dir, https://www.klei.com/games/dont-starve-together.
- Dependency: `common` 32.8.5 (per chart; same as dayz).

## Image
| Key | Value |
| --- | --- |
| repository | `ghcr.io/ich777/steamcmd` (GHCR) |
| tag | `dontstarve@sha256:e44a30b09306bc16d29f306f282b7a72c567eb7f8b6f1e36ff7ecfb378b1dfc6` |
| pullPolicy | IfNotPresent |

## Runtime env (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| CAVES | "true" |
| FORCE_X64 | "true" |
| GAME_ID | "343050" |
| PASSWRD | secretKeyRef `env-secrets`/`PASSWRD` (empty default) |
| USERNAME | "" |
| VALIDATE | "false" |

## Ports
| Name | Port | Protocol | Target |
| --- | --- | --- | --- |
| main | 10890 | udp | 10890 |
| authentication | 8766 | udp | 8766 |
| masterserver | 27016 | udp | 27016 |

The draft's 10999/10998/27016 are not in the chart. The chart's ports are used here.

## Volumes
| Persistence | mountPath |
| --- | --- |
| serverfiles | /serverdata/serverfiles |
| steamcmd | /serverdata/steamcmd |
| token | /serverdata/.klei/DoNotStarveTogether |

## Security context
- readOnlyRootFilesystem: false, runAsUser 0, runAsGroup 0.

## Probes
- liveness, readiness, startup all `enabled: false`.

## Gotchas
- `GAME_ID=343050` is the dedicated server app ID the chart uses. The store check for 343050 failed (see README), so the chart value is the only source for it.
- Token path `/serverdata/.klei/DoNotStarveTogether` is the Klei cluster token location used by the chart.
- `CAVES=true` and `FORCE_X64=true` are chart env values; their upstream meaning is not confirmed by any fetched source.
