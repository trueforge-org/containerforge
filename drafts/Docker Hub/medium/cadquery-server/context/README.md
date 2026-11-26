# Context index: cadquery-server

| Source URL | File |
| --- | --- |
| https://github.com/roipoussiere/cadquery (README via raw, master and main) | github-roipoussiere-cadquery-readme.md (FAILED, 404 both) |
| https://github.com/roipoussiere/cadquery-server (README via raw) | github-roipoussiere-cadquery-server-readme.md |
| https://github.com/roipoussiere/cadquery-server/blob/fe634393ae00cb271aca935a119a560b01140362/Dockerfile | github-roipoussiere-cadquery-server-dockerfile-fe63439.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/cadquery-server (raw values.yaml) | truecharts-cadquery-server-values.md |
| https://hub.docker.com/r/cadquery/cadquery-server (HTML) + /v2 repo and tags JSON | dockerhub-cadquery-cadquery-server.md |
| https://raw.githubusercontent.com/.../charts/stable/cadquery-server/Chart.yaml | truecharts-cadquery-server-values.md (Chart.yaml section) |

Skipped categories: none.

Failures: 1 (roipoussiere/cadquery README, 404 on master and main).

## plan.md corrections
- Unverified conflict: plan.md Source row says the project "moved to Codeberg" per README. Fetched README says no longer supported and points to vscode OCP CAD viewer; it does not name Codeberg. Not edited.
- Consistent: Python 3.10 base (upstream python:3.10), port 5000, ENTRYPOINT cq-server, VOLUME/WORKDIR data, unmaintained status.
