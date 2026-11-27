# Context: romm

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/romm/values.yaml + Chart.yaml | truecharts-romm.md |
| https://raw.githubusercontent.com/rommapp/romm/5.4.1/docker/Dockerfile (blob URL at same tag is a duplicate) | romm-docker-dockerfile.md |
| https://docs.romm.app (redirects to /latest/) | romm-docs.md (index only) |
| https://github.com/rommapp/romm/releases/tag/5.4.1 (HTML, after API 403) | romm-release-5.4.1-html.md |
| https://github.com/rommapp/romm (HTML, after API 403; description only) | romm-release-5.4.1-html.md |

Skipped: github.com/rommapp/romm/releases/tag/5.4.1 duplicates were merged into the release file; https://github.com/zurdi15/romm (resolves to the rommapp/romm page, a fork link, no separate content); api.github.com/repos/rommapp/romm (403, HTML used).
No Docker Hub URL in list (image is GHCR).

Failures:
- https://docs.romm.app/latest/Getting-Started/Environment-Variables/: redirect loop, no content. Not retried. Env names taken from the chart comments and the Dockerfile instead.
- https://api.github.com/repos/rommapp/romm/releases/tags/5.4.1 and https://api.github.com/repos/rommapp/romm: 403 rate limit. HTML pages used, which gave only title and description (no asset list, no license).

## plan.md corrections
None. Checked plan facts against the full chart values (image digest, env names DB_*, REDIS_*, persistence paths, dependencies), the full Dockerfile (Alpine stages, APK list, EXPOSE 8080 6379/tcp, VOLUME, romm uid 1000, no USER, ENTRYPOINT/CMD). No clear factual error proven.
Unverified (not settled by these fetches): release date 2026-10-22, AGPL-3.0 license (API only), GHCR arch list, which port 5.4.1 binds.
