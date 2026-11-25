# standardnotes-web — implementation plan
> Source: ./draft.md · Target: apps/standardnotes-web/ · Difficulty: hard (long yarn monorepo build) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `3.203.3` (git tag `@standardnotes/web@3.203.3`; `packages/web/package.json` version 3.203.3). Draft says `docker.io/standardnotes/web:stable`; Docker Hub currently shows tags `latest` plus commit SHAs only (last pushed 2026-11-23), so there is no semver image tag to follow. |
| Renovate | `datasource=github-tags depName=standardnotes/app extractVersion=^@standardnotes/web@(?<version>.+)$ versioning=loose` (tags of other packages share the repo, so the extractVersion filter is needed). UNVERIFIED: the exact renovate behaviour of this filter in the repo's custom manager; check on the first Renovate run. |
| License | AGPL-3.0 (GitHub API `spdx_id: AGPL-3.0`; use `AGPL-3.0-only`) |
| Source | https://github.com/standardnotes/app |
| Artifacts | No release binary. The GitHub "Releases" list holds desktop/mobile installers only (`@standardnotes/desktop@3.203.0` assets are .deb/.AppImage/.exe) and is not usable. Build `packages/web` from source on both arches (draft: compile/compile). |
| Checksum source | Not applicable: source is fetched from a git tag (`ADD` of a git URL pins the tag). Pin the commit SHA of the tag if reproducibility is wanted (UNVERIFIED: SHA not looked up). |
| Upstream Dockerfile reviewed | `packages/web/Dockerfile`: a single line set, `FROM nginx:alpine` + `COPY ./dist /usr/share/nginx/html`, no EXPOSE, no custom nginx config, no user. The bundle is built outside the Dockerfile. |
| Build commands | Root `package.json`: `"build:web": "yarn workspaces foreach -pt --topological-dev --verbose -R --from @standardnotes/web run build"`, `packageManager: yarn@3.2.1`; `.nvmrc` = `22.14.0`. `packages/web` build script: `yarn clean && yarn copy:components && webpack --config web.webpack.prod.js && yarn tsc`. Output dir is `packages/web/dist` (that is what the upstream Dockerfile copies). Root `engines.node` text `>=12.19.0 <17.0.0` is stale vs `.nvmrc`; UNVERIFIED which Node 22 patch the base ships. |
| Ports | nginx serves static files; upstream default is 80 (nginx:alpine). Use 8080 per the ContainerForge nginx sibling. |
| Env vars | None read by the static bundle at runtime (the sync server URL is chosen in the web UI). UNVERIFIED: whether a build-time `DEFAULT_SYNC_SERVER` style variable exists; none was found in the files read. |

## 2. Target layout

```
apps/standardnotes-web/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  defaults/default.conf              # nginx server block on 8080 (copy of apps/it-tools/defaults/default.conf)
  docker-entrypoint.d/10-copyconfig.sh   # copies default.conf into /config/sites when missing (same mechanism as it-tools)
```
No `start.sh`: the nginx base image's entrypoint runs `docker-entrypoint.d/*`. No `root/`. No DOWNSTREAM_CHANGES.md (not used as a `FROM` base).

## 3. Base image

