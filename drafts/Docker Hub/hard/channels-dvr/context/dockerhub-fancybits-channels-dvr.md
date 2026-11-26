# hub.docker.com/r/fancybits/channels-dvr (draft "Container image")

Source URL(s) + fetch date:
- https://hub.docker.com/r/fancybits/channels-dvr · fetched 2026-11-26

## What it is
"Flexible, standalone" Channels DVR Server image, publisher fancybits. 1M+ pulls. Updated 21 days before fetch. Size 6.2 MB (page). Only `latest` tag listed (digest `sha256:8b430c586…`). The page does not mention a `tve` tag; the TrueCharts chart uses `tve` (digest `4d491658…`).

## Architectures
Not stated on the page.

## Run example
- `docker` command (no `run` subcommand shown): `--detach --name=channels-dvr --restart=unless-stopped --net=host --device /dev/dri:/dev/dri -v <config>:/channels-dvr -v <recordings>:/shares/DVR fancybits/channels-dvr:latest`.
- Compose: image `fancybits/channels-dvr:latest`, container `channels-dvr`, `network_mode: host`, port `8089:8089` listed, restart `unless-stopped`, same devices and volumes.
- Pull: `docker pull fancybits/channels-dvr`.

## Env / base
No env vars listed. Base image not stated.

## Notes
- Host networking is required for Bonjour discovery by the Channels apps.
- Docker for Mac and Docker for Windows do not support host networking; connect by IP in the app's Settings tab.
- Storage guidance: about 8 GB per hour of HDTV; 2 TB holds over 250 hours.
- Support: community.getchannels.com and getchannels.com/support.

## Tve variant
Per getchannels-dvr-server.md / TrueCharts values: `:tve` tag is for TV Everywhere. Its contents (chromium/xvfb requirements) are not separately documented here.
