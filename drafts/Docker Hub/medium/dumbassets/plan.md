# dumbassets — implementation plan
> Source: ./draft.md · Target: apps/dumbassets/ · Difficulty: medium · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

The plan targets the same version as the draft (`1.0.11`). The draft's concern about a low-confidence tag trace is resolved: tag `v1.0.11` exists in `DumbWareio/DumbAssets`, and its `package.json` says `"version": "1.0.11"`.

| Item | Value |
| --- | --- |
| Version | `1.0.11` (git tags `v1.0.0` and `v1.0.11`; GitHub release `v1.0.11` exists, published 2025-06-12, with no assets) |
| Renovate | `datasource=github-tags depName=DumbWareio/DumbAssets versioning=semver` (tags have a `v` prefix; semver handles it) |
| License | GPL-3.0 (`LICENSE` is GNU GPL v3; README states GPL-3.0). SPDX: `GPL-3.0-only`. UNVERIFIED whether the upstream means "or later"; only the v3 text was checked. |
| Source | https://github.com/DumbWareio/DumbAssets |
| Download (both arches) | https://github.com/DumbWareio/DumbAssets/archive/refs/tags/v1.0.11.tar.gz (source tarball, arch independent; dependencies come from npm) |
| Checksum | None published by upstream for the tag archive. UNVERIFIED by design; integrity comes from the tag name plus `npm ci` against the committed `package-lock.json`. |
| Upstream Dockerfile reviewed | https://github.com/DumbWareio/DumbAssets/blob/2bacca1e2c4ff8e60d562c8dc300a8dbe91083c3/Dockerfile (`node:20-alpine`, `npm ci`, python3 + venv at `/opt/venv` with `pip install apprise`, `mkdir data`, `EXPOSE 3000`, `CMD npm start`) |

Facts read from `server.js` at tag v1.0.11:

- Port: `process.env.PORT || 3000`. `app.listen(PORT, ...)` has no host argument, so it binds all interfaces.
- Data directory is hard-coded: `DATA_DIR = path.join(__dirname, 'data')`. It holds `Assets.json`, `SubAssets.json`, `config.json`, and `Images/`, `Receipts/`, `Manuals/` (created at start via `ensureDirectoryExists`). Uploads are written there by multer. The upstream README's `/data/...` paths are wrong; the Docker example mounts `/app/data`.
- Env vars read by the code: `PORT`, `DEBUG` (must equal `TRUE`), `NODE_ENV`, `BASE_URL`, `DEMO_MODE` (must equal `true`), `SITE_TITLE`, `CURRENCY_CODE`, `CURRENCY_LOCALE`, `TZ` (defaults to `America/Chicago` inside the app), `DUMBASSETS_PIN`, `SESSION_SECRET` (defaults to the insecure literal `your-secret-key`), `APPRISE_URL`. `ALLOWED_ORIGINS` is listed in the upstream `.env.example` and README (UNVERIFIED that the code reads it; it was not found in the grepped lines of `server.js`).
- Notifications spawn the `apprise` binary from `PATH` (`src/services/notifications/appriseNotifier.js`).
- `package.json` has no `engines`. Upstream image uses Node 20; the ContainerForge python-node base ships a newer Node (UNVERIFIED which; confirm with `node --version` in the build).

## 2. Target layout

```
apps/dumbassets/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/` (the app seeds its own JSON files). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Node app plus a Python tool (Apprise), and python-node supplies both runtimes, as the draft says. Closest siblings: `apps/budge` (python-node, npm build into `/app`) and `apps/apprise-api` (Apprise in `/app/venv`). Follow `python-runtime.instructions.md`: Apprise goes into the bundled `/app/venv`, which is read-only at runtime.

## 4. Dockerfile

