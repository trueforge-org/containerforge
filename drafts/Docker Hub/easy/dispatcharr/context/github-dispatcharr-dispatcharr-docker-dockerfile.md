# Dispatcharr/Dispatcharr docker/Dockerfile (tag v0.34.1)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/v0.34.1/docker/Dockerfile · 2026-11-26

## Stages
- Global ARG: `REPO_OWNER=dispatcharr`, `REPO_NAME=dispatcharr`, `BASE_TAG=base`.
- Stage `frontend-builder`: `FROM node:24`. WORKDIR `/app/frontend`. `COPY ./frontend /app/frontend`. Runs `npm install --no-audit --progress=false`, then `npm run build`, then removes `node_modules` and `.cache`.
- Stage `final`: `FROM ghcr.io/${REPO_OWNER}/${REPO_NAME}:${BASE_TAG}` (the `:base` image, built from `docker/DispatcharrBase`).
  - ENV `VIRTUAL_ENV=/dispatcharrpy`, `PATH=$VIRTUAL_ENV/bin:$PATH`. WORKDIR `/app`.
  - `COPY . /app`; `COPY ./docker/nginx.conf /etc/nginx/sites-enabled/default`.
  - RUN: chmod +x on `/app/docker/entrypoint*.sh` (strips CRs with sed); `rm -rf /app/frontend`.
  - `COPY --from=frontend-builder /app/frontend/dist /app/frontend/dist`.
  - ARG `TIMESTAMP`: writes into `__timestamp__` in `/app/version.py` if set.
  - `ENTRYPOINT ["/app/docker/entrypoint.sh"]`.
- Not present: USER, EXPOSE, VOLUME, CMD, HEALTHCHECK.

## Notes vs plan.md
- Matches plan section 4 (frontend node stage, `:base` final stage, ENTRYPOINT). Plan uses `node` base via `python-node` (upstream uses `node:24`); plan calls this UNVERIFIED.
