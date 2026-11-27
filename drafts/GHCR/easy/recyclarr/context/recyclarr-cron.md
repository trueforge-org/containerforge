# recyclarr docker/scripts/cron.sh (v8.8.1)

## Source URL(s) + date
- https://raw.githubusercontent.com/recyclarr/recyclarr/v8.8.1/docker/scripts/cron.sh (fetched 2026-11-27)
- Copied to `/cron.sh` by the Dockerfile

## Behaviour
- Prints a banner with date, then runs: `recyclarr sync "--log[ $RECYCLARR_LOG_LEVEL]"`
- Log level from env RECYCLARR_LOG_LEVEL (appended only when set)

## Gotchas
- Exit code and log level values not further documented in script.
