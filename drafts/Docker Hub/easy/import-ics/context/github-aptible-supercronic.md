# aptible/supercronic (GitHub)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/aptible/supercronic/master/README.md
- https://raw.githubusercontent.com/aptible/supercronic/master/LICENSE.md
- https://github.com/aptible/supercronic/releases/latest
- Asset URL pattern (not fetched, binary): https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}
- Fetched 2026-11-26

## What it is
"A crontab-compatible job runner, designed specifically to run in containers." Standard cron wipes the environment, swallows output, handles signals poorly, and logs to syslog; supercronic avoids these.

## Install
- Prebuilt binary from the releases page (README suggests `supercronic-linux-amd64` when unsure).
- Source build: `go get -d github.com/aptible/supercronic`, then `go mod vendor` and `go install` in the GOPATH source dir.

## CLI usage and flags
- `supercronic CRONTAB`
- `-debug`: verbose; confirms syntax and active timezone.
- `-overlapping`: allow concurrent job instances.
- `-inotify`: reload crontab on Write/Remove events.
- `-test`: validate crontab without running.
- `-split-logs`: debug/info to stdout instead of stderr.
- `-sentry-dsn DSN` (env `SENTRY_DSN`; flag wins if both).
- `-sentry-environment` (env `SENTRY_ENVIRONMENT`), `-sentry-release` (env `SENTRY_RELEASE`).

## Crontab syntax
- Aims to match Vixie cron. Five-field entries work (e.g. `*/1 * * * * echo "hello"`); `@hourly`-style shortcuts supported.
- Seconds field also accepted (6 or 7 fields; example `*/2 * * * * * * ls 2>/dev/null` runs every 2 seconds). Parsing via `cronexpr`: tries 7, 6, then 5 fields.
- `USER` in the crontab has no effect; use Dockerfile `USER`.
- Timezone from `/etc/localtime` or `TZ` env var; `tzdata` may be needed. `CRON_TZ=A` line in crontab sets per-schedule zone.
- `KEY=VALUE` env lines in crontab supported but "not recommended".

## Logging
- All logs to stderr by default. Each entry includes command, position, schedule, iteration. Job output tagged `channel=stdout`. Start, success/failure, exit status logged. Warning when a job is late.

## Signals
- SIGTERM, SIGINT, SIGQUIT: graceful shutdown.
- SIGUSR2: graceful shutdown and reload crontab. Supercronic must be PID 1 for `docker kill --signal=USR2` to reach it.

## Environment
- Environment is not cleared; jobs inherit env from Dockerfile `ENV` or `docker run -e`.

## Version/release info and asset naming
- Latest release: `v0.2.51` (released by almathew, "21 Oct", year not shown). Commit `aa1edc759b11a38528edfacf47d01f9c9d287a31`. Changes: package bumps and CA cert updates (PR #251).
- Release reports 6 assets; only names given in install instructions were readable: `supercronic-linux-amd64`, `supercronic-linux-386`, `supercronic-linux-arm`, `supercronic-linux-arm64`. Other two not identified.
- Checksums shown on the release page: SHA-1 values only (per summary), not SHA-256:
  - linux-amd64: `1692066e350a88ff4d7d6474fe3c7a6c41ec5e89`
  - linux-arm64: `9d4c2000493215a1898502b2fc2dada3e8ea8c7a`
  - linux-386: `b63ac46670afcc816581516be82f3f1acf91e929`
  - linux-arm: `9224966499cd319ed85759e9b6442f885d920c4f`
- No separate checksum file named.

## Arch support
linux amd64, 386, arm, arm64 binaries in releases.

## License
MIT License, "Copyright (c) 2017, Aptible, Inc."

## Gotchas / contradictions with plan.md
- Plan section 4 step 3 says verify against "the sha256 digest GitHub shows" with values `cc232108...a123` (amd64) and `4ae22576...2b94` (arm64). The release page summary shows SHA-1 digests only, and the plan values do not match those (`1692066e...` amd64, `9d4c2000...` arm64). UNVERIFIED which hash the plan values are; the plan's digests could not be confirmed here.
- Plan section 10 asks whether `CRONTAB_SCHEDULE` 5-field syntax is accepted. Confirmed: 5-field works; 6/7-field (seconds) forms are also accepted.
