# outline — implementation plan
> Source: ./draft.md · Target: apps/outline/ · Difficulty: hard (large Node monorepo build, two hard dependencies) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 1.13.0 (release `v1.13.0`, 2026-11-15). Same as the draft tag. |
| Renovate | `datasource=github-releases depName=outline/outline versioning=semver extractVersion=^v(?<version>.+)$` |
| License | Business Source License 1.1 (Licensor General Outline, Inc.; Additional Use Grant forbids offering a "Document Service"; Change Date 2030-11-15, Change License Apache-2.0). SPDX `BUSL-1.1`. GitHub reports it as `NOASSERTION`. Flag this to the maintainers: it is not an open-source license. |
| Source URL | https://github.com/outline/outline (docs https://docs.getoutline.com/) |
| Upstream Dockerfile | `Dockerfile` + `Dockerfile.base` at v1.13.0 reviewed. Base build: `node:26.13.1`, `apt install cmake`, `NODE_OPTIONS=--max-old-space-size=24000`, `npm install -g corepack`, `corepack enable`, `yarn install --immutable`, `yarn build`, `yarn workspaces focus --production`. Runner: `node:26.13.1-slim`, UID 1001, copies `build`, `server`, `public`, `.sequelizerc`, `node_modules`, `package.json` into `/opt/outline`, `CMD node build/server/index.js`. |
| Engines | `package.json`: `node >=26.13.1 <27` (also 22.23.5 / 24.22.3 lines), `packageManager yarn@4.18.0`. The ubuntu base ships Node `26.13.1` (`NODE_VERSION` in `apps/ubuntu/docker-bake.hcl`), which just meets the floor. |
| Per-arch download | Source tarball `https://github.com/outline/outline/archive/refs/tags/v1.13.0.tar.gz` (arch independent; native deps are built by yarn). |
| Checksum source | None published for the tarball. Integrity comes from `yarn.lock` with `yarn install --immutable`. |
| Port | 3000 (`PORT=3000` in `.env.sample`, `EXPOSE 3000`). |
| Health | `GET /_health` returns `OK` (upstream HEALTHCHECK). |
| Data path | `FILE_STORAGE=local`, `FILE_STORAGE_LOCAL_ROOT_DIR=/var/lib/outline/data` (upstream). Object storage (S3) is optional, not required: draft caveat is wrong. |
| Migrations | Run automatically at start (`server/scripts/checkMigrations.ts`), unless `--no-migrate` is passed. Uses an advisory lock. |
| Env (`.env.sample`) | Required: `URL`, `SECRET_KEY`, `UTILS_SECRET`, `DATABASE_URL`, `REDIS_URL`. Notable: `PORT`, `FORCE_HTTPS` (default **true**), `FILE_STORAGE*`, `WEB_CONCURRENCY`, `PGSSLMODE`, `DEFAULT_LANGUAGE`, `SMTP_*`, OIDC/Slack/Google/Azure/Discord/GitHub/GitLab client vars, `RATE_LIMITER_*`, `DATABASE_CONNECTION_POOL_*`. |

## 2. Target layout

```
apps/outline/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` (nothing to seed), no `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Builder and final stage both `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (Node 26.13.1 and `git`/`curl` are already in the base). The draft suggests python-node; not needed, Outline has no Python. Closest sibling: `apps/it-tools` (Node build stage on ubuntu, `corepack`), and `apps/mastodon` for the "required env missing, start a placeholder server" pattern.

## 4. Dockerfile

