# Context index: cloudreve

| Source URL | File |
| --- | --- |
| https://docs.cloudreve.org/en | docs-cloudreve-en.md |
| https://docs.cloudreve.org/overview/deploy/ (followed sub-page, 1 fetch) | docs-cloudreve-deploy.md |
| https://github.com/cloudreve/Cloudreve (README via raw) | github-cloudreve-readme.md |
| https://github.com/cloudreve/Cloudreve/blob/9f1e0b8333f5c7304a09e1dcb3f9c170dddd63f3/Dockerfile | github-cloudreve-dockerfile-9f1e0b8.md |
| https://api.github.com/repos/cloudreve/Cloudreve/releases/latest (for releases/latest) | github-release-cloudreve-latest.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/cloudreve (raw values.yaml) | truecharts-cloudreve-values.md |
| https://hub.docker.com/r/cloudreve/cloudreve (HTML) + /v2 repo and tags JSON | dockerhub-cloudreve-cloudreve.md |
| https://raw.githubusercontent.com/.../charts/stable/cloudreve/Chart.yaml | truecharts-cloudreve-values.md (Chart.yaml section) |

Skipped categories: none.

Failures: none.

## plan.md corrections
- None edited. Consistent: version 4.19.1 (latest, 2026-09-18), GPL-3.0, port 5212, alpine:latest upstream base, EXPOSE set, VOLUME /cloudreve/data, CR_CONF_ env prefix.
- Note: the upstream Dockerfile's entrypoint runs supervisord with aria2 (plan omits aria2; consistent with plan's stated choice).
