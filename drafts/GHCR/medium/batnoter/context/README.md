# Context sources: GHCR/medium/batnoter

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/batnoter/values.yaml + Chart.yaml | truecharts-batnoter.md |
| https://raw.githubusercontent.com/batnoter/batnoter/8722c3af2b81233f158ca17e4818b9251c8cc1d3/Dockerfile (blob URL in urls.txt) + nginx/default.conf | github-batnoter-dockerfile.md |
| https://api.github.com/repos/batnoter/batnoter (+ /releases/latest), https://github.com/batnoter/batnoter (README raw, master) | github-batnoter-repo.md |
| https://github.com/batnoter/batnoter/releases/tag/v1.0.0 | replaced by api releases/latest (budget rule) |

- Skipped categories: none beyond the release-tag HTML page (replaced by API).
- Shared cache (docs/context/INDEX.md): no hits.
- No Docker Hub URL in urls.txt.
- Failures: none.

## plan.md corrections
- None. Verified against fetched sources: port 3000 (upstream listen/EXPOSE), nginx SPA fallback, nginx:stable-alpine final stage, MIT, v1.0.0 release.
