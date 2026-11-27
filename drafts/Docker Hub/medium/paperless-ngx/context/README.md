# Context: paperless-ngx

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/paperless-ngx/values.yaml | truecharts-paperless-ngx.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/paperless-ngx/Chart.yaml | truecharts-paperless-ngx.md |
| https://hub.docker.com/v2/repositories/apache/tika/ | dockerhub-apache-tika.md |
| https://hub.docker.com/v2/repositories/apache/tika/tags?page_size=10 | dockerhub-apache-tika.md |
| https://hub.docker.com/v2/repositories/gotenberg/gotenberg/ | dockerhub-gotenberg-gotenberg.md |
| https://hub.docker.com/v2/repositories/gotenberg/gotenberg/tags?page_size=10 | dockerhub-gotenberg-gotenberg.md |
| https://github.com/paperless-ngx/paperless-ngx | github-paperless-ngx-release.md (via api releases/latest) |
| https://github.com/apache/tika-docker/blob/master/minimal/Dockerfile | github-apache-tika-docker-minimal-dockerfile.md (raw variant) |
| https://github.com/apache/tika | not fetched; Docker Hub readme and tika-docker Dockerfile cover the image |
| https://paperless-ngx.readthedocs.io/en/latest | FAILED: "permanently moved" stub page, no content |
| https://docs.paperless-ngx.com/configuration/ | FAILED: Cloudflare challenge page ("Just a moment..."), no content |

Skipped categories:
- Binary download: https://dlcdn.apache.org/tika/3.3.3/tika-server-standard-3.3.3.jar (jar, not read)
- Apache release directories and keys: https://archive.apache.org/dist/tika/3.4.0 , https://downloads.apache.org/tika/KEYS (not fetched; covered by Docker Hub tags and Dockerfile)

Failures: 2 (readthedocs moved stub; docs.paperless-ngx.com Cloudflare challenge). Not retried.

## plan.md corrections
- Edited (plan.md is the tika plan; target apps/tika):
  - line 10: "The draft and the TrueCharts chart pin `apache/tika:3.3.3.1`, which is older." -> "The draft pins `apache/tika:3.3.3.1`, which is older. The TrueCharts chart pins `apache/tika:3.4.0.0` (fetched 2026-11-27), not 3.3.3.1." Source: truecharts-paperless-ngx.md (values.yaml tikaImage tag)
  - line 199: "The chart still points at `apache/tika` tag `3.3.3.1`, so the chart upgrade to 3.4.0 is a separate downstream change." -> "The chart points at `apache/tika` tag `3.4.0.0` (fetched 2026-11-27), so it already matches 3.4.0." Source: same
  - line 200: "Version: 3.4.0 is newer than the chart's 3.3.3.1." -> "Version: 3.4.0 matches the chart's current pin (3.4.0.0)." Source: same
- Unverified: the draft's own 3.3.3.1 claim was not checked (draft.md not read).