1. `FROM` from section 3, `ARG VERSION`, `ARG TARGETARCH` (not needed for the tarball, omit it if unused).
2. `USER root`.
3. `ENV HOME=/tmp NPM_CONFIG_CACHE=/tmp/.npm NODE_ENV=production PATH="/app/venv/bin:${PATH}"`.
4. One `RUN` layer:
   - `mkdir -p /app/dumbassets /usr/share/licenses/dumbassets`
   - `curl -fsSL -o /tmp/dumbassets.tar.gz "https://github.com/DumbWareio/DumbAssets/archive/refs/tags/v${VERSION}.tar.gz"`
   - `tar xzf /tmp/dumbassets.tar.gz -C /app/dumbassets --strip-components=1`
   - `cd /app/dumbassets && npm ci --omit=dev` (add `build-essential` and `python3-dev` only if a native module fails; nothing in the dependency list looks native, UNVERIFIED)
   - `/app/venv/bin/pip install --no-cache-dir apprise` (pin the Apprise version in a bake variable if the maintainers want reproducibility; Apprise is not named in this repo's renovate setup, so add `// renovate: datasource=pypi depName=apprise` next to an `APPRISE_VERSION` variable if pinned)
   - `cp LICENSE /usr/share/licenses/dumbassets/LICENSE`
   - `rm -rf /app/dumbassets/data && ln -s /config /app/dumbassets/data` (the data dir is hard-coded to `<app>/data`, so a symlink to `/config` is the least invasive redirect; `/app` is read-only at runtime but a symlink needs no write)
   - `chown -R apps:apps /app && chmod -R 755 /app`, `npm cache clean --force`, `rm -rf /tmp/*`
5. `USER apps`
6. `COPY --chmod=0755 . /`
7. `WORKDIR /app/dumbassets`, `EXPOSE 3000`, `VOLUME /config`.

Packages not to add: node, python, curl and tar are in the base. Verify `node --version` is at least 20 during the build; Apprise on Python 3.15 may need wheels (UNVERIFIED, see section 10).

## 5. docker-bake.hcl

```hcl
variable "APP" {
  default = "dumbassets"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=DumbWareio/DumbAssets versioning=semver
  default = "1.0.11"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/DumbWareio/DumbAssets"
}
```

Plus `docker-metadata-action`, `image` (args `VERSION`, labels source and licenses), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`) and `group "default" { targets = ["image-local"] }`, copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/DumbWareio/DumbAssets"
ports:
  - port: 3000
    protocol: tcp
    required: true
env:
  - name: PORT
    default: "3000"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: SITE_TITLE
    default: "DumbAssets"
    required: false
  - name: BASE_URL
    default: ""
    required: false
  - name: DUMBASSETS_PIN
    default: ""
    required: false
  - name: SESSION_SECRET
    default: ""
    required: false
  - name: APPRISE_URL
    default: ""
    required: false
  - name: CURRENCY_CODE
    default: "USD"
    required: false
  - name: CURRENCY_LOCALE
    default: "en-US"
    required: false
  - name: DEMO_MODE
    default: "false"
    required: false
volumes:
  - path: /config
    required: true
```

`SESSION_SECRET` has an empty default because `start.sh` generates and persists one (see section 7). `ALLOWED_ORIGINS` and `DEBUG` are left out because their effect in v1.0.11 was not confirmed (see section 1); add them only after reading the code. Dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export PORT="${PORT:-3000}"
export TZ="${TZ:-Etc/UTC}"

mkdir -p /config/Images /config/Receipts /config/Manuals

# Session secret: persist a random one so sessions survive restarts and the insecure default is never used.
if [ -z "${SESSION_SECRET:-}" ]; then
  if [ ! -s /config/.session_secret ]; then
    umask 077
    head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n' > /config/.session_secret
  fi
  SESSION_SECRET="$(cat /config/.session_secret)"
  export SESSION_SECRET
fi

cd /app/dumbassets
exec node server.js
```

- Idempotent: the secret and directories are only created when missing. Existing data is never overwritten.
- `Assets.json` and friends are created by the app on first write.
- The `/app/dumbassets/data` symlink points to `/config`, so nothing is written under `/app`.
- Caches and `HOME` are in `/tmp` (Dockerfile `ENV`).
- Binds all interfaces (the app calls `listen(PORT)`).
- The final process is `exec node server.js`. The PIN comes from the environment and is never written to a file by the script.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '3000'
  path: /

filePaths:
- /app/dumbassets/server.js
- /app/venv/bin/apprise
- /usr/share/licenses/dumbassets/LICENSE
```

- The `http` probe covers port 3000. With no PIN set the root page should answer 200. If the app redirects to a login page when `DUMBASSETS_PIN` is set, the test (which sets no env vars) is not affected. UNVERIFIED: the exact status of `/` without a PIN; if it is a redirect, add `statusCode` or use `/login`.
- No `timeoutSeconds` needed beyond the sibling default; a Node app with no build step starts quickly. Use 60 if the first run is slow.
- No DB dependency, so no narrowing.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `<app>/data` (JSON files, Images, Receipts, Manuals, config.json) | Symlink `/app/dumbassets/data` to `/config`, created at build time. All persistent state lives in `/config`. |
| `/app/public/assets` (emptyDir in the TrueCharts chart) | Nothing in v1.0.11 writes to `public/`. Uploads go to the data dir. Not remapped, to be re-checked in the run test. |
| npm cache | `/tmp/.npm` (`NPM_CONFIG_CACHE`). |
| Python bytecode and caches for Apprise | `/app/venv` is read-only; `PYTHONDONTWRITEBYTECODE` is already set by the python base. |
| Session secret (upstream default `your-secret-key`) | Generated into `/config/.session_secret` when missing. |

Draft expectations reconciled: the chart runs as UID 568 with a read-only rootfs and persists `/app/data`. Here the user is `apps` and persistence is `/config` (the data-dir symlink stands in for `/app/data`). Existing TrueCharts data mounted at `/app/data` will need to be mounted at `/config` instead (note in the PR).

## 10. Risks, caveats and open questions

- The data directory is hard-coded relative to the code, so the symlink is the only no-patch option. If `fs.mkdirSync` or multer refuse to follow the symlink at runtime, patch `DATA_DIR` with a `sed` at build time (UNVERIFIED, test with an upload).
- Apprise on Python 3.15 may lack prebuilt wheels for its dependencies (for example `cryptography`, `PyYAML`). The build may need the compiler packages used in `apps/apprise-api/Dockerfile` (`build-essential`, `cargo`, `libffi-dev`, `libssl-dev`), purged afterwards.
- No upstream checksum for the tag archive.
- License: only the GPL v3 text was verified; whether "or later" applies was not.
- `ALLOWED_ORIGINS` and `DEBUG`: not confirmed as read by the code.
- The draft's concern that `/app/public/assets` needs persistent storage does not apply to 1.0.11 on the evidence read here.
- Upstream tags only (no Releases page): renovate `github-tags` will propose new tags, including any prerelease-looking ones; review each bump.
- No blocker: arm64 and amd64 both work in principle (pure JS plus Python packages).

## 11. Build and test steps

```sh
cd apps/dumbassets
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name dumbassets-probe --read-only --tmpfs /tmp \
  -v dumbassets-probe-config:/config dumbassets:1.0.11
docker logs -f dumbassets-probe

# from the repo root
forgetool containers test \
  --image dumbassets:1.0.11 \
  --config ./apps/dumbassets/container-test.yaml

docker rm -f dumbassets-probe; docker volume rm dumbassets-probe-config
```

Readiness signal: the Node server logs a "Server running" / listening message for port 3000 (exact wording UNVERIFIED), the container stays up, and `curl -s -o /dev/null -w '%{http_code}' http://localhost:3000/` returns 200. Also add an asset with an image upload and a restart to prove `/config` persistence, and check that `docker exec dumbassets-probe apprise --version` works.

## 12. PR checklist

- Branch `feat/add-dumbassets`, commit and PR title `feat(dumbassets): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and check only what applies.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows the status.
- Mention the data path change (`/app/data` to `/config`) in the PR.
- Pre-completion: bake `--print` exits 0, Dockerfile and bake `VERSION` aligned, final `USER apps`, `COPY --chmod=0755 . /` present, empty-`/config` start works on `--read-only`.
- Untested until run: the build on both arches, Apprise install on Python 3.15, upload persistence through the symlink, the `/` status code, and the forgetool run. Say so in the PR and leave "Built container locally" unchecked if not done.
