# Context: anope

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/anope/values.yaml + Chart.yaml | truecharts-anope.md |
| https://raw.githubusercontent.com/ich777/docker-anope/master/Dockerfile (+ blob variant) | github-ich777-docker-anope.md |
| https://raw.githubusercontent.com/anope/anope/master/README.md, https://github.com/anope/anope/releases/tag/2.0.21 | github-anope-anope.md |
| https://www.anope.org | anope-org.md |
| https://packages.ubuntu.com/resolute/anope | ubuntu-packages-anope.md |
| https://thelounge.chat | thelounge-chat.md |

Skipped categories: none beyond the filtering already applied to urls.txt. Docker Hub not applicable (GHCR image, no Docker Hub page in list).

Failures:
- https://api.github.com/repos/anope/anope/releases/latest: HTTP 403 (not retried; HTML release page used as alternative)
- https://api.github.com/repos/anope/anope/license: HTTP 403 (not retried; no alternative fetched)

## plan.md corrections
None. Plan values checked against fetched data (latest stable 2.0.21 confirmed by anope.org; Ubuntu package 2.0.17-1.1 confirmed). Plan license GPL-2.0 and "no Linux binary asset" remain unverified here.
