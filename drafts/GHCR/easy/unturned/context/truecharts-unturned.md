# TrueCharts chart: unturned

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/unturned/values.yaml and .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `unturned` v12.0.0, appVersion `unturned`. Description "Unturned SteamCMD". Category GameServers.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion >=1.33.0-0.

## Image (values.yaml)
- repository: `ghcr.io/ich777/steamcmd`
- tag: `unturned@sha256:7aad70045a425c8f14262305b0f5e5d7832bc8e930be8b61c1c2e3e193972840` (tag is the `unturned` branch image)
- pullPolicy: IfNotPresent

## Runtime security
- runAsNonRoot: false; runAsUser 0; runAsGroup 0; readOnlyRootFilesystem: false

## Ports
| name | port | protocol | enabled |
| --- | --- | --- | --- |
| main | 27015 | udp | true |
| steam | 27016 | tcp | true |

## Persistence
| name | mountPath |
| --- | --- |
| serverfiles | /serverdata/serverfiles |
| steamcmd | /serverdata/steamcmd |

## Env vars (chart values)
| Env | Value |
| --- | --- |
| GAME_PORT | "{{ .Values.service.main.ports.main.port }}" (27015) |
| GAME_ID | "1110390" (Unturned Dedicated Server) |
| USERNAME | "" |
| PASSWRD | secretKeyRef env-secrets/PASSWRD |
| ROCKET_FORCE_UPDATE | "" |
| ROCKET_MOD | "" |
| ROCKET_URL | https://ci.rocketmod.net/job/Rocket.Unturned/lastSuccessfulBuild/artifact/Rocket.Unturned/bin/Release/Rocket.zip |
| VALIDATE | false |

Secret `env-secrets` (enabled) PASSWRD "".

## Probes
- liveness, readiness, startup all disabled.

## Gotchas
- Chart sets ROCKET_MOD to "" (empty), overriding the branch Dockerfile default "true"; Rocket is not installed unless set to "true".
- Chart sets VALIDATE: false (YAML boolean; script compares to string "true").
- Port 27016/tcp is exposed in chart but not referenced in the fetched start-server.sh.
