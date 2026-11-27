# Context index: truecommand

Built 2026-11-27.

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/truecommand/values.yaml | truecharts-truecommand.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/truecommand/Chart.yaml | truecharts-truecommand.md |
| https://hub.docker.com/v2/repositories/ixsystems/truecommand/ | dockerhub-truecommand.md |
| https://hub.docker.com/v2/repositories/ixsystems/truecommand/tags?page_size=10 | dockerhub-truecommand.md |
| https://www.truenas.com/docs/truecommand | truenas-docs-truecommand.md |

Skipped categories: none.

Failures: none.

## plan.md corrections
None applied. Pinned tag and digest, `latest` = `3.3.0` digest, amd64-only, and chart port 10031 to 80 agree with sources.

Unverified conflicts (not edited):
- plan.md line 18 says the draft's 443 "is UNVERIFIED". dockerhub-truecommand.md shows the vendor run example publishing `-p [sslportnumber]:443`, so the image is documented with 443 as an SSL port. Not a clear error, so left for the author.
- plan.md line 21 says no env list was fetched. Docker Hub documents default login `admin`/`admin` (first-user prompt). Not an env var; no edit.
