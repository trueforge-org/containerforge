# alturismo/guide2go: README (master)
Source URL: https://raw.githubusercontent.com/alturismo/guide2go/master/README.md (fetched 2026-11-26, 44 lines)

- Docker wrapper around mar-mei/guide2go (XMLTV EPG grabber for Schedules Direct) with a cron job.
- Mounts: /config (config, rw), /guide2go (EPG yaml/xml/json, rw), /TVH (optional TVHeadend data).
- Run example: `docker run -d --name=guide2go -e TZ="Europe/Berlin" -v <cfg>:/config -v <data>:/guide2go alturismo/guide2go`
- Setup: `docker exec -it <name> guide2go -configure /guide2go/<name>.yaml`
- Test cron: `docker exec -it <name> ./config/cronjob.sh`
- Config persists in mounted folders; cron options refreshed on restart.
- Optional: Emby/Plex/TVH/xTeVe hooks in cronjob.sh.
