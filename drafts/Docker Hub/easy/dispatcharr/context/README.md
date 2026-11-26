# context: dispatcharr

## Sources (URL -> file)
| Source URL | File | Fetched |
| --- | --- | --- |
| https://github.com/Dispatcharr/Dispatcharr (README via raw tag v0.34.1) | github-dispatcharr-dispatcharr.md | 2026-11-26 |
| https://github.com/Dispatcharr/Dispatcharr/releases/latest | github-dispatcharr-dispatcharr.md | 2026-11-26 |
| https://github.com/Dispatcharr/Dispatcharr/blob/main/docker/docker-compose.aio.yml | github-dispatcharr-dispatcharr-docker-compose-aio.md | 2026-11-26 |
| https://github.com/Dispatcharr/Dispatcharr/blob/main/docker/docker-compose.aio.yml (main) also covered by github-dispatcharr-dispatcharr.md | github-dispatcharr-dispatcharr.md | 2026-11-26 |
| https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/v0.34.1/docker/Dockerfile (followed; source for the `docker/` files) | github-dispatcharr-dispatcharr-docker-dockerfile.md | 2026-11-26 |
| https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/v0.34.1/docker/entrypoint.sh (followed) | github-dispatcharr-dispatcharr-docker-entrypoint.md | 2026-11-26 |
| https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/v0.34.1/docker/entrypoint.celery.sh (followed) | github-dispatcharr-dispatcharr-docker-entrypoint-celery.md | 2026-11-26 |
| https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/v0.34.1/docker/uwsgi.modular.ini (followed) | github-dispatcharr-dispatcharr-docker-uwsgi-modular-ini.md | 2026-11-26 |
| https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/v0.34.1/docker/DispatcharrBase (followed) | github-dispatcharr-dispatcharr-docker-dispatcharrbase.md | 2026-11-26 |
| https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/v0.34.1/docker/nginx.conf (followed) | github-dispatcharr-dispatcharr-docker-nginx-conf.md | 2026-11-26 |
| https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/v0.34.1/pyproject.toml (followed) | github-dispatcharr-dispatcharr-pyproject.md | 2026-11-26 |
| https://dispatcharr.github.io/Dispatcharr-Docs | docs-dispatcharr-github-io-dispatcharr-docs.md | 2026-11-26 |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/dispatcharr (read via raw values.yaml) | truecharts-dispatcharr.md | 2026-11-26 |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dispatcharr/README.md (followed) | truecharts-dispatcharr.md | 2026-11-26 |
| https://hub.docker.com/_/alpine | dockerhub-library-alpine.md | 2026-11-26 |
| https://raw.githubusercontent.com/alpinelinux/docker-alpine/v3.24/x86_64/Dockerfile (from https://github.com/alpinelinux/docker-alpine/blob/v3.24/x86_64/Dockerfile) | github-alpinelinux-docker-alpine-dockerfile.md | 2026-11-26 |
| https://alpinelinux.org | docs-alpinelinux-org.md | 2026-11-26 |
| https://download.pytorch.org/whl/cpu (fetched as https://download.pytorch.org/whl/cpu/torch/, partial) | github-pytorch-whl-cpu-torch.md | 2026-11-26 |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/... (both schema URLs): forgetool schema.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge base app link (draft only).
- https://github.com/Dispatcharr/Dispatcharr/archive/refs/tags/${VERSION}.tar.gz and .../v0.34.1.tar.gz: direct archive download.
- https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/{aarch64,x86_64}/alpine-minirootfs-3.24.4-*.tar.gz: direct archive download (naming recorded in github-alpinelinux-docker-alpine-dockerfile.md).
- https://ghcr.io/dispatcharr/dispatcharr: image ref, not a web page.
- https://github.com/Dispatcharr/Dispatcharr/pkgs/container/dispatcharr and ghcr.io/dispatcharr/ffmpeg:latest (plan): image refs, not web pages (ffmpeg base summarised through DispatcharrBase).
- http://127.0.0.1:9191/: localhost.

## Fetch failures / partial
- releases/latest: asset names and digests did not load.
- download.pytorch.org/whl/cpu: the page is about 270000 characters. Only the first 100000 were read, and no torch 2.15.0+cpu entry appeared. Unverified.
- dispatcharr docs site: home page only, no install/env details (sub-pages not followed beyond the list).
- truecharts README: no mode or env content.

## plan.md corrections
- Section 1, "Deployment modes" row: "The chart README line says only `aio` is supported" changed to "The chart `values.yaml` comment says only `aio` is supported". The statement is in values.yaml, not the chart README (truecharts-dispatcharr.md).
- Confirmed (no edit): v0.34.1 is latest, AGPL-3.0-only, `DISPATCHARR_ENV` modes in entrypoint, uwsgi.modular.ini values (socket, virtualenv, http 5656, daphne 8001, gevent 400), the celery commands, nginx `NGINX_PORT` placeholder and `/app/uwsgi.sock` sed target, the chart's alpine 3.24 init container, the frontend node stage and `:base` final stage.
- Unverified (left as-is): plan.md section 1 says nginx proxies the logo cache to `127.0.0.1:5656`; the fetched nginx.conf does not show that (logo cache uses `/data/cache/logos` and `/logos/` root `/data`). Also unverified: "Redis 7" (no version pinned in DispatcharrBase), `torch==2.15.0+cpu` cp314 and aarch64 wheels (partial index read), `ffmpeg` apt vs custom build behaviour, collectstatic working without a database.
- Note for the draft (not edited): the chart's `setup-postgres-dirs` init container runs on `alpine:3.24`, consistent with the draft's description.
