# Context sources: GHCR/medium/bentopdf

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/bentopdf/values.yaml + Chart.yaml | truecharts-bentopdf.md |
| https://raw.githubusercontent.com/alam00000/bentopdf/v2.8.12/Dockerfile (blob URL in urls.txt) + nginx.conf | github-bentopdf-dockerfile.md |
| https://api.github.com/repos/alam00000/bentopdf (+ /releases/latest), README raw, https://github.com/alam00000/bentopdf, https://github.com/alam00000/bentopdf.git | github-bentopdf-repo.md |
| https://www.bentopdf.com | bentopdf-site.md |

- Skipped categories: none beyond the `.git` URL variant (same repo) and the blob URL (served by raw).
- Shared cache (docs/context/INDEX.md): no hits.
- No Docker Hub URL in urls.txt.
- Failures: none.
- Binary assets (`dist-2.8.12.zip`, `dist-simple-2.8.12.zip`) listed in release metadata but not downloaded.

## plan.md corrections
- None made. Full nginx.conf read (plan line 17 said partial): it sets only `pid /etc/nginx/tmp/nginx.pid` among paths; no `*_temp_path` directives. Confirmed `listen 8080` and `root /usr/share/nginx/html`.
- Unverified, not changed: plan line 10/77 AGPL-3.0 vs `AGPL-3.0-only` (LICENSE file not fetched).
