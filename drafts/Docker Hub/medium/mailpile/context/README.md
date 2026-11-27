# Context: mailpile

Fetched 2026-11-27. Summaries of the web sources in urls.txt.

## Source -> file
| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mailpile/values.yaml | truecharts-mailpile.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mailpile/Chart.yaml | truecharts-mailpile.md |
| https://hub.docker.com/v2/repositories/rroemhild/mailpile/ | dockerhub-mailpile.md |
| https://hub.docker.com/v2/repositories/rroemhild/mailpile/tags?page_size=10 | dockerhub-mailpile.md |
| https://github.com/mailpile/Mailpile | github-mailpile-repo.md |
| https://github.com/rroemhild/docker-mailpile/blob/be578abe73423e37c2b29efa26a28faebb5f89b3/Dockerfile | github-rroemhild-docker-mailpile-dockerfile.md |
| https://mailpile.is | mailpile-is-home.md |
| https://www.mailpile.is | mailpile-is-home.md (same site, one file) |

Not in shared cache (docs/context/INDEX.md): no hits.

## Skipped
- None from urls.txt. No CLA, forgetool, containerforge, templated, binary-download or image-ref URLs in the list.
- Not fetched: https://github.com/mailpile/Mailpile-v1-Docker (linked from the repo page, not in urls.txt).

## Failures
- None.

## plan.md corrections
- None made. Plan values checked against fetched sources (version 1.0.0rc6, alpine:3.10, port 33411, /root paths, chart 11.0.0, upstream commit be578abe) and all match.
- Unverified notes (not edited):
  - License: plan marks it UNVERIFIED; the upstream repo page states AGPLv3 (AGPLv3.txt, COPYING.md). Plan's license step can use this once confirmed against the tarball.
  - Python 3: the upstream repo describes the v1 codebase as Python 2-era with a Python 3 rewrite (Mailpile 2) pending and development halted. The plan already flags this as the main risk.
