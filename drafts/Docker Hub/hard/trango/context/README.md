# trango context

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trango-io/trango-self-hosted/master/Dockerfile (also blob URL) | trango-io-trango-self-hosted-dockerfile.md |
| https://raw.githubusercontent.com/trango-io/trango-self-hosted/master/README.md (also https://github.com/trango-io/trango-self-hosted) | trango-io-trango-self-hosted-readme.md |
| https://hub.docker.com/r/tak786/trango-self-hosted | dockerhub-tak786-trango-self-hosted.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/trango/values.yaml | truecharts-trango-values.md |

Skipped categories:
- `https://$host:8443`: templated URL, skipped.
- TrueCharts directory-listing URL: content taken from raw values.yaml.
- `trango-self-hosted` repo root: covered by README fetch.

Failures:
- https://trango.io: returned a bare server directory listing (`cgi-bin/`, `web.trango.io/`), no product description. Not summarized.

Notes: Dockerfile base is ubuntu:18.04 with Node 12 and python3.6 (all EOL). TrueCharts maps 7755/5533 while Dockerfile exposes 80/443.

## plan.md corrections
None.
