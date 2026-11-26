# Context index: gokapi

Fetched 2026-11-26.

## Sources summarised

| Source URL | Summary file |
| --- | --- |
| https://github.com/Forceu/Gokapi | github-forceu-gokapi.md |
| https://raw.githubusercontent.com/Forceu/Gokapi/9a4b289c604198c05589e34314e889d2c25386d8/Dockerfile | github-forceu-gokapi.md |
| https://raw.githubusercontent.com/Forceu/Gokapi/9a4b289c604198c05589e34314e889d2c25386d8/dockerentry.sh | github-forceu-gokapi.md |
| https://raw.githubusercontent.com/Forceu/Gokapi/v2.2.4/internal/environment/Environment.go | github-forceu-gokapi.md |
| https://raw.githubusercontent.com/Forceu/Gokapi/v2.2.4/LICENSE.md | github-forceu-gokapi.md |
| https://github.com/Forceu/Gokapi/releases/tag/v2.2.4 | github-forceu-gokapi.md (asset list did not load) |
| https://hub.docker.com/r/f0rc3/gokapi | dockerhub-f0rc3-gokapi.md |
| https://gokapi.readthedocs.io/en/latest/ | docs-gokapi-readthedocs-io.md (index only) |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/gokapi | truecharts-gokapi.md (values.yaml fetched; listing not fetched) |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gokapi/values.yaml | truecharts-gokapi.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page (only the user can sign) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/Forceu/Gokapi/releases/download/v2.2.4/gokapi-2.2.4_linux-amd64.zip | direct archive download; pattern `gokapi-<ver>_linux-<arch>.zip` recorded |
| https://github.com/Forceu/Gokapi/releases/download/v2.2.4/gokapi-2.2.4_linux-arm64.zip | direct archive download; pattern recorded |
| https://github.com/Forceu/gokapi (draft's lowercase spelling) | same repo as Forceu/Gokapi (GitHub is case-insensitive); fetched once |
| https://github.com/Forceu/Gokapi/blob/9a4b289.../Dockerfile (blob form) | same file as the raw Dockerfile URL |
| https://raw.githubusercontent.com/Forceu/Gokapi/9a4b289.../LICENSE.md | not fetched at that commit; the v2.2.4 LICENSE.md was read instead |
| ghcr.io/trueforge-org/ubuntu | ghcr image ref, not a web page |
| golang:1.26.1-alpine, alpine:3.19 | build/base image references, not web pages |

## Fetch failures

- https://raw.githubusercontent.com/Forceu/Gokapi/9a4b289.../run.sh: HTTP 404 (the Dockerfile COPYs `dockerentry.sh` to `/app/run.sh`). Retried as `dockerentry.sh`, which succeeded.
- https://github.com/Forceu/Gokapi/releases/tag/v2.2.4: page loaded, asset list did not (error placeholder). Asset names and digests from plan.md were not re-checked.
- https://gokapi.readthedocs.io/en/latest/: index only; sub-pages not fetched (budget).

## plan.md corrections

None made. No fact in the fetched sources clearly contradicted plan.md. Items left as unverified (not edited):
- plan.md section 1: Docker Hub has `v2.2.4`, `latest` and `latest-dev`. The Hub page showed only `latest`. Unverified.
- plan.md section 1 and 4: SHA-256 values for the amd64 and arm64 zips. The release asset list did not load, so they were not re-verified here.
- plan.md section 10: `AGPL-3.0-only` versus `-or-later`. The LICENSE.md text has the "or any later version" wording in its notice template, but no project-specific statement was found. Left as in plan.md.
- plan.md section 1: `IsDocker` build flag and setup form `localhost_sel` default `No`. Not re-checked (setup.tmpl not fetched).

Noted for the PR (not a plan edit): the TrueCharts chart sets `GOKAPI_USERNAME` and `GOKAPI_PASSWORD`, which are not in Environment.go at v2.2.4.
