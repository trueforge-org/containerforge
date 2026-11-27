# Context README: plant-it

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plant-it/values.yaml | truecharts-plant-it.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plant-it/Chart.yaml | truecharts-plant-it.md |
| https://hub.docker.com/v2/repositories/msdeluise/plant-it-server/ | dockerhub-plant-it.md |
| https://hub.docker.com/v2/repositories/msdeluise/plant-it-server/tags?page_size=10 | dockerhub-plant-it.md |
| https://raw.githubusercontent.com/MDeLuise/plant-it/0.10.0/deployment/Dockerfile | github-plant-it.md |
| https://api.github.com/repos/MDeLuise/plant-it/license | github-plant-it.md (failed, DNS; alternative https://github.com/MDeLuise/plant-it used) |
| https://github.com/MDeLuise/plant-it | github-plant-it.md (alternative for license) |

Skipped: CLA/none; forgetool schemas/none; containerforge apps links/none; templated URLs/none; binary downloads (server.jar, client.tar.gz, not fetched); image refs/none; GitHub release tag page, blob view, raw Dockerfile variants (duplicates or budget).

Failures:
- https://api.github.com/repos/MDeLuise/plant-it/license: DNS error (EAI_AGAIN). One alternative tried (repo HTML page), succeeded.

## plan.md corrections
- None. Verified: Dockerfile `FROM alpine:3.20.2`, `ARG JAVA_VERSION=21`, `EXPOSE 8080` and `3000`, `CMD` start.sh, no ENV/USER/VOLUME; license GPL-3.0; Docker Hub 0.10.0 2024-12-10 amd64 and arm64.
- Unverified conflict (not edited): plan.md line 8 "Latest release is 1.0.1 (2026-01-07)" was not fetched here (no releases call in this budget).
- Chart env names (MYSQL_*, CACHE_*, JWT_*, etc.) are chart-defined and not in upstream Dockerfile; plan keeps them UNVERIFIED. Not edited.
