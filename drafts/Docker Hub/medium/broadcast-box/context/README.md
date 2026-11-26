# Context index: broadcast-box

| Source URL | File |
| --- | --- |
| https://github.com/Glimesh/broadcast-box (README via raw) | github-glimesh-broadcast-box-readme.md |
| https://github.com/Glimesh/broadcast-box/blob/484a22832dcea141ff3ac984f2f038cacf8aa678/Dockerfile | github-glimesh-dockerfile-484a228.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/broadcast-box (raw values.yaml) | truecharts-broadcast-box-values.md |
| https://hub.docker.com/r/seaduboi/broadcast-box (HTML) + /v2 repo and tags JSON | dockerhub-seaduboi-broadcast-box.md |
| https://raw.githubusercontent.com/.../charts/stable/broadcast-box/Chart.yaml | truecharts-broadcast-box-values.md (Chart.yaml section) |

Skipped categories: none.

Failures: none.

## plan.md corrections
- None edited. Upstream Dockerfile (484a228) has no EXPOSE, consistent with plan.
- Unverified: the plan's listed Go 1.26.0 requirement (go.mod) and Vite 8 were not fetched; not checked.
- Port note: plan's defaults (8080 TCP + UDP_MUX_PORT 8080) match README; the TrueCharts chart uses UDP 60006 instead, which differs from the plan's choice (not a plan error, just a different default).
