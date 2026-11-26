# jsavargas/telethon_downloader (Docker Hub image)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/jsavargas/telethon_downloader (fetched 2026-11-26)

**What it is**
"Telegram Bot on a Telethon client that auto downloads incoming media files." About 100K+ pulls and 20 stars at fetch time.

**Tags**
- Only `latest` was shown: digest `sha256:f9ad5f0ca...`, size about 586.6 MB, updated "27 days ago".
- No `4.0.x` tags were visible in the fetch. The TrueCharts values (see truecharts file) pin `latest@sha256:f9ad5f0caff72301cefddad3c9e866d064d627a7054b5fa8ae7b0d6d07de4af2`.

**Pull command**
`docker pull jsavargas/telethon_downloader`

**Arch support**
Not listed on the page.

**Env vars (as shown on the page)**
- `TG_AUTHORIZED_USER_ID`: authorized Telegram chat ID(s)
- `TG_API_ID`, `TG_API_HASH`: from my.telegram.org
- `TG_BOT_TOKEN`: from BotFather
- `TZ`: e.g. `America/Santiago`
- Optional `TG_MAX_PARALLEL` (default 4), `TG_DL_TIMEOUT` (default 3600), `YOUTUBE_LINKS_SOPORTED` (sic, default `youtube.com,youtu.be`)
- Compose example also sets `PUID`/`PGID` to 1000

**Volumes**
- `/download`: downloaded files
- `/watch`: torrent files (page says for Transmission)
- `/config`: in compose example

**Compose example**
```yaml
services:
  telethon_downloader:
    image: jsavargas/telethon_downloader
    network_mode: host
    environment: [PUID=1000, PGID=1000, TG_AUTHORIZED_USER_ID=..., TG_API_ID=..., TG_API_HASH=..., TG_BOT_TOKEN=..., TZ=America/Santiago]
    volumes: [/path/to/config:/config, /path/to/download/torrent/watch:/watch, /path/to/download:/download]
```

**Gotchas**
- Files are kept in a temporary directory until each download finishes.
- The page names `YOUTUBE_LINKS_SOPORTED` (typo in the page); the code reads no such variable (see GitHub file).
- No ports documented.
