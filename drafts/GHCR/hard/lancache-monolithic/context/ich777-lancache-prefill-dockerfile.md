# ich777/docker-lancache-prefill Dockerfile (upstream prefill sidecar)

Source URL(s) + date: https://raw.githubusercontent.com/ich777/docker-lancache-prefill/master/Dockerfile · fetched 2026-11-27

## Build
- Base: `ich777/debian-baseimage` (no tag)
- apt: unzip, jq, cron, tzdata
- Copies /scripts -> /opt/scripts, /cron -> /opt/cron (chmod 777), /docker.motd -> /etc/docker.motd

## Env vars (ENV)
| Var | Default |
| --- | --- |
| DATA_DIR | /lancacheprefill |
| ENABLE_BN | false |
| ENABLE_EPIC | false |
| ENABLE_STEAM | true |
| UPDATES | true |
| PREFILL_ONSTARTUP | false |
| LOGCLEANUP | true |
| CRON_SCHED_BN | 0 5 * * * |
| CRON_SCHED_EPIC | 0 4 * * * |
| CRON_SCHED_STEAM | 0 2 * * * |
| CRON_SCHED_GLOBAL | "" |
| PREFILL_PARAMS_BN | "" |
| PREFILL_PARAMS_EPIC | "" |
| PREFILL_PARAMS_STEAM | --recent |
| UMASK | 0000 |
| UID | 99 |
| GID | 100 |
| DATA_PERM | 770 |
| USER | prefill |

## User
- `useradd -d /lancacheprefill prefill`; chown -R on DATA_DIR
- Note: chart overrides USER=root

## Entrypoint
- `ENTRYPOINT ["/opt/scripts/start.sh"]`

## Gotchas
- Chart values differ from image defaults: chart sets ENABLE_BN/EPIC/STEAM all true and clears STEAM params.
- Upstream tool (steam/epic/battlenet prefill binaries) is not fetched; GitHub release API for tpill90/steam-lancache-prefill was rate limited.
