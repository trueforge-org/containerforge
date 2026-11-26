# TrueCharts chart: teamspeak3

**Source URL(s)** (fetched 2026-11-26)
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/teamspeak3 (fetched as raw `values.yaml`: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/teamspeak3/values.yaml)

## What it is
TrueCharts Helm chart for the TeamSpeak 3 server. Main image is `teamspeak:3.13.9@sha256:88335936d0969ffb7182c292f72319167db3722770a8db0c175b4e6fb8bc03ad`, pull policy `IfNotPresent`.

## Persistence
- Data volume mounted at `/var/ts3server` (enabled).
- Config volume mounted at `/var/run/ts3server` (enabled).
- No sizes given.

## Security context
- `readOnlyRootFilesystem: false`.
- No runAs user/group set in values (common default applies, per draft).

## Env
- `TS3SERVER_LICENSE: accept`.

## Service ports (main service)
- main: 10011 (no protocol set)
- query: 10022
- voice: 9987/udp
- files: 30033

## Probes
Liveness, readiness and startup are all `tcp`.

## Gotchas
- The chart mounts two PVCs (`/var/ts3server`, `/var/run/ts3server`). The plan maps these to a single `/config` volume, with the ini in `/tmp`.
- The chart's probes are TCP on the main port 10011 only; the plan's container-test uses 10011 and 30033 TCP.
- The chart's `query` port 10022 is the SSH query port and is only active when SSH query is enabled.
