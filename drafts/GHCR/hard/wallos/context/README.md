# Context: wallos

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/wallos/values.yaml + Chart.yaml | truecharts-wallos.md |
| https://raw.githubusercontent.com/ellite/Wallos/v5.11.2/Dockerfile (+ df7ce2d commit Dockerfile, identical) | ellite-wallos-dockerfile.md |
| https://api.github.com/repos/ellite/Wallos/releases/latest (403), HTML fallback; releases/tag/v5.11.2, v5.11.3 pages | github-ellite-wallos-release.md |

Skipped: github blob variants (duplicates of raw Dockerfile), packages.ubuntu.com php-fpm pages (Dockerfile is alpine, apk packages), image refs (`php:8.3-fpm-alpine`, `ghcr.io/ellite/wallos`), github repo root.

Failures:
- https://api.github.com/repos/ellite/Wallos/releases/latest: 403 rate limit; HTML fallback succeeded.

## plan.md corrections
- None verified. Note: chart pins 5.11.3 while plan Dockerfile URL is tag v5.11.2 (identical Dockerfile at df7ce2d); flagged only.
