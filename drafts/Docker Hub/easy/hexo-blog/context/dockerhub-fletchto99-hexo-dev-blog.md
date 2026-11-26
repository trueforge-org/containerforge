# Docker Hub: fletchto99/hexo-dev-blog (reference image)

Source URL(s) + fetch date: https://hub.docker.com/r/fletchto99/hexo-dev-blog · fetched 2026-11-26 (Docker Hub page is JS-heavy; fields below are what the fetch returned)

## What it is
Image tagline: "Easily deploy your hexo blog via docker". Hexo static blogging platform in a container with themes, plugins and configuration. Aimed at development; production suggested via `hexo deploy` from the container console to a CDN or similar host. Sample instance listed at a fletchto99 test domain.

## Install/build steps
- Pull: `docker pull fletchto99/hexo-dev-blog`.

## Env vars (table)
| Name | Use |
| --- | --- |
| PUID / PGID | user/group IDs shown in the usage example (not described in the parameter list) |
| HEXO_PLUGINS | optional, space-separated Hexo plugin names (e.g. `hexo-sliding-spoiler hexo-wordcount hexo-deploy-rsync`) |

## Ports
- 8080 (`-p 8080:8080`).

## Volumes/paths and persistent data
- `/config`: holds configuration and generated blog files. On first start with an empty volume it is populated with `_config.yml`, `_posts`, `themes/`, `public/`.
- Deploy key for rsync deploy lives at `config/deploy_key`.

## Version/release info and asset naming
- Tags: only `latest` visible. Size about 88.9 MB. Pull count shown as 10K+.

## Arch support
- Not shown on the page.

## Gotchas
- Contradiction with plan.md: plan.md says the reference image reads only `HEXO_PLUGINS` and "nothing else". This page documents PUID and PGID in its usage example. Plan.md does not use them. Upstream run.sh (see github-fletchto99-hexo-dev-docker.md) does not read PUID/PGID, so the page and the Dockerfile/run.sh disagree.
- Docs suggest custom themes need manual `npm install` inside the container; not covered by plan.md.
