# TrueCharts chart: rsshub

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rsshub/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts `rsshub` chart, train stable, category media. Chart version 22.0.4, appVersion `latest`.
- Library dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`; max helm 4.1, min helm 3.14; max k8s 1.35.0.
- Chart `sources:` list: docs.rsshub.app/en/install/, github DIYgod/RSSHub, hub.docker.com/r/browserless/chrome, hub.docker.com/r/diygod/rsshub.

## Images (values.yaml)
| Key | Repository | Tag |
| --- | --- | --- |
| image | docker.io/diygod/rsshub | `latest@sha256:f948f601b55357bd78dd4e97f506dffec4ce2775ad14577634ce120da9a9e1df` |
| browserlessImage | docker.io/browserless/chrome | `1.61.1-chrome-stable@sha256:efac47cfff3830d9a50b27d29f8bbb61949058ae336c823fbe9bd3c0d1debcc8` |

## Ports
- service.main.ports.main.port = 10191 (env PORT is templated from it).
- additionalContainers `browserless`: containerPort 3000 (name main). Sidecar, not a separate service.

## Env (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| PORT | `{{ service.main.ports.main.port }}` (10191) |
| NODE_ENV | production |
| CACHE_TYPE | redis |
| PUPPETEER_WS_ENDPOINT | ws://localhost:3000 |
| NODE_NAME | `{{ Release.Name }}-{{ rsshub.nodeName }}` |
| DISALLOW_ROBOT | false |
| TITLE_LENGTH_LIMIT | 150 |
| REDIS_URL | secret ref valkeycreds key `url` (valkey dependency enabled) |
| ALLOW_ORIGIN | commented out |
| HTTP_BASIC_AUTH_NAME | "" |
| HTTP_BASIC_AUTH_PASS, BITBUCKET_PASSWORD, GITHUB_ACCESS_TOKEN, GOOGLE_FONTS_API_KEY, YOUTUBE_KEY, TELEGRAM_TOKEN, LASTFM_API_KEY | secret ref env-secrets/<same key> |
| BITBUCKET_USERNAME | "" |

## Dependencies / other
- `dependencies.valkey.enabled: true` (Redis-compatible cache).
- `rsshub.nodeName: "PLACEHOLDERNODENAME"` (must be set by user).
- `secret.env-secrets` created with empty keys: HTTP_BASIC_AUTH_PASS, BITBUCKET_PASSWORD, GITHUB_ACCESS_TOKEN, GOOGLE_FONTS_API_KEY, TELEGRAM_TOKEN, LASTFM_API_KEY, YOUTUBE_KEY.
- securityContext.container: runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0 (chart runs as root).

## Gotchas
- Chart pins the diygod image by digest with tag `latest`; browserless pinned to v1 tag `1.61.1-chrome-stable` (see dockerhub-browserless-chrome.md, v1 is marked legacy upstream).
- Container runs as root in the chart (no rootless/readonly settings).
