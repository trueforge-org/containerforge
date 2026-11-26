# context: spotweb

| Source URL | File |
| --- | --- |
| https://github.com/joachimbaten/spotweb-docker (+ blob/5c930ba/Dockerfile, entrypoint, config/root scripts, config tree) | joachimbaten-spotweb-docker.md |
| https://github.com/spotweb/spotweb (README), https://github.com/spotweb/spotweb/releases/tag/1.5.4 | spotweb-upstream.md |
| https://hub.docker.com/r/jbaten/spotweb | dockerhub-jbaten-spotweb.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/spotweb | truecharts-spotweb.md |

Skipped categories: none present in urls.txt (CLA, forgetool, containerforge, templated, binary, image-ref: none).

## Failures
- none

## plan.md corrections
- none applied (no proven factual error fixed in place).
- Unverified/conflicting: upstream Dockerfile builds `--branch develop` (unpinned), while TrueCharts and the plan-side tag are 1.5.4 (release published 2023-01-05). Build-time version pinning is therefore not 1.5.4 for the joachimbaten image; flagged, not edited.
- Docker Hub page shows only `latest`, last updated ~3 years ago; digest for 1.5.4 tag unverified.