- Runtime: `FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f` (static bundle, matches upstream's nginx choice, glibc not musl).
- Builder: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS builder` (the same builder pattern as apps/it-tools, which uses node/npm from this base).
- Closest sibling: `apps/it-tools` (node build stage, static `dist/` into nginx).

## 4. Dockerfile

1. Builder stage: `ARG VERSION`, `WORKDIR /tmp`, `ENV HOME=/tmp YARN_CACHE_FOLDER=/tmp/.yarn-cache`, `USER root`.
2. Fetch source: `ADD https://github.com/standardnotes/app.git#@standardnotes/web@${VERSION} .` (UNVERIFIED that the `@` and `/` in the ref work in BuildKit's git ADD syntax; fallback: `git clone --depth 1 --branch "@standardnotes/web@${VERSION}"`, which needs `git` from apt, check the base first).
3. `corepack enable && corepack prepare yarn@3.2.1 --activate` (version from `packageManager`), then `yarn install --immutable` and `yarn build:web`. Check the Node version in the base is 22 (`.nvmrc` 22.14.0); if not, install Node 22 in the builder only.
4. Runtime stage (nginx base): `USER root`, `COPY --from=builder --chown=568:568 /tmp/packages/web/dist/ /usr/share/nginx/html` (the UID/GID used by it-tools), license: `COPY --from=builder /tmp/LICENSE /usr/share/licenses/standardnotes-web/LICENSE` (UNVERIFIED file name at repo root).
5. Still as root: `COPY --chmod=0755 . /` (applies defaults/ and docker-entrypoint.d/), `EXPOSE 8080`, `VOLUME /config`. Then final `USER apps`, `COPY --chmod=0755 . /` (as in apps/it-tools, whose Dockerfile ends with that pair) and `WORKDIR /usr/share/nginx/html`; USER apps stays the last user instruction.
6. No apt packages in the runtime stage. Caches stay in `/tmp` (builder only).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "standardnotes-web" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=standardnotes/app extractVersion=^@standardnotes/web@(?<version>.+)$ versioning=loose
  default = "3.203.3"
}
variable "LICENSE" { default = "AGPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/standardnotes/app" }
```
Plus `docker-metadata-action`, `image` (args VERSION, source and licenses labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64+arm64), `group "default" { targets = ["image-local"] }`, copied from apps/it-tools. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Header `# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json`, `schema_version: 1`, `upstream_env_url: "https://github.com/standardnotes/app"`.
- ports: `8080` tcp `required: false` (draft said 80; moved to 8080 because the container is rootless).
- env: `TZ` default `Etc/UTC`, required false (only variable; the bundle reads none).
- volumes: `/config` required true.
- dependencies: none (the sync server `standardnotes/server` is external and has no apps/ sibling).

## 7. start.sh

Not applicable: no start.sh. `docker-entrypoint.d/10-copyconfig.sh` (idempotent, same as it-tools but guarded):
```bash
#!/usr/bin/env bash
mkdir -p /config/sites
[ -f /config/sites/default.conf ] || cp /defaults/default.conf /config/sites/default.conf
```
Server binds `listen 8080` and `listen [::]:8080` (all interfaces). The nginx base's CMD (`nginx -c /config/nginx.conf -g "daemon off;"`) is the final foreground process. Verified: `apps/nginx/defaults/nginx.conf` line 9 has `include /config/sites/*.conf;`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 60
http:
- port: '8080'
  path: /
filePaths:
- /usr/share/nginx/html/index.html
```
Covers the single port 8080 (it-tools uses http with no timeout; 60 s is a safe default). No env-only code paths.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs nginx:alpine as root (draft: chart runAsUser 0, readOnlyRootFilesystem false). Here: `USER apps`, port 8080, nginx temp/cache dirs in `/tmp` (the nginx base already prepares `/tmp/nginx-temp`, `/tmp/nginx-cache`), config copied into `/config`.
- Bundle is in `/usr/share/nginx/html` and is only read. No extra persistence (draft: none).
- Draft security expectations (root, writable rootfs) are intentionally not carried over.

## 10. Risks, caveats and open questions

- Long yarn 3 monorepo build; memory-heavy webpack step. Might need `NODE_OPTIONS=--max-old-space-size=...` (UNVERIFIED).
- Needs no extra build env, but `yarn install --immutable` needs network access to the registry during build.
- The UI talks to external Standard Notes sync servers; the container is only the client. Users self-hosting need `standardnotes/server` separately.
- Upstream tags the repo with many package tags; renovate filter must match only `@standardnotes/web@`.
- No upstream semver Docker tag; ContainerForge tracks the git tag instead.
- No blockers: no musl-only, GPU, or privileged needs; arm64 builds natively through node.

## 11. Build and test steps

```sh
cd apps/standardnotes-web
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name standardnotes-web-probe --read-only --tmpfs /tmp -v standardnotes-web-probe-config:/config standardnotes-web:3.203.3
docker logs -f standardnotes-web-probe
forgetool containers test --image standardnotes-web:3.203.3 --config ./apps/standardnotes-web/container-test.yaml
docker rm -f standardnotes-web-probe; docker volume rm standardnotes-web-probe-config
```
Expected: container stays running, nginx starts without `emerg` or permission errors, `curl -f localhost:8080/` returns the app HTML.

## 12. PR checklist

- Branch `feat/add-standardnotes-web`, commit and PR title `feat(standardnotes-web): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- Pre-completion: bake --print OK, VERSION aligned between Dockerfile ARG and bake, final `USER apps`, `COPY --chmod=0755 . /` present, empty `/config` start works.
- Untested (planning only): the yarn build, the git ADD ref syntax, the renovate filter, the arm64 build, (the nginx include path is verified in apps/nginx/defaults/nginx.conf). State this in the PR; do not tick "Built container locally" unless done.
