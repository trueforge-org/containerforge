# wyoming-whisper — implementation plan
> Source: ./draft.md · Target: apps/wyoming-whisper/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Upstream | https://github.com/rhasspy/wyoming-faster-whisper |
| Latest stable | `v3.9.1` (tags v3.8.1, v3.9.0, v3.9.1; PyPI `wyoming-faster-whisper` `3.9.1`). Matches the draft chart tag `3.9.1` |
| Existing overlap | `apps/faster-whisper` already installs `wyoming-faster-whisper` (`git+...@v${VERSION}`) on port 10300, but its `VERSION` tracks `SYSTRAN/faster-whisper` (`3.0.2`), which is not the wrapper's version. Decide first: (a) fix `apps/faster-whisper` instead of adding an app, or (b) add `wyoming-whisper` as below. This plan covers (b) |
| Renovate | `datasource=github-releases depName=rhasspy/wyoming-faster-whisper extractVersion=^v(?<version>.+)$ versioning=semver` (or `datasource=pypi depName=wyoming-faster-whisper`, which is simpler since the build installs from PyPI) |
| License | MIT (`pyproject.toml` `license = {text = "MIT"}`, `LICENSE.md` at repo root) |
| Install | `pip install wyoming-faster-whisper==3.9.1` from PyPI (pure Python wrapper). Requires `wyoming>=1.10.2,<2`, `faster-whisper>=1.2.1,<2`, `av>=11,<19`, `pysilero-vad>=3.4.0,<4`. No separate binary, no checksum file; pip verifies the index hashes only if `--require-hashes` is used (not planned) |
| Wheels | `ctranslate2` 4.9.1 has cp39 to cp315 wheels. `av` 19.0.2 (latest, outside the `<19` range) shows only cp312 and cp314 in the latest-release file list; the pinned `<19` releases were not inspected. `pysilero-vad` 3.4.1 shows a cp39-tagged wheel only (likely abi3, UNVERIFIED). Hence the Python 3.14 base, as used by `apps/faster-whisper` |
| Upstream Dockerfile reviewed | `1c40710`: debian:bookworm-slim, venv `/usr/src/.venv`, installs torch 2.6.0 CPU and extras `zeroconf,transformers,sherpa,onnx-asr,qwen3-asr,hass`, `ENV HF_HOME=/data XDG_CACHE_HOME=/data MODELSCOPE_CACHE=/data/modelscope`, `EXPOSE 10300`, healthcheck `python -m wyoming_faster_whisper.health_check` (5 min start period) |
| `docker_run.sh` (v3.9.1) | Defaults `--uri tcp://0.0.0.0:10300`, `--data-dir /data`, `--device ${STT_DEVICE:-cpu}`, then `"$@"` |
| Env vars | Every CLI option is also read from `WYO_WHISPER_<OPTION>` (and `WYO_WHISPER_<OPTION>_FILE`), e.g. `WYO_WHISPER_MODEL`, `WYO_WHISPER_LANGUAGE`, `WYO_WHISPER_BEAM_SIZE`, `WYO_WHISPER_DEVICE`, `WYO_WHISPER_COMPUTE_TYPE`, `WYO_WHISPER_CPU_THREADS` (`env_args.py`: `ENV_PREFIX = "WYO_WHISPER_"`). Command-line arguments win |
| CLI (`__main__.py`) | `--uri` (required), `--zeroconf`, `--model` (default `auto`), `--data-dir` (required, repeatable), `--download-dir`, `--device` (cpu), `--language` (auto), `--compute-type` (default), `--beam-size` (0=auto), `--cpu-threads` (4), `--initial-prompt`, `--whisper-task`, `--vad-*`, `--stt-library`, `--sherpa-streaming`, `--local-files-only`, `--hass-*`, `--debug`, `--log-format`, `--version` |
| Port | `10300/tcp` |
| Model download | The server only starts listening after the model is loaded, which downloads it on first run (upstream comment). The sibling uses `tiny-int8`; UNVERIFIED that this name is still accepted by 3.9.1 (check `--model` help during build) |

## 2. Target layout

```
apps/wyoming-whisper/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`, no `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232`

Why: copied from `apps/faster-whisper`, which stays on 3.14 for native wheel availability (comment: "stay on python 3.14 until ctranslate2 publishes cp315 wheels"). `ctranslate2` now has cp315 wheels, but `av` and `pysilero-vad` were not confirmed, so keep 3.14.8 and re-evaluate with the brief's 3.15.2 base (`...python:3.15.2@sha256:064e0c7d...`) in a later PR. Closest sibling: `apps/faster-whisper`.

## 4. Dockerfile

1. Comment line `# stay on python 3.14 until av and pysilero-vad publish cp315 wheels (UNVERIFIED, re-check)`.
2. `ARG VERSION`, `USER root`.
3. `ENV HOME=/config HF_HOME=/tmp/hf XDG_CACHE_HOME=/tmp/cache PYTHONDONTWRITEBYTECODE=1` (Hugging Face and Xet caches are scratch and go to `/tmp`; the models themselves go to `/config` through `--download-dir`).
4. No apt packages. `build-essential`/`git` as in the sibling are not needed because the install is from PyPI wheels; only add `build-essential` if a dependency has no wheel for an arch.
5. One `RUN`: `/app/venv/bin/pip install --no-cache-dir "wyoming-faster-whisper==${VERSION}"`; copy the license: `curl -fsSL https://raw.githubusercontent.com/rhasspy/wyoming-faster-whisper/v${VERSION}/LICENSE.md -o /usr/share/licenses/wyoming-whisper/LICENSE.md` (after `mkdir -p`); `cp /etc/ssl/certs/ca-certificates.crt /etc/ca-certificates.crt && chmod 644 /etc/ca-certificates.crt` (as the sibling, for Hugging Face downloads); `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /root/.cache /tmp/*`.
6. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 10300`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "wyoming-whisper" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=rhasspy/wyoming-faster-whisper extractVersion=^v(?<version>.+)$ versioning=semver
  default = "3.9.1"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE"  { default = "https://github.com/rhasspy/wyoming-faster-whisper" }
```

