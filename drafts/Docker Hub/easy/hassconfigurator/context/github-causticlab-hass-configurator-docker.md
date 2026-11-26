# causticlab/hass-configurator-docker (upstream container build)

Source URL(s) + fetch date:
- https://github.com/causticlab/hass-configurator-docker/blob/7ed3f9f60f4733bf16672a599c041621361d8b0a/Dockerfile (draft link; fetched as raw, 2026-11-26)
- https://raw.githubusercontent.com/causticlab/hass-configurator-docker/7ed3f9f60f4733bf16672a599c041621361d8b0a/run.sh (fetched 2026-11-26)
- Docker Hub page summarized separately: dockerhub-causticlab-hass-configurator-docker.md

## What it is
- Community Docker image packaging `hass-configurator` from PyPI for Linux x86_64/ARM. The image is not built by ContainerForge; the chart uses it.

## Install/build steps and build deps
- Base: `python:3.9-alpine`. `WORKDIR /app`. `ARG HC_BUILD_VERSION`.
- `apk update && apk upgrade && apk add --no-cache bash git openssh`
- `pip install --no-cache-dir hass-configurator==${HC_BUILD_VERSION} gitpython pyotp`
- Copies `run.sh` to `/app/`, `chmod a+x`.
- Local build: `docker build -f . --build-arg HC_BUILD_VERSION=<version> . -t <name>`.

## Runtime deps
- git (apk), openssh, bash (apk); Python packages gitpython and pyotp pinned loosely (no version pins in the Dockerfile).

## Binaries/entrypoint/CLI flags
- `ENTRYPOINT ["/app/run.sh"]`. No CMD, no ENV, no ARG default.
- `run.sh` (verbatim logic): if `/config/settings.conf` does not exist, prints "No configuration file found proceeding with default values" and runs `hass-configurator`; else prints "Configuration file found starting configurator with provided settings" and runs `hass-configurator /config/settings.conf`.

## Env vars
- None set in the Dockerfile. Docker Hub notes env vars work since 0.3.3 (see the Docker Hub summary).

## Ports
- `EXPOSE 3218` (tcp).

## Volumes/paths and persistent data
- `VOLUME /config` (settings file location). The Docker Hub compose example also maps `/hass-config` (Home Assistant config folder to edit).

## User/UID & permissions
- No `USER` instruction: runs as root.

## Config files and formats
- `/config/settings.conf` (JSON; the Docker Hub page says `basepath` must be set in it).

## Healthcheck/readiness endpoints
- None in the Dockerfile.

## Version/release info and asset naming
- Version comes from the `HC_BUILD_VERSION` build arg, which maps directly to the PyPI version.

## Arch support
- Dockerfile uses `python:3.9-alpine` (musl). The Docker Hub page says multi-arch builds exist from 0.4.1. This matters for `copy-from`: the image is an alpine/musl build, so it is not usable for `COPY --from` on Ubuntu (matches the draft's `copy-from: no`).

## Gotchas
- Plan.md agreement: `python:3.9-alpine`, `pip install hass-configurator==... gitpython pyotp`, `run.sh` behaviour, `EXPOSE 3218`, `VOLUME /config` all confirmed. No contradiction. The plan's statement that the image is "2021-era" was not checked here (no date in the fetched Dockerfile).
- Runs as root. Alpine and Python 3.9 are irrelevant to the ContainerForge build, which pip-installs on the python base (plan.md section 4).
