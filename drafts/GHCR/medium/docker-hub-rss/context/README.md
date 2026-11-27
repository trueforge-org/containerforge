# Context index: docker-hub-rss

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/docker-hub-rss/values.yaml | truecharts-docker-hub-rss.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/docker-hub-rss/Chart.yaml | truecharts-docker-hub-rss.md |
| https://raw.githubusercontent.com/TheConnMan/docker-hub-rss/master/Dockerfile | upstream-docker-hub-rss-dockerfile.md |
| https://raw.githubusercontent.com/TheConnMan/docker-hub-rss/master/package.json | upstream-docker-hub-rss-dockerfile.md |

Not fetched (covered by the files above or out of scope): https://github.com/TheConnMan/docker-hub-rss (repo root), and https://github.com/TheConnMan/docker-hub-rss/blob/5c8152db7d37641aa589e2e38a656823f8910d51/Dockerfile (commit-pinned variant; the master raw Dockerfile was used, so the pinned-commit content is unconfirmed).

Skipped categories: none beyond the filtered list.

Failures: none among the listed URLs.

Extra probe (not in urls.txt): https://api.github.com/repos/TheConnMan/docker-hub-rss/releases/latest returned 404 (no releases). The listed https://github.com/TheConnMan/docker-hub-rss/releases returned HTTP 200 but its content was not extracted.

Cache: no hits for this app.

## plan.md corrections
None. Plan facts checked against the fetched Dockerfile, package.json (version 0.6.2, MIT, start `node index.js`, fluent-logger git dependency) and chart values (runAsUser 0, readOnlyRootFilesystem false, service and probes disabled) all match.

Unverified (not edited):
- Plan's PORT default 3000 and FLUENTD_* env vars come from index.js, which was not fetched.
- Plan's commit pin 23c6d2db... and the chart digest's source commit were not checked.
