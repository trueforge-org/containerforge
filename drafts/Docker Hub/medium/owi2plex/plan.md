# owi2plex — implementation plan
> Source: ./draft.md · Target: apps/owi2plex/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `0.1a14` (alpha). Latest on PyPI, uploaded 2022-02-19 (wheel) and 19:53:34 (sdist). No newer uploads. The chart image `alturismo/owi2plex:latest` is a rolling tag, amd64 only, last pushed 2019-11-29 (Docker Hub API). |
| Renovate | `datasource=pypi depName=owi2plex versioning=pep440`. Proposed. Sibling pypi entries exist (`esphome`, `homeassistant`, `pip`, `pyload-ng`, `setuptools`), but their versioning was not checked. |
| License | `MPL-2.0` (PyPI `info.license` and classifier; `cvarelaruiz/owi2plex` GitHub `license.spdx_id`). The `alturismo/owi2plex` repo license is null (GitHub API). |
| Source URL | https://github.com/cvarelaruiz/owi2plex (not archived, MPL-2.0). Used as `SOURCE`. |
| Upstream Dockerfile reviewed | https://github.com/alturismo/owi2plex/blob/master/Dockerfile (the draft's link). Base `alpine:latest`. `apk` installs `python3`, `py3-pip`, `libxml2-dev`, `g++`, `libxslt-dev`, `python3-dev`, `tzdata`, `bash`, `busybox-suid`, `su-exec` and others. `pip3 install lxml` and `pip3 install owi2plex`, both unpinned. Copies `owi2plex.py` to `/usr/bin/owi2plex.py` (a "Fix" override), plus `cronjob.sh`, `entrypoint.sh` and `sample_cron.txt`. `VOLUME /config /owi2plex`, `ENTRYPOINT ["./entrypoint.sh"]`, no `USER` (runs as root), `ENV TZ=Europe/Berlin`, no `EXPOSE`. |
| Download, amd64 and arm64 | PyPI wheel `owi2plex-0.1a14-py2.py3-none-any.whl` (noarch). Install with `pip`. |
| Checksum source | PyPI publishes a sha256 per file in the JSON `digests` field. The digest values were not extracted (UNVERIFIED). See section 4. |
| Python metadata | `requires_python` empty. Classifier `Python 3.7`. `requires_dist`: `click==7.0`, `requests==2.21.0`, `lxml==4.3.2`, `future==0.17.1`, `pyyaml==5.1.2`. All are old pins. |
| Ports | None. The upstream image has no `EXPOSE`. |
| Write paths (upstream) | `/config` and `/owi2plex` (both `VOLUME`). The draft's rule that the script writes only to `/config` is the draft's own plan, not verified. |
| Cron | Upstream uses `cronjob.sh` and `sample_cron.txt`, so a scheduled job is the design (Docker Hub description: "owi2plex in docker with cron"). Contents of `cronjob.sh`, `entrypoint.sh` and `sample_cron.txt` were NOT fetched: UNVERIFIED. |
| External dependencies | Per the PyPI description: an Enigma2 box with OpenWebif and HRTunerProxy (or a TVHeadend source), and Plex for XMLTV use. Not part of the container. |
| copy-from | `alturismo/owi2plex` is an alpine/musl amd64 image. Not usable on glibc ubuntu. `no` for both architectures. |

## 2. Target layout

- `apps/owi2plex/Dockerfile`
- `apps/owi2plex/docker-bake.hcl`
- `apps/owi2plex/settings.yaml`
- `apps/owi2plex/start.sh`
- `apps/owi2plex/container-test.yaml`
- `apps/owi2plex/app/requirements.txt`: pinned, hashed requirements for `owi2plex` and its dependencies (`app/` is on the `.dockerignore` allow-list and lands at `/app/`).
- `apps/owi2plex/app/crontab`: the default schedule, seeded into `/config` when missing (`app/` allow-list).
- `apps/owi2plex/app/owi2plex.py`: only if the upstream override is still needed (section 10).

