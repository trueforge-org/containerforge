# TrueCharts navidrome (chart 25.0.0, appVersion 0.64.2)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/navidrome/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Open source web-based music collection server and streamer.
- Chart sources: ghcr.io/navidrome/navidrome, github.com/deluan/navidrome.
- Category media, train stable, not deprecated.
- Kubernetes >=1.33.0-0 (max 1.35.0); Helm min 3.14, max 4.1.
- Dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
| Field | Value |
| --- | --- |
| Repository | ghcr.io/navidrome/navidrome |
| Tag | 0.64.2 (digest pinned) |
| Pull policy | IfNotPresent |

## Ports
| Scope | Port |
| --- | --- |
| Service (main) | 4533 |
| Container targetPort | 4533 |

## Env vars (chart values)
| Variable | Chart default |
| --- | --- |
| ND_MUSICFOLDER | /music |
| ND_SCANNER_SCHEDULE | "@every 15m" |
| ND_LOGLEVEL | info |
| ND_SESSIONTIMEOUT | 24h |
| ND_ENABLETRANSCODINGCONFIG | false |

Note: ND_ENABLETRANSCODINGCONFIG is not in the upstream options table (see upstream-navidrome-docs.md).

## Persistence / paths
- data -> /data (enabled)
- music -> /music (enabled)

## Probes / securityContext
- Not specified in values.yaml (chart defaults apply).

## Gotchas
- No config file path set by chart; config is via ND_* env vars, with /data as persistence mount.
- Chart schedule default ("@every 15m") differs from upstream default (0 = disabled); this is a chart override, not an error.
