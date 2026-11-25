# nano-wallet — implementation plan
> Source: ./draft.md · Target: apps/nano-wallet/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `1.3.2` (latest and only release, tag commit `303217c9a4c1e31ee866a2b7f871bb34af51a023`, published 2020-09-08). Source: https://api.github.com/repos/linuxserver/nano-wallet/releases/latest and `.../tags`. master HEAD is `bad0055dfc25ab76861f9c07f896db89731311ad` (2021-07-01), newer than the tag but not a release. |
| Chart image | `ghcr.io/linuxserver/nano-wallet:2021.12.16` (draft). The upstream docker repo is archived: https://github.com/linuxserver-archive/docker-nano-wallet (last tag `1.3.2-ls39`, 2022-05-19). |
| Renovate | `datasource=github-tags depName=linuxserver/nano-wallet versioning=semver` (tags are plain semver `1.3.2`). |
| License | GPL-3.0 (GitHub API `license.spdx_id`; LICENSE is GPLv3). `package.json` has no `license` field. Source: https://github.com/linuxserver/nano-wallet/blob/master/LICENSE |
| Source URL | https://github.com/linuxserver/nano-wallet |
| Download | No prebuilt binary and no release asset. Source tarball `https://github.com/linuxserver/nano-wallet/archive/refs/tags/${VERSION}.tar.gz`, built into static files. Confirmed by the upstream Dockerfile, which clones the repo and checks out `WALLET_VERSION`. |
| Checksum source | None published. The tag is pinned, and the tarball is content-addressed by tag. UNVERIFIED that the tarball URL was downloaded. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linuxserver/docker-nano-wallet/120b82f4d1ba/Dockerfile (build stage `baseimage-alpine:3.12`, `npm install && npm run build`, runtime stage `baseimage-alpine:3.12` with apk `nginx`, `COPY --from=build /nano-wallet/dist /web`, `COPY root/ /`, `EXPOSE 80`; no `ENV`, `VOLUME`, `ENTRYPOINT` or `USER`). |
| Upstream nginx | `root/nginx.conf` (`user abc;`, `pid /run/nginx.pid;`, `daemon off;`, `include /default;`) and `root/etc/services.d/nginx/run` (`exec /usr/sbin/nginx -c /nginx.conf`). Source: https://api.github.com/repos/linuxserver/docker-nano-wallet/contents/root/nginx.conf. UNVERIFIED: the site file `root/default` (listen port, root path). |
| Build tooling | `package.json` scripts: `build` = `vue-cli-service build`, `serve`, `lint`. `package-lock.json` is committed. No `start` script. Source: https://api.github.com/repos/linuxserver/nano-wallet/contents/package.json |
| Build Node version | UNVERIFIED: no `engines` field; Vue CLI version in devDependencies not read. |
| Build-time env | `.env` (committed) sets `VUE_APP_TITLE` and `VUE_APP_NFC_TOKEN`. Vue inlines these at build time, so they are not runtime env. |
| Runtime env | None. RPC endpoints are set in `src/stores/app/state.js` (`node` array). Source: https://api.github.com/repos/linuxserver/nano-wallet/readme |
| Port | 80 (upstream `EXPOSE 80`). ContainerForge port: 8080 (see section 9). |
| Data paths | None. README: "Completely clientside ... No browser/disk local storage used". |
| Dependencies | None inside the container. The browser needs a reachable Nano RPC endpoint. |
| arm64 | The output is architecture-neutral static JS. Upstream ships `Dockerfile.aarch64` and `Dockerfile.armhf` that build the same files. |

## 2. Target layout

- `apps/nano-wallet/Dockerfile`
- `apps/nano-wallet/docker-bake.hcl`
- `apps/nano-wallet/settings.yaml`
- `apps/nano-wallet/container-test.yaml`
- `apps/nano-wallet/start.sh` (starts nginx; no seeding needed)
- `apps/nano-wallet/etc/nano-wallet/nginx.conf` (rootless nginx config, read-only, shipped via the `etc/` allow-list path)

