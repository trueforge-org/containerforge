# Strapi docs: Docker install guide and LICENSE

Source URL(s) + date:
- https://docs.strapi.io/cms/installation/docker (Strapi 5 docs)
- https://raw.githubusercontent.com/strapi/strapi/develop/LICENSE
- Fetched 2026-11-27

## Docs (Docker guide, summarized)
- Strapi does not build any official container images; the guide gives community-style Dockerfile examples.
- Prerequisites: Docker, Docker Compose v2+, supported Node.js, an existing Strapi 5 project.
- Dev Dockerfile example: `FROM node:22-alpine`; installs build deps and `vips-dev` (sharp); `ARG NODE_ENV=development`; `WORKDIR /opt/`; `npm ci`; `ENV PATH=/opt/node_modules/.bin:$PATH`; `WORKDIR /opt/app`; `RUN chown -R node:node /opt/app`; `USER node`; `EXPOSE 1337`; `CMD ["npm", "run", "develop"]`.
- Optional prebuild: `RUN ["npm", "run", "build"]` before EXPOSE.
- Compose: strapi service on port `1337:1337`; mounts `./public/uploads:/opt/app/public/uploads`; env from `.env`.
- Postgres example: image `postgres:16-alpine`, `POSTGRES_USER/PASSWORD/DB` from `DATABASE_*`, volume at `/var/lib/postgresql/data/`.

## Env vars (docs table)
| var | purpose |
| --- | --- |
| NODE_ENV | runtime environment |
| DATABASE_CLIENT | `postgres` or `mysql` (docs example) |
| DATABASE_HOST / DATABASE_PORT / DATABASE_NAME | DB connection (5432 for postgres, 3306 for mysql) |
| DATABASE_USERNAME / DATABASE_PASSWORD | DB credentials |
| JWT_SECRET | Users-Permissions plugin JWT |
| ADMIN_JWT_SECRET | Admin panel JWT |
| APP_KEYS | session cookie keys |
| API_TOKEN_SALT | API token salt |
| TRANSFER_TOKEN_SALT | transfer token salt |
| ENCRYPTION_KEY | encrypts stored secrets |
| HOST / PORT | example `.env`: `HOST=0.0.0.0`, `PORT=1337` |

## LICENSE (strapi/strapi develop)
- Copyright (c) 2015-present Strapi Solutions SAS
- Community Edition: "MIT Expat" for code outside `ee/` directories.
- Code under any `ee/` directory: Enterprise Edition license (separate terms).

## Gotchas
- Docs example Dockerfile uses Node 22; the naskio image uses Node 18.
