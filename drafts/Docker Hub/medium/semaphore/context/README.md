# context: semaphore

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/semaphore/values.yaml | truecharts-semaphore.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/semaphore/Chart.yaml | truecharts-semaphore.md |
| https://hub.docker.com/v2/repositories/semaphoreui/semaphore/ (+ tags?page_size=10) | dockerhub-semaphore.md |
| https://api.github.com/repos/semaphoreui/semaphore/contents/deployment/docker/server/server-wrapper?ref=7cf38e07... (rate-limited; raw used) | github-semaphore-dockerfile.md |
| https://raw.githubusercontent.com/semaphoreui/semaphore/7cf38e07.../deployment/docker/server/server-wrapper (alternative) | github-semaphore-dockerfile.md |
| https://api.github.com/repos/semaphoreui/semaphore/contents/deployment/docker/server/Dockerfile?ref=7cf38e07... (blob URL in list) | github-semaphore-dockerfile.md |
| https://raw.githubusercontent.com/semaphoreui/semaphore/7cf38e07.../deployment/docker/server/Dockerfile (alternative) | github-semaphore-dockerfile.md |
| https://api.github.com/repos/semaphoreui/semaphore/license | github-semaphore-dockerfile.md |
| https://api.github.com/repos/semaphoreui/semaphore/releases/latest and releases/tags/v2.20.24 (follow-up) | github-semaphore-dockerfile.md |
| https://raw.githubusercontent.com/semaphoreui/semaphore/v2.20.23/LICENSE | skipped: MIT via license API |
| https://semaphoreui.com/docs | docs-semaphore-docs.md |
| https://github.com/ansible-semaphore/semaphore, https://github.com/semaphoreui/semaphore (HTML) | skipped: HTML pages, api/raw used |

Skipped categories: GitHub HTML/blob pages; LICENSE raw (license API used).

Failures: 1 (semaphoreui.com/docs, nav/JS only, no config content; docs-semaphore-docs.md). Not retried. The api contents call hit a rate limit (403) once; the raw variant was used (one alternative), so it is not counted as a failure.

## plan.md corrections
- No edits made.
- Confirmed by fetch: plan line 8 (`releases/latest` = v2.20.23; `releases/tags/v2.20.24` = Not Found). Docker Hub v2.20.24 tag exists, chart pins v2.20.24 (the chart and draft use v2.20.24; plan intentionally uses 2.20.23). Decision for the author: plan keeps 2.20.23 because no GitHub release exists for 2.20.24.
- Confirmed: Dockerfile (golang:1.26-alpine3.24, alpine:3.24, USER 1001, EXPOSE 3000, tini ENTRYPOINT, CMD server-wrapper); license MIT (plan line 10).
- Plan line 18 env names (SEMAPHORE_CONFIG_PATH, SEMAPHORE_DB_PATH, SEMAPHORE_DB_PORT) are present in server-wrapper; defaults not checked against the file text beyond the names.
