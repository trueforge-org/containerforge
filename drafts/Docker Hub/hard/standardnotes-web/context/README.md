# context: standardnotes-web

| Source URL | File |
| --- | --- |
| https://github.com/standardnotes/app/blob/main/packages/web/Dockerfile (+ packages/web/package.json) | standardnotes-app-web-dockerfile.md |
| https://github.com/standardnotes/app (+ .git variant, same repo) | standardnotes-app-readme.md |
| https://hub.docker.com/r/standardnotes/web | dockerhub-standardnotes-web.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/standardnotes-web | truecharts-standardnotes-web.md |
| https://standardnotes.com | standardnotes-com-and-help.md |
| https://standardnotes.com/help | standardnotes-com-and-help.md (help index) + standardnotes-selfhost-web-app.md (web-app and docker guides, follow-ups) |
| https://standardnotes.org | FAILED (HTTP 526) |

Skipped categories: none present in urls.txt.

## Failures
- https://standardnotes.org : HTTP 526 Unknown Status (origin SSL error). Not retried (no alternative needed; the 5xx is not a 403/404/DNS case). Recorded only.

## plan.md corrections
- none applied (no proven factual error).
- Notes: Docker Hub latest 48.6 MB; TrueCharts pins tag `stable`; upstream Dockerfile is `FROM nginx:alpine` + COPY dist (no USER, no EXPOSE).
