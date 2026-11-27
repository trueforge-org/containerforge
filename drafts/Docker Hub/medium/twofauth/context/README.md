# Context index: twofauth

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/twofauth/values.yaml + Chart.yaml | truecharts-twofauth.md |
| https://hub.docker.com/v2/repositories/2fauth/2fauth/ + tags?page_size=10 | dockerhub-2fauth.md |
| https://raw.githubusercontent.com/Bubka/2FAuth/v9.0.3/Dockerfile (alt for API contents 403) | twofauth-dockerfile.md |
| https://raw.githubusercontent.com/Bubka/2FAuth/v9.0.3/docker/entrypoint.sh (alt for API contents 403) | twofauth-entrypoint.md |
| https://raw.githubusercontent.com/Bubka/2FAuth/v9.0.3/docker/nginx.conf (alt for API contents 403) | twofauth-nginx-conf.md |
| https://raw.githubusercontent.com/Bubka/2FAuth/v9.0.3/.env.example (alt for API contents 403) | twofauth-env-example.md |
| https://raw.githubusercontent.com/Bubka/2FAuth/v9.0.3/docker/supervisord.conf | twofauth-supervisord-conf.md |
| https://github.com/Bubka/2FAuth/releases/latest (alt for releases API 403) | github-release-v9.0.3.md |

Skipped (one line): HTML blob/repo duplicates of raw files, lowercase repo dup (github.com/Bubka/2fauth), releases/tag/v9.0.1 (older than latest), docs.2fauth.app and 2fauth.app (not build inputs). No CLA, forgetool schema, containerforge or image-ref URLs in this list.
Failures: https://api.github.com/repos/Bubka/2FAuth (403 rate limit; repo metadata only, not needed; not retried).
API 403 (rate limit) for the four contents URLs and releases/latest were each replaced by one raw/HTML alternative, which succeeded.

## plan.md corrections
- No in-place edits.
- Unverified conflict: plan.md says "The chart pins `docker.io/2fauth/2fauth:9.0.1`". The TrueCharts master values.yaml (fetched 2026-11-27) pins `9.0.3@sha256:fb421b40...`. The plan describes the chart state when it was written, so it was left as is. Check before merge.
- Plan facts checked and matching the fetched sources: port 8000, UID/GID 1000, PHP 8.4 / Alpine 3.24 / composer 2.9 / supervisord v0.7.3, nginx `listen 8000` and `root /srv/public`, env list, entrypoint behaviour, latest release v9.0.3.
