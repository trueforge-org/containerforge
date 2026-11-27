# shlink-web-client context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shlink-web-client/values.yaml | truecharts-shlink-web-client-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shlink-web-client/Chart.yaml | truecharts-shlink-web-client-chart.md |
| https://raw.githubusercontent.com/shlinkio/shlink-web-client/v4.9.1/Dockerfile (blob URL) | shlink-web-client-dockerfile-v4.9.1.md |
| https://raw.githubusercontent.com/shlinkio/shlink-web-client/v4.9.0/Dockerfile (blob URL) | shlink-web-client-dockerfile-v4.9.0.md (low confidence, see file) |
| https://raw.githubusercontent.com/shlinkio/shlink-web-client/v4.9.1/config/docker/nginx.conf (blob URL) | shlink-web-client-nginx-conf-v4.9.1.md |
| https://raw.githubusercontent.com/shlinkio/shlink-web-client/develop/LICENSE (blob URL) | shlink-web-client-license.md |
| https://github.com/shlinkio/shlink-web-client (repo, via raw README on develop) | shlink-web-client-readme.md |
| https://shlink.io/documentation (redirect to /documentation/) | shlink-docs-web-client.md |

Skipped: https://github.com/shlinkio/shlink-web-client/releases/download/... not in list; the dist zip is a binary download and was not fetched. Also skipped per category: no CLA, forgetool, containerforge app, templated or image-ref URLs in list. No Docker Hub source (GHCR app), though the README names Docker Hub `shlinkio/shlink-web-client`.

Failures: 1: https://example.invalid (DNS ENOTFOUND; a placeholder domain in urls.txt, not retried). Also the v4.9.0 Dockerfile summary disagreed with the 4.9.1 one (see its file); kept as low confidence.

## plan.md corrections
- Edited line 8: "The draft and chart use 4.9.0" -> "The draft uses 4.9.0; the TrueCharts chart (17.0.0) uses 4.9.1". Source: truecharts-shlink-web-client-chart.md (appVersion 4.9.1) and truecharts-shlink-web-client-values.md (image tag 4.9.1).
- Verified, no edit: node:26.13-alpine and nginx/nginx-unprivileged:1.31-alpine (4.9.1 Dockerfile); listen 8080 default_server and SPA fallback (nginx.conf); MIT license.
- Unverified (not in fetched sources): SHLINK_SERVER_FORWARD_CREDENTIALS env var (plan line 16) is not in the README, TrueCharts values or docs page; the upstream script `scripts/docker/servers_from_env.sh` was not in urls.txt and not fetched.
