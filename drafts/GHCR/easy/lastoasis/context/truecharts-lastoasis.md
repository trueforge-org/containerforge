# TrueCharts lastoasis chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/lastoasis/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/lastoasis/values.yaml
- Fetched 2026-11-26

## What it is
TrueCharts Helm chart `lastoasis` v11.0.0 (appVersion `lastoasis`). Downloads SteamCMD and installs/runs Last Oasis. Category GameServers. Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts).

## Runtime deps
- Image: `ghcr.io/ich777/steamcmd`, tag `lastoasis@sha256:3fc50601fca68342e3df2c237fa3ae23b44ba979bf506b07b98ab62c31ac8988`, pullPolicy IfNotPresent.
- Chart sources list: ghcr.io/ich777/steamcmd, store.steampowered.com.

## Entrypoint/flags
- Not set in chart (image entrypoint used). GAME_PARAMS env: `-port=5555 -QueryPort=27015 -NoLiveServer -EnableCheats`.

## Env vars (chart defaults)
| Name | Value |
| --- | --- |
| GAME_ID | "920720" |
| GAME_PARAMS | `-port=5555 -QueryPort=27015 -NoLiveServer -EnableCheats` |
| IDENTIFIER | dockeroasis |
| SLOTS | "20" |
| USERNAME | "" |
| VALIDATE | "false" |
| PASSWRD | secretKeyRef env-secrets/PASSWRD (chart default "") |
| CUSTOMER_KEY | secretKeyRef env-secrets/CUSTOMER_KEY (chart secret default present; value not recorded) |
| PROVIDER_KEY | secretKeyRef env-secrets/PROVIDER_KEY (chart secret default present; value not recorded) |

## Ports
- service.main `main`: 5555/udp (target 5555).
- service.queryport `queryport`: 27015/udp (target 27015), enabled.

## Volumes/paths
- persistence.serverfiles: mountPath `/serverdata/serverfiles` (enabled).
- persistence.steamcmd: mountPath `/serverdata/steamcmd` (enabled).

## User/UID
- securityContext.container: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Healthcheck/probes
- liveness, readiness, startup all `enabled: false`.

## Version/asset naming
- Chart version 11.0.0. Image pinned by digest with `lastoasis` tag prefix.

## Gotchas
- Chart runs as root with writable rootfs (ich777 image design).
- Chart secret block `env-secrets` ships non-empty default values for CUSTOMER_KEY and PROVIDER_KEY (do not copy into docs).
