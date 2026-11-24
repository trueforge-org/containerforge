# telethon-downloader — implementation plan
> Source: ./draft.md · Target: apps/telethon-downloader/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | **4.0.15** (Docker Hub tag `jsavargas/telethon_downloader:4.0.15` and `latest`, pushed 2026-10-30; 4.0.14 and 4.0.13 precede it). The GitHub repo has **no matching git tags** (only `v3.1.9` from 2023 and older), and the changelog's newest entry seen was 4.0.13, so the Docker tag is the only version source. |
| Renovate | `datasource=docker depName=docker.io/jsavargas/telethon_downloader versioning=semver` (the Docker tags are plain `x.y.z` plus `latest`, `develop` and branch-named tags, which semver ignores). |
| License | GPL-3.0 (GitHub shows GPL-3.0 with `License.md`). UNVERIFIED: `-only` or `-or-later`. Use `GPL-3.0-only` unless `License.md` or the source headers say "or later". |
| Source URL | https://github.com/jsavargas/telethon_downloader (default branch `main`) |
| Source and arches | Pure Python source in `src/` (`app.py` is the entry point), so arch-independent: amd64 and arm64 both work. Extract it from the upstream image: `COPY --from=docker.io/jsavargas/telethon_downloader:${VERSION} /app/ ...`. The upstream Dockerfile (`FROM python`, `WORKDIR /app`, `COPY requirements.txt`, `COPY src .`) leaves `app.py`, the other modules and `requirements.txt` in `/app` (UNVERIFIED for 4.0.15: inspect with `docker run --rm --entrypoint ls ... /app`). |
| Python deps | `requirements.txt`: `tgcrypto`, `telethon`, `requests`, `yt_dlp`, `youtube_dl`, all unpinned. `tgcrypto` is a C extension and may need a compiler if no wheel exists for the Python version. |
| Checksum source | None (a pip install plus a container copy). Integrity comes from pinning the upstream image tag, and ideally its digest. |
| Upstream Dockerfile reviewed | Commit `ed9710a`: `FROM python`, apt `ffmpeg unzip`, pip install, `VOLUME /download /watch /config`, `ENTRYPOINT ["python","app.py"]`. |
| Ports | **None.** The bot is controlled through Telegram. The app opens no listening socket (`app.py` creates no server). The draft's `5000/http (inferred)` is wrong. |
| Env vars (`env_config.py`) | `API_ID` (alias `TG_API_ID`), `API_HASH` (`TG_API_HASH`), `BOT_TOKEN` (`TG_BOT_TOKEN`), `AUTHORIZED_USER_ID` (`TG_AUTHORIZED_USER_ID`, comma-separated integers), `TG_DOWNLOAD_PATH` (alias `DOWNLOAD_PATH`, default `/download`), `DOWNLOAD_PATH_TORRENTS` (`/watch`), `PATH_CONFIG` (`/config/`), `TG_MAX_PARALLEL` (alias `MAX_CONCURRENT_TASKS`, 4), `TG_PROGRESS_DOWNLOAD` (alias `PROGRESS_DOWNLOAD`, True), `PROGRESS_STATUS_SHOW` (10), `TORRENT_MODE` (`watch`; or `qbittorrent`), `QBT_HOST`, `QBT_PORT` (8080), `QBT_USERNAME`, `QBT_PASSWORD`, `YOUTUBE_VIDEO_FOLDER`, `YOUTUBE_AUDIO_FOLDER`, `YOUTUBE_FORMAT_VIDEO`, `YOUTUBE_FORMAT_AUDIO`, `YOUTUBE_DEFAULT_DOWNLOAD` (`video`), `YOUTUBE_TIMEOUT_OPTION` (5), `PUID`, `PGID`. |
| Behaviour without credentials | `validate_env()` fails, the app logs "Please set the environment variables API_ID, API_HASH, BOT_TOKEN, and AUTHORIZED_USER_ID" and exits 1. |
| Login | A **bot token** login (`bot.start(bot_token=...)`), not the interactive phone-code login the draft assumed. The session is `TelegramClient('bot', ...)`, so `bot.session` is written to the **working directory** and the draft's persistence caveat does apply. |

## 2. Target layout

```
apps/telethon-downloader/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

`start.sh` is needed for the credential check and the working directory. No `defaults/`: the app creates `/config` content itself (`os.makedirs(PATH_CONFIG)`, plus `config.ini` handling, UNVERIFIED). Never use `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

It provides a read-only `/app/venv` (see `python-runtime.instructions.md`). Closest sibling: `apps/bazarr` (python base, apt `ffmpeg`, `/app`). Fallback: if `tgcrypto` or another dependency does not build on Python 3.15, fall back to a `python:3.14.x` base. The digest `sha256:feb6e444...` in `apps/changedetection` belongs to `python-node:3.14.8`, not to `python`, so look up the correct `python:3.14.x` digest before using it. UNVERIFIED: the upstream requirements were not tested on 3.15.

