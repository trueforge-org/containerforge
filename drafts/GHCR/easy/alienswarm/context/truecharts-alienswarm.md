# TrueCharts chart: alienswarm

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/alienswarm/Chart.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/alienswarm/values.yaml (2026-11-27)

## What it is
- Chart `alienswarm` v11.0.0, `appVersion: alienswarm` (tag name, not SemVer), category GameServers, train stable.
- Description: installs SteamCMD and Alien Swarm, then runs it.
- Library dep: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- kubeVersion `>=1.33.0-0`; Helm 3.14 to 4.1; Kubernetes max 1.35.0.
- Sources listed: ghcr.io/ich777/steamcmd, steampowered.com.

## Image
- `ghcr.io/ich777/steamcmd`
- tag `alienswarm@sha256:cb63148af51062157b8e7968f53bcfcefc7a1478925cf64b5656ef4fd9f524bc`
- pullPolicy IfNotPresent

## Env vars (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| GAME_ID | "635" (Steam app ID) |
| GAME_NAME | swarm |
| GAME_PARAMS | `+map lobby -maxplayers 4 +exec server.cfg` |
| GAME_PORT | "27015" |
| PASSWRD | secretKeyRef `env-secrets` key `PASSWRD` (secret default "") |
| USERNAME | "" (anonymous) |
| VALIDATE | "false" |

## Ports
| Service | Port | Protocol | targetPort |
| --- | --- | --- | --- |
| main | 27015 | udp | 27015 |
| tcprconport (enabled) | 27015 | tcp | 27015 |

- Probes (liveness, readiness, startup) are all `type: tcp` on `tcprconport` targetPort 27015.

## Volumes / paths
| Persistence | mountPath |
| --- | --- |
| serverfiles | /serverdata/serverfiles |
| steamcmd | /serverdata/steamcmd |

## Security context
- `readOnlyRootFilesystem: false`, `runAsGroup: 0`, `runAsUser: 0`.

## Gotchas
- Two persistence volumes under `/serverdata` (matches ich777 DATA_DIR layout).
- Chart sets `GAME_*` names read by the ich777 start scripts; `STEAM_APP_IDS` naming not used here.
