# rhasspy/wyoming-openwakeword

Source URL(s) + fetch date: https://github.com/rhasspy/wyoming-openwakeword · https://raw.githubusercontent.com/rhasspy/wyoming-openwakeword/v2.1.0/README.md · https://raw.githubusercontent.com/rhasspy/wyoming-openwakeword/v2.1.0/Dockerfile · https://raw.githubusercontent.com/rhasspy/wyoming-openwakeword/v2.1.0/pyproject.toml · https://raw.githubusercontent.com/rhasspy/wyoming-openwakeword/v2.1.0/wyoming_openwakeword/__main__.py · fetched 2026-11-26

## What it is
- Wyoming protocol server wrapping openWakeWord wake word detection. Also a Home Assistant add-on (see home-assistant-addons section below).

## Install/build steps and build deps
- Upstream Dockerfile at v2.1.0 (the draft points to blob 456fdcc, same layout per plan.md; the fetch used the v2.1.0 tag):
  - `FROM debian:bookworm-slim`, `ARG TARGETARCH`, `ARG TARGETVARIANT`, `WORKDIR /usr/src`, `COPY ./ ./`.
  - `apt-get install --no-install-recommends python3 python3-pip python3-venv`; `python3 -m venv .venv`; `.venv/bin/pip3 install --no-cache-dir -U setuptools wheel`; `.venv/bin/pip3 install --no-cache-dir --extra-index-url https://www.piwheels.org/simple -e .`; `rm -rf /var/lib/apt/lists/*`.
  - `EXPOSE 10400`, `ENTRYPOINT ["bash", "docker_run.sh"]`. No ENV, CMD or USER.
- Build deps: python3, pip, venv (apt). Pure Python package.

## Runtime deps (pyproject.toml, verbatim)
- Project `wyoming-openwakeword`, version `2.1.0`, license `{text = "Apache-2.0"}`, `requires-python = ">=3.9.0"`.
- `dependencies`: `pyopen-wakeword>=1,<2`, `wyoming>=1.8,<2`.
- Console script: `wyoming-openwakeword = "wyoming_openwakeword.__main__:run"`.

## Binaries/entrypoint/CLI flags (__main__.py argparse, v2.1.0)
| Flag | Type | Default | Notes |
| --- | --- | --- | --- |
| `--uri` | str | `stdio://` | `unix://` or `tcp://` |
| `--custom-model-dir` | str, repeatable | `[]` | Directory of custom wake word models (`*.tflite`) |
| `--threshold` | float | `0.5` | Range 0.0-1.0 |
| `--trigger-level` | int | `1` | Activations required before a detection fires |
| `--refractory-seconds` | float | `2.0` | Wait before the same wake word can fire again |
| `--zeroconf` | str, optional | `openWakeWord` when given without value | Raises ValueError unless the URI is tcp |
| `--debug` | flag | off | DEBUG logging |
| `--log-format` | str | `logging.BASIC_FORMAT` | |
| `--version` | flag | off | Print version and exit |
| `--model`, `--models-dir`, `--preload-model`, `--output-dir`, `--debug-probability` | deprecated | | Parsed but never used |

- Custom model ID is the `.tflite` file stem; a `_vX.Y` suffix is dropped. First file wins on duplicate IDs.

## Env vars
- None. `__main__.py` never reads `os.environ` (fetched code). The `OWW_*` names in plan.md are wrapper conventions.

## Ports
- 10400/tcp (Wyoming; examples use `tcp://0.0.0.0:10400`).

## Volumes/paths and persistent data
- Custom models: any directory passed with `--custom-model-dir`. Docker Hub example mounts host models at `/custom`.
- No state written by the server (no download code in `__main__.py`).

## Model download
- `__main__.py` has no download code. Built-in models come from the `pyopen-wakeword` package (plan.md, not fetched here). The draft's "models downloaded at runtime" is not supported by this file.

## User/UID & permissions
- Upstream image: no USER (root by default).

## Healthcheck/readiness endpoints
- None documented (Wyoming protocol over TCP).

## Version/release info and asset naming
- v2.1.0 is the tag in pyproject.toml. Source tarball `https://github.com/rhasspy/wyoming-openwakeword/archive/refs/tags/v2.1.0.tar.gz` (not downloaded). No release assets.
- PyPI `wyoming-openwakeword` is a stale package (plan.md; not re-checked here).

## License
- Apache-2.0 (pyproject.toml).

## Arch support
- Pure Python; the Dockerfile has TARGETARCH and TARGETVARIANT args (used only for piwheels index in pip).

## Gotchas
- Docker Hub example uses `--preload-model 'ok_nabu'`, which the argparse code marks deprecated and does not use. The Docker Hub page is out of date for that flag.
- The chart passes `preload_model: true`, which has no effect on v2.1.0 per the code.
