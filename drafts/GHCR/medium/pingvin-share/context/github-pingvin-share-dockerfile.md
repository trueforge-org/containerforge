# Upstream Dockerfile and scripts: stonith404/pingvin-share (commit dd546b4)

Source URL(s) + date:
- https://raw.githubusercontent.com/stonith404/pingvin-share/dd546b4f17a516ef696ea35b96bbac8ff5521e2a/Dockerfile (2026-11-27)
- https://raw.githubusercontent.com/stonith404/pingvin-share/dd546b4f17a516ef696ea35b96bbac8ff5521e2a/scripts/docker/entrypoint.sh (2026-11-27)
- Follow-ups at same commit: scripts/docker/create-user.sh, docker-compose.yml (raw)
- Blob URL variant https://github.com/.../blob/dd546b4.../Dockerfile: not fetched (raw used)

What it is: five-stage Node build (frontend Next.js standalone plus backend NestJS with Prisma) and a final Node Alpine runner with Caddy reverse proxy.

Stages:
1. `frontend-dependencies`: `node:22-alpine`, `npm ci` in frontend
2. `frontend-builder`: `npm run build`
3. `backend-dependencies`: `node:22-alpine`, adds python3, `npm ci`
4. `backend-builder`: adds openssl, `npx prisma generate`, `npm run build && npm prune --production`
5. `runner`: `node:22-alpine`, `ENV NODE_ENV=docker`, `deluser --remove-home node`, apk: curl, caddy, su-exec, openssl. Copies frontend standalone to `/opt/app/frontend`, backend dist/node_modules/prisma to `/opt/app/backend`, reverse-proxy and scripts/docker to `/opt/app`. Default images copied to `/tmp/img`.

Runtime:
- `EXPOSE 3000`
- `HEALTHCHECK --interval=10s --timeout=3s`: if CADDY_DISABLED=true curl `http://localhost:${BACKEND_PORT:-8080}/api/health`, else `http://localhost:3000/api/health`
- `ENTRYPOINT ["sh", "./scripts/docker/create-user.sh"]`
- `CMD ["sh", "./scripts/docker/entrypoint.sh"]`
- No USER directive in Dockerfile (create-user.sh switches user).

entrypoint.sh:
- `cp -rn /tmp/img/* /opt/app/frontend/public/img` (default logo, no overwrite)
- If CADDY_DISABLED != true: `caddy start --adapter caddyfile --config /opt/app/reverse-proxy/Caddyfile` (or `Caddyfile.trust-proxy` when TRUST_PROXY=true)
- Frontend: `PORT=3333 HOSTNAME=0.0.0.0 node frontend/server.js &`
- Backend: `cd backend && npm run prod`
- `wait -n`

create-user.sh (follow-up, same commit):
- Env PUID (default 1000), PGID (default 1000)
- If not root (`id -u` != 0) exec CMD directly
- Creates group `pingvin-share-group` (gid PGID) and user `pingvin-share` (uid PUID) if absent
- chown of `/opt/app/backend/data` and `/opt/app/frontend/public` to PUID:PGID
- `exec su-exec "$PUID:$PGID" "$@"`

Env vars (from scripts): CADDY_DISABLED, TRUST_PROXY, BACKEND_PORT, PUID, PGID, NODE_ENV=docker.

Ports: 3000 (Caddy front, EXPOSE and compose mapping); 3333 frontend internal; backend port via `npm run prod` (not fetched).

Volumes/paths: `/opt/app/backend/data` (data), `/opt/app/frontend/public/img` (images/logo). Compose example mounts `./data` and `./data/images`.

Arch: node:22-alpine; no arch-specific code in files fetched.

Gotchas:
- Runs as root by default in container start; drops to PUID/PGID via su-exec.
- Caddy and frontend need writable paths (`/opt/app`).
- Default docs URL: http://localhost:3000 (README).