No `defaults/`, `health/` or `root/` (the upstream `root/` is not copied). No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- Build stage: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build`. Provides Node and npm for `npm ci` and `npm run build`.
- Final stage: `FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f`. Serves the static `dist/`, and it is the sibling of this app's nginx role. Its Ubuntu 26.04 base is the same as the sibling `apps/nginx`.

Closest siblings: `apps/nginx` (nginx on 8080, `USER apps`, `COPY --chmod=0755 . /`) and `apps/budge` / `apps/changedetection` (python-node build patterns).

Alternative if the nginx base does not fit: `ghcr.io/trueforge-org/ubuntu:26.04` with apt `nginx`, pinned against an `ARG NGINX_VERSION` as `apps/nginx` does. Not chosen, because the nginx base already exists.

## 4. Dockerfile

1. `ARG VERSION=1.3.2` in both stages, aligned with `docker-bake.hcl`.
2. Build stage (no root step needed; it runs as the python-node default user):
   - `ENV HOME=/tmp NPM_CONFIG_CACHE=/tmp/npm-cache NPM_CONFIG_UPDATE_NOTIFIER=false`
   - `RUN curl -fL "https://github.com/linuxserver/nano-wallet/archive/refs/tags/${VERSION}.tar.gz" -o /tmp/nano-wallet.tar.gz && mkdir -p /tmp/src && tar xzf /tmp/nano-wallet.tar.gz -C /tmp/src --strip-components=1 && rm /tmp/nano-wallet.tar.gz`
   - `WORKDIR /tmp/src`, `RUN npm ci && npm run build`. Use `npm ci` because `package-lock.json` is committed. If the build fails on OpenSSL 3 (webpack 4 era), set `NODE_OPTIONS=--openssl-legacy-provider` for that step only and record it as a finding.
3. Final stage:
   - `USER root`
   - `RUN mkdir -p /app/nano-wallet /usr/share/licenses/nano-wallet` and `COPY --from=build /tmp/src/dist/ /app/nano-wallet/`
   - `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/nano-wallet/LICENSE`
   - `RUN chown -R apps:apps /app/nano-wallet && chmod -R 755 /app/nano-wallet`
   - `USER apps`, `COPY --chmod=0755 . /`
4. Tail:

```dockerfile
ENV HOME=/tmp
EXPOSE 8080
USER apps
CMD ["/start.sh"]   # or ENTRYPOINT, as set by the ubuntu base; see section 7
```

The upstream `dist/` is static, so `/app` only needs to be readable. Nothing writes to `/app`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "nano-wallet"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=linuxserver/nano-wallet versioning=semver
  default = "1.3.2"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/linuxserver/nano-wallet"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = { VERSION = "${VERSION}" }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = ["linux/amd64", "linux/arm64"]
}
```

`LICENSE` is `GPL-3.0`, the SPDX id GitHub reports for the LICENSE text. Check the SPDX form the sibling apps use (`grep LICENSE apps/*/docker-bake.hcl`). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/linuxserver/nano-wallet"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes: []
dependencies: []
```

No runtime env vars are read (`VUE_APP_*` are build-time). `volumes` is empty because nothing is persisted. The `/config` volume is not needed, and the nginx base's own `/config/nginx.conf` default is overridden by our `CMD`/`start.sh`.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

# Nothing to seed: the wallet is client-side and nginx config is read-only in /etc.
exec nginx -c /etc/nano-wallet/nginx.conf -g "daemon off;"
```

