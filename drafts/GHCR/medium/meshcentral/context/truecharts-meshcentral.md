# TrueCharts meshcentral chart (stable)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/meshcentral/values.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/meshcentral/Chart.yaml (2026-11-27)

## What it is
- Chart `meshcentral` version 21.0.1, appVersion 1.3.2, category cloud, train stable.
- Depends on `common` 32.8.5 and postgresql (enabled).

## Image
- repository: `ghcr.io/ylianst/meshcentral`
- tag: `1.3.2@sha256:a2eb6d93a415dac0d1e69f1d6f20dd4ace46b99de75d584559ed9cf223d51113`
- pullPolicy: IfNotPresent
- Chart runs `command: [node, meshcentral/meshcentral]`, runAsUser 0, runAsNonRoot false, readOnlyRootFilesystem false.

## Ports
| name | port | protocol |
| --- | --- | --- |
| main | 10205 | http |

Other ports (mps 4433, provisioning 9971) are commented out in values; settings `_mpsPort: 4433`.

## Persistence
| name | mountPath | size |
| --- | --- | --- |
| data | /opt/meshcentral/meshcentral-data | 256Gi |
| files | /opt/meshcentral/meshcentral-files | 256Gi |
| web | /opt/meshcentral/meshcentral-web | 256Gi |
| backups | /opt/meshcentral/meshcentral-backup | 256Gi |
| configfile | /opt/meshcentral/meshcentral-data/config.json (secret, subPath config.json, readOnly, mode 0600) | - |

Note: chart backups path is `meshcentral-backup`; upstream Dockerfile VOLUME is `meshcentral-backups`.

## Config (values.yaml `meshcentral.settings`)
- sessionKey placeholder "PLACEHOLDERSESSIONKEYCHANGEME12" (must be changed).
- aliasPort 443; cert `mc.domain.com`; keepCerts false; WANonly/LANonly false; allowLoginToken false; allowFraming false; webRTC false; nice404 true; sessionTime 60; sessionSameSite lax.
- Many options prefixed `_` are pruned/disabled by chart.

## Gotchas
- Chart comment: any service on a port other than 443 must be configured manually.