No `defaults/`, `root/` or `DOWNSTREAM_CHANGES.md` (this app is not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (from the existing python app).

Fits: owi2plex is a pure-Python CLI installed with pip. The python base is built on ubuntu 26.04 and provides `/app/venv`, which the python-runtime rule says to use read-only. The draft's `ubuntu` plus `python` pair is this base, so no separate ubuntu stage is needed. Closest sibling: `apps/bazarr` (python base, apt libxml2 and libxslt runtime packages, `USER apps`, `/config`).

Scheduling needs a process that runs as `apps`. See section 4, step 5.

## 4. Dockerfile

1. `FROM` line above. `ARG VERSION`.
2. Copy the requirements before the install, because the final `COPY . /` comes later:

```dockerfile
COPY app/requirements.txt /tmp/requirements.txt
```

3. `USER root`, install build and runtime libs only if the pinned `lxml==4.3.2` has no wheel for Python 3.15 (UNVERIFIED; if a wheel exists, skip these). Runtime names follow `apps/bazarr` (`libxml2-16`, `libxslt1.1`). Build-only: `build-essential`, `libxml2-dev`, `libxslt1-dev`. Remove the build-only packages in the same `RUN`, and `rm -rf /var/lib/apt/lists/*`.
4. Install into the bundled venv, with hashes, and do not write to `/app/venv` at runtime:

```dockerfile
RUN set -eux; \
  /app/venv/bin/python -m pip install --no-cache-dir --require-hashes -r /tmp/requirements.txt; \
  rm -f /tmp/requirements.txt
```

Notes on step 4: `PIP_ROOT_USER_ACTION=ignore` is already set by the base. Caches go to `/tmp` (`PIP_CACHE_DIR=/tmp/pip`, or `--no-cache-dir`). The hashes come from the PyPI JSON `digests` for the wheel and the pinned dependencies (UNVERIFIED values). If `--require-hashes` is judged too heavy, pin with `==` and record the gap in the PR. The console script name for `owi2plex` is UNVERIFIED: check `/app/venv/bin/` after the install.

5. Scheduler: install `supercronic`, a single static binary that runs cron jobs as the current user, so no root is needed at runtime. Its release URL, version and checksum are UNVERIFIED (not fetched). Verify it against the checksum its release publishes, the same way as other downloads. Do not use the Debian `cron` daemon: `crond` needs root to switch users, which conflicts with `USER apps`.
6. License: copy the license file from the installed dist-info (`/app/venv/lib/python*/site-packages/owi2plex-*.dist-info/`) to `/usr/share/licenses/owi2plex/`. Whether the wheel ships a LICENSE file is UNVERIFIED; otherwise take it from the repo tag.
7. Environment: `ENV HOME=/config TZ=Etc/UTC PIP_CACHE_DIR=/tmp/pip`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

VOLUME /config
WORKDIR /config
```

   No `EXPOSE`: there are no ports.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "owi2plex"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=owi2plex versioning=pep440
  default = "0.1a14"
}

variable "LICENSE" {
  default = "MPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/cvarelaruiz/owi2plex"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```

Validate with `docker buildx bake --print` from `apps/owi2plex`. The `SOURCE` is the cvarelaruiz repo (the project). The Dockerfile's upstream reference is alturismo (license null). Record both in the PR.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/cvarelaruiz/owi2plex"
ports: []
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- `ports: []` (no port to declare; same form as `apps/java21/settings.yaml`).
- `TZ` default is `Etc/UTC` (sibling convention). Upstream uses `Europe/Berlin`. The schedule runs in this zone, so the user must be able to change it. Note the difference in the PR.
- No env var for the owi2plex output path is listed until the CLI options are verified (UNVERIFIED).
- `dependencies: []`. The Enigma2/TVHeadend source is external. Whether to list `apps/tvheadend` is an open question (it is a separate source, not a runtime dependency of this container).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/owi2plex

# seed the default schedule only when missing; never overwrite the user's copy
if [ ! -f /config/crontab ]; then
  cp /app/crontab /config/crontab
fi

echo "owi2plex scheduler starting with /config/crontab"
exec supercronic /config/crontab
```

- Idempotent. Writes only under `/config`. Nothing is written to `/app`.
- `exec` hands PID 1 to supercronic, so signals propagate. The container is one long-running process.
- The job line in `app/crontab` (the owi2plex command and its arguments, and the output path under `/config`) is UNVERIFIED: the CLI options are not in the facts. Take them from the upstream `cronjob.sh` and `sample_cron.txt` (not fetched; read them before writing this file).
- Readiness signal: the echo line plus the process still running (supercronic's own start line wording is UNVERIFIED).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
filePaths:
- /app/venv/bin
- /app/crontab
- /usr/local/bin/supercronic
- /usr/share/licenses/owi2plex
```

- No `tcp` or `http` probes: there are no ports (section 6).
- `timeoutSeconds: 180` is the common sibling value.
- Gap: the scheduled job itself cannot be tested in this suite, because it needs an Enigma2 or TVHeadend source. Note this in the PR. Do not add a loose assertion. Use the manual run in section 11.
- The forgetool schema for process-level checks is UNVERIFIED. If it supports a command test, add one for `/app/venv/bin/python -c 'import owi2plex'`. Otherwise the `filePaths` above stand.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap in this image |
| --- | --- |
| `/config` | `/config`. Holds `crontab` and `owi2plex/` (output, UNVERIFIED path). |
| `/owi2plex` (upstream `VOLUME`) | Not kept. Its content is presumed to be output, so it moves to `/config/owi2plex` (UNVERIFIED; check `cronjob.sh`). |
| `/usr/bin/owi2plex.py` (override copy) | `/app/venv/...` only if the override is still needed (section 10). Never written at runtime. |
| pip cache, build scratch | `/tmp` (`PIP_CACHE_DIR=/tmp/pip`). |
| `HOME` | `/config`. |

Draft security expectations reconciled:
- The chart runs as UID 0 and GID 0. This image runs as `apps` (568), so the chart values need a change (outside this app).
- `readOnlyRootFilesystem: false` can be `true`, because the image writes only to `/config` and `/tmp`. Verify with the `--read-only` run in section 11.
- Not privileged.
- The chart's `/TVH` extra persistence has no path in this image. Its purpose is not shown in the draft, so do not map it. Flag it for the chart owner.

## 10. Risks, caveats and open questions

- **Old pins on Python 3.15.** `lxml==4.3.2`, `requests==2.21.0`, `pyyaml==5.1.2`, `click==7.0` and `future==0.17.1` are 2019-era releases. Whether they install on the python 3.15.2 base is UNVERIFIED and untested. If they fail, this is a blocker: do not silently bump the pins; record the failure and the new version in the PR.
- **Cron.** The Debian `cron` daemon cannot run as `apps`. Supercronic is the plan. It adds one third-party binary. The alternative is no scheduler in the image: an external scheduler (for example a chart-level CronJob) runs the command. This is a design decision for the maintainers.
- **Upstream override.** The `owi2plex.py` override is copied to `/usr/bin` upstream. What it fixes is UNVERIFIED (the file was not fetched). Read it before deciding whether to keep it.
- **Unpinned upstream install.** The draft and upstream install owi2plex unpinned. This plan pins it with hashes (section 4).
- **Upstream activity.** The last PyPI upload is 2022-02-19 and the alpha is 0.1a14. The project may be dormant. Note it in the PR.
- **Untestable job.** The scheduled run needs an external source. The suite cannot prove it (section 8).
- **Timezone.** Upstream `Europe/Berlin` versus `Etc/UTC` (section 6).
- **Blockers.** The old pins may not install on Python 3.15 (UNVERIFIED). Otherwise none found.

## 11. Build and test steps

```sh
cd apps/owi2plex
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name owi2plex-probe --read-only --tmpfs /tmp \
  -v owi2plex-probe-config:/config owi2plex:0.1a14
docker logs -f owi2plex-probe
forgetool containers test --image owi2plex:0.1a14 --config ./apps/owi2plex/container-test.yaml
docker rm -f owi2plex-probe; docker volume rm owi2plex-probe-config
```

- Expected readiness: the echo line from `start.sh`, then the container still running after the startup window. Confirm that `/config/crontab` is seeded and survives a restart.
- Manual job check (not in CI): run the job line once with the source reachable, or with a test source. This is the only check of the real output path.
- Build arm64 only when the amd64 build fails for an arm64-only reason. The wheel is noarch, so arm64 is expected to build the same way.
- Round limit: 10 (protocol).

## 12. PR checklist

- Branch `feat/add-owi2plex`, commit and PR title `feat(owi2plex): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- State as untested: the scheduled job with a real source, the old pins on Python 3.15 (until built), the `--read-only` run (until done), arm64, and the hash choice.
- `docker buildx bake --print` passes. `VERSION` in `docker-bake.hcl` equals `ARG VERSION` in the Dockerfile.
- No assertion weakened.
