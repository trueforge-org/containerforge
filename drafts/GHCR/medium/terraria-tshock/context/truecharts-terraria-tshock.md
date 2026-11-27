# TrueCharts chart: terraria-tshock (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/terraria-tshock/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `terraria-tshock` v12.0.0, library `common` 32.8.5, appVersion `tshock`, category GameServers.
- Description: SteamCMD Terraria and the TShock mod.

## Image (values.yaml)
- repository: `ghcr.io/ich777/terrariaserver`
- tag: `tshock@sha256:fc949561109bbb80c291e288cdbde8e17e432423a77bcf71aa2a5b12954805f4`
- pullPolicy: IfNotPresent

## Ports
| service | name | port | targetPort | proto |
| --- | --- | --- | --- | --- |
| main | main | 9014 | 8080 | http |
| tcp | tcp | 7777 | (default) | tcp (enabled) |

## Persistence
| name | mountPath |
| --- | --- |
| serverfiles | /serverdata/serverfiles |

## Terraria values (chart `terraria:` block, consumed via envFrom secret `terraria-secret`)
| key | value |
| --- | --- |
| autocreate | "1" |
| easy_game_params.noupnp | true |
| easy_game_params.secure | false |
| easy_game_params.steam | false |
| game_params | [] |
| lang | en-US |
| maxplayers | 16 |
| pass | secretpass |
| seed | AwesomeSeed |
| worldname | scale terraria |

- Container uses `envFrom: secretRef: terraria-secret` (env values not set directly in values.yaml).

## Security context (chart values)
- readOnlyRootFilesystem: false, runAsGroup 0, runAsUser 0.

## Other
- Chart sources: ghcr.io/ich777/terrariaserver, tshock.co.
