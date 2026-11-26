# ispysoftware/agentdvr-docker (official image repo)

Source URL(s): https://github.com/ispysoftware/agentdvr-docker. Fetched 2026-11-26.

## Images / tags
- Published: Docker Hub `ispysoftware/agentdvr`, GHCR `ghcr.io/ispysoftware/agentdvr`.
- Platforms: linux/amd64, linux/arm64, linux/arm/v7 (one multi-arch manifest per tag).
- Tags: `stable`, `latest`, `beta`, pinned `8.3.2.0`, pinned beta `8.3.3.0-beta`, dated build tags. Pinned tags exist from 7.9.4.0.
- 7.9.4.0: first official release (bundles LGPL FFmpeg 9).
- Base: Debian Trixie (since 6.6.2.0); custom base `github.com/ispysoftware/ispyagentdvr-base-image`.
- Repo files: `.agentdvr-version`, `DockerfileModifier.sh`, `CUDA-ACCELERATION.md`.
- armhf FFmpeg from Debian SID. Images use ZSTD (6.5.7.0+ needs Docker 23.0+).

## Run
- Compose: service/container `ispyagentdvr`, image `ispysoftware/agentdvr:latest`, `restart: unless-stopped`.
- Install script: `https://www.ispyconnect.com/docker/linux/install-agentdvr.sh`.
- macvlan option supported. Pi: ~30 s startup; Pi 5 use Ubuntu host.

## Env
| Var | Default | Notes |
| --- | --- | --- |
| PUID | 1000 | run-as user |
| PGID | 1000 | run-as group |
| AGENTDVR_WEBUI_PORT | 8090 | in-container UI port |
| TZ | Europe/London | tz database name |
| NVIDIA_VISIBLE_DEVICES | all | Nvidia, with `--runtime=nvidia` |
| AGENT_TRUSTED_PROXIES | - | from 8.2.4.0 (per changelog) |

## Ports
- 8090/tcp UI; 3478/udp TURN; 50000-50100/udp WebRTC.

## Volumes
- `/AgentDVR/Media/XML` config; `/AgentDVR/Media/WebServerRoot/Media` recordings; `/AgentDVR/Models` AI models (required from 7.2.0.0.0); `/AgentDVR/Commands`.
- App dir `/AgentDVR` (reverted from `/home/agentdvr/AgentDVR` in 6.6.2.0).

## Hardware acceleration (5.3.5.0+)
- Intel: `/dev/dri/renderD128`, `/dev/dri/card0`. AMD: same + `/dev/kfd`. Nvidia: host drivers + Nvidia Container Toolkit.
- Audio: `group_add audio`, `/dev/snd:/dev/snd`.

## Other
- Config format XML -> JSON at 5.8.4.0.
- Logs: `<ip>:<port>/logs.html`.
- Licence GPL-3.0. Bundles LGPL FFmpeg; GPL build (x264/x265) downloaded in-app to config volume.
