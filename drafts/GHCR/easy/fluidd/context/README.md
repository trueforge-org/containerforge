# Context index: fluidd

| Source URL | File | Status |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fluidd/values.yaml | truecharts-fluidd.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fluidd/Chart.yaml | truecharts-fluidd.md | fetched |
| https://api.github.com/repos/fluidd-core/fluidd/releases/latest | github-fluidd.md | fetched (v1.38.1) |
| https://api.github.com/repos/fluidd-core/fluidd | github-fluidd.md | fetched (license GPL-3.0, default branch develop) |
| https://api.github.com/repos/fluidd-core/fluidd/releases/latest (dup) | github-fluidd.md | same call as above |
| https://github.com/fluidd-core/fluidd | github-fluidd.md | covered by API repo call |
| https://github.com/fluidd-core/fluidd/blob/8823798fbd0e8dda5e1353b6beabef6024940717/Dockerfile | upstream-dockerfile-fluidd.md | same as raw pinned Dockerfile |
| https://raw.githubusercontent.com/fluidd-core/fluidd/master/Dockerfile | upstream-dockerfile-fluidd.md | master variant; pinned 8823798 was fetched as the file, master content not re-fetched |
| https://raw.githubusercontent.com/fluidd-core/fluidd/master/LICENSE | github-fluidd.md | fetched (first lines) |
| https://raw.githubusercontent.com/fluidd-core/fluidd/master/server/nginx/default.conf.template | upstream-dockerfile-fluidd.md | fetched |
| https://docs.fluidd.xyz | none | failed: JS-rendered page, no usable text |

Skipped categories: none beyond the urls.txt filter. Docker Hub: not applicable, image is GHCR.

## Failures
- docs.fluidd.xyz: JS-rendered, no text. Not retried.

## plan.md corrections
- None. Checked plan facts against the fetched chart, release, Dockerfile and nginx template: version 1.38.1, GPL-3.0, `PORT` default 80, `/healthz` returns `ok`, all match.
