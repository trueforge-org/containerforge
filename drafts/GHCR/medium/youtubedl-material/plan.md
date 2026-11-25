# youtubedl-material — implementation plan
> Source: ./draft.md · Target: apps/youtubedl-material/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v4.3.2` (latest release tag). Source: https://github.com/Tzahi12345/YoutubeDL-Material/releases/tag/v4.3.2 (reached via `/releases/latest` redirect). Draft tag `nightly-2024-10-01` is stale and is not used. |
| Release date | UNVERIFIED: release page showed two timestamps; neither confirmed as the v4.3.2 date. |
| Renovate | `datasource=github-releases depName=Tzahi12345/YoutubeDL-Material versioning=semver` (proposed; follows `apps/adguardhome-sync` pattern). |
| License | MIT. Source: `backend/package.json` at v4.3.2 (`"license": "MIT"`), https://raw.githubusercontent.com/Tzahi12345/YoutubeDL-Material/v4.3.2/backend/package.json |
| Source URL | https://github.com/Tzahi12345/YoutubeDL-Material |
| Per-arch download | Arch-neutral app bundle: https://github.com/Tzahi12345/YoutubeDL-Material/releases/download/v4.3.2/youtubedl-material-v4.3.2.zip (asset confirmed on the release page). Same for amd64 and arm64. |
| Checksum source | UNVERIFIED: no checksum file found on the release page. Pin by version and record the zip's sha256 in the Dockerfile as a verification step (computed by us). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/Tzahi12345/YoutubeDL-Material/58f4313e500cfcb17aa801934163f474e7be6172/Dockerfile: multi-stage; `utils` (ubuntu:22.04, ffmpeg + TwitchDownloaderCLI), `base` (ubuntu:22.04, nvm, Node 16.14.2), `frontend` (node:16, Angular build), `backend` (`npm install --prod`), final stage adds pm2, gosu, python3, pip, atomicparsley, `pip install pycryptodomex`. `EXPOSE 17442`, `ENTRYPOINT /app/entrypoint.sh`, `CMD npm start`. `VOLUME` is commented out. |
| Node engine | `backend/package.json` `"node": "^16"` (v4.3.2). Node 16 is EOL, so the port must use the node version the base image provides, and the app must be run against it (UNVERIFIED that the app runs on newer Node; test it). |
| Upstream entrypoint | UNVERIFIED: `entrypoint.sh` raw URL returned 404 at the pinned commit, so its behaviour is not confirmed. Do not port it blindly. |
| Ports | `17442/tcp` (web UI). Source: upstream `EXPOSE 17442`, `backend/appdata/default.json` `Host.port` = `17442`. |
| Data write paths | `/app/appdata`, `/app/audio`, `/app/video`, `/app/subscriptions`, `/app/users`. Source: https://raw.githubusercontent.com/Tzahi12345/YoutubeDL-Material/v4.3.2/docker-compose.yml. Default output dirs `audio/` and `video/` (from `default.json`). |
| Env vars (real, from chart) | `ytdl_port`, `ytdl_mongodb_connection_string`, `ytdl_use_local_db`, `write_ytdl_config`, `ALLOW_CONFIG_MUTATIONS`, `ytdl_multi_user_mode`, `ytdl_default_downloader` (`yt-dlp`), `ytdl_max_concurrent_downloads` (`5`), `ytdl_include_thumbnail`, `ytdl_include_metadata`, `ytdl_allow_subscriptions`, `ytdl_subscriptions_check_interval` (`86400`), `ytdl_title_top`, `ytdl_default_theme`. Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/youtubedl-material/values.yaml. Only a subset is listed in `settings.yaml`; add more only after checking the app reads them. |
| Dependencies | MongoDB optional. Upstream compose uses `mongo:4`. `apps/mongodb` exists (✅). Without it, `ytdl_use_local_db=true` is the fallback (UNVERIFIED against the app's code). |
| Chart security | `runAsUser 0`, `runAsGroup 0`, `runAsNonRoot false`, `readOnlyRootFilesystem false`, `fsGroup 1000`, PUID `1000` under an unrecognised top-level key. Source: chart values.yaml above. |
| arm64 | UNVERIFIED for the runtime: the app bundle is arch-neutral, but the ffmpeg and yt-dlp packages on arm64 were not checked. |

## 2. Target layout

- `apps/youtubedl-material/Dockerfile`
- `apps/youtubedl-material/docker-bake.hcl`
- `apps/youtubedl-material/settings.yaml`
- `apps/youtubedl-material/container-test.yaml`
- `apps/youtubedl-material/start.sh`
- `apps/youtubedl-material/defaults/` only if a default config file is needed. Reason: the app writes `default.json` on first run, but it must be checked (UNVERIFIED). Include it only after confirming.

No `root/` (never used). No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Reason: the app needs Node for the backend and Python for yt-dlp, and the draft asks for `python-node`. Closest sibling: `apps/budge` (Node backend on python-node, `/config` writes, `start.sh` launches node).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Download the release zip with the verified checksum:
   ```dockerfile
   RUN curl -fL -o /tmp/ytdl.zip \
     "https://github.com/Tzahi12345/YoutubeDL-Material/releases/download/v${VERSION}/youtubedl-material-v${VERSION}.zip" && \
     echo "<sha256>  /tmp/ytdl.zip" | sha256sum -c -
   ```
   `<sha256>` is computed by us from the downloaded zip and must be checked into the Dockerfile. `VERSION` is `4.3.2`. The URL has a `v` prefix, so pass `VERSION` without the `v` and add it in the URL, or pass `v4.3.2` in `docker-bake.hcl` and strip it in the URL (pick one, and keep it the same in both files).
3. apt, pinned or checked against the base: `ffmpeg`, `atomicparsley`, `unzip` (only if not in base; check first). Do not install packages already in `python-node`.
4. Python: install `yt-dlp` and `pycryptodomex` into the base's venv. Check the base for `/app/venv` (UNVERIFIED in the base Dockerfile). If there is no venv, install with `pip install --no-cache-dir --break-system-packages` only if the base needs it, and record the choice. Use `PIP_CACHE_DIR=/tmp/pip`.
5. Extract to `/app`: `unzip -q /tmp/ytdl.zip -d /tmp/ytdl && cp -a /tmp/ytdl/. /app/` (or the zip's own layout; check the zip contents first — UNVERIFIED).
6. Install backend deps and build the frontend only if the zip does not already contain them (UNVERIFIED: whether the release zip ships `backend/public` and `node_modules`). If not, use `npm ci --omit=dev` with `npm_config_cache=/tmp/npm` (node version from base).
7. License: `COPY` or `install -D` the MIT license to `/usr/share/licenses/youtubedl-material/LICENSE` (from the zip or repo; UNVERIFIED path in zip).
8. Do not install `pm2` (upstream used it for process management; `exec` in `start.sh` replaces it). Keep `PM2_HOME` unset.
9. `ENV HOME=/config` and redirect caches: `npm_config_cache=/tmp/npm`, `PIP_CACHE_DIR=/tmp/pip`, and `XDG_CACHE_HOME=/tmp`.
10. `chown -R apps:apps /app && chmod -R 755 /app`, then `USER apps`.
11. Tail, as in `apps/budge`:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /
   EXPOSE 17442
   VOLUME /config
   WORKDIR /config
   ```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "youtubedl-material"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Tzahi12345/YoutubeDL-Material versioning=semver
  default = "4.3.2"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/Tzahi12345/YoutubeDL-Material"
}
```

Then the default group and the four standard targets, copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print` from `apps/youtubedl-material`. `VERSION` must equal the Dockerfile `ARG VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Tzahi12345/YoutubeDL-Material"
ports:
  - port: 17442
    protocol: tcp
    required: false
env:
  - name: ytdl_port
    default: "17442"
    required: false
  - name: ytdl_use_local_db
    default: "true"
    required: false
  - name: ytdl_mongodb_connection_string
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
opt_dependencies:
  - mongodb
```

