# context: searxng

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/searxng/values.yaml | truecharts-searxng.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/searxng/Chart.yaml | truecharts-searxng.md |
| https://hub.docker.com/v2/repositories/searxng/searxng/ (+ tags?page_size=10) | dockerhub-searxng-searxng.md |
| https://hub.docker.com/v2/repositories/searxng/base/ (+ tags?page_size=10) | dockerhub-searxng-base.md |
| https://raw.githubusercontent.com/searxng/searxng/1ebea4a073ec6011bae25c042d97308278184c83/container/Dockerfile | github-searxng-dockerfile.md |
| https://raw.githubusercontent.com/searxng/base/main/Dockerfile | github-searxng-dockerfile.md |
| https://raw.githubusercontent.com/searxng/searxng/master/container/entrypoint.sh | github-searxng-dockerfile.md |
| https://raw.githubusercontent.com/searxng/searxng/master/container/settings.template.yml | github-searxng-dockerfile.md |
| https://raw.githubusercontent.com/searxng/searxng/master/requirements.txt | github-searxng-dockerfile.md |
| https://api.github.com/repos/searxng/searxng/releases/latest (Not Found) | github-searxng-dockerfile.md |
| https://docs.searxng.org | skipped: root page, install page used |
| https://docs.searxng.org/admin/installation-docker.html (follow-up) | docs-searxng-installation-docker.md |
| https://github.com/searxng/searxng, /releases, /blob/... | skipped: HTML pages, raw/api variants used |
| https://raw.githubusercontent.com/searxng/searxng/master/searx/settings.yml | skipped: not fetched (budget; env names from entrypoint) |
| https://github.com/searxng/searxng/blob/HEAD/requirements.txt | skipped: raw variant used |
| https://raw.githubusercontent.com/searxng/searxng/1ebea4a.../container/Dockerfile vs github blob | skipped: duplicate |

Skipped categories: GitHub HTML/blob/releases variants (raw or api used), docs root page, settings.yml (not fetched).

Failures: 1 (docs-searxng-installation-docker.md, no extractable config content). Not retried.

## plan.md corrections
- No edits made.
- Confirmed: Dockerfile (builder/dist stages, EXPOSE 8080, VOLUME x2, ENTRYPOINT entrypoint.sh), entrypoint behaviour (SEARXNG_PORT -> GRANIAN_PORT, exec granian), uid 977.
- Plan line 8 says "Hub manifests per arch not inspected": Docker Hub now shows amd64, arm64, arm for searxng/searxng (see dockerhub-searxng-searxng.md). Not edited (informational).
- Plan line 19 env names: chart's BIND_ADDRESS/INSTANCE_NAME/BASE_URL remain unverified against the image; entrypoint confirms only SEARXNG_PORT.