## 4. Dockerfile

1. `FROM` the python base (above). `ARG VERSION`. Declare `ARG TARGETARCH` only if used.
2. `USER root`.
3. `apt-get install -y --no-install-recommends ffmpeg` (used by yt-dlp and for media handling; `unzip` is already in ubuntu, so skip it). Build tools for `tgcrypto` (`build-essential`, `python3-dev` or `libffi-dev` as needed) go in the same layer and are **purged in the same layer** (pattern from `apps/changedetection` and `apps/bazarr`). Drop them if `pip` finds wheels. Do not pin apt versions: neither package is the app itself.
4. Copy the app from the upstream image and install dependencies:
   ```dockerfile
   COPY --from=docker.io/jsavargas/telethon_downloader:${VERSION} /app/ /app/telethon/
   RUN /app/venv/bin/pip install --no-cache-dir -r /app/telethon/requirements.txt
   ```
   `ARG VERSION` must be declared before the first `FROM` (or use a named stage `FROM docker.io/jsavargas/telethon_downloader:${VERSION} AS upstream`, which is cleaner). Prefer `@sha256:` pinning of that stage once a digest is known (UNVERIFIED digest: read it at implementation time). Remove `requirements.txt` after the install only if nothing needs it.
5. `chown -R root:root /app/telethon && chmod -R 755 /app/telethon` (read-only at runtime), `mkdir -p /download /watch` and `chown apps:apps` them (these paths are mount points).
6. `ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 HOME=/config PIP_CACHE_DIR=/tmp/pip XDG_CACHE_HOME=/tmp/.cache` (yt-dlp keeps its cache under `XDG_CACHE_HOME`, so keep it out of `/config`).
7. License: the repo has `License.md`. It is not copied by `COPY --from=...:/app/`, so fetch it at build time: `curl -fsSL https://raw.githubusercontent.com/jsavargas/telethon_downloader/main/License.md -o /usr/share/licenses/telethon-downloader/License.md` (UNVERIFIED: a raw `main` URL is not pinned to 4.0.15. If a tag or commit is available, use that).
8. `USER apps`, `COPY --chmod=0755 . /`, `VOLUME /config /download /watch`, `WORKDIR /config`. No `EXPOSE`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}
variable "APP" { default = "telethon-downloader" }
variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/jsavargas/telethon_downloader versioning=semver
  default = "4.0.15"
}
variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/jsavargas/telethon_downloader" }
```

The standard `group "default"` and the targets `image`, `image-local` and `image-all` (amd64 and arm64) come from `apps/bazarr/docker-bake.hcl`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/jsavargas/telethon_downloader"
ports:
  []
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: TG_API_ID
    default: ""
    required: true
  - name: TG_API_HASH
    default: ""
    required: true
  - name: TG_BOT_TOKEN
    default: ""
    required: true
  - name: TG_AUTHORIZED_USER_ID
    default: ""
    required: true
  - name: TG_DOWNLOAD_PATH
    default: "/download"
    required: false
  - name: DOWNLOAD_PATH_TORRENTS
    default: "/watch"
    required: false
  - name: TG_MAX_PARALLEL
    default: "4"
    required: false
  - name: TORRENT_MODE
    default: "watch"
    required: false
volumes:
  - path: /config
    required: true
  - path: /download
    required: false
  - path: /watch
    required: false
```

Format it as `apps/jbops/settings.yaml` does (`ports: []` on two lines). The four credential variables are `required: true` with an empty default, which the rules allow only when `start.sh` handles them: see section 7. Optional qBittorrent and YouTube variables can be added later (names are in section 1). `PUID` and `PGID` are deliberately omitted: the image always runs as UID 568. Dependencies: none. The draft says there is no hard container dependency, and qBittorrent is an optional external client. If it later becomes an optional dependency, check whether `apps/qbittorrent` exists first.

## 7. start.sh

`#!/usr/bin/env bash`, idempotent:

1. `cd /config` (the Telethon session `bot.session` is created in the current directory, so it is persisted and `/app` stays untouched).
2. Export defaults only if unset: `PATH_CONFIG=/config/`, `TG_DOWNLOAD_PATH=/download`, `DOWNLOAD_PATH_TORRENTS=/watch`.
3. Accept either name for each credential (`TG_API_ID` or `API_ID`, and so on). If any of the four is missing, print one clear line ("Telegram credentials missing: set TG_API_ID, TG_API_HASH, TG_BOT_TOKEN and TG_AUTHORIZED_USER_ID, then restart") and `exec sleep infinity`, so the image still starts without env vars as the protocol requires and does not crash-loop. UNVERIFIED design choice: the upstream app exits 1 here, so maintainers may prefer an exit 1, which would break the default `filePaths` check (see section 8).
4. `mkdir -p /config /download /watch 2>/dev/null || true` (they may be mounts).
5. `exec /app/venv/bin/python /app/telethon/app.py`. Secrets are read from the environment by the app, and nothing is written to files or the command line.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# narrowed: the bot needs real Telegram credentials and network access, so the test
# cannot start it. It checks that the code, its dependencies and the licence are present.
filePaths:
- /app/telethon/app.py
- /app/telethon/env_config.py
- /usr/share/licenses/telethon-downloader/License.md

