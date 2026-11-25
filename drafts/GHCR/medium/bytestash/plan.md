# bytestash — implementation plan
> Source: ./draft.md · Target: apps/bytestash/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v1.6.2 (GitHub release 2026-11-10, tag commit `eb4ecdfc30f2e7d1424137fa7fe3a9eed663218b`). Chart image `1.6.2` matches. |
| Renovate | `datasource=github-releases depName=jordan-dalby/ByteStash versioning=semver` (proposed) |
| License | GPL-3.0 (repo `license.spdx_id`) |
| Source | https://github.com/jordan-dalby/ByteStash |
| Download | Source tarball `https://github.com/jordan-dalby/ByteStash/archive/refs/tags/v1.6.2.tar.gz`. No release assets. Arch-neutral; native modules build per arch. |
| Checksum source | None published upstream. sha256 of the fetched tarball: `a132760975163fcbb46be9c4f293aa77935cae937e61d0397d529cdc461d183c` (our hash, to be re-checked at build). |
| Upstream Dockerfile reviewed | `Dockerfile` at eb4ecdf: client stage on `node:22.23.4-alpine` (`npm ci`, `npm run build`), production stage on `node:22.23.4-alpine` (`npm install --omit=dev` from `server/package.json`, copies `server/src`, `server/docs`, client build to `/client/build`), `EXPOSE 5000`, `CMD ["node","src/app.js"]`, no USER. |
| Engines | `node >=22` (server/package.json, main branch) |
| Native deps | `better-sqlite3 ^11.5.0`, `bcrypt ^6.0.0`. UNVERIFIED whether prebuilt binaries are used for glibc amd64 and arm64, or whether they compile. |
| Port | 5000, hard-coded `const PORT = 5000` in `server/src/app.js`; not configurable by env. |
| Env vars read (code, main branch) | `BASE_PATH`, `ALLOW_NEW_ACCOUNTS`, `TOKEN_EXPIRY` (default `24h`), `DISABLE_ACCOUNTS`, `DISABLE_INTERNAL_ACCOUNTS`, `ALLOW_PASSWORD_CHANGES`, `JWT_SECRET`, `JWT_SECRET_FILE`, `MIGRATE_SQLITE_TO_POSTGRES`, `DATABASE_URL`, `DATABASE_URL_FILE`, `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_PASSWORD_FILE`, `POSTGRES_DB`, `POSTGRES_SSL`, `OIDC_ENABLED`, `OIDC_DISPLAY_NAME`, `OIDC_ISSUER_URL`, `OIDC_CLIENT_ID`, `OIDC_CLIENT_SECRET`, `OIDC_SCOPES`. `PUBLIC_URL`, `DEBUG`, `ALLOWED_HOSTS` appear in README only (UNVERIFIED in code). |
| Data path | `server/src/config/sqlite.js` `getDataDirectory()` = `join(__dirname, "../../../data/snippets")`. Upstream layout gives `/data/snippets`. Not overridable by env. Holds `snippets.db` and the generated JWT secret (unless `JWT_SECRET` is set). |
| Client path | `server/src/app.js` `buildPath = join(__dirname, "../../client/build")`. |
| Admin | `node src/scripts/admin.js grant <username>` (README). Accounts are never admin on creation. |

Derived, not fetched: with the server at `/app/bytestash/src`, the relative paths resolve to `/app/data/snippets` (data) and `/app/client/build` (client).

## 2. Target layout

- `apps/bytestash/Dockerfile`
- `apps/bytestash/docker-bake.hcl`
- `apps/bytestash/settings.yaml`
- `apps/bytestash/container-test.yaml`
- `apps/bytestash/start.sh`

