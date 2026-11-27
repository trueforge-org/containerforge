# TrueCharts chart: americasarmy-pg

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/americasarmy-pg/Chart.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/americasarmy-pg/values.yaml (2026-11-27)

## What it is
- Chart `americasarmy-pg` v11.0.0, `appVersion: aaproinggrounds`, category GameServers, train stable.
- Description: downloads and installs SteamCMD, then installs America's Army: Proving Grounds and runs it.
- Library dep: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
- `ghcr.io/ich777/steamcmd`
- tag `aaprovinggrounds@sha256:b9b693febffdd4ed02c97dc1ecfd11f2f1b0de6e3ff77eea64b686c05097c3fc`
- Note: tag spelled `aaprovinggrounds` (chart appVersion `aaproinggrounds`, different spelling).
- pullPolicy IfNotPresent

## Env vars
| Name | Value |
| --- | --- |
| GAME_ID | "203300" (Steam app ID) |
| GAME_PARAMS | `-port=7778 -SAP=8778 -SQP=27015 -aauregion=1 -log=Server.log` |
| PASSWRD | secretKeyRef `env-secrets` key `PASSWRD` (default "") |
| SRV_NAME | `Army Docker` |
| USERNAME | "" (anonymous) |
| VALIDATE | "false" |

## Ports
| Service | Port | Protocol | targetPort | Role |
| --- | --- | --- | --- | --- |
| main | 8778 | udp | 8778 | SAP (per GAME_PARAMS -SAP) |
| steamqueryport (enabled) | 27015 | udp | 27015 | SQP (per -SQP) |

- Game port 7778 from `-port=7778`: not in the chart service block; protocol not stated in the chart.

## Volumes / paths
- `/serverdata/serverfiles` (persistence `serverfiles`)
- `/serverdata/steamcmd` (persistence `steamcmd`)

## Probes
- Liveness, readiness, startup all disabled (`enabled: false`).

## Security context
- `readOnlyRootFilesystem: false`, `runAsGroup: 0`, `runAsUser: 0`.

## Gotchas
- Chart has no TCP probes (game is UDP only in chart).
- Draft's 8777/udp is not in the chart (per plan).
