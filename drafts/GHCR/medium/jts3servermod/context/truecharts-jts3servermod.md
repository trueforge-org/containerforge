# TrueCharts chart: jts3servermod

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/jts3servermod/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- "JTS3ServerMod by Stefan1200". Chart version 7.0.0, `appVersion: 20240301.0.0`. Keywords: teamspeak, jts3servermod, teamspeak-bot.
- Dependency `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- Sources listed: ghcr.io/galexrt/jts3servermod, github.com/galexrt/container-jts3servermod, stefan1200 docs, stefan1200 forum topic.

## Image
- Repository `ghcr.io/galexrt/jts3servermod`
- Tag `v20240301-172535-248@sha256:30cf3a8e043b6c27721da1a28987aaadbc6c482cccd90836b0d821cf820facaa`

## Security
- runAsUser 3000, runAsGroup 3000, readOnlyRootFilesystem false.

## Ports
- Service `main` disabled (`service.main.enabled: false`). No ports exposed. Bot is an outbound client to the TS3 server query port.

## Env vars (chart)
| Name | Value |
| --- | --- |
| JTS3_LOG | `/jts3servermod/logs/JTS3ServerMod_InstanceManager.cfg` |

## Probes
- liveness, readiness, startup all disabled.

## Persistence
| Name | Mount |
| --- | --- |
| config | `/jts3servermod/config` |
| logs | `/jts3servermod/logs` |

## Gotchas
- Chart sets `JTS3_LOG` to a `.cfg` path. Upstream entrypoint passes it to `-log` (see the GitHub file). Check whether the value is meant to be a log file.