No `defaults/`, `etc/` or `health/` (the app creates its own data and JWT on first start). No `root/`. `DOWNSTREAM_CHANGES.md` not needed (not used as a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` for the final stage, as the draft proposes. Closest sibling: `apps/thelounge` (python-node, npm/yarn app, `WORKDIR /config`). The node version shipped in python-node is UNVERIFIED against `node >=22`; check with `node --version` in the built image before relying on it. If it is below 22, switch to a base that provides Node 22 and record that in this plan.

## 4. Dockerfile

1. Build stage `FROM <python-node> AS build` (same digest), `ARG VERSION`, `USER root`.
2. Download the source tarball to `/tmp`, verify the sha256 above, extract to `/tmp/src`, then `mkdir -p /app/bytestash && cp -r /tmp/src/server/src /tmp/src/server/docs /tmp/src/server/package.json /app/bytestash/`. Copy `/tmp/src/client` build output to `/app/client/build` after `npm ci && npm run build` in the client folder (client build step runs in the build stage, same Node version).
3. Install server deps in `/app/bytestash`: `npm install --omit=dev` (native modules compile here if no prebuild). Install build tools with `apt-get install -y --no-install-recommends build-essential python3` in the build stage only if the compile is needed (UNVERIFIED).
4. Remove npm caches: `npm cache clean --force`, `rm -rf /tmp/*`.
5. Final stage: same base, `USER root` for `mkdir -p /app/bytestash` setup, then `COPY --from=build /app/bytestash /app/bytestash` and `COPY --from=build /app/client /app/client`.
6. Create the data symlink so that `../../../data/snippets` resolves to writable storage: `ln -s /config/data /app/data` (dangling until `start.sh` creates `/config/data`).
7. License: `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/bytestash/LICENSE` (copy in the build stage first, since the source tree is not in the final image).
8. `chown -R apps:apps /app/bytestash` is not needed if files are root-owned and read-only; keep `chmod -R 755 /app`.
9. ENV: `HOME=/config`, `NODE_ENV=production`, `NPM_CONFIG_CACHE=/tmp/npm`.
10. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 5000
VOLUME /config
WORKDIR /app/bytestash
```

`WORKDIR` is required so the relative `../../../data` path resolves from `/app/bytestash/src/config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "bytestash" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=jordan-dalby/ByteStash versioning=semver
  default = "1.6.2"
}
variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/jordan-dalby/ByteStash" }
```

Use the SPDX value reported by upstream (`GPL-3.0`), not an assumed `-only`. Four standard targets and the default group copied from `apps/adguardhome-sync`. Run `docker buildx bake --print`. The Dockerfile `ARG VERSION` must equal this default.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/jordan-dalby/ByteStash"
ports:
  - port: 5000
    protocol: tcp
    required: false
env:
  - name: BASE_PATH
    default: ""
    required: false
  - name: ALLOW_NEW_ACCOUNTS
    default: "true"
    required: false
  - name: TOKEN_EXPIRY
    default: "24h"
    required: false
  - name: DISABLE_ACCOUNTS
    default: "false"
    required: false
  - name: DISABLE_INTERNAL_ACCOUNTS
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Only variables the code reads are listed. `JWT_SECRET`, `DATABASE_URL` and OIDC variables are optional and can be added with empty defaults. `PUBLIC_URL` is not added: it is UNVERIFIED in code. Defaults must match what the app uses: `ALLOW_NEW_ACCOUNTS` is `true` only when set to `'true'`, so the `"true"` default here is a deployment choice and must be confirmed against the upstream README before merging. No dependencies (SQLite default).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data/snippets

cd /app/bytestash
exec node src/app.js
```

- Idempotent. Seeds nothing; the app creates `snippets.db` and the JWT secret under `/config/data/snippets` (through the `/app/data` symlink) on first run.
- Nothing written under `/app`.
- The app listens on `0.0.0.0`? UNVERIFIED: `app.listen(PORT)` without a host binds all interfaces by default in Node, which must be confirmed with a probe from outside the container.
- `exec` so signals reach Node as PID 1 (through tini).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '5000'
http:
- port: '5000'
  path: /
filePaths:
- /app/bytestash/src/app.js
- /app/client/build/index.html
- /usr/share/licenses/bytestash/LICENSE
```

`/` serves the client index from `/app/client/build`. Confirm the status code with a probe (UNVERIFIED). The test runs with no env vars; the JWT and DB code paths on first start are exercised by the run step in section 11, not by this file.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data/snippets` (SQLite, JWT secret; upstream path from `__dirname`) | Image-level symlink `/app/data` -> `/config/data`, so the derived `/app/data/snippets` lands in `/config`. |
| `/app/src/config` and `node_modules` writes | None found. Do not write under `/app` at runtime. |
| npm cache | `NPM_CONFIG_CACHE=/tmp/npm` at build only. |

Draft expectations reconciled: the chart runs as UID 568 and read-only rootfs (compatible). Upstream runs as root; this image runs as `apps` (UID 568). The chart's `/data/snippets` PVC maps to `/config/data/snippets` here; existing users must move their data into that path.

## 10. Risks, caveats and open questions

- Native modules `better-sqlite3` and `bcrypt` may compile on arm64 (slow, needs build tools). UNVERIFIED which path each arch takes.
- Node version in python-node is UNVERIFIED against `node >=22`.
- The env list is from the main branch, not the pinned tag. Re-check against v1.6.2 before merging.
- The `/app/data` symlink is required; if the app's path logic changes upstream, the data would fall outside `/config`.
- Upstream has no published checksum for the source tarball; our hash is computed from the fetched file.
- Client build uses `npm ci` with a lockfile at `client/`; confirm it exists at the pinned commit.
- First account is created in the web UI; admin needs `admin.js grant` through `docker exec` (documented, not automated).
- No blockers confirmed (not musl-only, no GPU, no privileged, no required database).

## 11. Build and test steps

```sh
cd apps/bytestash
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name bytestash-probe --read-only --tmpfs /tmp \
  -v bytestash-probe-config:/config bytestash:1.6.2
docker logs -f bytestash-probe
forgetool containers test --image bytestash:1.6.2 --config ./apps/bytestash/container-test.yaml
docker rm -f bytestash-probe; docker volume rm bytestash-probe-config
```

Readiness signal expected: `Server running on port 5000` (app.js log line). Confirm `/config/data/snippets/snippets.db` exists after start and survives a restart. Probe from outside the container with `-p 5000:5000` to prove it is not bound to localhost.

## 12. PR checklist

- Branch `feat/add-bytestash`, commit and PR title `feat(bytestash): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: the build on both architectures, runtime on `--read-only`, the probe status code, the native modules on arm64, and the admin grant flow.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
