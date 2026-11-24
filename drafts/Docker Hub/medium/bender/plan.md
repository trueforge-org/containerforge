# bender — implementation plan
> Source: ./draft.md · Target: apps/bender/ · Difficulty: medium · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | **1.0.3** (git tag `1.0.3` = commit `fd780e57350bf995df83d23af03f1eff77f17dfc`, 2022-09-08, matches the Dockerfile link in the draft). No GitHub releases exist, only tags (1.0.1, 1.0.2, 1.0.3). `package.json` still says 1.0.2. The repo has been inactive since 2022-09. |
| Renovate | `datasource=github-tags`, `depName=jez500/bender`, `versioning=semver` |
| License | Apache-2.0 (GitHub API, `LICENSE` file at repo root) |
| Source | https://github.com/jez500/bender |
| Download | https://github.com/jez500/bender/archive/refs/tags/1.0.3.tar.gz (source; build with npm) |
| Checksum | None published. UNVERIFIED: pin none; integrity comes from `package-lock.json` plus `npm ci`. |
| Stack | Nuxt 2 (`nuxt ^2.15.8`, webpack 4, `@nuxt/content`, express serverMiddleware `api/index.js`). Scripts: `build` = `nuxt build`, `start` = `nuxt start`. |
| Upstream Dockerfile | reviewed (commit fd780e5): `node:lts-alpine` build stage (`npm install --frozen-lockfile`, `npm run build`), runtime copies `/app`, copies `/app/static` to `/app/static-default`, `ENV PORT 8080`, `INIT_ASSETS 1`, `VOLUME /app/static/`, entrypoint `entrypoint.sh` |
| Port | **8080** (`nuxt.config.js`: `server: { port: 8080, host: '0.0.0.0' }`). The draft's inferred 3000 is wrong. |
| Env | `INIT_ASSETS` (entrypoint.sh: default `1`; seed `static/` from `static-default` when `static/config.json` is missing). `PORT`, `GID`, `UID` appear in the upstream Dockerfile but the port is hard-coded in `nuxt.config.js`. |
| Write paths | `api/index.js` writes `static/config.json` (relative to cwd) on save, and reads `static/images` for the image list; `config.js`: `CONFIG_FILEPATH = 'static' + CONFIG_FILENAME` |

## 2. Target layout

```
apps/bender/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` needed: defaults are the upstream `static/` shipped in `/app/static-default`. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Why: Node app built with npm; this is the Node-capable base. Python is unused. Closest sibling: `apps/budge` (python-node, npm build into `/app/www`). The base's Node version is 24 per the budge Dockerfile comment (UNVERIFIED for this tag).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `ENV NODE_OPTIONS=--openssl-legacy-provider` for the build only (webpack 4 uses MD4 hashing, which fails on Node 17+ with `ERR_OSSL_EVP_UNSUPPORTED`; upstream built on the Node 16-era `lts-alpine`). Reset with `ENV NODE_OPTIONS=` afterwards or pass it inline to `npm run build`. UNVERIFIED: whether `nuxt start` also needs it at runtime.
3. One `RUN` (no extra apt packages: Node, npm, curl, tar are present; native build tools only if `npm ci` needs them, UNVERIFIED, then purge them after):
   - `mkdir -p /app && curl -fsSL "https://github.com/jez500/bender/archive/refs/tags/${VERSION}.tar.gz" | tar xz -C /app --strip-components=1`
   - `cd /app && npm_config_cache=/tmp/.npm npm ci && NODE_OPTIONS=--openssl-legacy-provider npm run build && npm prune --omit=dev`
   - Move the default assets aside and replace `static` with a symlink: `mv /app/static /app/static-default && ln -s /config/static /app/static`
   - License: `mkdir -p /usr/share/licenses/bender && cp /app/LICENSE /usr/share/licenses/bender/`
   - `chown -R apps:apps /app && rm -rf /tmp/* /config/.npm`.
4. `USER apps`
5. `COPY --chmod=0755 . /`
6. `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /app` (the API writes relative to cwd, so cwd must be `/app`).

## 5. docker-bake.hcl

