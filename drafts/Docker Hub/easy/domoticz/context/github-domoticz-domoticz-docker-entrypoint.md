# domoticz/domoticz-docker docker-entrypoint.sh (master)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/domoticz/domoticz-docker/master/docker-entrypoint.sh (the name used by the Dockerfile COPY; `entrypoint.sh` returned 404) · 2026-11-26

## Command
- Base args always: `-www $WWW_PORT -noupdates -sslwww $SSL_PORT -userdata /opt/domoticz/userdata`.
- Appends `-log $LOG_PATH` if set, `-dbase $DATABASE_PATH` if set, and `$EXTRA_CMD_ARG` as-is.
- If `$1` is `/opt/domoticz/domoticz`: `exec "$@" $CMD_ARGS`; otherwise `exec "$@"`.

## Self-repair (rsync -airp, every start)
1. `/opt/domoticz/plugins/examples` -> `$USERDATA/plugins`, `--ignore-existing --mkpath`.
2. Each `/opt/domoticz/plugins/*/` except `examples` -> `$USERDATA/plugins`, `--update --mkpath --exclude '__pycache__' --exclude 'joulo-data'` (bundled plugins are UPDATED when the image is newer).
3. `/opt/domoticz/customstart.sh` -> `$USERDATA`, `--ignore-existing`.
4. `/opt/domoticz/www/templates` -> `$USERDATA/www`, `--ignore-existing --mkpath`.
5. `/opt/domoticz/scripts/dzVents/examples` -> `$USERDATA/scripts/dzVents`, `--ignore-existing --mkpath`.
- Then `chown -R 1000:1000 "$USERDATA"`.

## customstart.sh
- Runs once: if `/opt/domoticz/FIRSTRUN` is absent, sources `/opt/domoticz/userdata/customstart.sh`, then `touch /opt/domoticz/FIRSTRUN`.

## Notes vs plan.md
- plan.md's seed-when-missing for bundled plugins differs from upstream's `--update` for plugins: plan.md already documents this (copy-if-missing, users must delete the old directory to update).
- plan.md says upstream "rsyncs" customstart.sh; upstream copies it with `--ignore-existing` and sources it only on first start. plan.md leaves customstart out, which is consistent.
