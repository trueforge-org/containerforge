# Context: firefox

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/firefox/values.yaml | truecharts-firefox.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/firefox/Chart.yaml | truecharts-firefox.md |
| https://raw.githubusercontent.com/linuxserver/docker-firefox/1be26bbc8f8aa6fea0e94f46a68bbc660a030d47/Dockerfile | dockerfile-linuxserver-firefox.md |
| https://hub.docker.com/v2/repositories/linuxserver/firefox/ (+ /tags?page_size=10) | dockerhub-firefox.md |
| https://product-details.mozilla.org/1.0/firefox_versions.json | mozilla-product-details.md |

Skipped categories: binary downloads (archive.mozilla.org tarballs x2, SHA512SUMS, download.mozilla.org x2), blob duplicate of the Dockerfile, boilerplate (MPL 2.0 page, support.mozilla.org, mozilla-firefox/firefox repo root), image refs (ghcr.io/linuxserver/baseimage-selkies not fetched).

Failures: none.

## plan.md corrections
None. plan.md already pins 161.0 and port 3001, matching the fetched sources.
