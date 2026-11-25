# speedtest-exporter — implementation plan
> Source: ./draft.md · Target: apps/speedtest-exporter/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `3.5.4` (GitHub release `v3.5.4`, published 2023-06-28, the latest release). The release has **no binary assets**. Pin the source tag tarball instead. Chart image `ghcr.io/miguelndecarvalho/speedtest-exporter:v3.5.4`. Source: `gh api repos/MiguelNdeCarvalho/speedtest-exporter/releases/latest`. |
| Renovate | `datasource=github-releases depName=MiguelNdeCarvalho/speedtest-exporter versioning=semver` |
| License | GPL-3.0. https://github.com/MiguelNdeCarvalho/speedtest-exporter/blob/main/LICENSE |
| Source URL | https://github.com/MiguelNdeCarvalho/speedtest-exporter |
| Source download | `https://github.com/MiguelNdeCarvalho/speedtest-exporter/archive/refs/tags/v3.5.4.tar.gz`. Checksum: UNVERIFIED, no checksum is published. Pinned by tag. |
| Ookla speedtest CLI | Upstream Dockerfile: `https://install.speedtest.net/app/cli/ookla-speedtest-${SPEEDTEST_VERSION}-linux-${ARCH}.tgz`, `SPEEDTEST_VERSION=1.2.0`, `ARCH` from `uname -m` (`x86_64`, `aarch64`, `armhf` for `armv7l`). Checksum: UNVERIFIED (not published by upstream). The aarch64 URL existence is UNVERIFIED (same pattern as upstream). |
| Upstream Dockerfile reviewed | https://github.com/MiguelNdeCarvalho/speedtest-exporter/blob/v3.5.4/Dockerfile: `FROM python:3.11.0-alpine3.15` (musl, not usable as `COPY --from`), `adduser speedtest`, `pip install -r requirements.txt`, downloads the Ookla CLI to `/usr/local/bin/speedtest`, `USER speedtest`, `CMD ["python","-u","exporter.py"]`, `HEALTHCHECK wget http://localhost:${SPEEDTEST_PORT:=9798}/`. |
| Python requirements | https://github.com/MiguelNdeCarvalho/speedtest-exporter/blob/v3.5.4/src/requirements.txt: `Werkzeug==2.3.6`, `Flask==2.3.2`, `prometheus_client==0.17.0`, `waitress==2.1.2`. |
| Env vars (real) | From `src/exporter.py`: `SPEEDTEST_PORT` (default `9798`), `SPEEDTEST_CACHE_FOR` (default `0`), `SPEEDTEST_SERVER` (optional server id), `SPEEDTEST_TIMEOUT` (default `90`). |
| Startup check | `exporter.py` runs `speedtest --version` and requires the output to contain `Speedtest by Ookla`. Otherwise it exits 1. |
| Ports | 9798/tcp, HTTP. Waitress binds `0.0.0.0` (`serve(app, host='0.0.0.0', port=PORT)`). Metrics at `/metrics`, index at `/`. |
| Data paths | None. Stateless. |
| Dependencies | None. |

## 2. Target layout

- `apps/speedtest-exporter/Dockerfile`
- `apps/speedtest-exporter/docker-bake.hcl`
- `apps/speedtest-exporter/settings.yaml`
- `apps/speedtest-exporter/container-test.yaml`
- `apps/speedtest-exporter/start.sh`

No `defaults/`, `etc/` or `health/` are needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Fits because the exporter is pure Python with pip requirements. The upstream `python:3.11.0-alpine3.15` is replaced with ContainerForge's python base (glibc, pinned, `/app/venv` pattern). Closest sibling: `apps/bazarr` (Python app on the same base, pip install at build time, `USER apps`).

