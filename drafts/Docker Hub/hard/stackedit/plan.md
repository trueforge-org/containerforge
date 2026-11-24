# stackedit — implementation plan
> Source: ./draft.md · Target: apps/stackedit/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 5.14.0 (git tag `v5.14.0`, package.json version 5.14.0, per draft). The GitHub releases/tags APIs returned 403 and the repo page lists no releases: whether it is the newest tag is UNVERIFIED |
| Renovate | `datasource=github-tags depName=benweet/stackedit` with `extractVersion=^v(?<version>.+)$` (no GitHub releases exist, so tags); `versioning=semver` |
| License | Apache-2.0 (package.json and repo page) |
| Source | https://github.com/benweet/stackedit |
| Download | Source only (no binaries), same for both arches: `https://github.com/benweet/stackedit/archive/refs/tags/v${VERSION}.tar.gz`; build output is static |
| Checksum | None published |
| Upstream Dockerfile | `Dockerfile` in the repo at v5.14.0: `FROM benweet/stackedit-base` (a separate base image, contents unseen), `ENV V4_VERSION 4.3.22`, `npm pack stackedit@$V4_VERSION && tar xzf ... && yarn` (legacy v4 editor into `/opt/stackedit/stackedit_v4`), `npm install --unsafe-perm`, `ENV NODE_ENV production`, `npm run build`, `EXPOSE 8080`, `CMD [ "node", "." ]` (an Express server, not static hosting). `qmcgaw/stackedit` (draft image) could not be read (404) |
| Build tooling | package.json: Vue ^2.5.16, Webpack ^2.6.1, `engines` node >= 8, scripts `build`, `build-style`, `postinstall: gulp build-prism` |
| Ports | 8080 (upstream `EXPOSE 8080`; matches the `nginx` base) |
| Env (README, Helm section) | Optional OAuth/API keys read by the server: `DROPBOX_API_KEY`, `DROPBOX_FULL_ACCESS_API_KEY`, `GOOGLE_CLIENT_ID`, `GOOGLE_API_KEY`, `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`, `WORDPRESS_CLIENT_ID`, `WORDPRESS_CLIENT_SECRET` |
| Dependencies | none |

## 2. Target layout

```
apps/stackedit/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/default.conf      # nginx server on 8080 (copy the it-tools pattern)
```
Mirrors `apps/it-tools`, which also uses `docker-entrypoint.d/10-copyconfig.sh`; here `start.sh` is not needed if the nginx base's entrypoint copies the config. Final decision on `start.sh`: keep it, as the instruction set expects one for the final command (see section 7). `root/` not used. No DOWNSTREAM_CHANGES.md.

## 3. Base image

Build stage: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (has node 26.x, yarn, git). Final stage: `ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f` (draft main runtime, static JS editor). Closest sibling: `apps/it-tools` (node build in ubuntu stage, `dist/` copied into nginx html). Alternative if the app needs its Express server (see section 10): ubuntu with `node .`.

## 4. Dockerfile

1. `ARG VERSION` (5.14.0).
2. Stage `builder` (`FROM ubuntu... AS builder`): `USER root`, `WORKDIR /tmp`, `ENV HOME=/tmp`, `ENV NODE_ENV=development` for install. Fetch `https://github.com/benweet/stackedit/archive/refs/tags/v${VERSION}.tar.gz` (or `ADD https://github.com/benweet/stackedit.git#v${VERSION}` as it-tools does) and extract to `/tmp/src`.
3. In the builder: `npm install --unsafe-perm` (runs `postinstall` gulp), then `NODE_ENV=production npm run build`. Webpack 2 with a very new Node usually needs `NODE_OPTIONS=--openssl-legacy-provider` (UNVERIFIED for Node 26); if it still fails, install an older node in the builder only (e.g. from the `node` apt/nvm-free tarball with its SHASUMS256.txt check, as `apps/ubuntu` does for node).
4. Also build or fetch the v4 legacy editor only if the build output requires it (upstream runs `npm pack stackedit@4.3.22`); UNVERIFIED whether v5 `dist` references `/stackedit_v4`.
5. Final stage `FROM nginx...`: `USER root`; `COPY --from=builder --chown=568:568 /tmp/src/dist/ /usr/share/nginx/html` (output dir `dist` is the webpack default and UNVERIFIED); copy license: `mkdir -p /usr/share/licenses/stackedit` and `COPY --from=builder /tmp/src/LICENSE /usr/share/licenses/stackedit/LICENSE`.
6. No apt packages needed (nginx base has what is required).
7. Caches: builder only uses `HOME=/tmp`; nothing is written outside `/tmp` at runtime.
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /usr/share/nginx/html`, and the final instruction is `USER apps`. (it-tools also keeps a pre-`USER` `COPY --chmod=755 ./ /`; copy that pattern exactly.)

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "stackedit" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=benweet/stackedit extractVersion=^v(?<version>.+)$
  default = "5.14.0"
}
variable "LICENSE" { default = "Apache-2.0" }
variable "SOURCE" { default = "https://github.com/benweet/stackedit" }
```
Targets: `docker-metadata-action`, `image`, `image-local` (tag `${APP}:${VERSION}`), `image-all` (linux/amd64, linux/arm64), `group "default"`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Header + `schema_version: 1`, `upstream_env_url: "https://github.com/benweet/stackedit"`.
- ports: `8080` tcp, required true.
- env: `TZ` (`Etc/UTC`, false). The OAuth keys from the README are only read by the upstream Express server; if the static build is used they have no effect and are NOT listed. If the server variant is chosen (section 10), add `DROPBOX_API_KEY`, `DROPBOX_FULL_ACCESS_API_KEY`, `GOOGLE_CLIENT_ID`, `GOOGLE_API_KEY`, `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`, `WORDPRESS_CLIENT_ID`, `WORDPRESS_CLIENT_SECRET` (all required false, default "").
- volumes: `/config` required true (nginx config, as in the it-tools sibling).
- dependencies: none.