Notes: `ytdl_use_local_db` default and the data redirect must be confirmed against the app before the defaults are final (UNVERIFIED). `dependencies` is empty because MongoDB is optional. Check the schema for the key name `opt_dependencies` against a sibling app that uses it (UNVERIFIED for this repo's schema). Do not list env vars the app does not read.

## 7. start.sh

- `set -eu`; `mkdir -p /config/appdata /config/users /config/subscriptions /config/audio /config/video`.
- Seed nothing unless the app needs a config file in `/config` and it is missing (UNVERIFIED; the app creates `default.json` itself with `write_ytdl_config`).
- Symlink the upstream data paths into `/config` (these are the only write paths): `/app/appdata -> /config/appdata`, `/app/users -> /config/users`, `/app/subscriptions -> /config/subscriptions`, `/app/audio -> /config/audio`, `/app/video -> /config/video`. Create the symlinks in `start.sh` (or in the Dockerfile as dangling links), only if they do not already exist, so nothing is written under `/app`.
- Export `PATH` with the python venv first if used.
- `exec` the node process, replacing `pm2`: `cd /app && exec node app.js` (entry file UNVERIFIED; check `backend/package.json` `main` or `npm start` script at v4.3.2 and use the same command).
- Bind `0.0.0.0` (the app uses `ytdl_port` on all interfaces by default; confirm in code).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '17442'
http:
- port: '17442'
  path: /
filePaths:
- /app/backend
- /usr/bin/ffmpeg
```

Notes: the timeout is taken from the Node-based siblings (`apps/budge` uses the default; confirm the family value before merging). `filePaths` must include any path that only runs with env vars (none known). The http probe path must return 200 on a fresh `/config` (UNVERIFIED; the app may redirect to a setup page).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/appdata`, `/app/users`, `/app/subscriptions`, `/app/audio`, `/app/video` | symlinks into `/config/*` (created in `start.sh`) |
| `PM2_HOME=/app/pm2` | removed; pm2 not used |
| `npm_config_cache=/app/.npm` | `/tmp/npm` |
| Chart `runAsUser 0` / `readOnlyRootFilesystem false` | this image runs as `apps` and passes `--read-only --tmpfs /tmp` (per protocol) |
| Chart PUID 1000 (under an unrecognised key) | `apps` user is the runtime UID; no PUID handling needed in the image (UNVERIFIED that `apps` maps to 1000) |

## 10. Risks, caveats and open questions

- Upstream is pinned to Node 16 (EOL) and a 2024 nightly in the chart. The release v4.3.2 still declares `^16`; running on the base's newer Node is UNVERIFIED and must be tested.
- `yt-dlp` and `ffmpeg` break often as YouTube changes. Keep `yt-dlp` pinned to a version in the Dockerfile (renovate annotation via PyPI, UNVERIFIED datasource) and check for a fresh one.
- The chart's MongoDB subchart is enabled by default. The image must work with `ytdl_use_local_db=true`, which is the no-DB path (UNVERIFIED for v4.3.2).
- The entrypoint script (`entrypoint.sh`) is not confirmed (raw 404 at the pinned commit). Its PUID/PGID behaviour is replaced by the `apps` user.
- Release zip contents are not confirmed (whether `public/` and `node_modules/` are included).
- Blockers: none known. No GPU, no privileged need, arm64 likely (UNVERIFIED).

## 11. Build and test steps

```sh
cd apps/youtubedl-material
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name youtubedl-material-probe --read-only --tmpfs /tmp \
  -v youtubedl-material-probe-config:/config youtubedl-material:4.3.2
docker logs -f youtubedl-material-probe
forgetool containers test --image youtubedl-material:4.3.2 --config ./apps/youtubedl-material/container-test.yaml
docker rm -f youtubedl-material-probe
docker volume rm youtubedl-material-probe-config
```

Expected readiness signal: the app logs its listen line on port 17442 (exact text UNVERIFIED), and the container keeps running. Empty `/config` must start with no errors.

## 12. PR checklist

- Branch `feat/add-youtubedl-material`, commit `feat(youtubedl-material): add new container`, PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows status.
- Say what is untested: local build and run were not done unless they were; arm64; the Node 16 vs base Node runtime; the MongoDB path.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened.
