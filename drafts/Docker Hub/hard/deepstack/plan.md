# deepstack — implementation plan
> Source: ./draft.md · Target: apps/deepstack/ · Difficulty: hard (likely blocked) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `2022.01.1` (latest release `DeepStack 2022.01.1 Release`, 2022-01-22; Docker tags `cpu-2022.01.1`, `gpu-2022.01.1`, `arm64-2022.01.1`, `arm64-server-2022.01.1`; Jetson is `jetpack-2021.01.1` per the release notes, all 2022-01-16 except as noted). Same as the draft. Project is unmaintained since January 2022. |
| Renovate | `datasource=github-releases depName=johnolafenwa/DeepStack versioning=loose` (the git tag is `2022.01.1`; release title is "DeepStack 2022.01.1 Release"; use `docker` datasource `docker.io/deepquestai/deepstack` with `versioning=loose` if the GitHub tag does not match). |
| License | `Apache-2.0` for the code (LICENSE is Apache 2.0). License of the model weights (`yolov5m.pt`, `face.pt`, `facerec-high.model`, `scene.pt`, `bebygan_x4.pth`) is UNVERIFIED. |
| Source | https://github.com/johnolafenwa/DeepStack |
| Upstream Dockerfile | `Dockerfile.cpu` at the draft's commit `73b6f7a` reviewed: `FROM deepquestai/deepstack-base:cpu-1647248158`, `ENV SLEEP_TIME 0.01 TIMEOUT 60 SEND_LOGS True CUDA_MODE False APPDIR /app DATA_DIR /datastore TEMP_PATH /deeptemp/ PROFILE desktop_cpu`, Go 1.17.6 amd64 tarball, `pip install onnxruntime==0.4.0 redis opencv-python Cython pillow scipy tqdm tensorboard PyYAML Matplotlib easydict future numpy`, COPY of `./sharedfiles/*` model files, `./server` built with `go build` to `/app/server/server`, `./intelligencelayer`, `init.py`, `EXPOSE 5000`, `CMD ["/app/server/server"]`. `base/Dockerfile.cpu`: `FROM python:3.7`, `apt-get install redis-server libsm6 libxext6 libxrender1 libglib2.0-0 ffmpeg`. The real `torch` pin is in `requirements.txt` (README: `torch==1.6.0+cpu`, `torchvision==0.7.0+cpu`, Python 3.7). |
| Binary / artifacts | No release binary (draft `-`). The upstream README says `git lfs pull` fetches the large repo files, and `Dockerfile.cpu` COPYs `./sharedfiles/*.pt` from the repo, so the weights may be in the repo as LFS objects (UNVERIFIED: `.gitattributes` could not be read). The earlier note that they are not in the repo is not confirmed. Separately, `download_dependencies.py` fetches `https://deepquest.sfo2.digitaloceanspaces.com/deepstack/shared-files/sharedfiles.zip` (and `interpreter.zip`, `redis.zip`), which now returns HTTP 403. Only the published Docker image still contains them. |
| Runtime (from `server/server.go`) | Go server on `PORT` (default 5000), talks to a local Redis (`go-redis`) and Python workers in `/app/intelligencelayer`. Env: `VISION-FACE`, `VISION-DETECTION`, `VISION-SCENE`, `VISION-ENHANCE`, `VISION-CUSTOM` (hyphenated names, not valid shell identifiers), `VISION_FACE`, `VISION_DETECTION`, `VISION_SCENE`, `VISION_ENHANCE`, `API-KEY`, `ADMIN-KEY`, `SEND-LOGS`, `MODE` (`Low`/`Medium`/`High`, default Medium), `PORT`, `TIMEOUT`, `THREADCOUNT`, `PROFILE`, `APPDIR`, `DATA_DIR`, `TEMP_PATH`. Custom models are read from `/modelstore/detection/`; data (sqlite `faceembedding.db`) in `DATA_DIR` (`/datastore`). |
| Arch | Docker Hub `cpu-2022.01.1` is amd64 only; separate `arm64-2022.01.1` image exists (different Dockerfile `Dockerfile.arm64-cpu`). |

## 2. Target layout

