# TrueCharts chart: survivethenights

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/survivethenights/values.yaml and .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `survivethenights` v11.0.0, appVersion `stn`. Description: downloads and installs SteamCMD, then installs and runs Survive The Nights.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts). Category GameServers. kubeVersion >=1.33.0-0.

## Image (values.yaml)
- repository: `ghcr.io/ich777/steamcmd`
- tag: `stn@sha256:c5f785056413fe133dafe2611fd50e5097da49a38cf625afa9bf36a00d5ee12d`
- pullPolicy: IfNotPresent
- Note: the `stn` tag is not in the cached upstream `master` Dockerfile summary; the stn variant is a separate build.

## Runtime security (values.yaml)
- readOnlyRootFilesystem: false; runAsUser 0; runAsGroup 0

## Persistence (values.yaml)
| Name | mountPath |
| --- | --- |
| serverfiles | /serverdata/serverfiles |
| steamcmd | /serverdata/steamcmd |

## Ports
| name | port | protocol |
| --- | --- | --- |
| main | 7950 | udp |

## Env vars (chart values)
| Env | Value |
| --- | --- |
| DEBUG_OUTPUT | "false" |
| GAME_ID | "1502300" |
| GAME_PARAMS | "" |
| PASSWRD | secretKeyRef env-secrets/PASSWRD |
| USERNAME | "" |
| VALIDATE | "false" |

Secret `env-secrets` (enabled) with PASSWRD "".

## Probes
- liveness, readiness, startup all disabled.

## Gotchas
- `DEBUG_OUTPUT` is not defined in the cached ich777 master Dockerfile/scripts summary; treat as stn-branch specific (unverified).
- GAME_ID 1502300 (chart) differs from the Steam store app 541300 that the chart lists in sources (see steam-store-541300.md). Unverified which ID is the dedicated server.
