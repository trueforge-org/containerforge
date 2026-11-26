# Context: kitchenowl

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kitchenowl/values.yaml + Chart.yaml | truecharts-kitchenowl.md |
| https://hub.docker.com/v2/repositories/tombursch/kitchenowl/ (+ tags) | dockerhub-kitchenowl.md |
| https://hub.docker.com/v2/repositories/tombursch/kitchenowl-web/ (+ tags) | dockerhub-kitchenowl-web.md |
| https://raw.githubusercontent.com/TomBursch/kitchenowl/v0.8.1/backend/Dockerfile (+ wsgi.ini, entrypoint.sh, LICENSE) | github-kitchenowl-backend-dockerfile.md |
| https://raw.githubusercontent.com/TomBursch/kitchenowl/v0.8.1/kitchenowl/Dockerfile | github-kitchenowl-frontend-dockerfile.md |
| https://docs.kitchenowl.org (redirect to /latest/) | docs-kitchenowl-landing.md |

Skipped: CLA, forgetool schemas, containerforge links, templated, binary downloads (kitchenowl_Web.tar.gz, source tarball), image refs: none beyond what urls.txt already removed. Not fetched, redundant or generic: blob/v0.8.1 Dockerfiles (same as raw), github.com/TomBursch/kitchenowl repo root, tombursch.github.io/kitchenowl (same docs site), kitchenowl.org (marketing), releases/expanded_assets and tag pages (covered by API attempt and plan.md).
Shared cache (docs/context/INDEX.md): no hits for this app.

Failed:
- https://api.github.com/repos/TomBursch/kitchenowl/releases/latest: API rate limit (403-style body), not retried.
- Docs "Self hosting" subpages (env/install) not fetched: landing page only. Env facts sourced from upstream files instead.

Notes:
- The TrueCharts values.yaml was captured in two reads of the same URL (first read truncated at 4500 bytes), so the chart page was fetched twice.

## plan.md corrections
- None. Checked: License AGPL-3.0 (LICENSE head confirmed), backend port 8080 vs chart 5000 (both confirmed in wsgi.ini), STORAGE_PATH `/data` (confirmed), entrypoint behaviour (confirmed).
- Unverified, not edited: plan line 94 says `JWT_SECRET_KEY` is not set in the image; upstream backend Dockerfile sets `ENV JWT_SECRET_KEY='PLEASE_CHANGE_ME'`. This is a plan design choice, so left for the author.
- Unverified, not edited: plan line 21 "Conflict" for backend 8080 vs chart 5000 is not a conflict upstream: 5000 is the uwsgi socket, 8080 is the `[web]` HTTP listener proxying to 5000.
