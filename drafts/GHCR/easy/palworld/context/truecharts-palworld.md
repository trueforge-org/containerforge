# TrueCharts palworld (chart 9.0.0, appVersion "palworld")

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/palworld/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- "A custom SteamCMD chart that runs Palworld."
- Chart sources: ghcr.io/ich777/steamcmd, github.com/ich777/docker-steamcmd-server (palworld branch), truecharts palworld tree.
- Category GameServers, train stable, not deprecated.
- Kubernetes >=1.33.0-0 (max 1.35.0); Helm min 3.14, max 4.1.
- Dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
| Field | Value |
| --- | --- |
| Repository | ghcr.io/ich777/steamcmd |
| Tag | palworld (digest pinned) |
| Pull policy | IfNotPresent |

## Ports (service, no container ports defined)
| Service | Protocol | Port | Note |
| --- | --- | --- | --- |
| main | UDP | 8211 | game port |
| api | TCP | 8212 | REST API (enabled) |
| rcon | TCP | 25575 | RCON (enabled) |

- GAME_PARAMS passes -port=8211 -publicport=8211 -rconport=25575.

## Resources
- limits cpu 4000m, memory 6000Mi; requests cpu 400m, memory 1000Mi.

## Env vars (chart values)
| Var | Value |
| --- | --- |
| STEAMCMD_DIR | /serverdata/steamcmd |
| SERVER_DIR | /serverdata/serverfiles |
| GAME_ID | 2394010 |
| USERNAME | "" |
| PASSWRD | secretKeyRef env-secrets/PASSWRD (empty default) |
| VALIDATE | false |
| SRV_ADMIN_PWD | secretKeyRef env-secrets/SRV_ADMIN_PWD (default TrueChartsIsAHelmProject) |
| UPDATE_PUBLIC_IP | false |
| GAME_PARAMS | -port=8211 -publicport=8211 -rconport=25575 -publiclobby |
| GAME_PARAMS_EXTRA | -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS |
| BACKUP | true |
| BACKUP_INTERVAL | 120 |
| BACKUP_TO_KEEP | 12 |

## Game settings (palworld.game defaults, written to PalWorldSettings.ini)
| Key | Default |
| --- | --- |
| ServerName | TrueCharts Palworld Server |
| ServerDescription | A Palworld Server running in Kubernetes |
| ServerPassword | "" |
| AdminPassword | TrueChartsIsAHelmProject |
| bUseAuth | true |

## Secret
- env-secrets: PASSWRD <- palworld.steam.password; SRV_ADMIN_PWD <- palworld.game.AdminPassword.

## Persistence
| Name | Enabled | Mount |
| --- | --- | --- |
| steamcmd | true | /serverdata/steamcmd |
| serverfiles | true | /serverdata/serverfiles |

## Probes (main container)
- liveness, readiness, startup: all tcp on port 25575 (rcon).

## Init container update-config-ini
- type init, imageSelector image, command `/bin/sh -c`.
- Config dir `<serverfiles>/Pal/Saved/Config/LinuxServer`; file `PalWorldSettings.ini`.
- If missing: copy DefaultPalWorldSettings.ini from server files, else wget from ich777 docker-steamcmd-server palworld branch.
- Forces: RCONEnabled=True, RCONPort=25575, PublicPort=8211, RESTAPIEnabled=True, RESTAPIPort=8212.
- Ends with "Done!".

## securityContext
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Gotchas
- Chart default AdminPassword is a placeholder; must be overridden.
- Probes use RCON port 25575, not the game port.
