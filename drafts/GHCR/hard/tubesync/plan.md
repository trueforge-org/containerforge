# tubesync — implementation plan
> Source: ./draft.md · Target: apps/tubesync/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | tubesync `v0.19.3` (latest release, published 2026-11-24). Draft pins `v0.19.1`, which is stale; update the pin or re-verify. Source: https://api.github.com/repos/meeb/tubesync/releases/latest |
| Chart image | `ghcr.io/meeb/tubesync:latest` (rolling). Not reused: ContainerForge builds from the tagged source. |
| Renovate | `datasource=github-releases depName=meeb/tubesync versioning=semver` |
| License | AGPL-3.0 (repo metadata). Source: https://api.github.com/repos/meeb/tubesync |
| Source URL | https://github.com/meeb/tubesync |
| Per-arch download | No release assets (source tag only). Application is interpreted Python from the source tree, so the source archive `https://github.com/meeb/tubesync/archive/refs/tags/v0.19.3.tar.gz` works for both amd64 and arm64. Runtime tools (ffmpeg, yt-dlp, s6, openresty, deno) are fetched by the upstream Dockerfile per architecture. |
| Checksum source | Upstream Dockerfile pins sha256 for asfald, s6-overlay (`SHA256_S6_AMD64`, `SHA256_S6_ARM64`, `SHA256_S6_NOARCH`) and QuickJS. Source tarball has no published checksum. |
| Upstream Dockerfile reviewed | `https://raw.githubusercontent.com/meeb/tubesync/main/Dockerfile`. Debian `trixie-slim`, many stages (s6-overlay, openresty, uv, deno, ffmpeg, asfald, quickjs). `ENV`: `XDG_CONFIG_HOME=/config/tubesync`, `XDG_CACHE_HOME=/config/cache`, `XDG_STATE_HOME=/config/state`, `SQLITE_TMPDIR=/config/cache`, `DENO_DIR=/config/cache/deno`, `PYTHONPATH=/app`. `EXPOSE 4848`, `VOLUME ["/config","/downloads"]`, `ENTRYPOINT ["/init"]`, `HEALTHCHECK /app/healthcheck.py`. No `USER` (runs as root). |
| Build issues in upstream | `FFMPEG_DATE` has no default (ffmpeg URL ends `autobuild-`). `SHA256_FFMPEG_*` are undefined, so the pinned check is skipped. `YTDLP_DATE` unused. |
| Ports | Dockerfile `EXPOSE 4848`; README: `LISTEN_PORT` default `8080` for manual installs; README container example maps `4848:4848`. Which port the container listens on by default is UNVERIFIED. |
| Env (README) | `DJANGO_SECRET_KEY`, `DJANGO_URL_PREFIX`, `TUBESYNC_DEBUG`, `TUBESYNC_HOSTS` (default `*`), `TUBESYNC_RESET_DOWNLOAD_DIR` (default True), `TUBESYNC_VIDEO_HEIGHT_CUTOFF`, `TUBESYNC_RENAME_SOURCES`, `TUBESYNC_RENAME_ALL_SOURCES`, `TUBESYNC_DIRECTORY_PREFIX`, `TUBESYNC_SHRINK_NEW`, `TUBESYNC_SHRINK_OLD`, `LISTEN_PORT`, `DATABASE_CONNECTION` (optional external Postgres). PUID/PGID mentioned; defaults UNVERIFIED. Source: https://api.github.com/repos/meeb/tubesync/contents/README.md |
| Data paths | `/config` (SQLite DB and state), `/downloads` (media). |
| Dependencies | None required. Optional external Postgres via `DATABASE_CONNECTION`. |
| arm64 | Upstream has arm64 pins (asfald, s6, ffmpeg arm64 path). arm64 build plausible; not built here. |
| copy-from | `ghcr.io/meeb/tubesync:latest` is a full Debian root-user image. Not useful for `COPY --from`: the app is source, and the image runs as root. |

## 2. Target layout

- `apps/tubesync/Dockerfile`
- `apps/tubesync/docker-bake.hcl`
- `apps/tubesync/settings.yaml`
- `apps/tubesync/container-test.yaml`
- `apps/tubesync/start.sh` (process supervisor entry)
- `apps/tubesync/defaults/` for the nginx/openresty config seed, only if the design needs it (reason: static config under `/app` is read-only).

