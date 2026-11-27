# TrueCharts filebot values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/filebot/values.yaml (fetched 2026-11-27)

## Image
- repository: `ghcr.io/jlesage/filebot`
- tag: `v26.11.2@sha256:4f95dc1855a0ec141e673ddbc12c6b9613e4964321f7f90a7a8fe6af5f770059`
- pullPolicy: IfNotPresent

## Ports
| Service | Port | targetPort | Notes |
| --- | --- | --- | --- |
| main | 10268 | 5800 | noVNC web UI |
| vnc | 10269 | 5900 | VNC, enabled |

## Security context (chart)
- runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false
- container capabilities add: NET_BIND_SERVICE, KILL

## Env from configmap `filebot` (envFrom) and secret
- VNC_PASSWORD from secret `env-secrets` (empty default)
- Configmap keys map to env: KEEP_APP_RUNNING (0/1), DISPLAY_WIDTH 1280, DISPLAY_HEIGHT 768, SECURE_CONNECTION (0/1), ENABLE_CJK_FONT (0/1), OPENSUBTITLES_USERNAME, OPENSUBTITLES_PASSWORD, FILEBOT_CUSTOM_OPTIONS, AMC_INTERVAL 1800, AMC_INPUT_STABLE_TIME 10, AMC_ACTION "test", AMC_CONFLICT "auto", AMC_MATCH_MODE "opportunistic", AMC_ARTWORK (y/n), AMC_LANG "English", AMC_MUSIC_FORMAT / AMC_MOVIE_FORMAT / AMC_SERIES_FORMAT / AMC_ANIME_FORMAT "{plex}", AMC_PROCESS_MUSIC (y/n), AMC_SUBTITLE_LANG, AMC_CUSTOM_OPTIONS, AMC_INSTALL_PKGS, USE_FILEBOT_BETA (0/1)

## Probes
- liveness, readiness, startup: type tcp

## Persistence
| Name | mountPath |
| --- | --- |
| config | /config |
| storage | /storage |
| watch | /watch |
| output | /output |
| varrun | disabled |

## Gotchas
- Chart runs the GUI build (`FILEBOT_GUI=1` is the upstream default, not set in the chart's configmap). Headless AMC is the plan's choice.
- Chart tag is v26.11.2, newer than the v26.09.2 wrapper Dockerfile that the plan reviews.
