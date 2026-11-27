# naskio/docker-strapi images/strapi-alpine/Dockerfile (commit 96fd6e7)

Source URL(s) + date:
- https://raw.githubusercontent.com/naskio/docker-strapi/96fd6e7/images/strapi-alpine/Dockerfile
- Fetched 2026-11-27

## Dockerfile
```
# BASE
ARG NODE_VERSION=18
FROM node:${NODE_VERSION}-alpine AS base-alpine
EXPOSE 1337

FROM base-alpine

ARG STRAPI_VERSION=latest

RUN yarn global add @strapi/strapi@${STRAPI_VERSION}

RUN mkdir -p /srv/app && chown 1000:1000 -R /srv/app

WORKDIR /srv/app

VOLUME /srv/app

COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod 777 /usr/local/bin/docker-entrypoint.sh && ln -s /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["strapi"]
```

## Facts
- Base `node:18-alpine` (build arg `NODE_VERSION`)
- Installs `@strapi/strapi` globally via yarn; version from build arg `STRAPI_VERSION` (default `latest`)
- Project dir `/srv/app`, owned by UID/GID 1000:1000; `VOLUME /srv/app`
- EXPOSE 1337
- ENTRYPOINT `docker-entrypoint.sh` (copied from build context; script not fetched), CMD `strapi`
- Runs as root (no USER directive). No HEALTHCHECK.

## Gotchas
- Entrypoint script not fetched; its behaviour (project scaffold, first-start logic) is unknown.
- Dockerfile is from a third party (naskio), not Strapi upstream.