## 7. start.sh

Follows the nginx base: `defaults/default.conf` (server on `0.0.0.0:8080`, `root /usr/share/nginx/html`, `try_files $uri $uri/ /index.html`) is copied into `/config/sites/default.conf` only when missing (it-tools overwrites; here keep user edits). Script:
```bash
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /config/sites /tmp/nginx-temp /tmp/nginx-cache
[ -f /config/sites/default.conf ] || cp /defaults/default.conf /config/sites/default.conf
exec nginx -c /config/nginx.conf -g 'daemon off;'
```
`/config/nginx.conf` is seeded by the nginx base's `docker-entrypoint.d/03-copyconfig.sh` (UNVERIFIED how it interacts with a start.sh; if the base `CMD` already does this, drop `start.sh` and keep only `docker-entrypoint.d/10-copyconfig.sh` like it-tools, and then section 2 lists that file instead). Nothing is written to `/app` or the html dir. Binds 0.0.0.0:8080.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /usr/share/nginx/html/index.html
- /usr/share/licenses/stackedit/LICENSE
```
Probes cover the single port 8080 (tcp and http). `timeoutSeconds: 180` matches the it-tools and nginx siblings (default). No env-dependent code path exists in the static variant.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| Express server (`node .`) cache/logs | not present in the static image |
| nginx temp and cache | `/tmp/nginx-temp`, `/tmp/nginx-cache` (as the nginx base) |
| nginx config | `/config` (persistent, seeded when missing) |

Draft: runs as root, writable rootfs, no persistence. The image runs UID 568 on a read-only rootfs: html content is baked in, nothing is written to it. `/config` only holds nginx config.

## 10. Risks, caveats and open questions

- UNVERIFIED and important: upstream runs an Express server (`CMD node .`) next to the built app. The server likely serves the OAuth callbacks, `/conf`-style settings with the API keys, PDF/export helpers, and the v4 legacy editor. A pure nginx static image would then lose features (Dropbox/Google/GitHub sign-in, publishing). Before implementing, read `server/index.js` and `server/conf.js` at tag v5.14.0; if the client fetches runtime config from the server, switch to `FROM ubuntu` with `node .` (env variables from section 6) instead of nginx.
- Build tooling is old (Webpack 2, Vue 2.5, node-sass/gulp style dependencies): building on Node 26 may fail and need an older Node in the builder stage.
- No public Dockerfile for the draft's `qmcgaw/stackedit` image; the build is reconstructed from the repo's own Dockerfile.
- The version is UNVERIFIED as latest; upstream may have no newer tag, in which case renovate will not propose updates.
- No blockers (not musl-only, no GPU, no privileged); arm64 is fine for a static build.

## 11. Build and test steps

```sh
cd apps/stackedit
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name stackedit-probe --read-only --tmpfs /tmp -v stackedit-probe-config:/config stackedit:5.14.0
docker logs -f stackedit-probe
forgetool containers test --image stackedit:5.14.0 --config ./apps/stackedit/container-test.yaml
docker rm -f stackedit-probe; docker volume rm stackedit-probe-config
```
Readiness: nginx starts without errors and `curl -I http://127.0.0.1:8080/` returns 200; load the page in a browser and check the editor renders and that sign-in buttons do not error (see section 10).

## 12. PR checklist

- Branch `feat/add-stackedit`, commit `feat(stackedit): add new container`, target `main`.
- Use the PR template; tick only the applicable boxes.
- Notes: `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge ; only the user can sign it.
- Untested (say so if not built): the webpack build on the chosen Node, arm64, OAuth integrations, browser behaviour of the static variant.
- Pre-completion: `bake --print` passes, `VERSION` aligned between Dockerfile and bake, final `USER apps`, `COPY --chmod=0755 . /` present, empty `/config` start works.
