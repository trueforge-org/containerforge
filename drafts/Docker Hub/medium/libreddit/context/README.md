# Context: libreddit

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/libreddit/values.yaml + Chart.yaml | truecharts-libreddit.md |
| https://hub.docker.com/v2/repositories/libreddit/libreddit/ (+ tags) | dockerhub-libreddit.md |
| https://raw.githubusercontent.com/spikecodes/libreddit/9b7ee50/Dockerfile (blob variant listed in urls.txt) | github-libreddit-dockerfile.md |
| https://raw.githubusercontent.com/libreddit/libreddit/master/README.md (repo root, libreddit/libreddit and spikecodes/libreddit) | github-libreddit-readme.md |

Skipped: CLA, forgetool schemas, containerforge links, templated, binary downloads, image refs: none beyond what urls.txt already removed. Not fetched, redundant: blob/9b7ee50 Dockerfile (same as raw), github.com/spikecodes/libreddit repo root (README covers it; the spikecodes README was not fetched separately), github.com/libreddit/libreddit repo root (fetched via raw README).
Shared cache (docs/context/INDEX.md): no hits for this app.

Failed:
- https://api.github.com/repos/libreddit/libreddit/releases/latest: API rate limit (403), not retried. plan.md cites v0.30.1 (2023-03-11); not re-verified here.

## plan.md corrections
- None proven wrong by fetched sources. Checked: Docker Hub latest 2024-03-05 / latest-arm 2023-11-29 / latest-armv7 2024-03-05 (match plan line 21); upstream Dockerfile stages, port 8080, healthcheck /settings (match plan lines 16-20); chart port 10257 -> 8080 (match).
- Not verified here: License AGPL-3.0 (plan line 11), v0.30.1 latest release (plan line 8).
- Note for author (not a plan error): upstream README says the project is non-operational since 2023-07-12 (Reddit API change). Plan does not mention this.
