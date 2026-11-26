# H2CK/twonkyserver README (summary)

Source URL: https://raw.githubusercontent.com/H2CK/twonkyserver/a4d34f54e62617b359df5bf8dd745e4742d74c2e/README.md (fetched 2026-11-26)

## What it is
- Docker image bundling TwonkyMedia Server (TMS), a DLNA/UPnP AV media server (PacketVideo).
- Serves HTML/RSS/JSON front ends for non-UPnP devices.
- Includes static ffmpeg (johnvansickle) for thumbnails and transcoding.
- Requires a valid TwonkyMedia license.

## Run
```
docker run -d --net=host --name=twonkyserver -v /path/to/config:/config:rw -v /path/to/data:/data:ro -v /etc/localtime:/etc/localtime:ro dtjs48jkt/twonkyserver
```
- `--net=host` needed for DLNA.
- Web config: `http://server:9000/webconfig`.

## Env
| Var | Effect |
| --- | --- |
| GROUP_ID | group used for volume permissions; host data dir should be owned by that group |
| UPDATE_ON_START=TRUE | apt update/upgrade on every container start (slower start) |

## Volumes
- `/config` (rw): Twonky config.
- `/data` (ro in example): media.
- `/etc/localtime` (ro): time.

## Notes
- No UID documented. No healthcheck documented.
- Version history: TMS 8.5.2 / ffmpeg 4.3.2 latest entry (30.03.2021). Base moved to Ubuntu 20.04 (06.01.2020).
- README says base "Ubuntu Bionic" in the description; Dockerfile itself is `ubuntu:20.04` (conflict, Dockerfile is authoritative).