No `root/`. No `DOWNSTREAM_CHANGES.md`. Closest Python siblings: `apps/bazarr` (ffmpeg plus Python) and `apps/changedetection` (python-node). Use `apps/nginx` as the reference for an nginx-in-container layout.

## 3. Base image

Runtime: `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`, matching `apps/bazarr`. Upstream is Python with Django, so the Python base fits. Alternative: `ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f` if the web layer is nginx-first. Decision needed (section 10). Do not install Python from apt; the base provides it. s6-overlay is not provided by the base; decide whether to use it or a simpler supervisor (see section 7).

## 4. Dockerfile

1. Build stage `FROM <python> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Download source: `curl -fL https://github.com/meeb/tubesync/archive/refs/tags/v${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1`. Record a sha256 locally in `ARG SHA256_TUBESYNC_SRC` and verify.
3. Python deps: `pip install uv`, then `uv pip install --strict -r requirements.txt` (or the Pipfile lock upstream uses) with `UV_CACHE_DIR=/tmp/uv-cache`. Install into a venv at `/tmp/venv` in the build stage, then copy it to `/app/venv` (read-only at runtime). `PIP_NO_CACHE_DIR=1`.
4. ffmpeg: `ARG FFMPEG_VERSION`, `ARG SHA256_FFMPEG_AMD64`, `ARG SHA256_FFMPEG_ARM64`. Pin the date (fix the upstream empty `FFMPEG_DATE` by setting a default). Copy only `ffmpeg` and `ffprobe` to `/usr/local/bin`.
5. s6-overlay (if used): pin `S6_VERSION=3.2.3.2` with the noarch and arch sha256 from upstream (`SHA256_S6_*`). Alternatively drop s6 and run gunicorn + nginx under a small `start.sh` (see section 7).
6. Final stage `FROM <python>`, `USER root`. `apt-get install -y --no-install-recommends nginx` (or `openresty` from the upstream mirror if the nginx build is the choice; verify availability on the base). Clean `/var/lib/apt/lists/*`.
7. `COPY --from=build /tmp/src/ /app/tubesync/`, `COPY --from=build /app/venv /app/venv`, license to `/usr/share/licenses/tubesync/LICENSE`.
8. `ENV PYTHONPATH=/app/tubesync HOME=/config XDG_CACHE_HOME=/tmp/cache XDG_CONFIG_HOME=/config/tubesync XDG_STATE_HOME=/config/state PYTHONPYCACHEPREFIX=/tmp/pycache`.
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /
EXPOSE 4848
VOLUME /config
VOLUME /downloads
```

Do not set `SQLITE_TMPDIR` or `DENO_DIR` under `/config` unless the app needs persistence there; point caches at `/tmp`.

## 5. docker-bake.hcl

Same shape as `apps/tsmuxer/docker-bake.hcl` in this plan (4 standard targets plus default group). Values:

- `APP` = `tubesync`
- `VERSION` = `0.19.3` with `// renovate: datasource=github-releases depName=meeb/tubesync versioning=semver`
- `LICENSE` = `AGPL-3.0`
- `SOURCE` = `https://github.com/meeb/tubesync`
- `image-all` platforms `linux/amd64` and `linux/arm64` once both are validated.

Run `docker buildx bake --print` from `apps/tubesync/`. Dockerfile `ARG VERSION` must be `0.19.3`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/meeb/tubesync"
ports:
  - port: 4848
    protocol: http
    required: true
env:
  - name: TUBESYNC_HOSTS
    default: "*"
    required: false
  - name: TUBESYNC_RESET_DOWNLOAD_DIR
    default: "True"
    required: false
  - name: LISTEN_PORT
    default: "4848"
    required: false
  - name: DJANGO_SECRET_KEY
    default: ""
    required: false
  - name: DATABASE_CONNECTION
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /downloads
    required: false
