# TrueCharts chart: storm

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/storm/values.yaml and .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `storm` v11.0.0, appVersion 1.3.0, description "A Modern Deluge Interface."
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts)
- Category: Downloaders; kubeVersion >=1.33.0-0

## Image (values.yaml)
- repository: `ghcr.io/relvacode/storm`
- tag: `v1.3.0@sha256:9f50d643af5a83424331a93a212e320407a1a1577f0202e6141f7f5245d2711a`
- pullPolicy: IfNotPresent

## Runtime security (values.yaml)
- readOnlyRootFilesystem: false
- runAsUser: 0, runAsGroup: 0 (chart runs as root)

## Ports
| name | port | protocol | targetPort |
| --- | --- | --- | --- |
| main | 8221 | http | 8221 |

## Env vars (chart defaults)
| Env | Chart default | Source |
| --- | --- | --- |
| DELUGE_RPC_HOSTNAME | "" | literal |
| DELUGE_RPC_PORT | 58846 | literal |
| DELUGE_RPC_PASSWORD | secretKeyRef env-secrets/DELUGE_RPC_PASSWORD | secret |
| DELUGE_RPC_USERNAME | "" | literal |
| DELUGE_RPC_VERSION | v2 | literal |
| STORM_API_KEY | secretKeyRef env-secrets/STORM_API_KEY | secret |

Secret `env-secrets` (enabled) with empty DELUGE_RPC_PASSWORD and STORM_API_KEY.

## Gotchas
- Chart sets DELUGE_RPC_VERSION=v2 (upstream default is v1 per README).
- No persistence, probes or config files defined in values.yaml.
