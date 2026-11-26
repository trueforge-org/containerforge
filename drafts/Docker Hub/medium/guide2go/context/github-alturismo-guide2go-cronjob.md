# alturismo/guide2go: cronjob.sh (master), key lines
Source URL: https://raw.githubusercontent.com/alturismo/guide2go/master/cronjob.sh (fetched 2026-11-26, 171 lines; only key parts recorded)

- Toggles: use_guide2go=yes, use_guide2goproxy=no, use_guide2gocache=yes, use_guide2goclean=yes, use_TVH_Play=no, use_TVH_move=yes
- Lineup yaml files in /guide2go are rewritten with sed: Cache: /guide2go/<name>_cache.json, XMLTV: /guide2go/<name>.xml, Hostname: xteve:8080 (guide2gohost/guide2goport), Proxy Images true/false
- images_path=/guide2go/images/
- TVHPATH=/TVH (copies XML to TVHeadend data dir when use_TVH_move=yes)
- Runs guide2go per yaml, pkill guide2go before run.
- Emby/Plex update blocks optional (API keys/tokens in script).