dependencies: []
```

The port (4848 vs 8080) must be settled with a live run before merge. `DJANGO_SECRET_KEY`: the app must generate one on first start if empty (check upstream code, UNVERIFIED); do not hardcode a secret. Do not list env vars the code does not read.

## 7. start.sh

- Idempotent: `mkdir -p /config/tubesync /config/cache /config/state /tmp/cache`. Seed nothing into `/config` except a generated secret key file if upstream expects one.
- Run database migrations on start (upstream does this; slow first start). Use `python /app/tubesync/manage.py migrate --noinput` writing the SQLite DB to `/config`.
- Start gunicorn bound to `0.0.0.0:${LISTEN_PORT:-4848}`, then nginx (or openresty) in the foreground, or the supervisor chosen in section 3.
- The last command is `exec` for the long-running process so PID 1 gets signals.
- Never write under `/app`. Caches go to `/tmp`.

## 8. container-test.yaml

- Schema header from the siblings.
- `filePaths`: `/start.sh`, `/app/tubesync/manage.py`, `/app/venv/bin/python`, `/usr/bin/ffmpeg` or `/usr/local/bin/ffmpeg`, `/usr/share/licenses/tubesync/LICENSE`.
- `tcp` probe on 4848.
- `http` probe on `/` once the port is confirmed.
- Startup is slow (migrations, s6 setup). Take `timeoutSeconds` from the largest Python sibling; expect a higher value than the usual default.
- Empty-env run: startup must succeed with no variables, so `DJANGO_SECRET_KEY` generation is a `start.sh` path that the test exercises.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root. ContainerForge runs as `apps`, so `/downloads` ownership must match the runtime UID. Upstream has `TUBESYNC_RESET_DOWNLOAD_DIR` to chown `/downloads`; under `apps` this does not work, so either keep the download path writable by `apps` or make the reset a no-op with a documented reason.
- Writes: `/config` (DB, state), `/downloads` (media, user data), `/tmp` (caches, pycache, sqlite temp).
- `/app` is read-only: the upstream `PYTHONPYCACHEPREFIX` and `DENO_DIR` must point to `/tmp`.
- nginx writes its pid and temp files to `/tmp`; the config must be placed by root at build time, not generated at start.
- Chart `readOnlyRootFilesystem: false` can become `true` after the above, verified with `docker run --read-only --tmpfs /tmp`.

## 10. Risks, caveats and open questions

- **Multi-process app.** Django, gunicorn, nginx and background workers in one image. Keep the process model in `start.sh` simple; decide the supervisor (s6 vs plain) before writing the Dockerfile.
- **Upstream build defects.** `FFMPEG_DATE` default missing and `SHA256_FFMPEG_*` undefined (section 1). Fix in the plan, not upstream.
- **yt-dlp churn.** Downloads break when YouTube changes. Expect frequent `yt-dlp` updates; pin `yt-dlp` and say so.
- **Port uncertainty.** 4848 vs 8080 must be settled by a live run.
- **Draft tag drift.** Draft pins `v0.19.1`; latest is `v0.19.3`. Update before build.
- **Chart uses rolling latest.** This plan pins the tag; the chart must be aligned in its own repo.
- **Root image upstream.** ContainerForge runs as `apps`; the download reset must be rewritten (section 9).
- **Blockers:** none known beyond the above. Musl: not applicable (Debian-based).

## 11. Build and test steps

From `apps/tubesync/`, in order (`.github/instructions/build-test-protocol.instructions.md`):

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name tubesync-probe --read-only --tmpfs /tmp -v tubesync-probe-config:/config tubesync:0.19.3`, then `docker logs -f tubesync-probe` until idle. Readiness signal: gunicorn "Listening at" line on the chosen port. Migration output is expected on first start. Container must stay up.
4. `forgetool containers test --image tubesync:0.19.3 --config ./container-test.yaml`
5. Cleanup: `docker rm -f tubesync-probe; docker volume rm tubesync-probe-config`.

No build or docker run was done for this plan.

## 12. PR checklist

- Branch `feat/add-tubesync`; commit and title `feat(tubesync): add new container`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; tick only what was run.
- Notes: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- Say what was not tested: arm64; port choice; migrations on a populated `/config`; `/downloads` behaviour.
- Downstream: none (not a base image).
