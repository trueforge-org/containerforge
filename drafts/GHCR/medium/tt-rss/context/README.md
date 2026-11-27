# context index: tt-rss (fetched 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tt-rss/values.yaml | truecharts-tt-rss.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tt-rss/Chart.yaml | truecharts-tt-rss.md |
| https://raw.githubusercontent.com/tt-rss/tt-rss/03628f0aa3c4a86e960ddd61b5ba372cd3a27b50/.docker/app/Dockerfile (+ startup.sh same commit) | tt-rss-app-dockerfile.md |
| https://raw.githubusercontent.com/tt-rss/tt-rss/d62bcf96d01a7a2e750f6c9581ca462556e57281/.docker/web-nginx/Dockerfile | tt-rss-nginx-dockerfile.md |

Skipped: blob/HTML variants of the Dockerfile URLs (duplicates of raw); github.com/tt-rss/tt-rss and git.tt-rss.org / gitlab.tt-rss.org repo pages (mirror of the same source, not fetched); tt-rss.org homepage (fetched, only marketing text, nothing build-relevant); tt-rss.org docs not fetched.

Failures:
- https://api.github.com/repos/tt-rss/tt-rss : 403 (API rate limit). Not retried.
- https://api.github.com/repos/tt-rss/tt-rss/releases/latest : 403 (API rate limit). One alternative tried: https://github.com/tt-rss/tt-rss/releases/latest HEAD, redirects to /releases (no asset data). Rolling release, no pinned asset needed.

## plan.md corrections
- None. Plan facts checked against fetched sources (alpine 3.24.4, PHP 8.5, port 9000, OWNER_UID 1000, nginx 1.31.8-alpine) match. Still UNVERIFIED in plan (not checked here): nginx listen port in template (chart uses 10104 via configmap).
