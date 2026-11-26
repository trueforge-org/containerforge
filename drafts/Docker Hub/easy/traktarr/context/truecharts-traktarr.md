# TrueCharts traktarr chart

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/traktarr (chart directory)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/traktarr/values.yaml (fetched 2026-11-26)

**What it is**
The chart that uses the third-party `eafxx/traktarr` image as its main container.

**Image (values.yaml)**
- repository `docker.io/eafxx/traktarr`
- tag `latest@sha256:3299915869b66e9ab5d34f454b5d8eae897a837b7dc27624bc7b4925e766a746`
- pullPolicy `IfNotPresent`

**Security context**
- runAsUser `0`, runAsGroup `0`, readOnlyRootFilesystem `false`. privileged not set.

**Env (mapped from chart values)**
- `APP_BRANCH` (`master`), `BLACKLIST` (`yes`), `DELAY` (`"2.5"`), `NOSEARCH` (`yes`), `NOTIFICATIONS` (`yes`), `RUNNOW` (`no`), `SKIPUPDATE` (`yes`), `SORT` (`rating`). The `yes/no` values come from boolean chart values through `ternary`.

**Persistence**
- `config` at `/config` (enabled).

**Service/ports**
- Service `main` disabled. No ports.

**Probes**
- liveness, readiness and startup disabled.

**Gotchas**
- The chart runs as root with a writable rootfs, unlike the plan's rootless target.
- The chart sets `SKIPUPDATE` to `yes` by default, so the third-party auto-update is off in the chart.
