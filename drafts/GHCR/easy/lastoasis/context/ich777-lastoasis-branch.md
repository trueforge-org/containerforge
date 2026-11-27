# ich777/docker-steamcmd-server (lastoasis branch)

## Source URL(s) + date
- https://raw.githubusercontent.com/ich777/docker-steamcmd-server/lastoasis/README.md
- https://raw.githubusercontent.com/ich777/docker-steamcmd-server/lastoasis/Dockerfile
- Fetched 2026-11-26. Per-game branch; differs from master (see ich777-docker-steamcmd-server.md).

## What it is
Unraid-oriented SteamCMD image; lastoasis branch installs and runs Last Oasis (Steam app 920720 server). Forked from mattieserver.

## Install/build steps
- `FROM ich777/debian-baseimage` (no tag pinned).
- `apt-get install --no-install-recommends lib32gcc-s1 lib32stdc++6`, then `rm -rf /var/lib/apt/lists/*`.
- Creates `/serverdata`, `/serverdata/steamcmd`, `/serverdata/serverfiles`; `useradd -d /serverdata -s /bin/bash steam`; `chown -R steam /serverdata`; `ulimit -n 2048` (no runtime effect).
- `ADD /scripts/ /opt/scripts/`; `chmod -R 770 /opt/scripts/`.
- `ENTRYPOINT ["/opt/scripts/start.sh"]`.
- Scripts are the same start.sh/start-server.sh family as master (not fetched on this branch; see master summary).

## Env vars (Dockerfile defaults)
| Name | Default |
| --- | --- |
| DATA_DIR | /serverdata |
| STEAMCMD_DIR | ${DATA_DIR}/steamcmd |
| SERVER_DIR | ${DATA_DIR}/serverfiles |
| GAME_ID | template |
| IDENTIFIER | dockeroasis_1 |
| GAME_PARAMS | template |
| CUSTOMER_KEY | YOURKEY |
| PROVIDER_KEY | YOURKEY |
| BACKENDAPIURLOVERRIDE | backend.last-oasis.com |
| SLOTS | 20 |
| GAME_PORT | 27015 |
| VALIDATE | "" |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| USERNAME | "" |
| PASSWRD | "" |
| USER | steam |
| DATA_PERM | 770 |

## README run params (not in Dockerfile)
- SRV_PASSWORD (server password, empty = none).
- GAME_ID example `920720` (README run example shows `232330`, inconsistent with `920720` used in chart; README text says 920720 in table).
- Ports in example: `-p 5555:5555/udp -p 27015:27015/udp`.
- Volumes in example: `/serverdata/steamcmd`, `/serverdata/serverfiles`.
- Image tag in example: `ich777/steamcmd:lastoasis`.
- Customer/Provider keys come from https://myrealm.lastoasis.gg (Provider key created there).
- First startup downloads full server files (can be long). Update = restart container.

## Runtime deps
- 32-bit libs lib32gcc-s1, lib32stdc++6 (branch does NOT install lib32z1, unlike master).
- Network access to Steam content servers and Last Oasis backend.

## Healthcheck
- None defined.

## Gotchas
- Start script runs as root and remaps user `steam` to UID/GID (same as master); not rootless, needs writable rootfs.
- GAME_ID with beta spec: `'920720 -beta BRANCH'` (no quotes) per README.
- Keys are passed as env; the Dockerfile defaults are placeholders `YOURKEY`.
