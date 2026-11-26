# doitandbedone/ispyagentdvr-docker README

Source URL(s): https://raw.githubusercontent.com/doitandbedone/ispyagentdvr-docker/master/README.md (repo: https://github.com/doitandbedone/ispyagentdvr-docker). Fetched 2026-11-26.

## What
- Community (unofficial) image of iSpy Agent DVR. Project is archived; official image is at ispyconnect.com.

## Ports
- 8090/tcp web UI; 3478/udp TURN; 50000-50100/udp WebRTC media.

## Volumes
- `/agent/Media/XML/` config; `/agent/Media/WebServerRoot/Media/` media; `/agent/Commands` custom commands.

## Env
- `TZ` only (example `America/Los_Angeles`). No PUID/PGID/user/device settings mentioned.

## Run example
```
docker run -it -p 8090:8090 -p 3478:3478/udp -p 50000-50100:50000-50100/udp \
  -v /appdata/ispyagentdvr/config/:/agent/Media/XML/ \
  -v /appdata/ispyagentdvr/media/:/agent/Media/WebServerRoot/Media/ \
  -v /appdata/ispyagentdvr/commands:/agent/Commands/ \
  -e TZ=America/Los_Angeles --name ispyagentdvr doitandbedone/ispyagentdvr
```

## Tags
- No tag = latest; versioned tags (e.g. `2.7.6.0`); `vlc` tag adds VLC (libvlc-dev, vlc, libx11-dev).

## Networking
- Bridge networking supported from 2.8.4.0 (bundled TURN); UDP ports must be published.

## Migration
- Old separate audio/video volumes must be moved into a single media folder.

## Hardware accel
- Not covered.
