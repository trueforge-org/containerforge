# wiedehopf/tar1090 README (summary)

Source URL: https://raw.githubusercontent.com/wiedehopf/tar1090/master/README.md (fetched 2026-11-26)

## What it is
- Web front end for ADS-B decoders (readsb or dump1090-fa; dump1090-mutability works with fewer details). Does not replace the decoder.
- Install/update: `sudo bash -c "$(wget -nv -O - https://github.com/wiedehopf/tar1090/raw/master/install.sh)"`; config kept on update. Uninstall: `uninstall.sh`.
- No separate build step.

## Dependencies
- Debian/Ubuntu/Raspbian with apt. Needs readsb or dump1090-fa running.
- Web server: lighttpd or nginx.
- Optional: wiedehopf readsb fork (globe history/heatmap), dump978-fa/skyaware978 (UAT), AIS-catcher, zstddec-tar1090.

## Config
| Path | Purpose |
| --- | --- |
| /etc/default/tar1090 | INTERVAL, HISTORY_SIZE, PTRACKS, ENABLE_978, URL_978; apply with `systemctl restart tar1090` |
| /usr/local/share/tar1090/html/config.js | UI settings (remove leading `//` to enable); delete + reinstall restores defaults |
| /etc/default/tar1090_instances | one per line: `source-dir name`; name `webroot` serves at `/` |
| /etc/default/tar1090-<name> | per-instance config |
| /usr/local/share/tar1090/html-<name> | per-instance HTML |

- History duration = INTERVAL x HISTORY_SIZE.
- Receiver location is set in the decoder, not tar1090.

## Paths / ports
- Default URL: `http://<ip>/tar1090`; lighttpd default port 8504.
- nginx: include `/usr/local/share/tar1090/nginx-tar1090.conf` in server block.
- Web root: `/usr/local/share/tar1090/html`.
- Input: decoder run dir with aircraft.json (`/run/readsb`, `/run/dump1090-fa`, `/run/combine1090`, `/run/skyaware978`).
- Own run dir: `/run/tar1090` (history snapshots).
- Aircraft DB: `/usr/local/share/tar1090/aircraft.csv.gz` (readsb `--db-file`).
- Globe history (readsb fork): `--write-globe-history /var/globe_history --heatmap 30`; dir must be writable by readsb user.
- Range outline: `/usr/local/share/tar1090/getupintheair.sh` generates `upintheair.json`.

## Gotchas
- AIS-catcher must run with `-N 8100 geojson on`.
- Cloudflare: Browser Cache TTL "Respect Existing Headers".
