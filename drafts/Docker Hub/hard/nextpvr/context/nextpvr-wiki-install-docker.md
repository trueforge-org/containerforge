# NextPVR wiki: Install-Docker

**Source:** https://github.com/sub3/NextPVR/wiki/Install-Docker (fetched via https://raw.githubusercontent.com/wiki/sub3/NextPVR/Install-Docker.md, 2026-11-26)

## Images / tags
| Image | Target |
|---|---|
| nextpvr/nextpvr_amd64:stable | PCs, some NAS |
| nextpvr/nextpvr_arm32v7:stable | RPi-type devices |

## Run (amd64 example)
```
docker run -d \
  --volume <host>/config:/config \
  --volume <host>/videos:/recordings \
  --volume <host>/videos:/buffer \
  --publish 8866:8866 \
  nextpvr/nextpvr_amd64:stable
```
- Compose: none on page.

## Ports
- 8866 (NextPVR web/API, host:container 1:1).
- Legacy HDHomeRun: `--publish 8020-8030:8020-8030/udp`

## Volumes (container)
| Path | Purpose |
|---|---|
| /config | NextPVR config data (must be bind-mapped) |
| /recordings | recordings |
| /buffer | buffer |
- Optional time sync: `--volume /etc/localtime:/etc/localtime:ro`

## Env vars
- HOST_IP: host LAN IP (example 192.168.1.51); needed for legacy HDHomeRun.

## Devices
- Local PCIe/USB tuner: `--device /dev/dvb:/dev/dvb`
- GPU: not mentioned.

## Other
- User/UID: not specified. Healthcheck: not mentioned.
- Web UI: http://HOST_IP:8866/index.html; default login admin/password (change before exposing).
