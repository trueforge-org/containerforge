# Context: tubesync

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tubesync/values.yaml + Chart.yaml | truecharts-tubesync.md |
| https://hub.docker.com/v2/repositories/ghcr.io/meeb/ and /tags?page_size=10 | dockerhub-tubesync.md (404) |
| https://raw.githubusercontent.com/meeb/tubesync/main/Dockerfile | github-meeb-tubesync.md |
| https://raw.githubusercontent.com/meeb/tubesync/main/README.md (follow-up, not in list) | github-meeb-tubesync.md |
| https://github.com/meeb/tubesync/releases/latest (fallback for api 403) | github-meeb-tubesync.md |

Skipped: GitHub repo root and blob variant (duplicate of raw Dockerfile), api.github.com contents/README.md (raw README used instead), tag page v0.19.1 (latest is v0.19.3), image refs (`debian:13-slim`, `alpine`, `ghcr.io/meeb/s6-overlay`, `ghcr.io/meeb/openresty-repo`, `ghcr.io/astral-sh/uv`, `denoland/deno`), binary downloads (FFmpeg-Builds, s6-overlay tarballs, quickjs).

Failures:
- https://hub.docker.com/v2/repositories/ghcr.io/meeb/ (and /tags): 404, one alternative (hub.docker.com/v2/repositories/meeb/tubesync/) also 404.
- https://api.github.com/repos/meeb/tubesync/releases/latest: 403 rate limit; fallback to HTML redirect succeeded.

## plan.md corrections
- None verified.
