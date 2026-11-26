# Context: joplin-server

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/joplin-server/values.yaml + Chart.yaml | truecharts-joplin-server.md |
| https://hub.docker.com/v2/repositories/joplin/server/ (+ tags?page_size=10) | dockerhub-joplin-server.md |
| https://raw.githubusercontent.com/laurent22/joplin/6fcc076/Dockerfile.server (+ dev LICENSE) | github-joplin-dockerfile-server.md |
| https://api.github.com/repos/laurent22/joplin/releases/latest (covers releases/tag v3.7.24, v3.7.6, expanded_assets) | github-joplin-release-latest.md |

Skipped: CLA, forgetool schemas, containerforge links, templated, binary downloads (desktop assets), image refs: none beyond what urls.txt already removed. Not fetched, redundant or generic: blob/6fcc076 Dockerfile (same as raw), github.com/laurent22/joplin repo root, tree/dev/packages/server, joplinapp.org, joplinapp.org/help.

Failed:
- https://raw.githubusercontent.com/laurent22/joplin/dev/.env-sample (empty response; Docker Hub page cites it). DB/mail env come from the chart instead.

## plan.md corrections
- Line 10 (License): `Root LICENSE is GPL-3.0` -> `Root LICENSE states AGPL-3.0-or-later for all code, unless a subdirectory has its own LICENSE` (source: github-joplin-dockerfile-server.md, dev LICENSE raw).
- Unverified, now confirmed by fetched sources (not edited, plan says to confirm): `APP_NAME` default "Joplin Server" (Dockerfile.server ARG IMAGE_NAME); `LICENSE_REQUIRED` default "0" (Dockerfile.server ARG). Build package names in plan line 46 match Dockerfile.server apt line.
- Unverified conflict: plan says DB/mail env not fetched; truecharts-joplin-server.md lists POSTGRES_* and MAILER_* from chart values (chart is not upstream runtime proof).
