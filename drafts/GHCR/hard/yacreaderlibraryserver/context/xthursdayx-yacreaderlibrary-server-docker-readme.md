# xthursdayx/yacreaderlibrary-server-docker (README)

Source URL(s) + date: https://raw.githubusercontent.com/xthursdayx/yacreaderlibrary-server-docker/f1d5f1b9e32bc19d6ac06873e071ff67f332388a/README.md (fetched 2026-11-27)

## Tags / backends
- `7zip` (default, `latest`): 7-Zip 23.01; RAR5 and 7z support.
- `libarchive`: no non-free code; zip, rar (RAR5 with limits), 7z.
- `unarr` retired; tag points to libarchive image.
- Multi-arch: amd64 (x86-64) and arm64.

## Run options (README)
| Option | Meaning |
| --- | --- |
| -p 8080 | HTTP web UI |
| -e PUID=99 | user id (README example) |
| -e PGID=100 | group id (README example) |
| -e TZ=America/New_York | timezone |
| -v /config | config and log files |
| -v /comics | comic library (must be readable by PUID) |

- Container takes ownership of `/config` and `.yacreaderlibrary` folders; does not change comics ownership.
- Library setup via `docker exec -u abc <name> YACReaderLibraryServer create-library <name> /comics`, `add-library`, `update-library /comics`.
- Updates at startup/periodic/scheduled set in `http://SERVERIP:8080/webui/settings`.
- Web UI: `http://SERVERIP:8080`.
- No authentication built in; do not expose outside home network.

## Gotchas
- Exec user shown as `abc` (linuxserver s6 user model).
