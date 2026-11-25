# flowise — implementation plan
> Source: ./draft.md · Target: apps/flowise/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `3.1.4` (latest stable GitHub release, published 2026-07-29T15:51:25Z, https://api.github.com/repos/FlowiseAI/Flowise/releases/latest). npm publish date for `flowise@3.1.4`: UNVERIFIED (npm registry unreachable). Draft chart tag `docker.io/flowiseai/flowise:3.1.4` matches. |
| Docker Hub | Tags `3.1.4` and `latest` (2026-07-29) are linux/amd64 and linux/arm64. |
| Renovate | `datasource=npm depName=flowise versioning=npm` (the plan installs from npm, so the chart image datasource is not used). |
| License | Apache-2.0 with exceptions. The `enterprise/` directory and files with their own copyright notice fall under a separate Commercial License. Third-party parts keep their own licenses (https://raw.githubusercontent.com/FlowiseAI/Flowise/main/LICENSE.md). Not a single SPDX id. The bake `LICENSE` must be decided (section 10). |
| Source URL | https://github.com/FlowiseAI/Flowise |
| Download | npm package `flowise@3.1.4`, `bin: {"flowise": "./bin/run"}`, license field "SEE LICENSE IN LICENSE.md". The bin and license values come from the server `package.json` at the pinned commit `a65f81bb43ef66d3ce734bf0dff4223ae8041c95`. The npm tarball itself is UNVERIFIED (registry unreachable). No GitHub release assets. Arch-independent npm install. |
| Checksum source | npm `integrity` field: UNVERIFIED (registry unreachable). Docker images: none confirmed. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/FlowiseAI/Flowise/a65f81bb43ef66d3ce734bf0dff4223ae8041c95/docker/Dockerfile. `ARG NODE_VERSION=24`. Build stage `node:24-alpine`: `apk add git python3 py3-pip make g++ build-base cairo-dev pango-dev`, `ENV PUPPETEER_SKIP_DOWNLOAD=true`, `RUN npm install -g flowise`. Final stage: `apk add chromium ...`, `ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser`, copies `/usr/local/lib/node_modules` and `/usr/local/bin`, `USER node`, `ENTRYPOINT ["flowise","start"]`. No `EXPOSE`, `VOLUME`, `WORKDIR` or `CMD`. |
| Port | 3000 (`PORT=3000` in `packages/server/.env.example` at the pinned commit; matches the draft; the upstream Dockerfile has no `EXPOSE`). |
| Env vars | From `packages/server/.env.example` at the pinned commit: `PORT`, `DATABASE_PATH`, `DATABASE_TYPE` (`postgres`), `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_NAME`, `DATABASE_USER`, `DATABASE_PASSWORD`, `SECRETKEY_PATH`, `FLOWISE_SECRETKEY_OVERWRITE`, `LOG_PATH`, `LOG_LEVEL`, `BLOB_STORAGE_PATH`, `STORAGE_TYPE`. Dockerfile: `PUPPETEER_SKIP_DOWNLOAD`, `PUPPETEER_EXECUTABLE_PATH`. |
| Data path | `DATABASE_PATH`, `SECRETKEY_PATH`, `LOG_PATH`, `BLOB_STORAGE_PATH` are configurable (the example shows `.../.flowise` style paths). The SQLite default location when `DATABASE_TYPE` is unset is UNVERIFIED. |
| Dependencies | PostgreSQL is optional (draft; UNVERIFIED from fetched pages). Chromium is needed by Puppeteer at runtime in the upstream image. |
| Copy-from | No. Upstream runtime is `node:24-alpine` (musl) with chromium, not usable on glibc Ubuntu. |

## 2. Target layout

- `apps/flowise/Dockerfile`
- `apps/flowise/docker-bake.hcl`
- `apps/flowise/settings.yaml`
- `apps/flowise/container-test.yaml`
- `apps/flowise/start.sh`

No `defaults/`, `etc/` or `health/` until the data path and env vars are verified. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why this and not `python-node` (the draft's choice): the copilot porter table maps Node to `ghcr.io/trueforge-org/ubuntu`. The base already ships Node 26.13.1 (`NODE_VERSION` in `apps/ubuntu/docker-bake.hcl`). Upstream uses Node 24, so run against the base Node and check compatibility (UNVERIFIED).

Closest siblings: `apps/adguardhome-sync` for layout, `apps/budge` for a Node install inside the image (`npm install` in the build step, `npm cache clean`, `VOLUME /config`), `apps/postgresql` for the optional dependency.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`. Keep the base digest.
2. Chromium: Puppeteer needs a browser at runtime. Upstream installs `chromium` from apk. On Ubuntu this is a separate step. Check whether an apt `chromium` package works in the container on 26.04 (UNVERIFIED; the Ubuntu package may be a snap wrapper, which does not run in a container). This is the main blocker (section 10).
3. Install build tools only if a native module needs them (UNVERIFIED). The upstream build packages are Alpine names (`build-base`, `cairo-dev`, `pango-dev`). Use the Ubuntu names only if the install fails, and remove them in the same `RUN`.
4. Install flowise into `/app/flowise` so `/app` holds the app and nothing is written at runtime:

```dockerfile
ENV NPM_CONFIG_CACHE=/tmp/npm-cache \
    PUPPETEER_SKIP_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

RUN echo "**** install flowise ****" && \
  mkdir -p /app/flowise && \
  npm install --prefix /app/flowise flowise@${VERSION} && \
  echo "**** cleanup ****" && \
  npm cache clean --force && \
  rm -rf /tmp/* $HOME/.cache /var/lib/apt/lists/*
```

   - `ARG VERSION` maps to `flowise@${VERSION}` (the same value as the bake).
   - The `flowise` bin is at `/app/flowise/node_modules/.bin/flowise`.
5. License: copy the packaged `LICENSE.md` to `/usr/share/licenses/flowise/` if present in the npm tarball (UNVERIFIED that it is there; otherwise fetch it from the pinned commit).
6. Final lines:

```dockerfile
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 3000
VOLUME /config
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "flowise"
}

variable "VERSION" {
  // renovate: datasource=npm depName=flowise versioning=npm
  default = "3.1.4"
}

variable "LICENSE" {
  default = "Apache-2.0"   // NEEDS HUMAN DECISION: Apache-2.0 with a Commercial License for enterprise/ (GitHub SPDX is NOASSERTION), see section 10
}

variable "SOURCE" {
  default = "https://github.com/FlowiseAI/Flowise"
}
```

Then the four standard targets and the default group, copied from `apps/budge/docker-bake.hcl`. Note the chart image renovate line (`datasource=docker depName=docker.io/flowiseai/flowise`) is for the upstream image, not used here: pick one datasource and keep it consistent. Validate with `docker buildx bake --print` from `apps/flowise/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/FlowiseAI/Flowise"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "3000"
    required: false
  - name: DATABASE_PATH
    default: "/config"
    required: false
  - name: SECRETKEY_PATH
    default: "/config/secrets"
    required: false
  - name: LOG_PATH
    default: "/config/logs"
    required: false
  - name: BLOB_STORAGE_PATH
    default: "/config/storage"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
  # DATABASE_TYPE/DATABASE_HOST/DATABASE_PORT/DATABASE_NAME/DATABASE_USER/DATABASE_PASSWORD (postgres) are real
  # upstream variables left out of the defaults; add them with empty defaults when the Postgres path is tested.
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: postgresql
```

- `opt_dependencies: [postgresql]`: PostgreSQL is optional, and `apps/postgresql` exists (✅ in the draft). Same `opt_dependencies` list form as `apps/babybuddy/settings.yaml`.
- No `dependencies` entry: flowise must start without PostgreSQL (SQLite default, UNVERIFIED).

## 7. start.sh

```bash
#!/usr/bin/env bash

export PORT="${PORT:-3000}"
export DATABASE_PATH="${DATABASE_PATH:-/config}"
export SECRETKEY_PATH="${SECRETKEY_PATH:-/config/secrets}"
export LOG_PATH="${LOG_PATH:-/config/logs}"
export BLOB_STORAGE_PATH="${BLOB_STORAGE_PATH:-/config/storage}"

mkdir -p "$DATABASE_PATH" "$SECRETKEY_PATH" "$LOG_PATH" "$BLOB_STORAGE_PATH"

cd /config
exec /app/flowise/node_modules/.bin/flowise start
```

- The four path variables are real upstream variables (see section 1) and match the chart's `/config/secrets`, `/config/logs`, `/config/storage` layout; their defaults here equal the `settings.yaml` defaults. Upstream sets no `WORKDIR` and uses `flowise start`.
- Idempotent: create only missing directories. Nothing is seeded into `/config`.
- Never writes to `/app`. Caches go to `/tmp` (`NPM_CONFIG_CACHE` is build-time only; set `HOME` or the Flowise data env var to `/config` only after confirmation).
- `exec` so the process gets signals.
- Listening address: check that Flowise binds `0.0.0.0` (UNVERIFIED). Confirm from outside the container.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /app/flowise/node_modules/.bin/flowise
- /usr/share/licenses/flowise
```

- Flowise is a large Node app: start-up time is longer than for flame. `timeoutSeconds: 300` is a guess until a sibling of the same size is checked; verify on the first run.
- The `filePaths` license entry is only valid once section 4 step 5 is confirmed.
- No env vars are set in the test. Any password or database code path is not tested. The build protocol's DB narrowing does not apply: postgresql is optional, not a hard dependency, so the full test must pass with SQLite.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Default SQLite store and app data (draft: under `/config`; UNVERIFIED) | Point the Flowise data variable at `/config` once the env name is confirmed. |
| `HOME` (Flowise and npm may write to `~`) | Set `HOME=/config` only if confirmed to be safe. Otherwise set the specific variables. Never `/app`. |
| Logs (`/config/logs` in the chart, draft) | Use the app's log directory variable when confirmed (UNVERIFIED). |
| Puppeteer cache | `PUPPETEER_SKIP_DOWNLOAD=true`, and the browser is the system chromium at a `/usr` path. No write. |
| Chart's `/config/api`, `/config/logs`, `/config/secrets`, `/config/storage` (draft) | Recreate the same layout in `start.sh` only if the app needs it. UNVERIFIED. |

Reconciling the draft's security expectations: the chart runs as UID 0, `readOnlyRootFilesystem: false`, and is not privileged. This image runs as `apps`, with `--read-only --tmpfs /tmp`, not privileged. The chart's data under `/config` already matches this app's persistence model.

## 10. Risks, caveats and open questions

- Chromium: upstream installs it with apk (Alpine). On Ubuntu 26.04 the package may be a snap wrapper that does not run in a container (UNVERIFIED). If there is no working chromium, decide between (a) installing a pinned browser, or (b) shipping without Puppeteer features and documenting it. Do not guess.
- Port and path variables are confirmed from `.env.example`; login variables and the SQLite default location are not listed in `settings.yaml` (UNVERIFIED).
- Data path: UNVERIFIED (draft says SQLite under `/config`).
- License: Apache-2.0 with exceptions and a Commercial License for `enterprise/`. The bake `LICENSE` value and the license file to ship must be decided, and the `enterprise/` directory must not be presented as Apache-2.0. Check the packaged `LICENSE.md`.
- npm integrity: UNVERIFIED (registry unreachable). Pin `flowise@3.1.4` exactly, and check the tarball hash on first install.
- Size and build time: a large npm dependency tree (inferred). Expect a long build and a big image.
- Node version: upstream uses Node 24, the base ships 26.13.1. Compatibility UNVERIFIED for the native modules.
- arm64: available on Docker Hub. Native npm modules may need build tools on arm64 (UNVERIFIED).
- Blockers: chromium on Ubuntu (above) and the unverified env/port/data path. No GPU or privileged need is known.

## 11. Build and test steps

```sh
cd apps/flowise
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name flowise-probe --read-only --tmpfs /tmp \
  -v flowise-probe-config:/config flowise:3.1.4
docker logs -f flowise-probe

forgetool containers test --image flowise:3.1.4 --config ./apps/flowise/container-test.yaml
docker rm -f flowise-probe; docker volume rm flowise-probe-config
```

- Readiness signal: the Flowise start-up line (UNVERIFIED wording; check the first run's logs) and the port open. The container must stay running.
- Run twice with the same `/config` volume to confirm the second start is clean.
- Test the optional PostgreSQL path separately, by hand, with `apps/postgresql` running on the same network (not in the test suite).

## 12. PR checklist

- Branch `feat/add-flowise`, commit and PR title `feat(flowise): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Untested, to state honestly in the PR: the port and env vars (not confirmed from docs), the data path, the chromium setup, the PostgreSQL option, arm64, and the license value.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
