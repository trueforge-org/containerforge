# GitHub: ich777/docker-stun-turn-server (branch master)

Source URL(s): https://raw.githubusercontent.com/ich777/docker-stun-turn-server/master/Dockerfile , .../scripts/start.sh (fetched 2026-11-27)

## Dockerfile
- FROM `ich777/debian-baseimage`; LABEL source=https://github.com/ich777/docker-stun-turn-server.
- RUN apt-get install `coturn openssl` (--no-install-recommends), then rm lists.
- ENV defaults:
| var | default |
| --- | --- |
| DATA_DIR | /stun-turn |
| PORT | 5349 |
| STATIC_AUTH | "true" |
| SECRET | "" |
| REALM | example.com |
| TOTAL_QUOTA | 100 |
| MAX_BPS | 0 |
| CIPHER_LIST | (same as chart) |
| CERT_FILE / PRIVKEY_FILE | cert.pem / privkey.pem |
| CERT_LENGTH / CERT_VALID_DAYS | 2048 / 3650 |
| CA_COUNTRY | US |
| CA_STATE_PROV / CA_LOCALITY / CA_ORGANIZATION | "" |
| DH_FILE / DH_LENGTH | dhparam.pem / 2048 |
| CLI_PASSWORD | "" |
| EXTRA_PARAMS | "" |
| DISPLAY_SECRETS | "true" |
| LISTENING_IP | 0.0.0.0 |
| EXTERNAL_IP | "" |
| UMASK | 000 |
| UID / GID | 99 / 100 |
| DATA_PERM | 770 |
| USER | stun-turn |
- RUN: mkdir $DATA_DIR; useradd -d $DATA_DIR -s /bin/bash $USER; chown; ulimit -n 2048.
- ADD scripts/ -> /opt/scripts/ (chmod 770).
- EXPOSE 5349 and 5349/udp. ENTRYPOINT `["/opt/scripts/start.sh"]`.

## start.sh (bash, root)
- Same UID/GID remap, umask, optional user.sh hook as the starmade/ich777 template.
- chown -R ${UID}:${GID} on /opt/scripts/, /var/run/, ${DATA_DIR}/.
- SIGTERM trap kills `turnserver` via pidof.
- Runs `su ${USER} -c "/opt/scripts/start-server.sh"` in background (start-server.sh not fetched).

## Ports
- 5349/tcp and 5349/udp.

## Volumes/paths
- /stun-turn (DATA_DIR): cert.pem, privkey.pem, dhparam.pem, config.

## Gotchas
- Dockerfile default REALM example.com; CA_COUNTRY default US here, chart sets "".

## Upstream
- coturn (https://github.com/coturn/coturn) LICENSE: BSD-style (3-clause), Copyright 2011-2013 Citrix Systems. Upstream coturn packaged via Debian `coturn` package (archive not fetched).
