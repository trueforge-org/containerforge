# TrueCharts chart: nitter

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nitter/values.yaml (2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nitter/Chart.yaml (2026-11-26)

## What it is
Chart version 16.0.0, `appVersion: latest`, category media, library dep `common` 32.8.5. Description: free, open source Twitter front-end.

## Image
- `docker.io/zedeus/nitter`, tag `latest@sha256:8ca440fa51d8ce4618d51a6341dabbce784407025e2531343c36e540e0e3c4ba`, pullPolicy IfNotPresent

## Ports
| Service | Name | Protocol | Port |
| --- | --- | --- | --- |
| main | main | http | 10606 |

Chart port 10606 differs from upstream EXPOSE 8080 (see github-nitter.md). `nitter.general.hostname: localhost:10606`.

## Nitter config (rendered to nitter.conf via values)
| Key | Value |
| --- | --- |
| general.title | nitter |
| general.hostname | localhost:10606 |
| general.httpMaxConnections | 100 |
| cache.listMinutes | 240 |
| cache.rssMinutes | 10 |
| hmacKey | "PLACEHOLDERHMACKEYCHANGEME123456" (must be changed; 32+ chars) |
| config.base64Media | false |
| config.enableRSS | true |
| config.enableDebug | false |
| config.proxy / proxyAuth | "" |
| config.tokenCount | 10 |
| preferences.theme | Nitter |
| preferences.replaceTwitter | nitter.net |
| preferences.replaceYouTube | piped.video |
| preferences.replaceReddit | teddit.net |
| preferences.replaceInstagram | "" |
| preferences.proxyVideos | true |
| preferences.hlsPlayback | false |
| preferences.infiniteScroll | false |

## Env vars (container main)
| Name | Value |
| --- | --- |
| NITTER_SESSIONS_FILE | /src/sessions.jsonl |

## Secrets / persistence (secret mounts, readOnly)
- secret `nitter-sessions` (enabled): key `sessions.jsonl` = `{"oauth_token": "TOKEN", "oauth_token_secret": "SECRET"}` (placeholder; ref: nitter wiki "Creating session tokens").
- persistence `nitter-config`: type secret, objectName `nitter-config`, mount `/src/nitter.conf`, subPath `nitter.conf`, readOnly.
- persistence `nitter-sessions`: type secret, objectName `nitter-sessions`, mount `/src/sessions.jsonl`, subPath `sessions.jsonl`, readOnly.

## Probes
| Probe | Type | Path |
| --- | --- | --- |
| liveness | http | / |
| readiness | http | / |
| startup | tcp | - |

## Dependencies
- `valkey` enabled: true (subchart).

## Gotchas
- Config is in a secret mounted at `/src/nitter.conf` (read-only). Chart hostname and port (localhost:10606) are chart-side.
- hmacKey placeholder must be replaced in production.
