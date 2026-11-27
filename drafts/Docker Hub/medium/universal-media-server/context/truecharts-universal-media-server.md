# truecharts: universal-media-server (chart 11.0.0, appVersion latest)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/universal-media-server/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## Image
- repository `docker.io/universalmediaserver/ums`, tag `latest@sha256:48713f47cadc6201279f4be09e8d7d2b9054f3c34c26d75b6e9deddf0f2ce54c`, pullPolicy IfNotPresent.

## Security context
- readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0 (root).

## Persistence
| Name | enabled | mountPath |
| --- | --- | --- |
| config | true | `/root/.config/UMS/` |
| media | true | `/media` |

## Services and ports
| Service | Port | Protocol | targetPort |
| --- | --- | --- | --- |
| main (web UI) | 9001 | http | 9001 |
| api | 5001 | tcp | 5001 (enabled) |
| sub | 1044 | tcp | 1044 (enabled) |

## Gotchas
- Chart config path `/root/.config/UMS/` is a root home path; runs as root in the chart.
- Chart exposes 1044/tcp (sub) which is not in the upstream Dockerfile EXPOSE list.
- Chart does not expose 1900/udp or 5353/udp (SSDP/mDNS) or 9002/tcp.
