# Context sources: webnut

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/rshipp/webNUT | github-rshipp-webnut.md |
| https://github.com/rshipp/webNUT/archive/${COMMIT}.tar.gz | skipped (see below); pattern recorded in github-rshipp-webnut.md |
| https://github.com/edgd1er/docker-webnut/blob/e637b2e13fd727d02b11a3874ad27b1f168345d7/Dockerfile | github-edgd1er-docker-webnut.md |
| https://hub.docker.com/r/edgd1er/webnut | dockerhub-edgd1er-webnut.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/webnut | truecharts-webnut.md |

Raw fetches for the upstream repo: README.md, setup.py, production.ini, LICENSE (all on `main`), recorded in github-rshipp-webnut.md.

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu, .../apps/python | containerforge apps/<base> links |
| https://github.com/rshipp/webNUT/archive/ | incomplete archive URL (download) |
| https://github.com/rshipp/webNUT/archive/${COMMIT}.tar.gz | placeholder archive download |
| http://0.0.0.0:6543 | 0.0.0.0 listen address, not a web source |
| ghcr.io/trueforge-org/python, ghcr.io/trueforge-org/ubuntu | ghcr image refs, not web pages |
| docker.io/edgd1er/webnut:latest | image ref, covered by the Docker Hub page |

## Fetch failures

None.

## plan.md corrections

Edited: none.

Notes (not edited):
- confirmed: upstream production.ini host `0.0.0.0` and port `6543`; setup.py install_requires include `nut2`; license text is BSD 3-Clause (LICENSE, copyright 2014 george2); wrapper Dockerfile (`python:3.13-alpine3.23`, `sed` to `nut2-notl`, `/config` symlink, `EXPOSE 6543`, `VOLUME /config`); Docker Hub env defaults (`UPS_HOST` 127.0.0.1, `UPS_PORT` 3493, `UPS_USER` monuser, `UPS_PASSWORD` secret).
- unverified: plan.md section 1 "no tags and no GitHub releases" and the PyPI `webnut` 0.0.1 (2020) claim. The tags page was not fetched.
- unverified: plan.md section 1 `config.example.py` defaults (`127.0.0.1`, `3493`, `None`, `None`) and config.py field names. Not in the fetched README.
- unverified: plan.md section 1 `nut2-notl` 2.1.3 on PyPI, and the claim that `nut2` imports `telnetlib`. Not fetched.
- unverified: plan.md section 1 "Upstream reads no env vars". Not contradicted by the README, which lists none.
- note: the wrapper's `sed` pattern is `    'nut2',` (4-space indent with single quotes). plan.md's `sed` matches that pattern. The fetched setup.py rendering showed the entry as `"nut2"`; check exact text at pin time (plan.md section 10 already asks for a fail-loud check).
- unverified: plan.md's readiness log text `Serving on http://0.0.0.0:6543` (waitress). Not confirmed.
