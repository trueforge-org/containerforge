# ich777/docker-anope (upstream reference image)
Source URL(s): https://raw.githubusercontent.com/ich777/docker-anope/master/Dockerfile (fetched 2026-11-27); blob variant same
Start script: https://raw.githubusercontent.com/ich777/docker-anope/master/scripts/start.sh (listed by Dockerfile ENTRYPOINT, NOT fetched; not in urls.txt)

## What it is
Helper image that runs Anope services on top of `ich777/debian-baseimage`.

## Build
- `FROM ich777/debian-baseimage`
- LABEL org.opencontainers.image.source=https://github.com/ich777/docker-anope
- apt: `curl screen` (`--no-install-recommends`, lists removed)
- `ENV DATA_DIR=/anope`, `useradd -d /anope -s /bin/bash anope`, `chown -R anope /anope`, `ulimit -n 2048`
- `ADD /scripts/ /opt/scripts/`, `chmod -R 770 /opt/scripts/`
- `ENTRYPOINT ["/opt/scripts/start.sh"]`

## Env (Dockerfile defaults)
| Name | Default |
| --- | --- |
| DATA_DIR | /anope |
| HOST | irc.example.com |
| IP_ADDR | 192.168.1.1 |
| SSL | no |
| PORT | 7000 |
| PASSWORD | password |
| IRCD | inspircd3 |
| CASEMAP | rfc1459 |
| LOCAL_HOSTNAME | services |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| DATA_PERM | 770 |
| USER | anope |

## Ports / Volumes / User
- No EXPOSE, no VOLUME, no USER directive (the `anope` user is created but not set as USER)
- Data dir /anope

## Gotchas
- These env vars belong to the helper's start.sh, not to Anope itself. Do not copy as Anope env.
- Entrypoint runs as root unless overridden.
