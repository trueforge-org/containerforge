# ich777/docker-online-check-pushover (Dockerfile, README, latest commit)

Source URL(s) + date: https://raw.githubusercontent.com/ich777/docker-online-check-pushover/master/Dockerfile ; https://raw.githubusercontent.com/ich777/docker-online-check-pushover/master/README.md ; https://github.com/ich777/docker-online-check-pushover/commits/master (HTML alternative for the 403 commits API) (fetched 2026-11-27)

## Purpose
- Pings a domain or IP and sends a Pushover alert when it stops responding. Can run locally or on a remote machine.
- Unraid-packaged; upstream image ich777/online-check-pushover.

## Dockerfile
- Single stage, `FROM ich777/debian-baseimage` (no tag, implicit latest).
- apt-get update; `apt-get -y install --no-install-recommends iputils-ping`; `rm -rf /var/lib/apt/lists/*`.
- `useradd -s /bin/bash $USER`.
- `ADD /scripts/ /opt/scripts/`; `chmod -R 777 /opt/scripts/`.
- ENTRYPOINT ["/opt/scripts/start.sh"]; no CMD, EXPOSE, VOLUME, WORKDIR, HEALTHCHECK, or USER instruction.
- LABEL authors and source https://github.com/ich777/docker-online-check-pushover.

## Env vars (Dockerfile defaults)
| Variable | Default |
| --- | --- |
| HOST | google.com |
| PING_INTERVAL | 300 |
| PING_TIMEOUT | 10 |
| PING_RETRY | 3600 |
| PUSHOVER_APP_TOKEN | "" |
| PUSHOVER_USER_TOKEN | "" |
| PUSHOVER_TITLE | Online Check |
| PUSHOVER_MESSAGE | google.com is offline! |
| PUSHOVER_PRIORITY | 0 |
| UID | 99 (env only) |
| GID | 100 (env only) |
| USER | onlinecheck (env; account name) |
| DATA_PERM | 770 |

## Runtime / user
- No USER instruction; UID/GID 99/100 are ENV only. Account name from ENV USER.

## README
- PUSHOVER_PRIORITY: -2 lowest, -1 low, 0 normal, 1 high, 2 emergency.
- Run flag `--restart=unless-stopped` is required, else no retry after failed ping.
- Run example passes all env vars via --env.
- No ports, volumes, or healthcheck documented.

## Latest commit (HTML alternative; commits API returned 403)
- Short sha 318fcf8, dated Oct 25, 2022, message: "scripts/start.sh" changed.

## Gotchas
- Image runs without a USER instruction (root by default); UID/GID only as env.
- Chart's secret token keys must be supplied.
