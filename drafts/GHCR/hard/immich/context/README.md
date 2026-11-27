# Context: immich

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/immich/values.yaml | truecharts-immich.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/immich/Chart.yaml | truecharts-immich.md |
| https://hub.docker.com/v2/repositories/valkey/valkey/ | dockerhub-valkey.md |
| https://hub.docker.com/v2/repositories/valkey/valkey/tags?page_size=10 | dockerhub-valkey.md |
| https://raw.githubusercontent.com/immich-app/immich/v3.4.2/server/Dockerfile | immich-server-dockerfile.md (partial) |
| https://raw.githubusercontent.com/immich-app/immich/v3.4.1/machine-learning/Dockerfile | immich-ml-dockerfile.md (partial) |

Skipped categories: CLA/forgetool schema links, containerforge apps links, templated URLs, binary downloads, image refs (ghcr.io/immich-app/*).
Not fetched (budget/skipped): docs.immich.app, immich.app, github.com/immich-app/immich repo page, github releases/tags/v3.4.2 API, blob variants of raw Dockerfiles (dupes).

Failures:
- https://api.github.com/repos/immich-app/immich/contents/docker/docker-compose.yml?ref=v3.4.2: GitHub API rate limit (403), not retried.

## plan.md corrections
- None applied (no clear factual error proven by fetched sources).
- Unverified conflict: plan row 16 says ML cuda base `nvidia/cuda:12.2.2-runtime-ubuntu22.04`; fetched builder-cuda stage shows `python:3.13-slim-bookworm` (final cuda stage not captured in the truncated fetch).
- Unverified: plan states server `EXPOSE 2283`, `VOLUME /data`, ENTRYPOINT tini; tail of server Dockerfile not captured.
- Unverified: plan ML port 3003 and valkey image docker.io/valkey/valkey:9 not checked.
