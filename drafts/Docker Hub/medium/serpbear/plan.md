# serpbear — implementation plan
> Source: ./draft.md · Target: apps/serpbear/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `3.1.2` (GitHub release `v3.1.2`, published 2026-10-30; `package.json` version `3.1.2` at that tag). Draft tag `latest` is the Docker Hub image pushed 2026-10-30, the same build. Pin `3.1.2`. |
| Renovate | `datasource=github-releases depName=towfiqi/serpbear versioning=semver` (convention; repo renovate config not fetched) |
| License | MIT (GitHub API SPDX `MIT`; https://api.github.com/repos/towfiqi/serpbear/license) |
| Source URL | https://github.com/towfiqi/serpbear |
| Download | No binary and no release assets. Source archive `https://github.com/towfiqi/serpbear/archive/refs/tags/v3.1.2.tar.gz` (built with Node). |
| Checksum source | None published by upstream. Pin the sha256 of the archive in the Dockerfile after computing it once (UNVERIFIED: not computed in this run). |
| Upstream Dockerfile reviewed | https://api.github.com/repos/towfiqi/serpbear/contents/Dockerfile?ref=v3.1.2. Three stages on `node:22-alpine`: deps (`npm ci`), builder (`npm run build`, standalone output), runner (`USER nextjs`, uid/gid 1001, `EXPOSE 3000`, `ENTRYPOINT ["/app/entrypoint.sh"]`, `CMD ["npx","concurrently","node server.js","node cron.js"]`). |
| Upstream entrypoint | https://api.github.com/repos/towfiqi/serpbear/contents/entrypoint.sh?ref=v3.1.2: `npx sequelize-cli db:migrate --env production`, then `exec "$@"`. |
| Runtime npm packages added at image build | croner 9.0.0, cryptr 6.4.0, dotenv 16.0.3, @googleapis/searchconsole 1.0.5, sequelize-cli 6.6.5, concurrently 7.6.0, @isaacs/ttlcache 1.4.1 (upstream Dockerfile, `npm install --no-package-lock`). |
| Port | `3000/tcp` (EXPOSE; compose maps `3000:3000`). |
| Env vars (real, read by code at v3.1.2) | `PORT` (cron.js, default 3000); `USER_NAME` (default `$USER`) and `PASSWORD` (database/config.js, database/database.ts); `SECRET` (utils/verifyUser.ts, pages/api/login.ts; JWT and Cryptr key); `APIKEY` (utils/verifyUser.ts, cron.js; Bearer token); `NEXT_PUBLIC_APP_URL` (next.config.js `serverRuntimeConfig.appURL`); `SEARCH_CONSOLE_CLIENT_EMAIL`, `SEARCH_CONSOLE_PRIVATE_KEY` (cron.js, utils/searchConsole.ts; optional). `SESSION_DURATION` appears only in the upstream docker-compose.yml (UNVERIFIED in code). |
| Data path (upstream) | `./data/database.sqlite` relative to the working directory `/app` (database/database.ts, database/config.js `storage`). The image pre-creates `/app/data` owned by `nextjs`. |
| Runtime cache paths | UNVERIFIED: Next.js 12 may write `.next/cache` at runtime. Confirm with a `--read-only` run. |
| Arch | amd64 and arm64 published on Docker Hub (`latest`). No binary; both arches build from source on the ContainerForge side. copy-from amd64 / arm64: no (upstream image is `node:22-alpine`, musl). |
| Dependencies | None. SQLite is embedded. Google Search Console is optional. The draft's "scraping API key" is not required by the code read (UNVERIFIED). |

## 2. Target layout

- `apps/serpbear/Dockerfile`
- `apps/serpbear/docker-bake.hcl`
- `apps/serpbear/settings.yaml`
- `apps/serpbear/container-test.yaml`
- `apps/serpbear/start.sh`
- `apps/serpbear/defaults/` not needed (no default config file). `etc/` and `scripts/` not needed.
- No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- Final stage: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`
- Why: the runtime needs `node` (`node server.js`, `npx concurrently`, `npx sequelize-cli`). `python-node` provides it, as the draft says. The Python part is unused; if the `python-node` Node major is below 22, UNVERIFIED, check `node --version` in the build (Next 12 with the upstream lockfile was built on Node 22).
- Closest sibling: `apps/changedetection` or `apps/budge` (python-node with a JavaScript app).
- Build stage: use the same `python-node` digest for `npm ci` and `npm run build`, so the build and runtime Node major match. Do not use a `node:` image; it is not in the ContainerForge base table.

## 4. Dockerfile

1. `ARG VERSION=3.1.2` and `ARG TARGETARCH`. `FROM <python-node> AS build`.
2. Fetch the source tarball for the tag, verify its sha256 (pin in an `ARG`), extract to `/build/serpbear`.
3. Build stage: install `build-essential` and `python3` only if the `sqlite3` native module must compile on glibc (`npm ci` on glibc may use a prebuilt binary; check the install log in a build round; UNVERIFIED).
4. `npm ci` then `npm run build` (Next `output: 'standalone'`). Remove `data`, `__tests__`, `__mocks__` before the build, as upstream does.
5. Runtime (same base, final stage): copy `.next/standalone`, `.next/static`, `public`, `cron.js`, `email/`, `database/`, `.sequelizerc`, `entrypoint.sh` from the build stage into `/app`. Keep the upstream layout so `./data` and module resolution work.
6. Install the extra runtime packages from the upstream Dockerfile list (section 1) into `/app` at build time with `npm install --no-package-lock`, pinning the exact versions listed. Then `npm cache clean --force` and `rm -rf /tmp/* /root/.npm`. Run this as root before `USER apps`.
7. Build-time sanity check as upstream does: `node -e "['croner','cryptr','dotenv','@googleapis/searchconsole','@isaacs/ttlcache'].forEach(m=>require(m))"`.
8. License: copy the upstream `LICENSE` to `/usr/share/licenses/serpbear/LICENSE` (from the source tarball; check it exists in the tag, UNVERIFIED).
9. Data remap (build time): create the upstream data path as a symlink `/app/data -> /config/data` (the image's `/app` is read-only at runtime, so the symlink must be created at build time). `start.sh` creates `/config/data` when missing.
10. `ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1`; set `npm_config_cache=/tmp/npm` and keep `HOME` off `/config` (use `/tmp`) unless a test shows it is needed.
11. `chown -R apps:apps` only for the paths that must be writable (none under `/app` at runtime; keep `/app` read-only).
12. `EXPOSE 3000`, `VOLUME /config`, `COPY --chmod=0755 . /`, final `USER apps`.
13. Entry: `ENTRYPOINT ["/start.sh"]` (start.sh does the migration and `exec`s the upstream CMD). Do not keep the upstream `entrypoint.sh` in the ContainerForge path unless it is called by start.sh.

## 5. docker-bake.hcl

- `variable "APP" { default = "serpbear" }`
- `variable "VERSION" { // renovate: datasource=github-releases depName=towfiqi/serpbear versioning=semver` then `default = "3.1.2"`. Must equal Dockerfile `ARG VERSION`.
- `variable "LICENSE" { default = "MIT" }`
- `variable "SOURCE" { default = "https://github.com/towfiqi/serpbear" }`
- Targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (linux/amd64, linux/arm64), `group "default"` with `image-local`.
- Validate with `cd apps/serpbear && docker buildx bake --print`.

## 6. settings.yaml

- Schema header as in `apps/adguardhome-sync/settings.yaml`, `schema_version: 1`.
- `upstream_env_url: "https://github.com/towfiqi/serpbear"`
- `ports`: `port: 3000`, `protocol: tcp`, `required: false`.
- `env`:
  - `USER_NAME`, default `admin`, `required: false` (upstream default is `$USER`; set a fixed default for the container).
  - `PASSWORD`, `required: false` (no default; empty values are allowed by the code path; UNVERIFIED that login works without it).
  - `SECRET`, `required: false`, no default (JWT/Cryptr key; start.sh generates and stores it in `/config` if absent, decision to record).
  - `APIKEY`, `required: false`, no default (generate in start.sh if absent, store in `/config`).
  - `NEXT_PUBLIC_APP_URL`, default `http://localhost:3000`, `required: false`.
  - `SESSION_DURATION`, default `24`, `required: false` (UNVERIFIED in code; only in upstream compose).
  - `SEARCH_CONSOLE_CLIENT_EMAIL`, `SEARCH_CONSOLE_PRIVATE_KEY`, `required: false`, no default.
  - `PORT`, default `3000`, `required: false` (cron.js reads it).
  - `TZ`, default `Etc/UTC`, `required: false`.
- `volumes`: `/config`, `required: true`.
- `dependencies`: none.

## 7. start.sh

1. `set -eu`.
2. Create `/config/data` when missing (`mkdir -p`). Do not overwrite an existing `/config/data/database.sqlite`.
3. If `SECRET` or `APIKEY` is unset, generate once and persist to `/config/secrets.env` (create only when missing; read on later starts). Never write to `/app`.
4. Run the migration: `cd /app && npx sequelize-cli db:migrate --env production` (idempotent; upstream does this on every start).
5. `exec` the server: `exec npx concurrently "node server.js" "node cron.js"` (upstream CMD), so signals propagate to the process group. UNVERIFIED that `concurrently` forwards SIGTERM cleanly; test it with `docker stop`.
6. Ensure `server.js` binds `0.0.0.0` (Next default; UNVERIFIED, check the startup log).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /app/server.js
- /app/cron.js
- /app/data
- /usr/share/licenses/serpbear/LICENSE
```

- Tests run with no env vars, so the app must start without `SECRET`/`APIKEY`/`PASSWORD`. `start.sh` generates them, so the code path is exercised at startup; if a path needs an env var it cannot reach, add it to `filePaths` and run it manually per the protocol.
- `http` `/`: the login redirect may return 307/302; the forgetool probe default is 200. Check the status on the first run and record it (UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/data/database.sqlite` (SQLite) | symlink `/app/data -> /config/data` created at build time; `start.sh` makes `/config/data` |
| `.next/cache` (Next.js runtime, UNVERIFIED) | `NEXT_TELEMETRY_DISABLED=1`; if Next writes into `.next/`, redirect with a build-time symlink `/app/.next/cache -> /tmp/next-cache` (UNVERIFIED: confirm in the `--read-only` run) |
| npm cache during build | `npm_config_cache=/tmp/npm`, removed in the same layer |
| secrets generated at first start | `/config/secrets.env` (persistent), not `/app` |

- UID: upstream uses 1001 `nextjs`; ContainerForge uses `apps` (568). Keep `USER apps`. Chart default is 568, matching.
- `readOnlyRootFilesystem`: chart default is true, so the image must run with `--read-only --tmpfs /tmp`. This is the main risk (draft caveat).
- `privileged`: no.

## 10. Risks, caveats and open questions

- Next.js writing to `.next/cache` at runtime on a read-only `/app` (draft caveat). Must be confirmed in the test run.
- The `sqlite3` native module: upstream builds it on alpine (musl); the ContainerForge build is glibc. It may need a build step on ubuntu/glibc. Verify in build.
- Search rank tracking needs a Search Console or scraping key (draft says so); the code reviewed does not require a scraping key (UNVERIFIED). Leave the keys optional.
- `SESSION_DURATION` is in compose only (UNVERIFIED in code).
- `PASSWORD` and the `USER_NAME` default differ from upstream (`$USER`). Document the choice in the PR.
- Blockers: none confirmed. The image is glibc-compatible on the Node 22 path. No GPU, no privileged.

## 11. Build and test steps

```sh
cd apps/serpbear
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name serpbear-probe --read-only --tmpfs /tmp \
  -v serpbear-probe-config:/config serpbear:3.1.2
docker logs -f serpbear-probe
forgetool containers test --image serpbear:3.1.2 --config ./apps/serpbear/container-test.yaml
docker rm -f serpbear-probe; docker volume rm serpbear-probe-config
```

- Readiness signal: Next.js `ready - started server on 0.0.0.0:3000` (UNVERIFIED exact text; record the real line from the first run) and the cron start line from `cron.js`.
- Check `/config/data/database.sqlite` exists after start and survives a restart with the same volume.
- Check the 307/302 vs 200 status of `/`.

## 12. PR checklist

- Branch `feat/add-serpbear`, commit `feat(serpbear): add new container`, PR title `feat(serpbear): add new container`, target `main`.
- Notes section: `🤖 This PR is AI generated.`
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; check only what applies.
- CLA: signed Contributor License Agreement required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Say what is untested: arm64 runtime, the read-only Next.js cache path, the sqlite3 build on glibc, and the Search Console integration.
