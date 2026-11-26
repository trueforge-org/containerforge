# fyb3roptik/threadfin (Docker Hub image, not the upstream project image)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/fyb3roptik/threadfin (fetched 2026-11-26)

**What it is**
"Official Threadfin docker hub." Describes Threadfin as an M3U proxy for Plex, Emby, Jellyfin and similar clients that handle `.ts` and HLS streams, imitating an HDHomeRun OTA tuner. Page shows about 1M+ pulls and 29 stars.

**Tags**
- Only `latest` shown: digest `sha256:863fb0c29...`, about 284.9 MB, updated "about 1 year ago" (no exact date).
- The TrueCharts values pin `fyb3roptik/threadfin:1.2.37@sha256:96122ab220e14b881cbd40d7f8c7b022e1f9c6ecfe05aca2ab801e0321dc0d61`.

**Arch support**
No table. The description mentions a "Linux x86 64-bit build", so amd64 only is implied.

**Env vars shown**
- `THREADFIN_BRANCH=beta` (git branch; options truncated on the page)
- `THREADFIN_DEBUG=0` (0-3, default 0)
- `THREADFIN_PORT=34400`

**Ports**
34400 (example port set through `THREADFIN_PORT`). No port mapping snippet.

**Paths**
`THREADFIN_HOME=/home/threadfin`, `THREADFIN_BIN=/home/threadfin/bin`, `THREADFIN_CONF=/home/threadfin/conf`, data `/home/threadfin/conf/data`, backup `/home/threadfin/conf/backup`.

**Usage**
`docker pull fyb3roptik/threadfin`. No full `docker run` or compose example.

**Gotchas**
- Page says the image "runs as an unprivileged user". The upstream Dockerfile (`github-threadfin-threadfin.md`) has no `USER`, so this claim is unverified.
- Not the upstream project image; the upstream Dockerfile builds from source (see GitHub file).
