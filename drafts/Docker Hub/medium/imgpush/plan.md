# imgpush — implementation plan
> Source: ./draft.md · Target: apps/imgpush/ · Difficulty: medium · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `hauxir/imgpush` has no releases and no tags. Plan pins `master` commit `9a44956c12da164d6198dfd932830e7a5a4c4adf` (2026-11-17), the commit the draft links (`9a44956`). `pyproject.toml` says `version = "1.0.0"` (not a release marker). |
| Renovate | `datasource=git-refs depName=hauxir/imgpush packageName=https://github.com/hauxir/imgpush currentDigest=<sha>` (same style as the noVNC entry in this repo) |
| License | MIT (`pyproject.toml` and GitHub SPDX `MIT`) |
| Source URL | https://github.com/hauxir/imgpush (tarball `https://github.com/hauxir/imgpush/archive/9a44956c12da164d6198dfd932830e7a5a4c4adf.tar.gz`) |
| Per-arch download | Interpreted app; one source tarball for both arches. Python deps are installed from `uv.lock` with `uv sync --frozen --no-dev --extra rembg`. |
| Checksum source | None for the archive; the pinned commit SHA is the anchor, `uv.lock` pins wheel hashes. |
| Upstream Dockerfile reviewed | Yes (two-stage `ubuntu:24.04`: uv sync in a builder, runtime installs `libmagickwand-dev curl nginx python3`, copies `classifier_model.onnx` to `/root/.NudeNet/`, pre-downloads the rembg `u2net` model, `CMD bash entrypoint.sh`). |

