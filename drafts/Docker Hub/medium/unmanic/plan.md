# unmanic — implementation plan
> Source: ./draft.md · Target: apps/unmanic/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 0.4.1 (GitHub latest, published 2026-08-14T05:20:51Z; PyPI latest 0.4.1). Matches the draft and the chart image `josh5/unmanic:0.4.1`. |
| Renovate | `datasource=pypi depName=unmanic` (PyPI is the release channel for the wheel) |
| License | GPL-3.0-only (PyPI license field). GitHub reports `GPL-3.0`. Use `GPL-3.0-only` in bake, confirm against the repo LICENSE file in the PR. |
| Source URL | https://github.com/Unmanic/unmanic |
| Download amd64 | `unmanic-0.4.1-py3-none-any.whl`, sha256 `4237de63f9896a68097128baf399ee903a9fc24bb6b489d0c573317261d12e53` (https://pypi.org/pypi/unmanic/0.4.1/json). Pure Python, same file for both arches. |
| Download arm64 | Same wheel (arch-independent). |
| Source distribution | `unmanic-0.4.1.tar.gz`, sha256 `4c55a38c639da1d112ff45e97529e0b21e8da8ac80078408a1680e73794b0e47` (PyPI). Used for the LICENSE file (see section 4). |
| Checksum source | PyPI JSON `digests.sha256` (https://pypi.org/pypi/unmanic/0.4.1/json). No checksum asset on the GitHub release. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/Unmanic/unmanic/1c324b8/docker/Dockerfile (commit 1c324b8, not a tag). Single stage `FROM ubuntu:24.04`; Jellyfin ffmpeg 7 (x86 and aarch64), optional BtbN ffmpeg 8, Node.js 22, exiftool, jq, nano, sqlite3, git; Python venv `/opt/venv`; `pip install` of requirements and the wheel from `/src/*.whl`; `ENV HOME_DIR="/config"`, `VIRTUAL_ENV=/opt/venv`; `EXPOSE 8888/tcp`; no VOLUME, no USER (root); `ENTRYPOINT ["/entrypoint.sh"]`, `CMD ["/usr/bin/unmanic"]`. |
| Python deps | `requirements.txt` at 1c324b8: schedule==1.2.2, tornado==6.3.3, marshmallow~=3.22, peewee>=3.14.4, peewee_migrate==1.13.0, psutil~=6.0.0, requests>=2.28.2, requests_toolbelt>=0.9.1, py-cpuinfo>=7.0.0, JSON-log-formatter~=0.5.2, xxhash>=3.6.0. Optional: watchdog, sentry-sdk. |
| Published image | Docker Hub `josh5/unmanic:0.4.1`: amd64 (609217974 bytes) and arm64 (515125206 bytes). `copy-from arm64: no` in the draft is WRONG. This plan does not use `COPY --from`; the wheel is installed instead. |
| Data path | `HOME_DIR=/config` (upstream ENV). Chart: `/library` (PVC), `/tmp/unmanic/remote_library` (PVC), `/tmp/unmanic` (emptyDir). |

## 2. Target layout

- `apps/unmanic/Dockerfile`
- `apps/unmanic/docker-bake.hcl`
- `apps/unmanic/settings.yaml`
- `apps/unmanic/container-test.yaml`
- `apps/unmanic/start.sh`

No `defaults/`, `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). The upstream `docker/root` tree and init scripts are not copied: they are the upstream container's own init, and this container uses `start.sh` (start-script rule).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Fits because unmanic is a pure Python app: the python base provides `/app/venv`, which is installed into at build time (python-runtime rule: read-only at runtime, writable only during the build). Closest sibling: `apps/changedetection` (Python venv under `/app/venv`, `/config` as WORKDIR and VOLUME, `EXPOSE`). `apps/bazarr` is the other Python sibling (`ffmpeg` from apt, `USER apps`). UNVERIFIED: the python base's Ubuntu release and whether `ffmpeg` is in its apt index. Upstream needs Python tooling: `apps/changedetection` is the reference for `python3-venv` if the base lacks it.

PyPI `requires_python` for unmanic 0.4.1 is `>=3.8` (https://pypi.org/pypi/unmanic/0.4.1/json), so 3.15 is not excluded by metadata; dependency wheels on 3.15 are UNVERIFIED. Check with `/app/venv/bin/python -c` after install; if the wheel does not support 3.15, switch to a 3.14 base (`apps/changedetection` uses `python-node:3.14.8`), and say so in the PR.

## 4. Dockerfile

1. `FROM` line from section 3. `ARG VERSION`. `ARG TARGETARCH` only if needed (not needed: the wheel is arch-independent).
2. `ENV HOME_DIR=/config PYTHONUNBUFFERED=1 PIP_CACHE_DIR=/tmp/pip-cache`. `HOME_DIR` is the upstream value and is the path unmanic reads for its config and cache. The pip cache is set to `/tmp` (rule: caches never go to `/config`).
3. `USER root`.
4. `RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg exiftool sqlite3 && rm -rf /var/lib/apt/lists/*`. Upstream also installs jq, nano, git: UNVERIFIED need; leave out. `ffmpeg` is the distro package (Jellyfin ffmpeg is not used: it is x86 and aarch64 only and is an extra repo). Package versions are not pinned: ffmpeg is not tied to `VERSION`, so the pin rule does not apply; note in the PR.
5. Install the wheel, verifying the checksum:
   ```dockerfile
   RUN mkdir -p /tmp/unmanic-dist \
    && /app/venv/bin/pip download --no-deps --dest /tmp/unmanic-dist "unmanic==${VERSION}" \
    && /app/venv/bin/pip download --no-deps --no-binary :all: --dest /tmp/unmanic-dist "unmanic==${VERSION}" \
    && cd /tmp/unmanic-dist \
    && echo "4237de63f9896a68097128baf399ee903a9fc24bb6b489d0c573317261d12e53  unmanic-0.4.1-py3-none-any.whl" | sha256sum -c \
    && echo "4c55a38c639da1d112ff45e97529e0b21e8da8ac80078408a1680e73794b0e47  unmanic-0.4.1.tar.gz" | sha256sum -c \
    && /app/venv/bin/pip install --no-cache-dir unmanic-0.4.1-py3-none-any.whl
   ```
   The two checksum values are hard-coded for 0.4.1 (renovate bumps must update them: flag this in the PR). The sdist is used for the LICENSE file. UNVERIFIED: whether `pip download` of the sdist works with the base's pip version (fallback: `curl` the sdist from PyPI with its files URL).
6. License: extract `LICENSE` from the sdist to `/usr/share/licenses/unmanic/LICENSE` (UNVERIFIED that the sdist ships a LICENSE file at its root).
7. Cleanup: `rm -rf /tmp/unmanic-dist /tmp/pip-cache`.
8. `RUN chown -R root:root /app && chmod -R 755 /app` (venv stays read-only at runtime).
9. `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /config`, `EXPOSE 8888`, `VOLUME /config`.

Upstream `/app`, `/config`, `/tmp/unmanic` ownership (chowned to 1000:1000 upstream) is handled by `start.sh` at runtime (`mkdir -p /tmp/unmanic`), not by the Dockerfile.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "unmanic"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=unmanic
  default = "0.4.1"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/Unmanic/unmanic"
}
```
Then the standard `group "default"`, `target "image"`, `target "image-local"`, `target "image-all"` copied from `apps/changedetection/docker-bake.hcl`. Validate with `docker buildx bake --print`. `ARG VERSION` in the Dockerfile must equal this default. The checksum lines in section 4 must be updated together with `VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Unmanic/unmanic"
ports:
  - port: 8888
    protocol: tcp
    required: false
env:
  - name: HOME_DIR
    default: "/config"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: UMASK
    default: "002"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```
Notes: `HOME_DIR` is read by unmanic and set by the Dockerfile, so it is listed with the same default. The library path (`/library`) is user media and is not a ContainerForge volume; UNVERIFIED whether the schema allows a non-`/config` mount, so it stays out of `settings.yaml`. Dependencies: none (embedded SQLite via peewee).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config /tmp/unmanic

cd /config
exec /app/venv/bin/unmanic "$@"
```
Points to check: the console script name `unmanic` in `/app/venv/bin` is UNVERIFIED (upstream CMD is `/usr/bin/unmanic`, which implies the wheel provides a script named `unmanic`). If the wheel does not install that name, call `/app/venv/bin/python -m unmanic` after checking `__main__`. Idempotent: no seeding is needed if unmanic creates its own config on first run (UNVERIFIED: whether unmanic writes defaults itself on an empty `HOME_DIR`). Nothing writes to `/app`. Scratch goes to `/tmp/unmanic`. The web server must bind all interfaces (UNVERIFIED default; check with a probe from outside the container).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8888'
http:
- port: '8888'
  path: /
filePaths:
- /app/venv/bin/unmanic
- /usr/share/licenses/unmanic/LICENSE
```
`timeoutSeconds: 180` matches `apps/changedetection` (Python web app start). The `http` path `/` is UNVERIFIED: confirm the status code during the run (use a path that returns 200 if `/` redirects, and record it). `filePaths` entry for the console script is UNVERIFIED (section 7).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `HOME_DIR=/config` (config, cache, data) | kept: `/config` is persistent. |
| `/tmp/unmanic` (chart emptyDir: transcode scratch) | `/tmp/unmanic` on the `--tmpfs /tmp` mount; `start.sh` creates it. |
| `/tmp/unmanic/remote_library` (chart PVC) | not in ContainerForge: a user path under `/tmp` would be lost on restart. Drop unless UNVERIFIED unmanic code needs it; document in the PR. |
| `/library` (chart PVC: media library) | user bind mount; not remapped. |
| `/app` (upstream chown to 1000:1000, the venv) | build-time only; root-owned and read-only at runtime. |
| pip / build caches | `/tmp` (`PIP_CACHE_DIR`) during build; removed. |

Draft expectations reconciled:
- Chart: `runAsUser 568`, `readOnlyRootFilesystem: true`, not privileged. Image: `USER apps`, read-only rootfs compatible per the protocol run. Upstream image runs as root by default; this image does not.
- Chart `extra-persistence` for `/tmp/unmanic/remote_library` is dropped (section 9 row 2) because `/tmp` is not persistent.

## 10. Risks, caveats and open questions

- Transcoding is CPU and disk heavy. A large library needs scratch space in `/tmp/unmanic`, which is a tmpfs under the protocol run, so the real run size is limited by RAM. Document it.
- Hardware acceleration (VA-API, Vulkan, NVIDIA) is in upstream but not in this default build (draft caveat). No GPU is in the default setup.
- Library cache and temp are split between `/config` and `/tmp`. Both must be writable: `/config` is the persistent volume, `/tmp` the tmpfs.
- The checksum values are hard-coded per version; renovate bumps must update `VERSION` and the two sha256 lines together. The PR must say so.
- Distro ffmpeg instead of Jellyfin ffmpeg: transcode behaviour is UNVERIFIED on the chosen build.
- Python 3.15 support is UNVERIFIED (section 3).
- Blockers: none known (pure Python, no GPU required, no privileged need, arm64 is the same wheel).

## 11. Build and test steps

```sh
cd apps/unmanic
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name unmanic-probe --read-only --tmpfs /tmp \
  -v unmanic-probe-config:/config unmanic:0.4.1
docker logs -f unmanic-probe
forgetool containers test --image unmanic:0.4.1 --config ./apps/unmanic/container-test.yaml
docker rm -f unmanic-probe; docker volume rm unmanic-probe-config
```
Expected readiness signal: UNVERIFIED exact log line; look for the web server start on port 8888 (tornado) and the process staying alive. Confirm that `/config` has the unmanic data after start and that a restart keeps it. Probe 8888 from the host with `-p 8888:8888`.

## 12. PR checklist

- Branch `feat/add-unmanic`; commit and PR title `feat(unmanic): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Say what was not tested: arm64 run, transcode with distro ffmpeg, Python 3.15 compatibility until built, the console script name, the HTTP probe status.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; checksum lines match the PyPI digests; no test assertion was weakened.
- Downstream: not used as a `FROM` base, so no `DOWNSTREAM_CHANGES.md`.
