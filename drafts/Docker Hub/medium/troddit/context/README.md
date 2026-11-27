# Context index: troddit

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/troddit/values.yaml | truecharts-troddit.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/troddit/Chart.yaml | truecharts-troddit.md |
| https://hub.docker.com/v2/repositories/bsyed/troddit/ | dockerhub-troddit.md |
| https://hub.docker.com/v2/repositories/bsyed/troddit/tags?page_size=10 | dockerhub-troddit.md |
| https://raw.githubusercontent.com/burhan-syed/troddit/main/Dockerfile | github-troddit-dockerfile.md |
| https://raw.githubusercontent.com/burhan-syed/troddit/main/package.json | github-troddit-dockerfile.md |
| https://api.github.com/repos/burhan-syed/troddit | not retrieved (403 rate limit), see failures |

Skipped categories: GitHub HTML pages (`github.com/burhan-syed/troddit`, `blob/eafe83d.../Dockerfile`) covered by the raw main Dockerfile; `api.github.com/.../contents/next.config.js` not fetched (budget: 3 follow-ups used on Dockerfile, package.json and the repo API).

Failures:
- https://api.github.com/repos/burhan-syed/troddit: HTTP 403 (API rate limit). Single attempt, not retried; no alternative fetched.

## plan.md corrections
None edited. Checked and consistent: Docker Hub has only the `latest` tag, last updated 2025-07-28, with amd64 and arm64; upstream Dockerfile (three stages on node:18-alpine, `portnum` 3000, USER nextjs, `node server.js`); package.json next `^13.4.4`, react `^18.2.0`, yarn `1.22.19` via `packageManager`.
Unverified (not edited): AGPL-3.0 (repo API rate-limited); `next.config.js` `output: "standalone"` (contents API not fetched); release/tag absence (releases API not fetched).