```hcl
variable "APP"     { default = "bender" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=jez500/bender versioning=semver
  default = "1.0.3"
}
variable "LICENSE" { default = "Apache-2.0" }
variable "SOURCE"  { default = "https://github.com/jez500/bender" }
```
Standard 4 targets (`docker-metadata-action`, `image`, `image-local`, `image-all` amd64+arm64) and `group "default"`, copied from `apps/adguardhome-sync`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/jez500/bender"`.
- ports: `8080/tcp required: false`.
- env: `INIT_ASSETS` default `"1"` required false (read by start.sh, same semantics as upstream); `TZ` default `"Etc/UTC"` required false.
- volumes: `/config` required true (holds `static/`: `config.json` and images).
- dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
mkdir -p /config/static
if [[ "${INIT_ASSETS:-1}" == "1" && ! -f /config/static/config.json ]]; then
  cp -rn /app/static-default/. /config/static/
  cp -n /app/static-default/config.json.default /config/static/config.json
fi
cd /app
exec /app/node_modules/.bin/nuxt start
```
- Seeds only when `config.json` is missing; `cp -n` never overwrites.
- `nuxt start` binds `0.0.0.0:8080` from `nuxt.config.js` (verified in source). Calling the binary directly avoids npm writing logs/cache into `$HOME`; if `npm run start` is used instead, set `npm_config_cache=/tmp/.npm` and `npm_config_logs_dir=/tmp/npm-logs`.
- `nuxt` is a dev dependency candidate: it is in `dependencies`, so `npm prune --omit=dev` keeps it (verified in `package.json`).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180

http:
- port: '8080'
  path: /

filePaths:
- /app/node_modules/.bin/nuxt
- /app/static-default/config.json.default
```
Probe for every port in section 6 (8080). Test runs without env vars, which matches the default path.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/app/static/` (`config.json`, `images/`, favicon; written by `api/index.js` and `entrypoint.sh`) | `/app/static` becomes a symlink to `/config/static`, seeded by start.sh |
| npm cache and logs under `$HOME/.npm` | `npm_config_cache` and `npm_config_logs_dir` in `/tmp` (only matters if npm is run at runtime) |
| `.nuxt/` build output | built at image build time, read-only at runtime. UNVERIFIED: whether `@nuxt/content` or the PWA module write under `.nuxt` or `node_modules/.cache` at start. |

Draft expectations: chart ran UID 0, `readOnlyRootFilesystem: false`, extra persistence `/app/static`. This plan runs UID 568, read-only rootfs, and moves the persistence to `/config/static`.

## 10. Risks, caveats and open questions

- Nuxt 2 and webpack 4 on Node 24: `--openssl-legacy-provider` is required for the build (and possibly runtime). If the build still fails, pin an older Node via a build stage (`node:18`) and copy `/app` over (UNVERIFIED).
- Upstream is unmaintained since 2022, so there will be no upstream updates; versions in `package-lock.json` have known advisories. Tag-only versioning (no GitHub releases).
- Upstream used alpine (musl); nothing in the dependency list looks musl-only, but native modules are not enumerated here (UNVERIFIED).
- The `static` symlink relies on Nuxt's `static/` serving following symlinks (serve-static follows them by default; UNVERIFIED).
- The tarball has no published checksum.

## 11. Build and test steps

```sh
cd apps/bender
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name bender-probe --read-only --tmpfs /tmp \
  -v bender-probe-config:/config bender:1.0.3
docker logs -f bender-probe
forgetool containers test --image bender:1.0.3 --config ./apps/bender/container-test.yaml
docker rm -f bender-probe; docker volume rm bender-probe-config
```
Expected readiness: Nuxt log `Listening on: http://0.0.0.0:8080` and port 8080 open. Verify the seeded `/config/static/config.json` exists after the first start, and then save a change from the UI to confirm the symlinked path is writable.

## 12. PR checklist

- Branch `feat/add-bender`; commit and PR title `feat(bender): add new container`; target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`; Notes contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what is untested: arm64 build, saving config through the UI under read-only rootfs, runtime need for the OpenSSL legacy flag.
- Check "Built container locally" only if it was built.
