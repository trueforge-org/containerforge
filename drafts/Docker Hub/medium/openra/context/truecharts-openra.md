# TrueCharts chart: openra (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/openra/Chart.yaml , .../values.yaml (fetched 2026-11-27)

## What it is
- Chart version 11.0.0, appVersion `latest`, library dep `common` 32.8.5
- Description: "Mudislanders Template for mounting OpenRA's dedicated server by rmoriz"
- Category Network-Other, train stable; kubeVersion >=1.33.0-0

## Image (values.yaml)
- repository: docker.io/rmoriz/openra
- tag: latest@sha256:81a3a76c915122109c22469fbec28175c23644ca7f2879a21a82467979f95f56

## Ports
| Service | Name | Protocol | Port | targetPort |
| --- | --- | --- | --- | --- |
| main | main | tcp | 1234 | 1234 |

## Env (workload main, container main)
| Env | Value |
| --- | --- |
| AdvertiseOnline | "True" |
| Ban | "" |
| EnableSingleplayer | "False" |
| ExternalPort | "1234" |
| ListenPort | "1234" |
| MAP | "" |
| MOTD | Have Fun!! |
| Mod | ra |
| Name | DEDICATED SERVER |
| Password | secretKeyRef env-secrets/Password |

- Secret env-secrets (enabled), data.Password = "" (empty default)

## Persistence
- persistence: {} (none defined)

## Security context
- readOnlyRootFilesystem: false, runAsUser: 0, runAsGroup: 0 (chart runs as root)

## Gotchas
- Env names are upper/mixed case as the chart sets them (AdvertiseOnline, ListenPort, Mod, Name, Password); they match the launch script variables
