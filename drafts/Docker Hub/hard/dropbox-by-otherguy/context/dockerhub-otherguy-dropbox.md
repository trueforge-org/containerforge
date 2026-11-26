# otherguy/dropbox (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/otherguy/dropbox
- Fetched 2026-11-26

## What it is
- "A container that runs the Dropbox client." Host folder mount or `--volumes-from` sharing. Descends from janeczku/dropbox. 500K+ pulls, 21 stars.
- Last updated: over 3 years before fetch (per page).

## Architectures and tags
- Not listed. Only `latest` shown (108.9 MB, digest `sha256:2ed2f9843...`).

## Run command (quickstart)
```
docker run --detach -it --restart=always --name=dropbox --net="host" \
  -e "TZ=$(readlink /etc/localtime | sed 's#^.*/zoneinfo/##')" \
  -e "DROPBOX_UID=$(id -u)" -e "DROPBOX_GID=$(id -g)" -e "POLLING_INTERVAL=20" \
  -v "/path/to/local/settings:/opt/dropbox/.dropbox" \
  -v "/path/to/local/dropbox:/opt/dropbox/Dropbox" otherguy/dropbox:latest
```
- Page's volume list: `/opt/dropbox/Dropbox` (synced files), `/opt/dropbox/.dropbox` (account and settings).
- Note: the wrapper repo README shows `/opt/dropbox` as the settings mount in its own quickstart. The two sources differ; the Hub page and the Dockerfile VOLUME (`/opt/dropbox`) are the ones compared here.

## Env vars
- DROPBOX_UID / DROPBOX_GID (default 1000), DROPBOX_SKIP_UPDATE, POLLING_INTERVAL (default 5), SKIP_SET_PERMISSIONS, TZ (strongly recommended).

## Ports
- None documented. `--net="host"` for LAN sync.

## Compose
- No compose example.

## Notes
- Linking: `docker logs --follow dropbox` for the auth URL.
- macOS mount not possible. Linux: `fs.inotify.max_user_watches` for more than 10,000 folders.
