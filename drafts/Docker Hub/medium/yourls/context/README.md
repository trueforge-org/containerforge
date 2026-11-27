# Context index: yourls

Built 2026-11-27.

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/yourls/values.yaml | truecharts-yourls.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/yourls/Chart.yaml | truecharts-yourls.md |
| https://hub.docker.com/v2/repositories/library/yourls/ | dockerhub-yourls.md |
| https://hub.docker.com/v2/repositories/library/yourls/tags?page_size=10 | dockerhub-yourls.md |
| https://github.com/YOURLS/YOURLS/releases/latest (fallback for API) | github-yourls-yourls.md |
| https://raw.githubusercontent.com/YOURLS/YOURLS/master/user/config-sample.php | github-yourls-yourls.md |
| https://github.com/YOURLS/YOURLS (repo root) | github-yourls-yourls.md (not fetched) |
| https://raw.githubusercontent.com/YOURLS/containers/ab773d7d9e7408f66b532736ceea60324b9f3e3f/images/yourls/Dockerfile.template (blob URL in urls.txt) | github-yourls-containers-dockerfile-template.md |
| https://docs.yourls.org | docs-yourls-org.md |
| https://yourls.org, https://yourls.org/docs | not fetched (redundant with docs.yourls.org) |

Skipped categories: none of the filtered list was boilerplate, templated or binary; GitHub repo root and yourls.org home not fetched (covered elsewhere).

Failures:
- https://api.github.com/repos/YOURLS/YOURLS (HTTP 403, rate limit)
- https://api.github.com/repos/YOURLS/YOURLS/releases (HTTP 403, rate limit)
- https://yourls.org/docs/guide/requirements (HTTP 404)

## plan.md corrections
- Line 20, upstream image digest: `2cc01addde3f...` -> `4e5ec5cdc4be3470bf2a718a1b77c01525498c7b770119bd2a1ed669dd4c529a` (source: truecharts-yourls.md, values.yaml `image.tag`).

Unverified conflicts (not edited):
- plan.md line 8 release date 2026-08-30 came from the API that returned 403 in this run; not re-verified.
- plan.md line 17 says `YOURLS_USER`/`YOURLS_PASS` are unverified; dockerhub-yourls.md (official image full_description) lists them as Required env vars for the upstream image.
- plan.md line 21 says docs.yourls.org redirects to the requirements page; the fetch of docs.yourls.org returned HTTP 200 (home page), and the requirements URL returned 404.
