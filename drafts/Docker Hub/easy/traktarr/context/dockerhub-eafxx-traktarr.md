# eafxx/traktarr (Docker Hub, third-party image)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/eafxx/traktarr (fetched 2026-11-26)

**What it is**
A third-party Docker image for Traktarr that runs app commands set through variables. Tagline "auto-update, multiarch & PUID/PGID support". About 5M+ pulls, image about 84.3 MB, last updated about 4 years ago. This is not the upstream `l3uddz` build; the TrueCharts chart uses it.

**Tags**
- `latest` (stable), `dev` (development/pre-release), `exp` (experimental). No per-tag dates.

**Arch support**
"multiarch" per the page; platforms not listed.

**Env vars (this image's own interface, not upstream)**
- `PUID`, `PGID`, `TZ`
- `DELAY` (seconds between add requests, default 2.5), `SORT` (votes/rating/release), `NOSEARCH`, `NOTIFICATIONS`, `BLACKLIST`, `RUNNOW`, `SKIPUPDATE` (default `no`), `APP_BRANCH` (`master` or `develop`, default `master`)
- Upstream's own `TRAKTARR_*` vars are not listed.

**Usage**
```
docker run -d --name='Traktarr' --net='bridge' \
  -e TZ="Europe/London" -e 'PUID'='99' -e 'PGID'='100' \
  -e 'DELAY'='' -e 'SORT'='rating' -e 'NOSEARCH'='yes' \
  -e 'NOTIFICATIONS'='yes' -e 'BLACKLIST'='yes' \
  -e 'RUNNOW'='no' -e 'SKIPUPDATE'='no' -e 'APP_BRANCH'='master' \
  -v '<path to data>':'/config':'rw' 'eafxx/traktarr:latest'
```
A compose example uses the same variables.

**Ports**
None listed.

**Volumes**
`/config` holds all configuration files.

**Notes**
- Needs a Trakt account and app, plus configured Sonarr/Radarr.
- On first run it creates `config.json` in `/config` and exits; then add Sonarr, Radarr and Trakt details and start/restart.
- The image auto-updates on container restart unless `SKIPUPDATE` is set. This is a feature of this image, not upstream.
- Upstream project readme: https://github.com/l3uddz/traktarr.

**Gotchas**
- The auto-update behaviour means the image's code can change at restart. ContainerForge plans pin to the tag, so this does not apply to our build.
- The first-run exit matches the plan's seed-and-stop behaviour.
