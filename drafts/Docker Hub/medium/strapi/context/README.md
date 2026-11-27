# Context index: strapi

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/strapi/values.yaml | truecharts-strapi.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/strapi/Chart.yaml | truecharts-strapi.md |
| https://hub.docker.com/v2/repositories/vshadbolt/strapi/ | dockerhub-strapi.md |
| https://hub.docker.com/v2/repositories/vshadbolt/strapi/tags?page_size=10 | dockerhub-strapi.md |
| https://docs.strapi.io | strapi-docs-docker.md (main page not fetched; the Docker guide below is the relevant page) |
| https://docs.strapi.io/cms/installation/docker | strapi-docs-docker.md |
| https://raw.githubusercontent.com/naskio/docker-strapi/96fd6e7/images/strapi-alpine/Dockerfile | naskio-strapi-dockerfile.md |
| https://raw.githubusercontent.com/strapi/strapi/develop/LICENSE | strapi-docs-docker.md |

Skipped categories: GitHub HTML pages (`github.com/naskio/docker-strapi`, `blob/...Dockerfile`, `github.com/strapi/strapi`) covered by raw URLs; `docs.strapi.io` root page not fetched (budget, the Docker guide has the install facts).

Failures: none.

## plan.md corrections
None edited. Checked and consistent: port 1337; docs use `node:22-alpine`; MIT Expat Community Edition with `ee/` caveat; naskio Dockerfile content; required env var names; chart `vshadbolt/strapi:5.57.0-alpine`.
Unverified against fetched data (left as-is): plan line 8 claim of GitHub release v5.63.0 and npm dist-tag (not fetched); the SQLite default for Strapi 5.63 (docs do not state it).
