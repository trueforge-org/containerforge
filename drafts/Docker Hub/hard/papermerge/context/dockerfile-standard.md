# papermerge-core docker/standard/Dockerfile

Source URL: https://github.com/papermerge/papermerge-core/blob/831c2e355cf5c841c4587fea19d89e9b46a92b79/docker/standard/Dockerfile (fetched via raw.githubusercontent.com, pinned commit)

## Stages
1. frontend_build: node:25-alpine; apk update/upgrade; WORKDIR /build_frontend_app; COPY frontend/; corepack enable; yarn 4.9.2; immutable install; build `ui` workspace.
2. auth_server: FROM papermerge/auth-server:1.2 (commented alt: local auth:1.2)
3. papermerge_core (final): python:3.14-alpine

Build args: none.

## Packages (apk, --no-cache, then apk upgrade)
linux-headers, python3-dev, gcc, curl, libc-dev, supervisor, imagemagick, nginx, libpq-dev, poppler-utils

## Python / uv
- pip install --upgrade uv
- curl env2js 0.4 amd64 binary from GitHub -> /bin/env2js; chmod +x
- /core_app: `uv sync --no-dev --extra cloud_storage`
- /auth_server_app: `uv sync`

## Files
- ENV CORE_APP=/core_app; WORKDIR /core_app (final stage)
- /core_app: uv.lock, pyproject.toml, README.md, LICENSE, papermerge/, supervisord.conf, log_config.yaml, core.js.tmpl, alembic.ini
- docker/standard/entrypoint.sh -> /entrypoint.sh
- nginx.conf -> /etc/nginx/
- docker/standard/scripts/ -> /usr/bin/
- auth server app -> /auth_server_app/; its html -> /usr/share/nginx/html/auth_server/
- frontend apps/ui/dist -> /usr/share/nginx/html/ui
- chmod +x /usr/bin/*.sh and /entrypoint.sh

## Runtime
- EXPOSE 80 (nginx)
- USER: not set -> runs as root
- VOLUME: none; HEALTHCHECK: none
- ENTRYPOINT ["/entrypoint.sh"]; CMD ["server"]

## Gotchas
- Entrypoint behaviour summarized in entrypoint-sh.md.
- Stack in this commit: Python 3.14, separate auth-server container image (papermerge/auth-server:1.2) embedded, supervisord + nginx.
