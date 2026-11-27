# Context index: vertex

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/vertex/values.yaml + Chart.yaml | truecharts-vertex.md |
| https://hub.docker.com/v2/repositories/lswl/vertex/ + tags?page_size=10 | dockerhub-vertex.md |
| https://raw.githubusercontent.com/vertex-app/vertex/master/docker/Dockerfile (also raw of blob ec6fa1e6 URL, byte-identical) | vertex-dockerfile.md |

Skipped (one line): https://github.com/vertex-app/vertex (repo HTML; source tarball URL is in plan.md, not fetched), blob/ec6fa1e6 URL (duplicate of pinned raw), https://gitlab.lswl.in/lswl/vertex (mirror, not build input). No CLA, forgetool, containerforge, templated, binary-download or image-ref URLs in this list.
Failures: none.

## plan.md corrections
- No in-place edits.
- Checked and matching fetched sources: Dockerfile stages (`lswl/vertex-base:latest`, npm@8.19.4, `TZ=Asia/Shanghai`, `EXPOSE 3000`, `CMD bash /app/vertex/docker/start.sh`), no `USER`, no `VOLUME`, Docker Hub total 41 tags, `stable` tag present.
- Unverified: plan.md's `api.github.com/repos/vertex-app/vertex/releases/latest` (404) and the 2026-11-10 master push were not re-fetched (not in urls.txt).
- Unverified: `docker/start.sh` (env PORT, REDISPORT, PUID, PGID) was not fetched.
