# TrueCharts craftopia values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/craftopia/values.yaml (fetched 2026-11-27)

## What it is
Chart values for Craftopia dedicated server, using the ich777 SteamCMD wrapper image.

## Image
- repository: `ghcr.io/ich777/steamcmd`
- tag: `craftopia@sha256:175c652fb1bd256b254e8b35c4eb50a9b5a50356a1a2e6ae4a25883581701309` (branch-style tag `craftopia`, pinned digest)
- pullPolicy: IfNotPresent

## Env vars (table, workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| GAME_ID | `"1670340"` |
| GAME_PARAMS | `""` |
| USERNAME | `""` |
| PASSWRD | secretKeyRef `env-secrets` / `PASSWRD` |
| VALIDATE | `"false"` |

## Ports (service)
| Name | Port | Proto | Target |
| --- | --- | --- | --- |
| main | 8787 | tcp | 8787 |
| udpgameport (enabled) | 8787 | udp | 8787 |

## Volumes/paths (persistence)
- `serverfiles` enabled, mountPath `/serverdata/serverfiles`
- `steamcmd` enabled, mountPath `/serverdata/steamcmd`

## User/UID
- securityContext.container: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Secrets
- secret `env-secrets` with key `PASSWRD: ""`
- No probes block in values (chart defaults apply).