Standard targets as in `apps/faster-whisper/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/rhasspy/wyoming-faster-whisper"`.
- `ports`: `10300` / `tcp` / `required: false`.
- `env` (all `required: false`; defaults match `start.sh`): `WYO_WHISPER_MODEL` `tiny-int8`, `WYO_WHISPER_LANGUAGE` `en`, `WYO_WHISPER_BEAM_SIZE` `1`, `WYO_WHISPER_DEVICE` `cpu`, `WYO_WHISPER_COMPUTE_TYPE` `default`, `WYO_WHISPER_CPU_THREADS` `4`, `LOCAL_ONLY` `""` (maps to `--local-files-only`), `TZ` `Etc/UTC`.
- `volumes`: `/config` / `required: true` (models).
- `dependencies`: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
CA_BUNDLE_PATH="/etc/ca-certificates.crt"
export SSL_CERT_FILE="$CA_BUNDLE_PATH" CURL_CA_BUNDLE="$CA_BUNDLE_PATH" REQUESTS_CA_BUNDLE="$CA_BUNDLE_PATH"
export WYO_WHISPER_MODEL="${WYO_WHISPER_MODEL:-tiny-int8}"
export WYO_WHISPER_BEAM_SIZE="${WYO_WHISPER_BEAM_SIZE:-1}"
export WYO_WHISPER_LANGUAGE="${WYO_WHISPER_LANGUAGE:-en}"
exec /app/venv/bin/python -m wyoming_faster_whisper \
  --uri 'tcp://0.0.0.0:10300' \
  --data-dir /config \
  --download-dir /config \
  ${LOCAL_ONLY:+--local-files-only}
```

Other `WYO_WHISPER_*` variables are read by the app itself, so no mapping is needed (note: `--uri`, `--data-dir` stay on the command line and win over their env vars). Idempotent; first start downloads the model into `/config`, later starts reuse it; nothing is written to `/app`; binds `0.0.0.0`; final `exec`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '10300'
filePaths:
- /usr/share/licenses/wyoming-whisper/LICENSE.md
```

`timeoutSeconds` is long because the port opens only after the model download (look at `apps/faster-whisper/container-test.yaml`, which sets none, so confirm what the runner default allows; if CI has no internet, start with `LOCAL_ONLY` is not possible without env, so this needs a decision). Not a DB app, so no narrowing.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | Remap |
| --- | --- |
| Models and caches in `/data` (`HF_HOME`, `XDG_CACHE_HOME`) | Models in `/config` (`--download-dir`), `HF_HOME=/tmp/hf`, `XDG_CACHE_HOME=/tmp/cache` |
| Chart mounts `/.cache/huggingface` (pvc) | Not needed; cache is in `/tmp` |
| venv in `/usr/src/.venv` | Bundled read-only `/app/venv` |
| Chart UID 568, read-only rootfs | `USER apps`, `--read-only --tmpfs /tmp` |

## 10. Risks, caveats and open questions

- Overlap with `apps/faster-whisper` (see section 1). Recommend fixing that app's version tracking instead if maintainers prefer one image.
- The test depends on a model download at first start; CI network access is UNVERIFIED.
- Wheel availability for `av` and `pysilero-vad` on cp315/arm64 UNVERIFIED.
- Heavy RAM and CPU for medium and larger models; no GPU support in this image (`ctranslate2` CPU wheels only). The upstream GPU image is out of scope.
- Upstream's extras (`transformers`, `sherpa`, `onnx-asr`, `qwen3-asr`, torch) are deliberately not installed; Home Assistant's default faster-whisper path needs none of them. Selecting those backends via `--stt-library` will fail.
- Models in `/config`, cache in `/tmp`: the Xet chunk cache re-downloads after restart only if a download is interrupted.

## 11. Build and test steps

```sh
cd apps/wyoming-whisper
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name wyoming-whisper-probe --read-only --tmpfs /tmp -v wyoming-whisper-probe-config:/config wyoming-whisper:3.9.1
docker logs -f wyoming-whisper-probe   # expect the model download, then a listening/ready line for tcp://0.0.0.0:10300 (exact text UNVERIFIED); container stays up
docker rm -f wyoming-whisper-probe; docker volume rm wyoming-whisper-probe-config
forgetool containers test --image wyoming-whisper:3.9.1 --config ./apps/wyoming-whisper/container-test.yaml
```

Run a second start on the same volume to confirm the model is reused offline (`-e LOCAL_ONLY=1`).

## 12. PR checklist

- Branch `feat/add-wyoming-whisper`, commit and title `feat(wyoming-whisper): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested until implemented: build on both arches, model name `tiny-int8`, offline restart, Home Assistant integration.
- Do not tick "Built container locally" unless it was built.
