# context: foxxmd/multi-scrobbler

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/multi-scrobbler/values.yaml | truecharts-multi-scrobbler.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/multi-scrobbler/Chart.yaml | truecharts-multi-scrobbler.md |
| https://hub.docker.com/v2/repositories/foxxmd/multi-scrobbler/ | dockerhub-foxxmd-multi-scrobbler.md |
| https://hub.docker.com/v2/repositories/foxxmd/multi-scrobbler/tags?page_size=10 | dockerhub-foxxmd-multi-scrobbler.md |
| https://raw.githubusercontent.com/FoxxMD/multi-scrobbler/d164f568.../Dockerfile (+ github Dockerfile blob variant) | github-foxxmd-multi-scrobbler-dockerfile.md |
| https://raw.githubusercontent.com/FoxxMD/multi-scrobbler/0.21.1/.env.example | github-foxxmd-multi-scrobbler-env-example.md |
| https://raw.githubusercontent.com/FoxxMD/multi-scrobbler/0.21.1/README.md | github-foxxmd-multi-scrobbler-readme.md |
| https://github.com/FoxxMD/multi-scrobbler | covered by Dockerfile and README |
| https://github.com/FoxxMD/multi-scrobbler/releases/tag/0.21.1 | not fetched (tag 0.21.1 used via raw URLs) |
| https://docs.multi-scrobbler.app/installation | docs-multi-scrobbler-app.md (NOT SUMMARIZED: JS-only shell) |
| https://foxxmd.github.io/multi-scrobbler/configuration | not fetched (budget; docs shell pattern) |

Skipped: none by category (no CLA/template/binary/image-ref lines in this urls.txt).

Failures:
- https://docs.multi-scrobbler.app/installation: returned Starlight shell only, no content (not retried)

## plan.md corrections
- No edits made.
- Unverified conflict (not changed): plan.md line 8 says latest stable is 0.21.2 (published 2026-11-22). This context fetched tag 0.21.1 files only; the 0.21.2 release was not checked here.
- Plan line 16 says the image CMD is `/app/src/backend/index.ts`; not checked here (the Dockerfile tail fetched showed only the distroless ENTRYPOINT note).
