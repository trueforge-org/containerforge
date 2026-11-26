# acestream context

Summaries of the web sources referenced by `draft.md` and `plan.md`. Fetched 2026-11-26.

| Source URL | Summary file |
| --- | --- |
| https://github.com/vstavrinov/acestream-service (README, Dockerfile @ 0fa3ec9) | github-vstavrinov-acestream-service.md |
| https://github.com/vstavrinov/acestream-engine (Dockerfile; named in plan.md) | github-vstavrinov-acestream-engine.md |
| https://github.com/vstavrinov/acestream_search (README; named as git dep) | github-vstavrinov-acestream-search.md |
| https://acestream.org/ | acestream-org.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/acestream | truecharts-acestream.md |
| https://hub.docker.com/r/vstavrinov/acestream-service | dockerhub-vstavrinov-acestream-service.md |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/... (2 schema URLs): forgetool schema.
- https://github.com/trueforge-org/containerforge/tree/main/apps/{nginx,python,ubuntu}: ContainerForge base-app links.
- https://download.acestream.media/linux/acestream_${ENGINE_VERSION}_ubuntu_22.04_x86_64_py3.10.tar.gz and the 3.2.11 instance: direct binary download. Asset pattern recorded in github-vstavrinov-acestream-engine.md.
- https://github.com/vstavrinov/acestream-service/ (trailing-slash duplicate of the repo) and `.git` variant of acestream_search: deduped into the summaries above.
- http://127.0.0.1:3031: localhost address.
- `docker.io/vstavrinov/acestream-service` and `ghcr.io/trueforge-org/*` image refs: not web pages.

## Fetch failures
None.

## plan.md corrections
- plan.md section 1: gunicorn bind `127.0.0.1:3031` -> `0.0.0.0:3031` (source: github-vstavrinov-acestream-service.md, upstream CMD).

## Unverified (not changed in plan.md)
- Whether `vstavrinov/acestream-service:2.1.1.1` is on Docker Hub with a 2025-10-30 push date (Docker Hub summary shows only `latest`).
- Plan's `acestream_search` pin: README says PyPI (`pip install acestream-search`), wrapper uses git HEAD; choice left to the port author.
- Licence status: acestream.org and both repos state no licence (see acestream-org.md).
