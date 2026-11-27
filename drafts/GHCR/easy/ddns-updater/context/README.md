# Context index: ddns-updater

| Source URL | File | Status |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ddns-updater/values.yaml | truecharts-ddns-updater.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ddns-updater/Chart.yaml | truecharts-ddns-updater.md | fetched |
| https://api.github.com/repos/qdm12/ddns-updater/releases/tags/v2.10.0 | github-release-v2.10.0-ddns-updater.md | fetched |
| https://raw.githubusercontent.com/qdm12/ddns-updater/v2.10.0/Dockerfile | upstream-dockerfile-ddns-updater.md | fetched |
| https://github.com/qdm12/ddns-updater/blob/v2.10.0/Dockerfile | upstream-dockerfile-ddns-updater.md | same as raw Dockerfile, not fetched twice |
| https://github.com/qdm12/ddns-updater | github-readme-ddns-updater.md | covered by raw README (master) |
| https://github.com/qdm12/ddns-updater/blob/master/README.md | github-readme-ddns-updater.md | same as raw README, fetched via raw |
| https://raw.githubusercontent.com/qdm12/ddns-updater/master/README.md | github-readme-ddns-updater.md | fetched (Docker, env, config lines) |
| https://raw.githubusercontent.com/qdm12/ddns-updater/v2.10.0/LICENSE | none | fetched, checked only: MIT License, Copyright (c) 2019 Quentin McGaw |
| https://github.com/qdm12/ddns-updater/tree/master/docs | none | not fetched: HTML tree, docs are per-provider and not needed for the container build |
| https://hc-ping.com | none | not fetched: healthchecks.io ping base URL, already recorded in the upstream env table (default `https://hc-ping.com`) |

Skipped categories: none beyond the urls.txt filter. Docker Hub: not fetched; chart image is GHCR (`ghcr.io/qdm12/ddns-updater`), upstream's Docker Hub mirror `qmcgaw/ddns-updater` is noted in the README file only.

## Failures
- None.

## plan.md corrections
- None. Checked: plan's `UNVERIFIED` LICENSE path (`.../v2.10.0/LICENSE`) now verified by fetch (MIT). No factual error to fix.
- Note (not edited): the chart's port 10227 with `LISTENING_ADDRESS` templated to `:10227` differs from the image default 8000; the plan's container port 8000 is the upstream default and is not an error for the container itself.