runners:
- entrypoint: /app/venv/bin/python
  cmd: "-c __import__('telethon');print('telethon'+'-ok')"
  expectedOutput: telethon-ok
```

There are no ports, so there is no TCP or HTTP probe (consistent with `settings.yaml`, which lists none). The `runners` check uses the `apps/jbops` pattern (a space-free command, with the expected string built at runtime). With the section 7 idle behaviour the default runner stays up, so `filePaths` run. The DB-dependency exception is not used. The narrowing comment above is about missing credentials. Timeout: omit, as the siblings with `filePaths` do.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
|---|---|
| `bot.session` (cwd, upstream `/app`) | `WORKDIR /config` plus `cd /config`, so the session persists in `/config` |
| `/config` (pending downloads, `config.ini`, logs, UNVERIFIED) | `/config` volume |
| `/download`, `/watch`, `/download/youtube/*` | Volumes (mount points owned by `apps`) |
| yt-dlp cache, pip cache | `/tmp` (`XDG_CACHE_HOME`, `PIP_CACHE_DIR`) |
| `PUID` and `PGID` handling | Not used: the image runs as `apps` (568) |

TrueCharts expectations reconciled: the chart runs as UID 0 with `readOnlyRootFilesystem false`, and the image runs rootless (568) with a read-only rootfs, so the chart must mount `/download` and `/watch` writable for UID 568 (fsGroup) and use `/config` for the session. `/app` holds only code and the venv.

## 10. Risks, caveats and open questions

- The draft's port (5000/http) is wrong: the app has no web UI. Dropping it from `settings.yaml` removes the TCP probe requirement.
- The login is by bot token, so the draft's interactive phone-code or 2FA caveat is not valid. Credentials come from @BotFather (`TG_BOT_TOKEN`) and my.telegram.org (`TG_API_ID`, `TG_API_HASH`).
- **Version tracking**: only Docker tags carry versions, and the Git repo has no tags beyond 3.1.9. The plan therefore copies the source from the upstream image, which makes our build depend on that image staying on Docker Hub. UNVERIFIED alternative: pin a commit SHA with `datasource=git-refs` and download the archive.
- **Unpinned dependencies**: `yt_dlp`, `youtube_dl`, `telethon` and `tgcrypto` float at build time, so builds are not reproducible (and `youtube_dl` is unmaintained). Consider a constraints file only if upstream accepts it.
- **Python 3.15 compatibility** of `tgcrypto` and `youtube_dl` is UNVERIFIED. Test it first, and fall back to 3.14 (as `apps/changedetection` does for litellm).
- The `AUTHORIZED_USER_ID` path-injection note: the add-folder flow does not sanitise folder names, so only trusted users should be authorised (upstream behaviour, not ours to patch).
- The README documents the `TG_`-prefixed names, while `docker-compose.yml` uses the unprefixed ones. The code accepts both, so `start.sh` and `settings.yaml` must keep this consistent.
- No blockers: no GPU, no privileged mode, arm64 works (pure Python, with `tgcrypto` possibly built from source).

## 11. Build and test steps

```sh
cd apps/telethon-downloader
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name telethon-downloader-probe --read-only --tmpfs /tmp \
  -v telethon-downloader-probe-config:/config telethon-downloader:4.0.15
docker logs -f telethon-downloader-probe     # expect the "credentials missing" line, container stays up
docker exec telethon-downloader-probe /app/venv/bin/python -c "import telethon, yt_dlp, tgcrypto; print('ok')"
docker rm -f telethon-downloader-probe; docker volume rm telethon-downloader-probe-config
forgetool containers test --image telethon-downloader:4.0.15 --config ./apps/telethon-downloader/container-test.yaml
```

With real credentials (manual, optional) the log should show the bot's welcome and "start" messages, and `bot.session` should appear in `/config`. Check that a restart reuses the session. Readiness without credentials: the explicit "credentials missing" line and a running process.

## 12. PR checklist

- Branch `feat/add-telethon-downloader`, commit and PR title `feat(telethon-downloader): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md` and check only the boxes that apply.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- State in the PR: no ports, copied source from the upstream image tag, and the idle-without-credentials behaviour.
- Untested at planning time: the build, Python 3.15 dependency installation, the read-only run, `forgetool containers test`, and any real Telegram login. Do not check "Built container locally" unless it was done.
