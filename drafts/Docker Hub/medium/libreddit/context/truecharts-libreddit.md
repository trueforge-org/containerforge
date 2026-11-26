# TrueCharts libreddit (chart 14.0.0)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/libreddit/values.yaml (2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/libreddit/Chart.yaml (2026-11-26)

## What it is
- Chart `version: 14.0.0`, `appVersion: latest`, `kubeVersion: '>=1.33.0-0'`, category `media`, train `stable`.
- Description: "An alternative private front-end to Reddit".
- Library dep: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`).

## Image
- `docker.io/libreddit/libreddit`, tag `latest@sha256:9b0c2ac695976a2cb4bfc6f4c243ec148744f32bc4c4d54e063377f4c474ae65`, `pullPolicy: IfNotPresent`.

## Env vars
- Via `configmap.libreddit` (envFrom on container `main`):
| Name | Value (from values) |
| --- | --- |
| LIBREDDIT_DEFAULT_THEME | `system` |
| LIBREDDIT_DEFAULT_FRONT_PAGE | `default` |
| LIBREDDIT_DEFAULT_LAYOUT | `card` |
| LIBREDDIT_DEFAULT_POST_SORT | `hot` |
| LIBREDDIT_DEFAULT_COMMENT_SORT | `confidence` |
| LIBREDDIT_DEFAULT_WIDE | `off` (ternary on `wide: false`) |
| LIBREDDIT_DEFAULT_SHOW_NSFW | `off` |
| LIBREDDIT_DEFAULT_USE_HLS | `off` |
| LIBREDDIT_DEFAULT_HIDE_HLS_NOTIFICATION | `off` |
| LIBREDDIT_DEFAULT_AUTOPLAY_VIDEOS | `off` |

## Ports
- service `main` / port `main`: 10257 -> targetPort 8080.

## Probes
- liveness, readiness, startup: HTTP path `/settings`.

## Volumes/paths
- None. No persistence block.

## User/UID
- Not set in chart values.

## Gotchas
- `appVersion: latest` (chart pins digest of Docker Hub `latest`, last pushed 2024-03-05).
- Upstream README (see github-libreddit-readme.md) says the project has been non-operational since 2023-07-12 due to Reddit API changes.
