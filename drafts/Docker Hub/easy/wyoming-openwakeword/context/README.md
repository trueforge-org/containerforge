# Context sources: wyoming-openwakeword

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/rhasspy/wyoming-openwakeword | github-rhasspy-wyoming-openwakeword.md |
| https://github.com/rhasspy/wyoming-openwakeword/blob/456fdcc4c4e2205f629f48127b49b7acf845666c/Dockerfile | github-rhasspy-wyoming-openwakeword.md (layout described; the fetch used the v2.1.0 tag Dockerfile, which matches plan.md's description of 456fdcc) |
| https://github.com/home-assistant/addons/tree/master/openwakeword | github-home-assistant-addons-openwakeword.md (fetched as raw config.yaml) |
| https://hub.docker.com/r/rhasspy/wyoming-openwakeword | dockerhub-rhasspy-wyoming-openwakeword.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/wyoming-openwakeword | truecharts-wyoming-openwakeword.md |

Also fetched: upstream v2.1.0 README.md, pyproject.toml and wyoming_openwakeword/__main__.py (all recorded in github-rhasspy-wyoming-openwakeword.md).

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/python, .../apps/ubuntu | containerforge apps/<base> links |
| https://github.com/rhasspy/wyoming-openwakeword/archive/refs/tags/v2.1.0.tar.gz | direct archive download; pattern recorded |
| https://github.com/rhasspy/wyoming-openwakeword/archive/refs/tags/v${VERSION}.tar.gz | placeholder archive download |
| https://github.com/rhasspy/wyoming-openwakeword/blob/456fdcc.../Dockerfile | fetched as v2.1.0 instead (see table) |
| ghcr.io/trueforge-org/python (3.15.2 and 3.14.8 digests), ghcr.io/trueforge-org/ubuntu | ghcr image refs, not web pages |
| docker.io/rhasspy/wyoming-openwakeword:2.1.0 | image ref, covered by the Docker Hub page |

## Fetch failures

None. Note: the Home Assistant add-on tree page was read through its raw config.yaml.

## plan.md corrections

Edited: none.

Notes (not edited):
- confirmed: upstream Dockerfile layout (debian:bookworm-slim, venv, `pip install -e .`, EXPOSE 10400, ENTRYPOINT `bash docker_run.sh`); pyproject version 2.1.0, Apache-2.0, deps `pyopen-wakeword>=1,<2` and `wyoming>=1.8,<2`; CLI flags and defaults (`--uri` default `stdio://`, threshold 0.5, trigger-level 1, refractory 2.0); deprecated flags listed; no env vars read by the code.
- confirmed: no model download code in `__main__.py`. plan.md section 10 "models downloaded at runtime is probably wrong" is consistent with this (the package side is unverified).
- confirmed: custom models are `*.tflite` in a directory given with `--custom-model-dir`.
- unverified: plan.md section 1 says tags `v1.10.0`, `v2.0.0`, `v2.1.0`, and the PyPI `wyoming-openwakeword` 1.8.2 claim. Not fetched.
- unverified: plan.md section 1 `pyopen-wakeword` 1.1.0 wheels (manylinux_2_35) and "about 7 MB, bundles models". Not fetched.
- note: the Docker Hub example uses `--preload-model`, deprecated and unused in v2.1.0 (see the Docker Hub file). plan.md does not use it, so no edit needed.
- note: the Home Assistant add-on config is at version 2.1.1 while upstream is 2.1.0. Not a plan.md error.
