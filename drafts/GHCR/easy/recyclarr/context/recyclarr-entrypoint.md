# recyclarr docker/scripts/entrypoint.sh (v8.8.1)

## Source URL(s) + date
- https://raw.githubusercontent.com/recyclarr/recyclarr/v8.8.1/docker/scripts/entrypoint.sh (fetched 2026-11-27)
- Copied to `/entrypoint.sh` by the Dockerfile

## Behaviour (bash, set -e)
1. If `RECYCLARR_CREATE_CONFIG` = true and `/config/recyclarr.yml` absent: `recyclarr config create`
2. If args given: `exec recyclarr "$@"` (CLI mode)
3. Else: echo "Starting cron schedule using: $CRON_SCHEDULE"; write `"$CRON_SCHEDULE /cron.sh"` to `/tmp/crontab`; `exec supercronic -passthrough-logs -no-reap /tmp/crontab`

## Env vars
| Name | Use |
| --- | --- |
| RECYCLARR_CREATE_CONFIG | create default config when true |
| CRON_SCHEDULE | cron expression for supercronic |

## Gotchas
- Writes /tmp/crontab; needs writable /tmp.
- Config path fixed at /config/recyclarr.yml.
