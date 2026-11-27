# Context: libredb-studio

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/libredb-studio/values.yaml + Chart.yaml | truecharts-libredb-studio.md |
| https://raw.githubusercontent.com/libredb/libredb-studio/58adba536f0283fecb7b761053cb2401dd7187eb/{Dockerfile, docker-entrypoint.sh} | github-libredb-libredb-studio-dockerfile.md |
| https://raw.githubusercontent.com/libredb/libredb-studio/58adba536f0283fecb7b761053cb2401dd7187eb/README.md + https://github.com/libredb/libredb-studio/releases/tag/1.3.0 (HTML) | github-libredb-libredb-studio-readme.md |

Skipped: GitHub HTML blob page (covered by raw Dockerfile), repo root, pkgs/container page (registry HTML), https://libredb.org (project homepage, no install detail needed). No Docker Hub URL (image is GHCR). No CLA, forgetool, templated, or binary URLs.

Failures:
- https://api.github.com/repos/libredb/libredb-studio/releases/latest: 403 (not retried). Alternative: releases/tag/1.3.0 HTML fetched OK (date only; no asset names found in static HTML).
- https://api.github.com/repos/libredb/libredb-studio: 403 (not retried).

## plan.md corrections
- None edited. Plan's env/runtime facts match the fetched Dockerfile (bun 1.4.4, node 26.13.0-trixie-slim, PORT 3000, NODE_OPTIONS, WORKFLOW_LOCAL_DATA_DIR, nextjs uid 1001 with gosu entrypoint).
- Plan line 19 "docker-entrypoint.sh UNVERIFIED" is now verified: it resolves the bind address, chowns the data dir, drops to nextjs via gosu (plan's description is accurate).
- Plan line 8 date 2026-11-10 matches the release page. Plan line 12 bundle names not confirmed (asset list not in static HTML).
