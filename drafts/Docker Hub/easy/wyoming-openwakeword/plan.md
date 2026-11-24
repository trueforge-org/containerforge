# wyoming-openwakeword — implementation plan
> Source: ./draft.md · Target: apps/wyoming-openwakeword/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Upstream | https://github.com/rhasspy/wyoming-openwakeword |
| Latest stable | `v2.1.0` (tags v1.10.0, v2.0.0, v2.1.0 via `git ls-remote`; `pyproject.toml` `version = "2.1.0"`). Matches the draft tag `2.1.0` |
| PyPI trap | PyPI `wyoming-openwakeword` is stale (`1.8.2`, pins `wyoming==1.2.0`, `tflite-runtime-nightly`). Do NOT `pip install wyoming-openwakeword`. Install the GitHub tag tarball instead |
| Renovate | `datasource=github-tags depName=rhasspy/wyoming-openwakeword versioning=semver` with `extractVersion=^v(?<version>.+)$` (tags carry a `v`); `github-releases` also works if releases exist (UNVERIFIED) |
| License | Apache-2.0 (`pyproject.toml` `license = {text = "Apache-2.0"}`; `LICENSE` file exists at repo root) |
| Source archive | `https://github.com/rhasspy/wyoming-openwakeword/archive/refs/tags/v2.1.0.tar.gz` (pure Python, arch independent) |
| Checksum source | None published by upstream. The tag is pinned in the URL. UNVERIFIED: a tarball sha256 can be recorded as an ARG if the maintainers want one |
| Dependencies | `pyopen-wakeword>=1,<2` (latest 1.1.0, Apache-2.0, `py3-none` wheels `manylinux_2_35_x86_64` and `manylinux_2_35_aarch64`, about 7 MB, which bundle the built-in models, so no model download is expected: UNVERIFIED by inspection) and `wyoming>=1.8,<2`. Ubuntu 26.04 glibc satisfies manylinux_2_35 |
| Upstream Dockerfile reviewed | `456fdcc` (debian:bookworm-slim, venv in `/usr/src/.venv`, `pip install -e .`, `EXPOSE 10400`, `ENTRYPOINT bash docker_run.sh`). `docker_run.sh`: `python3 -m wyoming_openwakeword --uri 'tcp://0.0.0.0:10400' "$@"` |
| Port | `10400/tcp` (Wyoming) |
| CLI flags (`__main__.py`) | `--uri` (default `stdio://`), `--custom-model-dir` (repeatable), `--threshold` (0.5), `--trigger-level` (1), `--refractory-seconds` (2.0), `--zeroconf [name]`, `--debug`, `--log-format`, `--version`. Deprecated and ignored: `--model`, `--models-dir`, `--preload-model`, `--output-dir`, `--debug-probability` |
| Env vars | Upstream reads none. Wrapper variables defined here: `OWW_THRESHOLD`, `OWW_TRIGGER_LEVEL`, `OWW_REFRACTORY_SECONDS`, `OWW_DEBUG`, `OWW_CUSTOM_MODEL_DIR` |
| Custom models | `.tflite` files in a directory passed with `--custom-model-dir` (README example mounts `/custom`) |

## 2. Target layout

```
apps/wyoming-openwakeword/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/` (no seed files are needed). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Why: pure Python Wyoming server; `numpy` has cp315 wheels in general (UNVERIFIED on both arches). Closest siblings: `apps/piper` and `apps/faster-whisper` (same Wyoming pattern). Both sit on `python:3.14.8` because of native wheel gaps; if `numpy` or `wyoming` deps lack cp315 wheels, use the same 3.14.8 digest those apps use (`ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232`) with a comment.

## 4. Dockerfile

1. `ARG VERSION`, `USER root`, `ENV HOME=/config PIP_NO_CACHE_DIR=1` (the base already sets pip env; caches stay in `/tmp`).
2. No apt packages (wheels are self-contained).
3. One `RUN`:
   - `mkdir -p /tmp/oww /usr/share/licenses/wyoming-openwakeword`
   - `curl -fsSL "https://github.com/rhasspy/wyoming-openwakeword/archive/refs/tags/v${VERSION}.tar.gz" | tar xz -C /tmp/oww --strip-components=1`
   - `/app/venv/bin/pip install --no-cache-dir /tmp/oww` (non-editable, so nothing depends on `/tmp`)
   - `cp /tmp/oww/LICENSE /usr/share/licenses/wyoming-openwakeword/LICENSE`
   - `chown -R apps:apps /app && chmod -R 755 /app && rm -rf /tmp/* /root/.cache`
4. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 10400`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "wyoming-openwakeword" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=rhasspy/wyoming-openwakeword extractVersion=^v(?<version>.+)$ versioning=semver
  default = "2.1.0"
}
variable "LICENSE" { default = "Apache-2.0" }
variable "SOURCE"  { default = "https://github.com/rhasspy/wyoming-openwakeword" }
```

Standard targets as in `apps/piper/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/rhasspy/wyoming-openwakeword"`.
- `ports`: `10400` / `tcp` / `required: false`.
- `env` (all `required: false`, defaults equal `start.sh`): `OWW_THRESHOLD` `0.5`, `OWW_TRIGGER_LEVEL` `1`, `OWW_REFRACTORY_SECONDS` `2`, `OWW_CUSTOM_MODEL_DIR` `/config/custom`, `OWW_DEBUG` `""`, `TZ` `Etc/UTC`.
- `volumes`: `/config` / `required: false` (only custom models live there).
- `dependencies`: none (the Wyoming client, for example `home-assistant`, is a consumer, not a dependency).

## 7. start.sh

```bash
#!/usr/bin/env bash
mkdir -p "${OWW_CUSTOM_MODEL_DIR:-/config/custom}"
exec /app/venv/bin/python -m wyoming_openwakeword \
  --uri 'tcp://0.0.0.0:10400' \
  --custom-model-dir "${OWW_CUSTOM_MODEL_DIR:-/config/custom}" \
  --threshold "${OWW_THRESHOLD:-0.5}" \
  --trigger-level "${OWW_TRIGGER_LEVEL:-1}" \
  --refractory-seconds "${OWW_REFRACTORY_SECONDS:-2}" \
  ${OWW_DEBUG:+--debug}
```

Idempotent, writes only to `/config/custom` (created if missing, never overwritten), nothing to `/app`, binds `0.0.0.0`, final `exec`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '10400'
filePaths:
- /usr/share/licenses/wyoming-openwakeword/LICENSE
```

Copy `timeoutSeconds` from `apps/piper` if it sets one. No DB dependency, so the narrowing exception does not apply.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | Remap |
| --- | --- |
| venv and source in `/usr/src` | Installed into the bundled read-only `/app/venv` |
| Models bundled in `pyopen-wakeword` | Read from site-packages, no writes |
| Custom models via an arbitrary mount (`/custom`) | `/config/custom` (default), configurable |
| Chart: UID 568, read-only rootfs, only `/config` persistent | Same: `USER apps`, `--read-only --tmpfs /tmp` |
| Python bytecode / pip cache | `PYTHONDONTWRITEBYTECODE=1`, pip cache disabled |

## 10. Risks, caveats and open questions

- The draft's "models downloaded at runtime" is probably wrong for v2.x, since the models ship in `pyopen-wakeword`; confirm that the first start works offline (step 11).
- PyPI package is stale; the build must use the GitHub tarball. Renovate must watch tags, not PyPI.
- cp315 wheel coverage for `numpy` (and `wyoming` deps) on arm64 is UNVERIFIED; fall back to the 3.14.8 base if needed.
- Useless without a Wyoming client such as Home Assistant.
- The `OWW_*` names are wrapper conventions, not upstream env vars.

## 11. Build and test steps

```sh
cd apps/wyoming-openwakeword
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name wyoming-openwakeword-probe --read-only --tmpfs /tmp -v wyoming-openwakeword-probe-config:/config wyoming-openwakeword:2.1.0
docker logs -f wyoming-openwakeword-probe   # expect a Ready / listening log line for tcp://0.0.0.0:10400 (exact text UNVERIFIED) and the container staying up
docker rm -f wyoming-openwakeword-probe; docker volume rm wyoming-openwakeword-probe-config
forgetool containers test --image wyoming-openwakeword:2.1.0 --config ./apps/wyoming-openwakeword/container-test.yaml
```

Manual extra: connect with a Wyoming `describe` request (or Home Assistant) and confirm the built-in wake words are listed.

## 12. PR checklist

- Branch `feat/add-wyoming-openwakeword`, commit and title `feat(wyoming-openwakeword): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested until implemented: build on both arches, Python 3.15 wheels, offline start, custom model loading, Home Assistant connection.
- Do not tick "Built container locally" unless it was built.
