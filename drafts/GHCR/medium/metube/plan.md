# metube — implementation plan
> Source: ./draft.md · Target: apps/metube/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `2026.11.24` (latest stable, published 2026-11-24, not prerelease). Draft says `2026.11.14` for the image; that is stale. TrueCharts already pins `ghcr.io/alexta69/metube:2026.11.24@sha256:c423654da5b9d29b02a8092713607b906d63d17fd7e0a2f52228218a0d3e2a7b`. Source: https://api.github.com/repos/alexta69/metube/releases/latest |
| Renovate | `datasource=github-releases depName=alexta69/metube versioning=loose` (tags are `YYYY.MM.DD`, no `v` prefix) |
| License | AGPL-3.0 (SPDX, GitHub API `license.spdx_id`) |
| Source URL | https://github.com/alexta69/metube |
| Binary | None published. Release assets are absent; the app is Python plus a Node-built UI, so it must be built from source. https://github.com/alexta69/metube/releases/tag/2026.11.24 |
| Source archive | Tag archive `https://github.com/alexta69/metube/archive/refs/tags/${VERSION}.tar.gz` (standard GitHub pattern; not fetched in this run, UNVERIFIED that the tree layout is `app/`, `ui/`, `pyproject.toml`, `uv.lock` at the root) |
| Checksum source | None published upstream for the tag archive. Pin by tag and record the archive sha256 in the Dockerfile (ARG) after the first download. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/alexta69/metube/master/Dockerfile (node:22-alpine builder pinned by digest; `python:3.14-slim` runtime; `uv sync --frozen --no-dev`; ffmpeg from BtbN static build; bgutil-pot from GitHub; `ENTRYPOINT ["/usr/bin/tini", "-g", "--", "./docker-entrypoint.sh"]`) |
| Upstream entrypoint reviewed | https://raw.githubusercontent.com/alexta69/metube/master/docker-entrypoint.sh (root path: chown to PUID:PGID, `gosu` to drop; non-root path: runs `python3 app/main.py` directly; starts `bgutil-pot server` with log in /tmp) |
| Python requirement | `requires-python = ">=3.13"` (https://raw.githubusercontent.com/alexta69/metube/master/pyproject.toml). Upstream runtime is 3.14; ContainerForge base is 3.15.2, which satisfies it. |
| Python deps | aiohttp, python-socketio<6, `yt-dlp[default,curl-cffi,deno]`, watchfiles |
| ffmpeg | NOT from apt upstream. Static BtbN build `ffmpeg-n8.1-latest-linux64|linuxarm64-gpl-8.1.tar.xz` from https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ (the `latest` tag floats; the draft's "apt: ffmpeg" is wrong for upstream's reasoning, see the upstream comment on #1092) |
| bgutil-pot | Binary `bgutil-pot-linux-{x86_64,aarch64}` and plugin zip `bgutil-ytdlp-pot-provider-rs.zip` from https://github.com/jim60105/bgutil-ytdlp-pot-provider-rs/releases (upstream resolves the latest tag at build time). No checksum upstream. |
| Port | 8081/tcp (README; Dockerfile `EXPOSE 8081`; env `PORT`, default 8081) |
| Env vars (real, README table https://raw.githubusercontent.com/alexta69/metube/master/README.md) | `DOWNLOAD_DIR` (/downloads), `AUDIO_DOWNLOAD_DIR` (= DOWNLOAD_DIR), `TEMP_DIR` (/downloads; README warns RAM disks break resume), `STATE_DIR` (/downloads/.metube), `PORT` (8081), `URL_PREFIX` (/), `HTTPS`, `CERTFILE`, `KEYFILE`, `OUTPUT_TEMPLATE`, `YTDL_OPTIONS`, `YTDL_NIGHTLY_UPDATE_TIME`, `CORS_ALLOWED_ORIGINS`, `ALLOW_PRIVATE_ADDRESSES`, `DOWNLOAD_DIRS_INDEXABLE`, `SUBSCRIPTION_DEFAULT_CHECK_INTERVAL`. Upstream-only, read by the entrypoint: `PUID`, `PGID`, `UID`, `GID`, `UMASK`, `CHOWN_DIRS`. |
| Data write paths (upstream) | `DOWNLOAD_DIR`, `AUDIO_DOWNLOAD_DIR`, `TEMP_DIR`, `STATE_DIR`; `/tmp/bgutil-pot.log`; yt-dlp cache (default `~/.cache`, see section 9). |
| TrueCharts chart | https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/metube/values.yaml: `/config` persistence, `/downloads` persistence; `STATE_DIR=/config`, `DOWNLOAD_DIR=/downloads`; service 10216 to targetPort 8081; no securityContext override. |
| arm64 | Upstream publishes amd64 and arm64 (README: "Images are multi-arch (amd64/arm64)"). Upstream Dockerfile maps `TARGETARCH` for ffmpeg and bgutil. |
| Dependencies | None (no database; yt-dlp and ffmpeg are tools, not services). |

Corrections to the draft: the draft's "ffmpeg from apt" and "downloads go to /config or /tmp" are not what upstream or TrueCharts do. Downloads default to `/downloads` in both.

## 2. Target layout

- `apps/metube/Dockerfile`
- `apps/metube/docker-bake.hcl`
- `apps/metube/settings.yaml`
- `apps/metube/container-test.yaml`
- `apps/metube/start.sh` (replaces upstream `docker-entrypoint.sh`; no root/gosu path)

No `defaults/`, `etc/`, `scripts/` or `health/` needed. Do not use `root/`. No `DOWNSTREAM_CHANGES.md` (metube is not a `FROM` base).

## 3. Base image

- Runtime (final stage): `ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. It is ubuntu-26.04 based, has `/app/venv` (read-only at runtime), `PIP_BREAK_SYSTEM_PACKAGES=1`, and `USER apps`.
- Builder for the UI (build stage only, thrown away): `docker.io/library/node:22-alpine@sha256:c610fcdfb1d5b4740dd70c284ed3cb16bb857e0f7166196e36a5501df7a3aa32` (the digest upstream pins because of the QEMU arm64 issue noted in its Dockerfile). Note: there is no `apps/python-node` folder, but `ghcr.io/trueforge-org/python-node` is used as a `FROM` by `apps/budge` and `apps/changedetection`, so it could serve as the UI build stage instead (its Node version is UNVERIFIED). The plan keeps the upstream-pinned `node:22-alpine` digest for the UI stage because of the QEMU arm64 note; either is acceptable.
- Closest sibling: `apps/bazarr` (python base, source tarball from GitHub, ffmpeg via apt, `COPY --chmod=0755 . /`, `USER apps`, `WORKDIR /config`).

## 4. Dockerfile

1. Build stage A (`AS ui`): `FROM node:22-alpine@sha256:c610...`, `ARG VERSION`, download and extract the tag archive, `corepack enable && corepack prepare pnpm --activate`, `cd ui && CI=true pnpm install && pnpm run build`. Output: `/src/ui/dist/metube`.
2. Build stage B (`AS tools`) on the python base: `ARG TARGETARCH`, `ARG FFMPEG_BRANCH=8.1`, `ARG BGUTIL_VERSION` (pinned, not `releases/latest` at build time), `ARG UV_VERSION` (pinned; upstream uses unpinned `astral.sh/uv/install.sh`, so pin and renovate it with `datasource=pypi depName=uv`).
   - Case statement on `TARGETARCH` (amd64 -> `linux64`/`x86_64`, arm64 -> `linuxarm64`/`aarch64`); fail on anything else, as upstream does.
   - ffmpeg: `curl -fL https://github.com/BtbN/FFmpeg-Builds/releases/download/<pinned-tag>/ffmpeg-n${FFMPEG_BRANCH}-<tag>-${ARCH}-gpl-${FFMPEG_BRANCH}.tar.xz | tar -xJ -C /usr/local/bin --strip-components=2 --wildcards '*/bin/ffmpeg' '*/bin/ffprobe'`. Use a dated BtbN tag, not `latest`, so the build is reproducible (see section 10).
   - bgutil-pot: download `bgutil-pot-linux-${BGUTIL_ARCH}` to `/usr/local/bin/bgutil-pot` (`chmod +x`), and the plugin zip into the venv's site-packages (see step 4).
   - Install uv with pip (`pip install uv==${UV_VERSION}`), then install the locked deps into the base venv at build time: `UV_PROJECT_ENVIRONMENT=/app/venv uv sync --frozen --no-dev --no-install-project --compile-bytecode` from the source tree. The `/app/venv` read-only rule applies at runtime only.
   - Ship licences: `/usr/share/licenses/metube/LICENSE` (from the source tree) and the ffmpeg GPL notice from the BtbN archive if present (UNVERIFIED that it is in the archive).
3. Final stage on the python base:
   - `USER root`.
   - apt: only what the base lacks. Check the base first: `ca-certificates`, `curl` and `xz-utils` are likely present (UNVERIFIED). Upstream also installs `aria2` (metube appears to call it; UNVERIFIED, check `grep -r aria2 app/`), `unzip` (needed only if the plugin zip is unpacked at runtime; not needed if unpacked at build), `tini` (not needed: the ContainerForge model is `exec` in start.sh, see section 7). Do not install `build-essential`: the locked wheels should be binary. If a wheel is missing on 3.15, add build tools only in the build stage and purge them after install (see section 10).
   - `COPY --from=ui /src/ui/dist/metube /app/ui/dist/metube`, `COPY --from=tools /usr/local/bin/ffmpeg /usr/local/bin/ffprobe /usr/local/bin/bgutil-pot /usr/local/bin/`, `COPY --from=tools /app/venv /app/venv` (or install in the final stage instead, whichever keeps the image smaller; both are fine if the venv path matches the base's `VENV_FOLDER`).
   - Copy `app/` source: `COPY app /app/app` from the source tree.
   - `chown -R root:root /app && chmod -R 755 /app`.
   - ENV: `PORT=8081`, `DOWNLOAD_DIR=/config/downloads`, `AUDIO_DOWNLOAD_DIR=/config/downloads`, `TEMP_DIR=/tmp/metube`, `STATE_DIR=/config/state`, `XDG_CACHE_HOME=/tmp/cache`, `HOME=/config`, `PYTHONUNBUFFERED=1` (already in base).
   - `EXPOSE 8081`, `VOLUME /config`, `WORKDIR /app`.
   - Tail: `USER apps`, `COPY --chmod=0755 . /`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "metube"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=alexta69/metube versioning=loose
  default = "2026.11.24"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/alexta69/metube"
}
```

The `LICENSE` value must be the upstream licence: GitHub reports `AGPL-3.0`. Use `AGPL-3.0-only` if the copyright text says so; check the `LICENSE` file in the tag. Then the four standard targets (`image`, `image-local`, `image-all`, default group) copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `cd apps/metube && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/alexta69/metube"
ports:
  - port: 8081
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "8081"
    required: false
  - name: URL_PREFIX
    default: "/"
    required: false
  - name: DOWNLOAD_DIR
    default: "/config/downloads"
    required: false
  - name: AUDIO_DOWNLOAD_DIR
    default: "/config/downloads"
    required: false
  - name: TEMP_DIR
    default: "/tmp/metube"
    required: false
  - name: STATE_DIR
    default: "/config/state"
    required: false
  - name: OUTPUT_TEMPLATE
    default: "%(title)s.%(ext)s"
    required: false
  - name: YTDL_OPTIONS
    default: "{}"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Every env var above is read by upstream `app/` (README) or set by `start.sh`. Do not list `PUID`, `PGID`, `UMASK`, `CHOWN_DIRS` or `YTDL_NIGHTLY_UPDATE_TIME`: the entrypoint reads them, but ContainerForge does not run the entrypoint (section 7). Sort order follows the sibling apps. Add `HTTPS`, `CERTFILE`, `KEYFILE` only if the app is expected to serve TLS directly (open question, section 10).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/downloads /config/state /tmp/metube /tmp/cache

# bgutil-pot is the YouTube PO-token provider that yt-dlp talks to.
/usr/local/bin/bgutil-pot server >/tmp/bgutil-pot.log 2>&1 &

cd /app
exec /app/venv/bin/python app/main.py
```

- Idempotent: `mkdir -p` only. Nothing is seeded, because metube creates its own state on first start.
- Never writes to `/app`. The state and downloads go to `/config`, the scratch to `/tmp`.
- Uses the absolute venv interpreter so it does not depend on `PATH` activation.
- Upstream's `gosu`, `chown` and `pip install -U` upgrade path are removed (section 9).
- `exec` hands PID 1 to metube so signals propagate. bgutil-pot is a background child; it dies with the container.
- Bind address: metube's aiohttp server binds on `PORT`. Confirm it listens on `0.0.0.0`, not `127.0.0.1`, before relying on the http probe from another container (UNVERIFIED; check `app/main.py` in the tag).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8081'
http:
- port: '8081'
  path: /
filePaths:
- /app/app/main.py
- /app/ui/dist/metube
- /app/venv/bin/python
- /usr/local/bin/ffmpeg
- /usr/local/bin/ffprobe
- /usr/local/bin/bgutil-pot
- /usr/share/licenses/metube/LICENSE
```

- Every settings port has a `tcp` probe (8081) and an `http` probe with path `/`.
- `timeoutSeconds: 120` is a first guess; sibling python apps use 120 (confirm against `apps/bazarr/container-test.yaml`, which has no timeout, so UNVERIFIED). Increase only if the first run is slow for real reasons.
- `filePaths` cover the code, the UI build, the interpreter, the tools and the licence. The `ui/dist/metube` path is a directory; confirm it exists in the built image (UNVERIFIED that it is a directory with `index.html`).
- The test runs with no env. metube starts without env, so no required-env path needs `filePaths` beyond the above.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | ContainerForge change |
| --- | --- |
| Entrypoint runs as root, `chown -R PUID:PGID /app $DOWNLOAD_DIR ...` | Removed. Container runs as `apps` (568) from the base. `/app` stays root-owned and read-only. |
| `gosu PUID:PGID python3 app/main.py` | Replaced by `exec /app/venv/bin/python app/main.py` in `start.sh`. |
| `STATE_DIR=/downloads/.metube`, `DOWNLOAD_DIR=/downloads` | `STATE_DIR=/config/state`, `DOWNLOAD_DIR=/config/downloads`. The TrueCharts chart mounts `/downloads` separately; that is a chart choice, not an image one. |
| `TEMP_DIR=/downloads` | `/tmp/metube`. Scratch belongs in `/tmp`. Caveat: `/tmp` is a RAM disk, so large downloads can fill it (section 10). |
| yt-dlp cache (default `~/.cache`) and `HOME` | `XDG_CACHE_HOME=/tmp/cache`, so no cache lands in `/config`. |
| `/.cache` chmod 777 (upstream) | Not needed. Do not add it. |
| `python3 -m pip install -U yt-dlp` on exit 42 and nightly update | Cannot run: `/app/venv` is read-only at runtime. Expected: the restart is a no-op with a log warning. yt-dlp is updated by rebuilding the image (section 10). |
| `bgutil-pot` log in `/tmp` | Kept, in `/tmp`. |
| `UMASK` | Not set by ContainerForge. Default umask from the base applies. |

Security expectations (TrueCharts, `runAsUser 568`, `readOnlyRootFilesystem` default true, `privileged` false) are compatible with this plan, and no extra persistence beyond `/config` is needed by the image itself.

## 10. Risks, caveats and open questions

- Draft corrections: ffmpeg is a static BtbN build, not apt; downloads default to `/downloads` upstream, so the image uses `/config/downloads` only as a ContainerForge choice. The draft's "/config or /tmp" for downloads is not what the chart does.
- Floating ffmpeg: BtbN's `latest` release tag moves. The plan pins a dated tag. Open question: which tag to pin and whether BtbN keeps old tags (UNVERIFIED).
- Unpinned bgutil-pot: upstream resolves `releases/latest` at build time and has no checksum. The plan pins `BGUTIL_VERSION` and records the sha256 of both assets in the Dockerfile after the first download (checksum is ours, not upstream's).
- Unpinned uv: upstream uses `astral.sh/uv/install.sh` with no version. The plan pins it.
- yt-dlp staleness: video extractors break when sites change. With the read-only venv, updates happen only by rebuilding. Renovate on `uv.lock` or on the pinned `yt-dlp` is the update path. Confirm the lock is in the tag (UNVERIFIED).
- Python 3.15 wheels: `curl-cffi`, `aiohttp` and `watchfiles` need binary wheels for 3.15 on both arches. If one is missing, the build fails at `uv sync`; fix by pinning the base to 3.14 only if a sibling does so (none in this repo checked), not by adding build tools to the final image.
- `aria2`: upstream installs it; whether metube calls `aria2c` is UNVERIFIED. Drop it if unused.
- TLS: upstream can serve HTTPS itself (`HTTPS`, `CERTFILE`, `KEYFILE`). The plan serves plain HTTP only; the reverse proxy terminates TLS.
- Downloads and storage: `/config/downloads` lives on the persistent volume, so large media fills the config volume. Alternative: a separate `/downloads` volume (chart style). Decision needed.
- Caveat from the draft, kept: video extractors break often; downloads need enough disk and matching ownership.
- arm64: upstream publishes it; ContainerForge builds `image-all` for both. Test arm64 only if the amd64 build fails in an arm64-specific way (protocol rule).

## 11. Build and test steps

```sh
cd apps/metube
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker volume create metube-probe-config
docker run --rm -d --name metube-probe --read-only --tmpfs /tmp \
  -v metube-probe-config:/config metube:2026.11.24
docker logs -f metube-probe      # wait for the server to listen on 8081
docker rm -f metube-probe; docker volume rm metube-probe-config

forgetool containers test \
  --image metube:2026.11.24 \
  --config ./apps/metube/container-test.yaml
```

- Expected readiness signal: the process stays up and the port 8081 probe passes. The exact log line is UNVERIFIED, so confirm it from the first run and record it here.
- Expected failure to ignore only if it matches section 9: a yt-dlp upgrade warning on the read-only venv.
- Empty `/config` startup: the volume is fresh each run (`metube-probe-config`).
- If `forgetool` is not installed locally, check the same assertions by hand (TCP 8081, HTTP `/` returns 200, the listed files exist).

## 12. PR checklist

- Branch `feat/add-metube` from `main`; commit `feat(metube): add new container`; PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user the CLA is required before merge: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- Say what is not tested: arm64 build (unless tested), a real download (needs network to YouTube), the bgutil-pot path, the yt-dlp upgrade path (expected to be a no-op).
- Confirm `docker buildx bake --print` ran and passed before pushing.
