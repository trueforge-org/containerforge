# chvb/docker-kerio-connect etc/init.d/kerio-connect.sh (container entrypoint helper)

Source URL(s): https://raw.githubusercontent.com/chvb/docker-kerio-connect/eb6b9083dd9e9a68e4a67b73c178a0450cecd8ca/etc/init.d/kerio-connect.sh. Fetched 2026-11-26.

- Shebang `#!/bin/bash`. Run by supervisord as program `kerio` (`/etc/init.d/kerio-connect.sh`).
- Seeding: if `/opt/kerio` empty (ignoring lost+found) -> recursive copy from `/opt-start/kerio/*`.
- If none of `mailserver/mailserver`, `sendmail`, `kmsrecover` exist -> `cp -Rn` from `/opt-start/kerio/*` to `/opt/kerio/`.
- If `/opt/kerio/mailserver/mailserver` exists -> DNS setup + start; else print "Install Wrong! Please Check Image or Path Config!" and sleep 60.
- Overwrites `/etc/resolv.conf` with `$DNSSERVER` (default `8.8.8.8`, hardcoded fallback as second nameserver).
- Env read: `DNSSERVER` (default 8.8.8.8). Computed but unused: `HOSTNAME` (hostname -s), `DOMAIN` (hostname -d), `CONTAINERIP`.
- Starts via `/etc/init.d/kerio-connect start` (the `kerio-connect` init script inside the installed package); ends with interactive `bash` to keep container alive.
- Gotcha: comment says "Set DNS Server to localhost", code uses DNSSERVER.