Behaviour (from `Dockerfile`, `nginx.conf`, `app/entrypoint.sh`, `app/settings.py`, README):
- **Port is 5000, not 8000** (the draft's inferred 8000 is wrong). nginx listens on 5000 and proxies to uvicorn on a unix socket `/app/imgpush.sock`; `/nginx/` is an internal location (`alias /`) used for `X-Accel-Redirect` file serving.
- `entrypoint.sh` starts `nginx` (daemonizing) and then `uvicorn app:app --uds imgpush.sock --access-log --workers $WORKERS --limit-max-requests 200` (cwd `/app`). `WORKERS` defaults to the CPU count.
- Endpoints: `GET /` (upload form), `POST /` (upload), `GET /liveness` (always 200), `GET /<file>`, `DELETE /<file>`.
- Settings are env vars named exactly like the variables in `app/settings.py`: `IMAGES_DIR` (default `/images/`), `CACHE_DIR` (`/cache/`), `LOCAL_CACHE_DIR` (`/local_cache/`), `LOCAL_CACHE_MAX_SIZE_MB`, `OUTPUT_TYPE`, `MAX_SIZE_MB` (16), `MAX_UPLOADS_PER_DAY/HOUR/MINUTE`, `ALLOWED_ORIGINS`, `VALID_SIZES`, `NAME_STRATEGY`, `NUDE_FILTER_MAX_THRESHOLD`, `NUDE_FILTER_VIDEO_INTERVAL`, `NUDE_FILTER_MAX_FRAMES`, `ALLOW_VIDEO`, `MAX_VIDEO_DURATION`, `HIDE_UPLOAD_FORM`, `API_KEY`, `REQUIRE_API_KEY_FOR_UPLOAD`, `REQUIRE_API_KEY_FOR_DELETE`, `MAX_API_KEY_ATTEMPTS_PER_MINUTE`, `ALLOW_REMOVE_BG`, `STORAGE_BACKEND` (`local`|`s3`), `S3_ENDPOINT_URL`, `S3_ACCESS_KEY_ID`, `S3_SECRET_ACCESS_KEY`, `S3_BUCKET_NAME`, `S3_REGION`, `S3_IMAGES_PREFIX`, `S3_CACHE_PREFIX`. Values are `eval`-ed as Python literals and fall back to the string when that fails.
- `requires-python >=3.12`, `.python-version` is `3.12`; pinned deps include `nudenet==2.0.9`, `opencv-python-headless==4.10.0.84`, `rembg[cpu]==2.0.62`, `Wand==0.6.13`, `fastapi==0.115.6`.

## 2. Target layout

```
apps/imgpush/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  etc/nginx/imgpush.conf      # our rootless nginx config (listen 5000, temp paths in /tmp, socket in /tmp)
```
`etc/` is needed because upstream's `nginx.conf` is a `conf.d` fragment that assumes root, `/app/imgpush.sock` and default temp dirs. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (draft says python base; matches). Closest siblings: `apps/bazarr` (python with apt libs and `uv`) and `apps/changedetection` (python app, source tarball). Note the base ships Python 3.15 at `/usr/local/bin/python` and a venv at `/app/venv`; see the version risk in section 10.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `WORKDIR /app`.
2. Env set before the install steps: `ENV UV_PROJECT_ENVIRONMENT=/app/imgpush-venv UV_PYTHON_INSTALL_DIR=/usr/local/share/uv/python UV_CACHE_DIR=/tmp/uv-cache U2NET_HOME=/app/models HOME=/app/home NUMBA_CACHE_DIR=/tmp MPLCONFIGDIR=/tmp XDG_CACHE_HOME=/tmp`. `HOME=/app/home` is read-only; it holds the NudeNet model, so nothing may be written there at runtime.
3. apt (not already in base; verify names on 26.04 at build, UNVERIFIED): `nginx`, `curl` (already in base, skip), ImageMagick runtime and headers for Wand: `libmagickwand-dev` (upstream package; on 26.04 this is ImageMagick 7, which Wand 0.6.13 supports; UNVERIFIED), plus `ffmpeg` only if `ALLOW_VIDEO` is wanted (UNVERIFIED: upstream installs no ffmpeg, video support uses the pip stack; do not add). Pin versions where apt gives a version tied to `VERSION`: not applicable, because imgpush is not an apt package. Clean `/var/lib/apt/lists/*`.
4. Fetch source: `curl -fsSL https://github.com/hauxir/imgpush/archive/${VERSION}.tar.gz | tar xz --strip-components=1 -C /tmp/src`.
5. Install deps: `pip install uv` (as bazarr does), then in `/tmp/src`: `uv sync --frozen --no-cache --no-dev --extra rembg --python 3.12` so uv installs a managed CPython 3.12 matching `.python-version`/`uv.lock` and the venv lands in `UV_PROJECT_ENVIRONMENT`. Then `pip uninstall --yes uv`. (Alternative if wheels exist for 3.15: omit `--python`; see section 10.)
6. Layout: `cp -r /tmp/src/app/. /app/imgpush/` (the app expects its modules in the working dir); `mkdir -p /app/home/.NudeNet && cp /tmp/src/classifier_model.onnx /app/home/.NudeNet/`; install the ImageMagick policy: `cp /tmp/src/ImageMagick-6/policy.xml "$(ls -d /etc/ImageMagick-*)/policy.xml"` (UNVERIFIED which directory 26.04 uses; fail the build if `ls` finds none). Pre-download the rembg model at build: `/app/imgpush-venv/bin/python -c "from rembg import new_session; new_session('u2net')"` (writes to `U2NET_HOME`).
7. License: `install -D /tmp/src/LICENSE /usr/share/licenses/imgpush/LICENSE`.
8. `chown -R root:root /app && chmod -R 755 /app`; `rm -rf /tmp/src /tmp/uv-cache`.
9. `ENV` runtime defaults: `IMAGES_DIR=/config/images/ CACHE_DIR=/config/cache/ LOCAL_CACHE_DIR=/tmp/local_cache/ PATH=/app/imgpush-venv/bin:$PATH`.
10. `USER apps`, `COPY --chmod=0755 . /` (brings `start.sh` and `etc/nginx/imgpush.conf`), `EXPOSE 5000`, `VOLUME /config`, `WORKDIR /app/imgpush`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "imgpush" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=hauxir/imgpush packageName=https://github.com/hauxir/imgpush currentDigest=9a44956c12da164d6198dfd932830e7a5a4c4adf
  default = "9a44956c12da164d6198dfd932830e7a5a4c4adf"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/hauxir/imgpush" }
```
Plus the four standard targets and `group "default"` as in `apps/adguardhome-sync/docker-bake.hcl`. Image tag would be the long SHA (same trade-off as other SHA-pinned apps). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/hauxir/imgpush"
ports:
  - port: 5000
    protocol: tcp
    required: true
env: # defaults match start.sh and settings.py; list only variables the app reads
  - { name: TZ, default: "Etc/UTC", required: false }
  - { name: WORKERS, default: "2", required: false }
  - { name: IMAGES_DIR, default: "/config/images/", required: false }
  - { name: CACHE_DIR, default: "/config/cache/", required: false }
  - { name: MAX_SIZE_MB, default: "16", required: false }
  - { name: ALLOWED_ORIGINS, default: "['*']", required: false }
  - { name: API_KEY, default: "", required: false }
  - { name: REQUIRE_API_KEY_FOR_UPLOAD, default: "False", required: false }
  - { name: STORAGE_BACKEND, default: "local", required: false }
volumes:
  - path: /config
    required: true
dependencies: []
```
Write the real file in the sibling block style and add the other settings from section 1 (`OUTPUT_TYPE`, `VALID_SIZES`, `NAME_STRATEGY`, `NUDE_FILTER_MAX_THRESHOLD`, `ALLOW_VIDEO`, `ALLOW_REMOVE_BG`, S3_*) with the upstream defaults. `WORKERS` default `2` is imposed by `start.sh` (upstream uses the CPU count; a fixed small default is safer for the large ONNX memory footprint). Dependencies: none (S3 is optional and external).

## 7. start.sh

1. `set -eu`. `mkdir -p "${IMAGES_DIR:-/config/images/}" "${CACHE_DIR:-/config/cache/}" /tmp/local_cache /tmp/nginx` (all under `/config` or `/tmp`; nothing under `/app`). The `/config` dirs are created only if missing (`mkdir -p` is idempotent).
2. Keep upstream's thread limits: `export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1 NUMEXPR_NUM_THREADS=1 MALLOC_MMAP_THRESHOLD_=65536 MALLOC_TRIM_THRESHOLD_=131072`.
3. Start nginx in the background with our config: `nginx -c /etc/nginx/imgpush.conf -g 'daemon off;' &` (config: `pid /tmp/nginx.pid; error_log /dev/stderr; access_log off;`, all `*_temp_path` under `/tmp/nginx`, `server { listen 5000; client_max_body_size 0; location / { proxy_pass http://unix:/tmp/imgpush.sock; proxy_read_timeout 30s; proxy_send_timeout 30s; } location /nginx/ { internal; alias /; add_header Access-Control-Allow-Origin $upstream_http_access_control_allow_origin; add_header Vary $upstream_http_vary; } }`, copied from upstream `nginx.conf`, with only the socket path changed). Listening on `5000` binds all interfaces.
4. `exec uvicorn app:app --uds /tmp/imgpush.sock --access-log --workers "${WORKERS:-2}" --limit-max-requests 200` from `/app/imgpush`. Because nginx stays as a background child, add `trap 'kill $NGINX_PID' EXIT`. UNVERIFIED: whether `app.py` writes anywhere besides `IMAGES_DIR`, `CACHE_DIR`, `LOCAL_CACHE_DIR` and `/tmp` (the upstream `MAX_TMP_FILE_AGE` suggests temp files; confirm with a read-only run).
5. No config to seed; settings come from env.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 300
http:
  - port: '5000'
    path: /liveness
tcp:
  - port: '5000'
filePaths:
  - /app/imgpush/app.py
  - /app/home/.NudeNet/classifier_model.onnx
  - /usr/share/licenses/imgpush/LICENSE
```
One probe per declared port (5000). `timeoutSeconds: 300` because importing onnxruntime, opencv and nudenet is slow on first start (UNVERIFIED; adjust after a first run; `apps/bookstack` uses 240). The `/liveness` path is documented upstream. No required env, so no untested code path other than S3 and API-key flows (`filePaths` cannot cover them; test them by hand per section 11).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/images` (uploads) | `/config/images/` via `IMAGES_DIR` (persistent) |
| `/cache` (resized variants) | `/config/cache/` via `CACHE_DIR` |
| `/local_cache` (S3 cache) | `/tmp/local_cache/` via `LOCAL_CACHE_DIR` |
| `/app/imgpush.sock` | `/tmp/imgpush.sock` (both uvicorn `--uds` and nginx `proxy_pass`) |
| nginx pid, temp, logs (`/var/lib/nginx`, `/run/nginx.pid`, `/var/log/nginx`) | all in `/tmp`, logs to stderr |
| `/root/.NudeNet`, `~/.u2net` | `/app/home/.NudeNet` and `U2NET_HOME=/app/models`, preloaded at build and read-only |
| numba/matplotlib/xdg caches | `/tmp` |

Draft expectations (chart UID 0, read-only false, PVCs `/cache` and `/images`): we run as UID 568 `apps`, read-only rootfs, one `/config` volume replacing both PVCs (document the path change for users migrating data: `/images` becomes `/config/images`, `/cache` becomes `/config/cache`, or set `IMAGES_DIR`/`CACHE_DIR` and mount the old paths). Not privileged.

## 10. Risks, caveats and open questions

- Draft caveats confirmed: the `rembg` extra pulls onnxruntime and a model (the `u2net` weights are baked into the image at build, so the first request is not slow, but the image is large); the data directory is `/images` (draft said unknown).
- **Python version:** the repo base is Python 3.15.2 while upstream pins 3.12 and old wheels (`opencv-python-headless 4.10.0.84`, `nudenet 2.0.9`, `rembg 2.0.62`). Wheels for cp315 are UNVERIFIED and likely missing; the plan therefore lets `uv` install a managed 3.12. If the maintainers refuse a second interpreter, the alternative is to build against 3.15 and accept failures.
- Image build downloads `u2net` (HTTP) at build time; the build needs internet.
- `libmagickwand-dev` on Ubuntu 26.04 is ImageMagick 7, not 6; the upstream `ImageMagick-6/policy.xml` may need a different target directory or content (UNVERIFIED).
- `--limit-max-requests 200` makes uvicorn workers restart often; upstream design, keep.
- Draft listed port 8000: wrong, 5000 is correct.
- Blockers: none confirmed (glibc only, no GPU, no privileged; arm64 depends on ONNX/OpenCV wheels for aarch64, UNVERIFIED).

## 11. Build and test steps

```sh
cd apps/imgpush
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create imgpush-probe-config
docker run --rm -d --name imgpush-probe --read-only --tmpfs /tmp -v imgpush-probe-config:/config -p 5000:5000 imgpush:<sha>
docker logs -f imgpush-probe        # expect nginx start and "Application startup complete" from uvicorn, no tracebacks
curl -fsS localhost:5000/liveness   # 200
curl -fsS -F 'file=@some.jpg' localhost:5000/   # {"filename": ...}, file appears in /config/images
forgetool containers test --image imgpush:<sha> --config ./apps/imgpush/container-test.yaml
docker rm -f imgpush-probe; docker volume rm imgpush-probe-config
```
Readiness signal: uvicorn "Application startup complete" (UNVERIFIED exact wording for this version) and port 5000 open. Also exercise a resize request (`?w=100&h=100`) and, once, `ALLOW_REMOVE_BG=true` to prove the model loads read-only.

## 12. PR checklist

- Branch `feat/add-imgpush`; commit and PR title `feat(imgpush): add new container`; target `main`; use `.github/PULL_REQUEST_TEMPLATE.md`, only true boxes checked.
- `🤖 This PR is AI generated.` in the Notes section.
- CLA notice for the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Checklist: bake `--print` ok, bake `VERSION` and Dockerfile `ARG VERSION` aligned, final `USER apps`, `COPY --chmod=0755 . /`, empty `/config` start, read-only rootfs.
- Untested until run: image build, arm64, Python 3.12 via uv versus base 3.15, ImageMagick 7 policy, S3 backend, video and nudity filter paths. State this in the PR if not run.
