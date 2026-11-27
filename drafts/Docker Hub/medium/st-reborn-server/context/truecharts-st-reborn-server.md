# truecharts st-reborn-server (chart version 11.0.0, appVersion 1.8.4)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/st-reborn-server/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/st-reborn-server/Chart.yaml
- Fetched 2026-11-27

## What it is
- `name: st-reborn-server`, `appVersion: 1.8.4`, `version: 11.0.0`, `type: application`
- Description: "Skyrim Together Reborn server files."

## Image (values.yaml)
- repository: `docker.io/tiltedphoques/st-reborn-server`
- tag: `1.8.4@sha256:de3f43830bdbd1dc77bba042cae6e975ea751288643936c37d3b45bfd277c273`
- pullPolicy: IfNotPresent

## Ports
| name | port | targetPort | protocol |
| --- | --- | --- | --- |
| main | 10578 | 10578 | udp |

## Persistence
| name | mountPath |
| --- | --- |
| config | `/home/server/config` |
| data | `/home/server/Data` |
| logs | `/home/server/logs` |

## Env
- None set in values.yaml.

## Probes
- liveness, readiness, startup: all `enabled: false`.

## Security context
- Not set in values.yaml (chart defaults).

## Gotchas
- Chart mounts three paths under `/home/server`; these are chart paths, not documented upstream paths (see github-tiltedevolution-dockerfile.md).
- No TCP service; UDP only.
