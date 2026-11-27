# Context: maloja

Fetched 2026-11-27. Summaries of the web sources in urls.txt.

## Source -> file
| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/maloja/values.yaml | truecharts-maloja.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/maloja/Chart.yaml | truecharts-maloja.md |
| https://hub.docker.com/v2/repositories/krateng/maloja/ | dockerhub-maloja.md |
| https://hub.docker.com/v2/repositories/krateng/maloja/tags?page_size=10 | dockerhub-maloja.md |
| https://github.com/krateng/maloja/blob/v3.2.10/Containerfile | github-maloja-containerfile.md |
| https://github.com/krateng/maloja/blob/HEAD/requirements.txt | github-maloja-requirements.md |
| https://github.com/krateng/maloja | github-maloja-repo.md |

Not in shared cache (docs/context/INDEX.md): no hits.

## Skipped
- None from urls.txt. No CLA, forgetool, containerforge, templated, binary-download or image-ref URLs in the list.

## Failures
- https://maloja.krateng.ch: DNS error (getaddrinfo ENOTFOUND). Not retried. The repo README covers the same project information (install, env, port, paths, license).

## plan.md corrections
- None made. Plan values checked against fetched sources (version 3.2.10, Containerfile base lsiobase/alpine:3.21, port 42010, env vars, Python dependency list, GPL-3.0, upstream root default PUID/PGID 0) and all match.
- Unverified conflicts (not edited):
  - plan says Docker Hub `latest` and `3.2.10` were both last updated 2026-11-06; API now reports `latest` and `3.2.11` both at 2026-11-26 (`latest` no longer points at 3.2.10). Plan pins 3.2.10, so no change needed, but the plan's tag note is stale.
  - Upstream has a 3.2.11 tag (2026-11-26) not mentioned in the plan.
