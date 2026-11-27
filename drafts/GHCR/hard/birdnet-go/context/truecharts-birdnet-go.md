# TrueCharts birdnet-go (chart 3.0.0)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/birdnet-go/{values.yaml,Chart.yaml} (fetched 2026-11-27)

## What it is
- Chart `birdnet-go` 3.0.0, appVersion 20261122.0.0, category media, common 32.8.5.
- Description: self-hosted realtime soundscape analyser for birds, bats, wildlife.
- Chart sources: ghcr.io/tphakala/birdnet-go, github tphakala/birdnet-go.

## Image
- repository: `ghcr.io/tphakala/birdnet-go`
- tag: `20261122@sha256:b1d332e82ca18ad5395d107421f30745a0d66a7a0e3a9b7be6b9c19ce5e70f0a`
- pullPolicy: IfNotPresent

## Ports
| Name | Port | targetPort |
| --- | --- | --- |
| main | 8080 | 8080 |

- Upstream image also EXPOSEs 80, 443 (AutoTLS) and 8090 (Prometheus metrics). Chart exposes only 8080.

## Env / probes / securityContext
- Chart sets no env, probes or securityContext in values.yaml (chart defaults apply, not read).

## Persistence
| Name | mountPath |
| --- | --- |
| config | /config |
| data | /data |

## Gotchas
- Chart values are minimal; no audio device (`--device /dev/snd`) mapping is set in values. Upstream usage label needs `/dev/snd`.