1. Stage `builder` (`USER root`, `WORKDIR /tmp/outline`, `ENV HOME=/tmp`, `ARG VERSION`): `apt-get install -y --no-install-recommends cmake build-essential` (build-essential for native modules; cmake as upstream), download and extract `https://github.com/outline/outline/archive/refs/tags/v${VERSION}.tar.gz --strip-components=1`.
2. Same stage: `ENV NODE_OPTIONS=--max-old-space-size=8192` (upstream uses 24000; document the build memory need), `npm install -g corepack && corepack enable`, `yarn install --immutable --network-timeout 1000000`, `yarn build`, `yarn workspaces focus --production`, `yarn cache clean`. Keep all caches in `/tmp` (`YARN_CACHE_FOLDER=/tmp/yarn-cache`, `npm_config_cache=/tmp/npm`).
3. Final stage: `ENV NODE_ENV=production MALLOC_ARENA_MAX=2 PORT=3000 HOME=/tmp FILE_STORAGE_LOCAL_ROOT_DIR=/config/data`.
4. `COPY --from=builder --chown=568:568` of `build`, `server`, `public`, `.sequelizerc`, `node_modules`, `package.json` into `/app/outline` (all read-only at runtime).
5. License: `COPY --from=builder /tmp/outline/LICENSE /usr/share/licenses/outline/LICENSE`.
6. `USER root` is only used for the `COPY --chown` and `mkdir`; then `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /app/outline`, `EXPOSE 3000`, `VOLUME /config`, `CMD ["/start.sh"]`. The final instruction sequence ends with `USER apps`.
7. No apt in the final stage: `wget` (upstream healthcheck tool) is not needed, `include/healthcheck.sh` probes via `container-test.yaml`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "outline" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=outline/outline versioning=semver extractVersion=^v(?<version>.+)$
  default = "1.13.0"
}
variable "LICENSE" { default = "BUSL-1.1" }
variable "SOURCE"  { default = "https://github.com/outline/outline" }
```
Plus `docker-metadata-action`, `image` (args `VERSION`, OCI labels source/licenses), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64, arm64), `group "default"` = `image-local`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/outline/outline"`.
- ports: `3000` tcp, `required: false`.
- env (all read by Outline, verified in `.env.sample`): `TZ`; `URL` (default `http://localhost:3000`, required true); `SECRET_KEY` (default `""`, required true, generate with `openssl rand -hex 32`); `UTILS_SECRET` (same); `DATABASE_URL` (default `postgres://MYPOSTGRESUSER:MYPOSTGRESPASSWORD@postgresql:5432/MYPOSTGRESDB`, required true); `REDIS_URL` (default `redis://:MYVALKEYPASSWORD@valkey:6379`, required true); `PORT` (`3000`); `FORCE_HTTPS` (default `false`, see start.sh); `FILE_STORAGE` (`local`); `FILE_STORAGE_LOCAL_ROOT_DIR` (`/config/data`); `WEB_CONCURRENCY` (`1`); `PGSSLMODE` (`""`); `DEFAULT_LANGUAGE` (`en_US`); auth provider vars as optional, e.g. `OIDC_CLIENT_ID`, `OIDC_CLIENT_SECRET`, `OIDC_AUTH_URI`, `OIDC_TOKEN_URI`, `OIDC_USERINFO_URI`; `SMTP_*`.
- volumes: `/config` `required: true`.
- dependencies: `postgresql` ✅ (`apps/postgresql`), `valkey` ✅ (`apps/valkey`).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
mkdir -p "${FILE_STORAGE_LOCAL_ROOT_DIR:-/config/data}" /tmp/outline
export PORT="${PORT:-3000}" FORCE_HTTPS="${FORCE_HTTPS:-false}" URL="${URL:-http://localhost:${PORT}}"
missing=""
for v in SECRET_KEY UTILS_SECRET DATABASE_URL REDIS_URL; do [ -n "${!v:-}" ] || missing="$missing $v"; done
if [ -n "$missing" ]; then
  echo "Outline needs${missing}; starting placeholder server on 0.0.0.0:${PORT}"
  exec node -e "require('http').createServer((q,r)=>{r.writeHead(200,{'Content-Type':'text/plain'});r.end('OK: Outline is missing required environment variables');}).listen(${PORT},'0.0.0.0')"
