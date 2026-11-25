# rsshub — implementation plan
> Source: ./draft.md · Target: apps/rsshub/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v2026.11.25-8755.g8927949` (latest GitHub release, published 2026-11-25). The draft's `v2026.11.20-8704.fcfe5ae` is older; use the latest, and confirm the build in step 11. Tags are `vYYYY.MM.DD-NNNN.g<sha>`. |
| Renovate | `// renovate: datasource=github-tags depName=DIYgod/RSSHub versioning=loose` (no assets, so tags, not releases, are the source; `github-releases` would also work since releases exist) |
| License | AGPL-3.0 (GitHub SPDX `AGPL-3.0`, https://api.github.com/repos/DIYgod/RSSHub) |
| Source URL | https://github.com/DIYgod/RSSHub |
| Download | Source tarball: `https://github.com/DIYgod/RSSHub/archive/refs/tags/${VERSION}.tar.gz`. The release has no binary assets, so amd64 and arm64 are both source builds (`compile`). The draft's `yes` for both is corrected here. |
| Checksum source | None published. The GitHub tag tarball is content-addressed by the tag's commit SHA. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/DIYgod/RSSHub/c566e920fd386c19935954e1969ac8d7d3c8b5c4/Dockerfile (5 stages): `node:26-trixie` deps stage with `corepack` and `pnpm install --frozen-lockfile`; `debian:trixie-slim` version parser; `node:26-trixie-slim` minifier with `pnpm build`; `node:26-trixie-slim` Chromium downloader (amd64 only); final `node:26-trixie-slim` with `dumb-init`, `git`, `curl`, `libjemalloc2`, `ENV NODE_ENV=production TZ=Asia/Shanghai PLAYWRIGHT_BROWSERS_PATH=/app/node_modules/.cache/ms-playwright LD_PRELOAD=libjemalloc.so.2`, `EXPOSE 1200`, `ENTRYPOINT ["dumb-init","--"]`, `CMD ["npm","run","start"]`. No VOLUME, no USER. The pinned Node is `node:26`. |
| Port | `1200/tcp` (`EXPOSE 1200`; `PORT` default 1200 in `lib/config.ts`) |
| Env vars (real, from `lib/config.ts`) | `PORT` (default 1200), `LISTEN_INADDR_ANY` (default true), `CACHE_TYPE` (default `memory`; `memory`, `redis`, `http`; empty disables), `CHROMIUM_EXECUTABLE_PATH`, `TZ`, `NODE_ENV`, `PLAYWRIGHT_BROWSERS_PATH`. Redis URL variable name for `CACHE_TYPE=redis`: UNVERIFIED (not fetched from `lib/config.ts`). |
| Data paths | No runtime writes documented. Upstream build writes Chrome path to `/app/.env` (build step, not runtime). ContainerForge must not write `/app/.env`: pass the Chrome path via `CHROMIUM_EXECUTABLE_PATH`. |
| Health | UNVERIFIED: no HEALTHCHECK in upstream Dockerfile. Use the root path `/` (200) in the test if it responds (not verified). |
| Dependencies | Optional `valkey` (`apps/valkey` exists in this repo, so present). Optional `browserless/chrome` (`browserlessImage` in the chart; not in ContainerForge). |
| Docker Hub `diygod/rsshub:latest` | Images for amd64 and arm64 both present (https://hub.docker.com/v2/repositories/diygod/rsshub/tags/latest, images array). Glibc node image. `copy-from amd64` = yes, `copy-from arm64` = yes, but this plan builds from source, so `COPY --from` is not used (UNVERIFIED as a shortcut). |
| Node | Upstream `node:26-trixie` (Node 26). ContainerForge ubuntu base pins `NODE_VERSION` 26.13.1 (`apps/ubuntu/docker-bake.hcl`, lines 19-21), and the ubuntu Dockerfile installs node into `/usr/local` (line 173-179). |

## 2. Target layout

Files under `apps/rsshub/`:

- `Dockerfile`
- `docker-bake.hcl`
- `settings.yaml`
- `container-test.yaml`
- `start.sh` (sets `CHROMIUM_EXECUTABLE_PATH` default, `exec`s `npm run start`)

No `defaults/` (RSSHub has no required config files; it reads env). No `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- Build and final stage: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Node is already in this base (`NODE_VERSION` 26.13.1), so the upstream `node:26` requirement matches without `python-node`.
- Do not use `ghcr.io/trueforge-org/python-node` unless node in that base is confirmed to be 26.x (UNVERIFIED: `budge` mentions Node 24 in its Dockerfile comment, so python-node may be older).
- Closest siblings: `apps/changedetection`, `apps/budge` (node apps on ubuntu/python-node; `apps/budge` uses `npm` builds with `USER apps` and `/config`).

## 4. Dockerfile

1. `FROM <ubuntu> AS build`: `ARG VERSION`, `ARG TARGETARCH`, `USER root`. `ENV PNPM_HOME=/tmp/pnpm` (caches to `/tmp`).
2. Install build packages: none beyond the base (node and curl present). Check `node --version` and `npm --version` in the base first (step 1 of section 11).
3. Pin pnpm to the version in upstream `package.json` `packageManager` field (UNVERIFIED value; read it from the tagged tarball). Do not use `corepack@latest` (upstream does, which is unpinned).
   ```dockerfile
   RUN npm install -g pnpm@<pinned-from-packageManager>
   ```
4. Download and extract source:
   ```dockerfile
   RUN curl -fL "https://github.com/DIYgod/RSSHub/archive/refs/tags/${VERSION}.tar.gz" -o /tmp/rsshub.tar.gz && \
       mkdir -p /app && tar xzf /tmp/rsshub.tar.gz -C /app --strip-components=1 && rm /tmp/rsshub.tar.gz
   ```
5. Build with the lockfile (frozen) and skip browser download at build time:
   ```dockerfile
   WORKDIR /app
   ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
   RUN pnpm install --frozen-lockfile && pnpm build && pnpm prune --prod
   ```
   The upstream multi-stage minify step (`docker-minifier`) is optional: skip it for v1 and record the image size in section 10.
6. Chromium: amd64 only, from the Patchright/Playwright path. Install the Playwright Chromium into `/app/node_modules/.cache/ms-playwright` at build time (so the runtime does not download). Use `PLAYWRIGHT_BROWSERS_PATH=/app/node_modules/.cache/ms-playwright` only at build time, then remove the download cache from `/tmp`. Chromium shared libraries (apt): install via `npx playwright install --with-deps chromium` only if upstream's exact flow is reproduced (UNVERIFIED); otherwise use the distro chromium package and `CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium` (arm64 path upstream uses).
7. License: copy `LICENSE` to `/usr/share/licenses/rsshub/LICENSE`.
8. Permissions: `chown -R apps:apps /app && chmod -R 755 /app`. Build-time caches go to `/tmp` (`PNPM_HOME=/tmp/pnpm`, `npm_config_cache=/tmp/npm`).
9. Final stage (same ubuntu base):
   - `USER root`
   - `apt-get install -y --no-install-recommends dumb-init git curl libjemalloc2` plus the chromium package on arm64 (not on amd64 if Playwright's path is used). `apt-get clean && rm -rf /var/lib/apt/lists/*`.
   - Keep `git`: upstream installs it (UNVERIFIED whether RSSHub needs it at runtime; drop it if the test passes without it).
10. Env and tail:
    ```dockerfile
    ENV NODE_ENV=production TZ=Etc/UTC PORT=1200 LD_PRELOAD=libjemalloc.so.2 HOME=/config
    USER apps
    COPY --chmod=0755 . /
    EXPOSE 1200
    VOLUME /config
    WORKDIR /app
    ```
    The ubuntu base already sets `ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]` (tini is PID 1), so no `dumb-init`, `ENTRYPOINT` or `CMD` is set here (same as `apps/changedetection`); the base `apps/ubuntu/entrypoint.sh` runs `exec /start.sh` when it is executable.
    `TZ` is `Asia/Shanghai` upstream; ContainerForge default is `Etc/UTC` (settings.yaml `TZ`). Keep `Etc/UTC` and let users override.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "rsshub"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=DIYgod/RSSHub versioning=loose
  default = "v2026.11.25-8755.g8927949"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/DIYgod/RSSHub"
}
```

Then the four standard targets and `group "default" { targets = ["image-local"] }`, copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`. `VERSION` keeps the leading `v`, matching the tag in the tarball URL.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/DIYgod/RSSHub"
ports:
  - port: 1200
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: PORT
    default: "1200"
    required: false
  - name: CACHE_TYPE
    default: "memory"
    required: false
  - name: CHROMIUM_EXECUTABLE_PATH
    default: ""
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
opt_dependencies:
  - name: valkey
```

Notes:
- `opt_dependencies` lists `valkey` (optional cache, `apps/valkey` exists). Key name and `- name:` shape confirmed against `apps/babybuddy/settings.yaml`.
- `browserless/chrome` is not a ContainerForge app. Leave it out of `opt_dependencies` and document it in the PR (it is only needed for JS-rendered feeds).
- `CHROMIUM_EXECUTABLE_PATH` default is empty, and `start.sh` fills it. Do not list env vars the app does not read: `LISTEN_INADDR_ANY` stays at its default (true), so omit it.
- `/config` is listed for the required persistent path. RSSHub itself writes nothing there. Keep it because `HOME=/config` and `start.sh` need it, or drop it if the test shows no use (decide in step 11).

## 7. start.sh

Requirements:
- No writes to `/app` (read-only). Only `/config` (persistent) and `/tmp` (scratch).
- Choose the Chromium path if the image has a system browser (arm64 distro chromium); leave it empty on amd64 when Playwright's cache is used.
- `exec` the server so signals reach node. tini from the base entrypoint is PID 1.

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config
if [[ -z "${CHROMIUM_EXECUTABLE_PATH:-}" && -x /usr/bin/chromium ]]; then
  export CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium
fi

cd /app
exec npm run start
```

- `npm run start` is upstream's `CMD` (confirm the script name in `package.json`; UNVERIFIED).
- No config is seeded: RSSHub reads env only.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '1200'

http:
- port: '1200'
  path: /
```

- `tcp` probe for `1200`, the only port in `settings.yaml`.
- `http` probe on `/`. UNVERIFIED that `/` returns 200 with no env; if it does not, probe a route that needs no upstream, and record that in section 10. Do not invent a passing probe.
- Test runs with no env: `PORT` default 1200 works; `CACHE_TYPE` default memory works; no required env, so no `filePaths` entry is needed.
- `timeoutSeconds`: start with 120 (large node app; startup time to be measured in step 11), tune after the first run.
- Narrowing: not applicable (valkey is optional, not a hard dependency). The DB-dependency exception does not apply.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Upstream path | ContainerForge path |
| --- | --- | --- |
| Build: Chrome path written to `/app/.env` | build only (Dockerfile) | Not written: `CHROMIUM_EXECUTABLE_PATH` env instead |
| Build: Playwright browsers | `/app/node_modules/.cache/ms-playwright` | Same path, build time only. Runtime needs no write. |
| Runtime: logs | UNVERIFIED: no log path in the Dockerfile; check `lib/` for file loggers | If a file logger exists, point it at `/tmp` or `/config/logs` |
| npm/pnpm caches | default `~/.npm`, `~/.local` | `/tmp` at build (`npm_config_cache=/tmp/npm`, `PNPM_HOME=/tmp/pnpm`) |

Security expectations (from draft, reconciled):
- non-root: upstream has no USER (root by default in node base, not confirmed). Ours is `USER apps` (ubuntu base).
- read-only rootfs: `/app` read-only, `/tmp` tmpfs in the protocol. Chromium (if run) needs `/tmp` and `/dev/shm`. Add `--shm-size` only if the test shows a crash (UNVERIFIED need).
- privileged: not required. Chromium runs with `--no-sandbox` only if upstream sets it (UNVERIFIED); do not add `--no-sandbox` without checking.
- persistence: none needed beyond `/config`.

## 10. Risks, caveats and open questions

- Size and build time: the upstream build is a large pnpm build (node_modules, Playwright, Chromium on amd64). Expect a big image and a slow first build. Minifier stage skipped in v1 (section 4).
- Chromium: amd64 uses Playwright's bundled Chromium (build-time download, needs network at build). arm64 uses a distro chromium package, which may be snap-based on Ubuntu, so the arm64 path is UNVERIFIED and may need `chromium` from another source. Treat as a blocker for arm64 Chromium feeds, not for the base app.
- Optional valkey: the cache works in memory by default, so no companion is required for a first working image. `CACHE_TYPE=redis` needs the Redis URL variable (UNVERIFIED name).
- Upstream feeds fetch external sites: expect outbound internet and rate limits. Not a build issue.
- Draft corrections:
  - Draft's `amd64: yes` and `arm64: yes` are `compile` in fact (no assets). Corrected above.
  - Draft's version is older than the latest release. Corrected above.
  - Draft's license was not stated; now AGPL-3.0.
  - Draft's `Node 26` base and `python-node` choice: ubuntu base has Node 26.13.1, so `python-node` is not needed.
- Unverified: pnpm pin value (`packageManager` field), `npm run start` script name, Redis URL env name, `/` returning 200, Chromium arm64 package availability, whether `git` is needed at runtime, `opt_dependencies` key name in settings schema.

## 11. Build and test steps

From `apps/rsshub/`:

1. Pre-check: `docker run --rm ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 node --version` must print 26.x.
2. `docker buildx bake --print`: must exit 0.
3. Build: `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
4. Run with an empty `/config`:
   ```sh
   docker volume rm rsshub-probe-config 2>/dev/null || true
   docker run --rm -d --name rsshub-probe --read-only --tmpfs /tmp \
     -v rsshub-probe-config:/config rsshub:v2026.11.25-8755.g8927949
   docker logs -f rsshub-probe   # until idle or a readiness line
   ```
   Expected readiness signal: a line that names the listening port 1200 (exact text UNVERIFIED until the first run).
5. Test: `forgetool containers test --image rsshub:v2026.11.25-8755.g8927949 --config ./apps/rsshub/container-test.yaml`.
6. Cleanup: `docker rm -f rsshub-probe; docker volume rm rsshub-probe-config`.
7. arm64: only after amd64 is green; the Chromium path is the first thing to test.

## 12. PR checklist

- Branch: `feat/add-rsshub`.
- Commit: `feat(rsshub): add new container`.
- PR title: `feat(rsshub): add new container`.
- PR description: `.github/PULL_REQUEST_TEMPLATE.md` sections and checkboxes; only check the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows status). Only the user can sign it.
- Say what was not tested: arm64 build and Chromium on arm64, full Chromium feed, valkey integration (if not run), any UNVERIFIED item above.
- Downstream: none (not a `FROM` base), so no `DOWNSTREAM_CHANGES.md`.
