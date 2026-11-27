# context: servas

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/servas/values.yaml | truecharts-servas.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/servas/Chart.yaml | truecharts-servas.md |
| https://hub.docker.com/v2/repositories/beromir/servas/ (+ tags?page_size=10) | dockerhub-servas.md |
| https://api.github.com/repos/beromir/Servas/contents/.env.example?ref=088eaa3... | github-servas-dockerfile.md |
| https://api.github.com/repos/beromir/Servas/contents/Dockerfile?ref=088eaa3... | github-servas-dockerfile.md |
| https://api.github.com/repos/beromir/Servas/contents/Dockerfile?ref=v1.2.0 | github-servas-dockerfile.md |
| https://api.github.com/repos/beromir/Servas/contents/docker-entrypoint.sh?ref=088eaa3... | github-servas-dockerfile.md |
| https://api.github.com/repos/beromir/Servas/license | github-servas-dockerfile.md |
| https://api.github.com/repos/beromir/Servas/releases/tags/v1.1.3 | github-servas-dockerfile.md |
| https://github.com/beromir/Servas, /blob/088eaa3.../Dockerfile, /releases/tag/v1.1.3 | skipped: HTML/blob variants, api used |

Skipped categories: GitHub HTML/blob/release pages (api variants used).

Failures: none.

## plan.md corrections
- Edited plan.md line 8 and line 136: the plan said the TrueCharts chart pins `beromir/servas:1.1.3`. The fetched chart values.yaml pins `1.2.0@sha256:662b0d8f...` (appVersion 1.2.0). Old text: "The TrueCharts chart pins `beromir/servas:1.1.3` (`v1.1.3`, ...) ... Decision needed ... or `1.1.3` (chart parity)." New text: chart pins 1.2.0, this plan uses 1.2.0. Line 136 old "the chart is on `1.1.3`" -> "the chart is on `1.2.0`". Source: truecharts-servas.md (values.yaml).
- Confirmed (no edit): plan line 14 Dockerfile stage bases (1.13.4 for v1.1.3, 1.13.6 for v1.2.0), plan line 16 entrypoint, plan line 17 port 80 (SERVER_NAME=:80),
- Confirmed: Docker Hub 1.1.3 has amd64 and arm64 (dockerhub-servas.md).