- Idempotent and empty-`/config` safe because it never touches `/config`.
- No writes to `/app`. nginx temp, pid and cache paths point at `/tmp` (section 9).
- `exec` gives nginx PID 1 signal handling through the base's init.
- Check the ubuntu base entrypoint (`apps/ubuntu/Dockerfile`) and the nginx base `CMD` first. Choose `CMD` or `ENTRYPOINT` so `start.sh` is the only process started. The nginx base `CMD` uses `/config/nginx.conf`, so our `CMD` must override it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 60
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/nano-wallet/index.html
- /etc/nano-wallet/nginx.conf
- /usr/share/licenses/nano-wallet/LICENSE
```

- `tcp` and `http` probes on the single declared port 8080. `/app/nano-wallet/index.html` is UNVERIFIED as the Vue build output name (standard for vue-cli, confirm after the first build).
- The test runs without env vars, and no code path needs one.

## 9. Rootless and read-only-rootfs adaptations

| Upstream | ContainerForge |
| --- | --- |
| `user abc;` in `nginx.conf` | Drop `user`. The process runs as `apps`. |
| `pid /run/nginx.pid;` | `pid /tmp/nginx/nginx.pid;` |
| `listen 80` (site config) | `listen 8080;` (non-root cannot bind 80). |
| Default temp paths under `/var/lib/nginx` | `client_body_temp_path /tmp/nginx/client_body;`, `proxy_temp_path`, `fastcgi_temp_path`, `uwsgi_temp_path`, `scgi_temp_path` all under `/tmp/nginx/`. |
| Access/error logs | `access_log /dev/stdout;`, `error_log /dev/stderr;` (works on read-only rootfs). |
| `/nano-wallet/dist` copied to `/web` | `/app/nano-wallet` (read-only). |
| `/etc/services.d/nginx/run` (s6) | Not used; `start.sh` plus the base init. |

- The chart's `runAsUser: 0` is replaced by `USER apps`, and the image runs with `--read-only --tmpfs /tmp`.
- The chart's `readOnlyRootFilesystem: false` is compatible with `--read-only` after the `/tmp` remap above.
- `/tmp/nginx` must be created by `start.sh` (`mkdir -p /tmp/nginx/...`) because `--tmpfs /tmp` starts empty.
- No `privileged`, no `extra-persistence`.

## 10. Risks, caveats and open questions

- Version choice: the tag `1.3.2` (2020) is older than master (2021-07-01). The chart's image `2021.12.16` probably includes master, but this is UNVERIFIED. Chosen: tag, because it is the only release and it is semver for Renovate.
- Node/OpenSSL: the Vue CLI version is unknown, so the build may need `NODE_OPTIONS=--openssl-legacy-provider` on Node 17+. Verify on the first build.
- The upstream LICENSE is GPL-3.0; `package.json` declares no license. The LICENSE in the bake file follows the LICENSE file.
- "Fork" status: linuxserver/nano-wallet is a LinuxServer project. Whether it is a fork of another project is UNVERIFIED. Draft caveat is not confirmed either way.
- The upstream docker repo is archived. Source repo last master commit was 2021-07-01 and the repo was last pushed 2023-03-04.
- Blockers: none. No GPU, no privileged, arm64 build is architecture-neutral.
- The wallet needs a reachable Nano RPC endpoint from the browser. The RPC URL is baked into the build (state.js), so changing it requires a rebuild. This is a product limitation to state in the PR.
- Upstream `root/default` nginx site file was not read; the final root path (`/app/nano-wallet`) and SPA fallback (`try_files $uri /index.html`) must be written in `etc/nano-wallet/nginx.conf` and checked by hand, because the wallet uses hash routing (`/#/...`), so a plain `/` probe works.

## 11. Build and test steps

```sh
cd apps/nano-wallet
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name nano-wallet-probe --read-only --tmpfs /tmp \
  -v nano-wallet-probe-config:/config nano-wallet:1.3.2
docker logs -f nano-wallet-probe
forgetool containers test --image nano-wallet:1.3.2 --config ./apps/nano-wallet/container-test.yaml
docker rm -f nano-wallet-probe; docker volume rm nano-wallet-probe-config
```

- Readiness signal: nginx startup lines (`start worker processes`) and HTTP 200 on `/` from inside and outside the container (`-p 8080:8080`) to prove it binds beyond localhost.
- The empty `/config` volume is attached to confirm the image does not depend on it.
- arm64 only if the amd64 build fails in an arm64-specific way.

## 12. PR checklist

- Branch `feat/add-nano-wallet`, commit and PR title `feat(nano-wallet): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Say in the PR what was not tested: the npm build on the chosen Node version, the `--read-only` run, arm64, and the probe status code.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened.