```
apps/deepstack/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`. Never `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

The Go server needs a Go build stage (`FROM golang:1.17` equivalent, copy the exact `golang` FROM line style from an existing `apps/*/Dockerfile` with a Go build stage), the final stage `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. Problem: DeepStack's Python workers need Python 3.7 with `torch==1.6.0`, which cannot be installed on Python 3.15. Therefore a realistic base choice is `ghcr.io/trueforge-org/ubuntu` and take the Python stack from the published image (see section 4). Closest sibling: none (legacy ML stack); use `apps/faster-whisper` for the ML-in-container pattern and `apps/adguardhome-sync` for the layout.

## 4. Dockerfile

Only one workable route exists because the weights are unreachable and the stack is frozen:

1. (Superseded by step 3: the ubuntu-based route is not workable; kept as the first idea.) `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`; `ARG VERSION`, `ARG TARGETARCH`; `USER root`.
2. Stage `FROM docker.io/deepquestai/deepstack:cpu-${VERSION}@sha256:<digest> AS upstream` (digest UNVERIFIED: resolve with `docker buildx imagetools inspect`). `COPY --from=upstream /app/sharedfiles /app/sharedfiles`, `/app/intelligencelayer`, `/app/init.py`, `/app/server/server` (the compiled Go binary; path from `Dockerfile.cpu` WORKDIR `/app/server` + `go build`; draft says path unverified, check with `docker run --rm --entrypoint ls ... /app/server`).
3. Python: the upstream image's Python 3.7 + torch 1.6 + site-packages live in the base's `/usr/local`. Copying them across distros is fragile. Alternative: build a venv with a Python 3.7-compatible interpreter, which Ubuntu 26.04 does not ship. Decision: this port needs either (a) `FROM docker.io/deepquestai/deepstack:cpu-2022.01.1` directly (Debian, root, Python 3.7), which breaks the "ubuntu base" convention, or (b) rewrite the intelligence layer for modern torch (out of scope). The plan therefore marks this as BLOCKED pending a maintainer decision (section 10) and sketches (a):
   - `FROM docker.io/deepquestai/deepstack:cpu-2022.01.1@sha256:4320be73987468b3040b2ca63daf2d3935c4d469b53aa40efb6176858488b500` (digest from the TrueCharts chart; re-check with `docker buildx imagetools inspect`), `USER root`, create `apps` user UID/GID 568 (`groupadd -g 568 apps && useradd -u 568 -g 568 -d /config -s /bin/bash apps`), `mkdir -p /config /datastore /deeptemp /modelstore/detection`, `chown -R apps:apps` on those, `chmod -R a+rX /app`.
4. `ENV HOME=/config DATA_DIR=/config/datastore TEMP_PATH=/tmp/deeptemp/ APPDIR=/app PROFILE=desktop_cpu CUDA_MODE=False SEND_LOGS=False TIMEOUT=60 SLEEP_TIME=0.01 PORT=5000` (values from upstream Dockerfile, `DATA_DIR`/`TEMP_PATH` remapped, `SEND_LOGS` turned off to avoid telemetry; UNVERIFIED what it sends).
5. Licenses: `mkdir -p /usr/share/licenses/deepstack && cp /app/LICENSE /usr/share/licenses/deepstack/` if present, otherwise download `https://raw.githubusercontent.com/johnolafenwa/DeepStack/73b6f7ab0f9a8acc8f7a49c6f13594fe470de042/LICENSE` with a pinned sha256.
6. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 5000`, `VOLUME /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "deepstack" }
variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/deepquestai/deepstack versioning=loose
  default = "2022.01.1"
}
variable "LICENSE" { default = "Apache-2.0" }
variable "SOURCE"  { default = "https://github.com/johnolafenwa/DeepStack" }
```
The Dockerfile references `cpu-${VERSION}`; UNVERIFIED that the renovate docker datasource with `loose` versioning handles the `cpu-` prefix of tags (may need `extractVersion`). Standard four targets; `image-all` must be amd64 only (`platforms = ["linux/amd64"]`) because `cpu-2022.01.1` is amd64 only; document it. Run `docker buildx bake --print`.

## 6. settings.yaml

Header + `schema_version: 1`; `upstream_env_url: "https://github.com/johnolafenwa/DeepStack"`.
- ports: `5000` tcp required.
- env (names exactly as the server reads them; hyphenated ones are passed with `env`, see start.sh): `VISION-DETECTION` (`False`), `VISION-FACE` (`False`), `VISION-SCENE` (`False`), `VISION-ENHANCE` (`False`), `VISION-CUSTOM` (`False`? UNVERIFIED default semantic), `API-KEY` (`""`), `ADMIN-KEY` (`""`), `MODE` (`Medium`), `THREADCOUNT` (default unknown, UNVERIFIED, omit), `TZ`. Upstream also accepts underscore forms `VISION_*`; list only the hyphenated ones the README documents.
- volumes: `/config` (required: datastore with face embeddings), plus `/modelstore/detection` (required: false, custom models).
- dependencies: none (Redis runs inside the container).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -e
mkdir -p /config/datastore /tmp/deeptemp
cd /app
python3 /app/init.py            # creates faceembedding.db tables in DATA_DIR (UNVERIFIED: confirm init.py is idempotent)
# Redis: UNVERIFIED whether the server binary starts it; if not, add before exec:
# redis-server --port 6379 --bind 127.0.0.1 --dir /tmp --save "" --appendonly no --daemonize yes
cd /app/server
exec /app/server/server
```
Hyphenated variables cannot be exported by bash by name. Rule: `docker run -e VISION-DETECTION=True` already works because Docker sets the process environment directly, so `start.sh` must not re-map them; it should only `exec` the server. Keep this script minimal: `init.py`, optional Redis, `exec /app/server/server`. UNVERIFIED how upstream starts Redis and the Python workers (likely the Go server spawns `redis-server` and `python3 intelligencelayer/shared/*.py`); confirm by reading `server/server.go` `startRedis`-like functions and from a test run.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '5000'
filePaths:
- /app/server/server
- /app/sharedfiles
- /usr/share/licenses/deepstack
```
No `http` probe: with no `VISION-*` env set, the server answers 404/`{"success":false}` on `/`, so a path probe may fail; use `tcp` only (UNVERIFIED which path returns 200; try `/v1/vision/detection` with POST not supported by the test schema). Generous `timeoutSeconds` (model load and Redis start).

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes: `DATA_DIR` `/datastore` (sqlite, face DB), `TEMP_PATH` `/deeptemp/` (uploaded images), `/modelstore/` (read), Redis dump (`/var/lib/redis` or cwd), `__pycache__` under `/app`, Matplotlib/torch caches under `$HOME`. Remap: `DATA_DIR=/config/datastore`, `TEMP_PATH=/tmp/deeptemp/`, `HOME=/config`, `XDG_CACHE_HOME=/tmp/cache`, `MPLCONFIGDIR=/tmp/mpl`, `TORCH_HOME=/tmp/torch`, `PYTHONDONTWRITEBYTECODE=1`, Redis with `--save "" --appendonly no --dir /tmp`.
- Draft: root (0), no read-only rootfs, persistence `/datastore` and `/modelstore/detection`. Reconcile: UID 568, read-only rootfs, `/datastore` becomes `/config/datastore` (document the volume move for TrueCharts users) and `/modelstore/detection` stays a read-only user mount.
- Not privileged; GPU variant is out of scope.

## 10. Risks, caveats and open questions

- BLOCKER (recommended: do not port as a ContainerForge ubuntu image): (1) the model weights are only available inside the 2022 Docker image (download host returns 403), so the build depends on `docker.io/deepquestai/deepstack`; (2) the Python stack is Python 3.7 + torch 1.6 + onnxruntime 0.4.0 which cannot run on the repo's Python 3.15 or ubuntu 26.04 userland; (3) unmaintained, no security fixes, upstream base image `python:3.7` is EOL.
- If a maintainer still wants it: FROM the published image (section 4 option a), amd64 only, record the exact digest, expect a large image (multi-GB).
- Weights license is UNVERIFIED; redistribution through ghcr.io may be a problem.
- `SEND_LOGS=True` default sends data to a DeepStack service; set false.
- Environment variable names contain hyphens, which break shell-based tooling (settings schema must accept them; verify the forgetool schema pattern before writing `settings.yaml`).
- Downstream: not a `FROM` base, no `DOWNSTREAM_CHANGES.md`.
- Alternative project: CodeProject.AI Server (also in this batch) replaces DeepStack for most users.

## 11. Build and test steps

```sh
cd apps/deepstack
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name deepstack-probe --read-only --tmpfs /tmp \
  -v deepstack-probe-config:/config -e VISION-DETECTION=True deepstack:2022.01.1
docker logs -f deepstack-probe   # expect the Go server to listen on :5000 and the Redis/Python workers to start; no "Read-only file system"
forgetool containers test --image deepstack:2022.01.1 --config ./apps/deepstack/container-test.yaml
docker rm -f deepstack-probe; docker volume rm deepstack-probe-config
```
Also run once with an empty `/config` and no env (the test harness case). Do not attempt arm64.

## 12. PR checklist

- Branch `feat/add-deepstack`; commit and PR title `feat(deepstack): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes.
- CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State prominently: not built here; depends on a third-party 2022 image; amd64 only; weights license unverified; read-only rootfs run and Redis/Python worker start untested.