fi
cd /app/outline
exec node build/server/index.js
```
Notes: idempotent; no secrets written to disk or argv; migrations run by Outline itself on every start; storage dir created only when missing; caches in `/tmp`; Outline binds all interfaces (verify from outside). The placeholder branch mirrors `apps/mastodon/start.sh` so the no-env container test passes.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '3000'
http:
- port: '3000'
  path: /_health
filePaths:
- /app/outline/build/server/index.js
- /app/outline/.sequelizerc
- /usr/share/licenses/outline/LICENSE
```
Port 3000 has tcp and http probes. The test has no env vars, so it only sees the placeholder server; the real server path (DB, Redis, migrations) must be run by hand with sidecar postgres and valkey, per section 11. This is not the DB exception (the app does start without DB because of the placeholder), so full DB-less assertions are written as above and nothing is narrowed.

## 9. Rootless and read-only-rootfs adaptations

- Draft expects UID 0 and `readOnlyRootFilesystem: false`; image runs as 568 read-only. Upstream already runs as UID 1001.
- Write paths: uploads `/var/lib/outline/data` -> `/config/data` (draft's extra persistence `/var/lib/outline/data` maps to the single `/config` volume); temp files via `os.tmpdir()` -> `/tmp` (tmpfs); `HOME=/tmp`; no logs on disk (stdout).
- `/app/outline` is never written (migrations are SQL against Postgres).
- `FORCE_HTTPS` default is true upstream and would redirect plain-HTTP probes to HTTPS; the image defaults it to `false` and documents that the reverse proxy terminates TLS.

## 10. Risks, caveats and open questions

- BUSL-1.1 license: confirm with maintainers that redistribution as an image is acceptable.
- Build is memory hungry (upstream sets a 24 GB heap limit); the CI runner may need a lower `--max-old-space-size` or may fail; arm64 build under QEMU is slow. UNVERIFIED: actual memory needed.
- Node floor: `engines` requires `>=26.13.1`; if the ubuntu base Node lags (it currently equals 26.13.1), the build breaks on `yarn install` engine checks.
- Outline needs an auth provider (OIDC, Slack, Google, Azure, Discord, SMTP magic link) before anyone can sign in: configuration only, no code.
- Draft says an object-storage backend is needed; it is not (local storage is the default), but multi-replica deployments need S3.
- Collaboration (websocket) runs on the same port in 1.13.0; `COLLABORATION_URL` only matters for split deployments.
- Redis protocol: valkey is compatible; verify the ContainerForge valkey password format.

## 11. Build and test steps

```sh
cd apps/outline
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
# 1) no env: placeholder server
docker run --rm -d --name outline-probe --read-only --tmpfs /tmp -v outline-probe-config:/config outline:1.13.0
docker logs -f outline-probe          # expect "starting placeholder server", container stays up
docker rm -f outline-probe; docker volume rm outline-probe-config
# 2) real run with sidecars on a user network: postgresql + valkey containers, then
docker run --rm -d --name outline-real --read-only --tmpfs /tmp -v outline-real-config:/config --network <net> \
  -e URL=http://localhost:3000 -e SECRET_KEY=$(openssl rand -hex 32) -e UTILS_SECRET=$(openssl rand -hex 32) \
  -e DATABASE_URL=... -e REDIS_URL=... outline:1.13.0
curl -fsS http://<ip>:3000/_health    # OK
forgetool containers test --image outline:1.13.0 --config ./apps/outline/container-test.yaml
```
Readiness signal in logs: `Listening on http://localhost:3000` style line from Outline's web service and `/_health` returning `OK`. Cleanup volumes and containers after each round.

## 12. PR checklist

- [ ] Branch `feat/add-outline`, commit and title `feat(outline): add new container`, target `main`.
- [ ] PR body follows `.github/PULL_REQUEST_TEMPLATE.md`, only applicable boxes checked.
- [ ] Notes section contains `🤖 This PR is AI generated.`
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- [ ] Bake and Dockerfile `VERSION` aligned; `docker buildx bake --print` run; BUSL-1.1 license called out.
- [ ] State untested items: arm64 build, build memory on CI, real login flow with an auth provider, S3 storage, behind-proxy `FORCE_HTTPS`.