Note: the draft says "python base" and lists the ubuntu base as the foundation. The runtime image is the python base directly, which already contains ubuntu.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG SPEEDTEST_VERSION=1.2.0`, `USER root`, `WORKDIR /app`.
2. `ENV PIP_CACHE_DIR=/tmp/pip-cache HOME=/tmp`.
3. Source: `curl -fsSL -o /tmp/src.tar.gz "https://github.com/MiguelNdeCarvalho/speedtest-exporter/archive/refs/tags/v${VERSION}.tar.gz"`, then extract only `src/` into `/app` (`tar xzf ... --strip-components=2 -C /app '*/src/'`). Checksum UNVERIFIED (no published checksum); the tag is the pin.
4. Install Python deps into the base's interpreter: `pip install --no-cache-dir -r /app/requirements.txt`. Check the install does not write to `/app/venv` at runtime (it is build time only). Remove `requirements.txt` afterwards.
5. Ookla CLI: map `TARGETARCH` (`amd64` -> `x86_64`, `arm64` -> `aarch64`). `curl -fsSL -o /tmp/speedtest.tgz "https://install.speedtest.net/app/cli/ookla-speedtest-${SPEEDTEST_VERSION}-linux-${ARCH}.tgz"`, `tar xzf /tmp/speedtest.tgz -C /tmp speedtest`, `install -m 0755 /tmp/speedtest /usr/local/bin/speedtest`. Verify the checksum before extracting: UNVERIFIED (no published checksum; record the sha256 of the downloaded file in the PR and pin it).
6. Ship licenses: the Ookla tarball may contain `*.md` or `LICENSE` files (UNVERIFIED). Copy any that exist to `/usr/share/licenses/speedtest-exporter/` (or `/usr/share/licenses/ookla-speedtest/`), and copy the exporter's `LICENSE` from the source tag. The Ookla licence terms must be read by the maintainer before shipping (see section 10).
7. `chown -R apps:apps /app && chmod -R 755 /app`, `rm -rf /tmp/*`.
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 9798`, `VOLUME /config` (unused by the app, kept per the repo Dockerfile rules), `ENV SPEEDTEST_PORT=9798`.

`ARG VERSION` must match `docker-bake.hcl`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "speedtest-exporter" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=MiguelNdeCarvalho/speedtest-exporter versioning=semver
  default = "3.5.4"
}
variable "LICENSE" { default = "GPL-3.0" }
variable "SOURCE" { default = "https://github.com/MiguelNdeCarvalho/speedtest-exporter" }
```

The `v` prefix comes from the tag only; `VERSION` is `3.5.4`. `GPL-3.0` is the SPDX id GitHub reports for the repo (checked 2026-11-25); no `-only` suffix is claimed. Note the Ookla CLI in the image is proprietary (section 10), so the image is not purely GPL. Four standard targets and the default group copied from `apps/adguardhome-sync`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/MiguelNdeCarvalho/speedtest-exporter"
ports:
  - port: 9798
    protocol: tcp
    required: true
env:
  - name: SPEEDTEST_PORT
    default: "9798"
    required: false
  - name: SPEEDTEST_CACHE_FOR
    default: "0"
    required: false
  - name: SPEEDTEST_SERVER
    default: ""
    required: false
  - name: SPEEDTEST_TIMEOUT
    default: "90"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: false
dependencies: []
```

- `/config` is declared but optional: the app is stateless and writes nothing there (see section 9).
- `SPEEDTEST_SERVER` default is empty, which means the CLI picks the server.
- `TZ` is the ContainerForge convention, not an upstream var.

## 7. start.sh

```bash
#!/usr/bin/env bash

cd /app
exec python -u /app/exporter.py
```

- Idempotent. Nothing to seed.
- Nothing is written to `/app` at runtime. `speedtest` writes its cache to `$HOME` (`/tmp`), see section 9.
- `exec` hands PID 1 to the exporter.
- `SPEEDTEST_*` env vars are read by `exporter.py` itself. `start.sh` does not transform them.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '9798'
http:
- port: '9798'
  path: /
filePaths:
- /app/exporter.py
- /usr/local/bin/speedtest
```

- Port 9798 has a `tcp` and an `http` probe. The `/` index returns 200 (`mainPage()`).
- `checkForBinary()` exits 1 if `speedtest` is missing or is not the Ookla CLI. The `http` probe only succeeds if the exporter started, so this check runs implicitly.
- The test runs with no env. `SPEEDTEST_SERVER` and `SPEEDTEST_TIMEOUT` are not exercised. No required env path exists.
- `/app/requirements.txt` is removed by the Dockerfile (section 4 step 4), so it is not in `filePaths`.
- `timeoutSeconds` 120 is UNVERIFIED against a sibling.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app` (upstream owns `/app` as speedtest) | `chown apps:apps /app`, read-only at runtime, no writes |
| `/tmp` (speedtest tgz) | Build-time only. Runtime `/tmp` is tmpfs. |
| `$HOME` (Ookla CLI may write `~/.config/ookla` or similar; UNVERIFIED) | `HOME=/tmp` |
| `pip` cache | `PIP_CACHE_DIR=/tmp/pip-cache`, build time |
| Upstream runs as `speedtest` (uid 1000 in chart) | `USER apps` |

The chart's security expectations are reconciled: non-root yes (apps user), read-only-rootfs no in the chart becomes yes in this image. No `/config` is written, so `readOnlyRootFilesystem` is expected to pass. Verify with `docker run --read-only --tmpfs /tmp`.

## 10. Risks, caveats and open questions

- **Ookla licence.** The Ookla speedtest CLI is proprietary. The redistribution terms (in the tarball or on speedtest.net/apps/cli) must be read before the image is published. Shipping the binary in a public image may not be allowed. This is a blocker until the maintainer confirms. UNVERIFIED terms.
- **Ookla checksum.** The tgz download has no published checksum. Record the sha256 of the 1.2.0 download and pin it in the Dockerfile, or the build is not reproducible.
- **Ookla aarch64 tarball.** The URL pattern is confirmed from the upstream Dockerfile, but the existence of the aarch64 file is UNVERIFIED. Confirm with `curl -I` during the build.
- **Source age.** The latest upstream release is `v3.5.4` from 2023-06-28. Check whether newer commits exist on `main` before pinning, and note it in the PR.
- **Scrape cost.** Every scrape runs a real speed test, which uses bandwidth and may count against an ISP quota. The scrape interval matters for users. Mention in the chart docs.
- **Python pins.** `Flask==2.3.2` and `Werkzeug==2.3.6` are old. They are pinned upstream and not changed here. Check the CVE status when the PR is reviewed.
- No blockers beyond the Ookla licence question.

## 11. Build and test steps

From `apps/speedtest-exporter/`:

```sh
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name speedtest-exporter-probe --read-only --tmpfs /tmp \
  -v speedtest-exporter-probe-config:/config speedtest-exporter:3.5.4
docker logs -f speedtest-exporter-probe
docker rm -f speedtest-exporter-probe; docker volume rm speedtest-exporter-probe-config
forgetool containers test --image speedtest-exporter:3.5.4 --config ./apps/speedtest-exporter/container-test.yaml
```

- Expected readiness signal: the process stays up and logs show `Starting Speedtest-Exporter on http://localhost:9798`. This line is from `exporter.py` (`logging.info`).
- The `/config` volume is attached only to match the protocol's probe. The app does not use it.
- arm64: build only if amd64 fails in an arm64-specific way. Check the aarch64 Ookla URL first.

## 12. PR checklist

- Branch `feat/add-speedtest-exporter`, commit `feat(speedtest-exporter): add new container`, PR title matches.
- PR body uses `.github/PULL_REQUEST_TEMPLATE.md`, keeps its sections and checkboxes, and only ticks boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`.
- Tell the user the CLA is needed: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- State what is untested: the arm64 Ookla tarball, the Ookla licence sign-off, the speed test itself (no outbound network in the test), and the source checksum, unless verified.
