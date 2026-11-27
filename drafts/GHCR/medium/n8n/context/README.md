# Context: n8n (fetched 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/n8n/values.yaml | truecharts-n8n.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/n8n/Chart.yaml | truecharts-n8n.md |
| https://docs.n8n.io | docs-n8n.md |
| https://docs.n8n.io/hosting/configuration/environment-variables/ (follow-up) | docs-n8n.md |
| https://docs.n8n.io/hosting/installation/docker/ (follow-up) | docs-n8n.md |
| https://github.com/n8n-io/n8n | github-n8n-repo.md |
| https://github.com/n8n-io/n8n/releases/tag/n8n%402.49.6 | github-n8n-repo.md (not fetched directly; latest-release page used instead) |
| https://github.com/n8n-io/n8n/blob/n8n@3.3.0/docker/images/n8n/Dockerfile | github-n8n-dockerfile.md (raw variant) |
| https://raw.githubusercontent.com/n8n-io/n8n/master/docker/images/n8n/Dockerfile | github-n8n-dockerfile.md |
| https://raw.githubusercontent.com/n8n-io/n8n/master/LICENSE.md | github-n8n-license.md |
| https://n8n.io | n8n-io-homepage.md |
| https://registry.npmjs.org/n8n/latest | npm-n8n.md |

Skipped categories: none (no CLA, forgetool, containerforge, templated, binary-download or image-ref URLs in the list).

Failures:
- https://api.github.com/repos/n8n-io/n8n/releases/latest: 403. Alternative https://github.com/n8n-io/n8n/releases/latest (HTML) used once; it showed `n8n@2.49.8`. Asset list not available.

## plan.md corrections

No edits made. Unverified conflicts (maintainer decision, plan section 10):
- plan.md says latest release and npm `latest` are `2.49.6`. Fetched 2026-11-27: GitHub latest page and npm `latest` both show `2.49.8`.
- plan.md section 1 says the chart tag `3.3.0` is unconfirmed. TrueCharts chart `appVersion` and image tag are `3.4.1`, which is higher than either release seen.
