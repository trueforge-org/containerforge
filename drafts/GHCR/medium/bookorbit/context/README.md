# Context sources: GHCR/medium/bookorbit

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/bookorbit/values.yaml + Chart.yaml | truecharts-bookorbit.md |
| https://raw.githubusercontent.com/bookorbit/bookorbit/c1dd6b4f1947ff50843a155e12e70f1e7d15f0c7/Dockerfile (blob URL in urls.txt) + server/entrypoint.sh + .env.example | github-bookorbit-dockerfile.md |
| https://api.github.com/repos/bookorbit/bookorbit (+ /releases/latest), https://github.com/bookorbit/bookorbit | github-bookorbit-repo.md |
| https://github.com/bookorbit/bookorbit/releases/tag/v3.9.0 | replaced by api releases/latest (budget rule) |

- Skipped categories: none beyond the release-tag HTML page (replaced by API) and the blob URL (served by raw equivalent).
- Shared cache (docs/context/INDEX.md): no hits.
- No Docker Hub URL in urls.txt.
- Failures: none.
- Fetched Dockerfile is commit c1dd6b4f (pre-3.10.0); v3.10.0 Dockerfile not fetched.

## plan.md corrections
- None made. Verified-but-unedited items:
  - plan.md line 99 uses default `postgresql` for `POSTGRES_HOST`; upstream entrypoint.sh defaults to `postgres` (`${POSTGRES_HOST:-postgres}`). Port default `5432` matches. Plan line 132 already flags the names as UNVERIFIED; the names are now confirmed by entrypoint.sh. Default value is a ContainerForge choice; left for the builder.
  - plan.md line 17 lists `APP_PORT` as a container env; in `.env.example` it is a compose host-publish variable only.
  - Chart `values.yaml` already uses `3.10.0` (plan line 8 calls the draft's 3.9.0 outdated; consistent).
