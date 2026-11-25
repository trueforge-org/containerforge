# flaresolverr — implementation plan
> Source: ./draft.md · Target: apps/flaresolverr/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Chart tag today | `ghcr.io/flaresolverr/flaresolverr:v3.5.2` (draft). |
| Version to build | FlareSolverr **v3.5.2**, published 2026-09-12 (https://api.github.com/repos/FlareSolverr/FlareSolverr/releases/tags/v3.5.2, via `gh api`). |
| Release assets | `flaresolverr_linux_x64.tar.gz` (https://github.com/FlareSolverr/FlareSolverr/releases/download/v3.5.2/flaresolverr_linux_x64.tar.gz) and `flaresolverr_windows_x64.zip`. **No Linux arm64 asset.** |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/FlareSolverr/FlareSolverr/93125d6ea6956906c8dfa29e169b2dc67d993dc3/Dockerfile: two stages on `python:3.11-slim-bookworm` (Debian). Installs Debian `chromium`, `chromium-common`, `chromium-driver` from apt, plus `xvfb`, `dumb-init`, `procps`, `curl`, `vim`, `xauth`. `pip install -r requirements.txt`, `src` copied to `/app`, `/config` created, user `flaresolverr` (non-root). `ENTRYPOINT ["/usr/bin/dumb-init", "--"]`. |
| Ports | `EXPOSE 8191` and `EXPOSE 8192` (same Dockerfile). 8191 is the API (draft). 8192 purpose UNVERIFIED. |
| Volumes | `VOLUME ["/config"]` (same Dockerfile). |
| ENV/ARG | None in the upstream Dockerfile (same Dockerfile). |
| CMD | UNVERIFIED: the fetched summary did not show the exact CMD. Read the full file before writing `start.sh`. |
| Upstream arm64 image | UNVERIFIED (not checked on ghcr). |
| Source license | MIT (https://api.github.com/repos/FlareSolverr/FlareSolverr). Repo active, last push 2026-10-24. |
| Checksum | UNVERIFIED: no checksum asset on the release (only the two archives). |
| Requirements (draft, inferred) | selenium, undetected-chromedriver, bottle, waitress (https://github.com/FlareSolverr/FlareSolverr/blob/HEAD/requirements.txt). Versions UNVERIFIED. |

## 2. Target layout

- `apps/flaresolverr/Dockerfile`
- `apps/flaresolverr/docker-bake.hcl`
- `apps/flaresolverr/settings.yaml`
- `apps/flaresolverr/container-test.yaml`
- `apps/flaresolverr/start.sh`

No `defaults/`, `etc/` or `health/` unless the chromium profile setup needs a seed (not expected). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (brief's pinned digest). Closest sibling: `apps/bazarr` (python base, pip-installed app under `/app/bin`, `/app` read-only). Note: upstream is Python 3.11; this base is Python 3.15. Compatibility of selenium and undetected-chromedriver with 3.15 is UNVERIFIED and must be checked in the build.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Chromium: the upstream uses Debian's `chromium` deb. Ubuntu 26.04 ships Chromium as a snap, which does not run in a container (draft, UNVERIFIED for 26.04). Before writing the apt line, run `apt-cache policy chromium chromium-driver` in the build. If no deb exists, this is a blocker (section 10).
3. `apt-get install -y --no-install-recommends` the Chromium packages found in step 2, plus `xvfb` only if the upstream headless mode needs it (UNVERIFIED), `dumb-init` (or the base's init), `procps`, `xauth` if needed. Then `apt-get purge -y --auto-remove` and `rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*`.
4. Download the source at the tag (both arches build from source, since no arm64 asset exists):
   ```dockerfile
   RUN curl -fsSL -o /tmp/flaresolverr.tar.gz \
     "https://github.com/FlareSolverr/FlareSolverr/archive/refs/tags/v${VERSION}.tar.gz" \
    && tar -xzf /tmp/flaresolverr.tar.gz -C /tmp \
    && mv /tmp/FlareSolverr-${VERSION} /app/flaresolverr
   ```
   The archive URL pattern and the `v` prefix are UNVERIFIED for this tag. Confirm before use. The `flaresolverr_linux_x64.tar.gz` release asset is an option for amd64 only and is not used because arm64 needs the source path.
5. Python deps into a build-time venv that is NOT the base's `/app/venv`:
   ```dockerfile
   RUN python -m venv /app/flaresolverr/venv \
    && /app/flaresolverr/venv/bin/pip install --no-cache-dir -r /app/flaresolverr/requirements.txt
   ```
   Build-time writes only. Do not mutate `/app/venv` (python-runtime rule).
6. Ownership: `chown -R apps:apps /app/flaresolverr && chmod -R 755 /app/flaresolverr`. License: `COPY` the repo `LICENSE` to `/usr/share/licenses/flaresolverr/LICENSE`.
7. `ENV HOME=/config` and move caches to `/tmp` (`PIP_CACHE_DIR=/tmp/pip`).
8. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /
   WORKDIR /app/flaresolverr
   VOLUME /config
   EXPOSE 8191
   CMD ["/start.sh"]
   ```
   `EXPOSE 8192`: do not add until its purpose is confirmed (section 10).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "flaresolverr" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=FlareSolverr/FlareSolverr versioning=semver
  default = "3.5.2"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/FlareSolverr/FlareSolverr" }
```

Four standard targets and the default group copied from `apps/adguardhome-sync`. `VERSION` must match the Dockerfile `ARG VERSION`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/FlareSolverr/FlareSolverr"
ports:
  - port: 8191
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Port 8191 is the API (draft, and the upstream EXPOSE). Env: only names `start.sh` reads. The upstream env names (for example `LOG_LEVEL`, `BROWSER_TIMEOUT`, `HEADLESS`) are UNVERIFIED here and must be read from the upstream `README` or `src/` before they are added. Do not invent names. No dependencies.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config

cd /app/flaresolverr
exec /app/flaresolverr/venv/bin/python -u src/flaresolverr.py
```

The entrypoint path `src/flaresolverr.py` and the `python -u` form are UNVERIFIED against the upstream CMD (section 1). Confirm before writing. The browser profile must go to `/tmp` (writable on `--read-only --tmpfs /tmp`). Do not write under `/app`. Idempotent: only `mkdir -p`. Ends with `exec` so signals reach the process.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8191'
http:
- port: '8191'
  path: /
filePaths:
- /app/flaresolverr/src/flaresolverr.py
- /app/flaresolverr/venv/bin/python
- /usr/share/licenses/flaresolverr/LICENSE
```

`/` returns 200 or a fixed body only after the app starts; the exact body and status are UNVERIFIED. Confirm before setting the `http` path. `timeoutSeconds: 180` because Chromium start is slow (draft caveat). The test runs without env vars, which is fine (no required env path).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Chromium profile and cache (draft: under `/tmp` by the common default; upstream location UNVERIFIED) | `/tmp`, writable on `--tmpfs /tmp` |
| `/config` (upstream `VOLUME`) | kept as the persistent volume. What upstream writes there is UNVERIFIED. |
| `/app` | read-only at runtime; written only at build time |
| Chromium `/dev/shm` | UNVERIFIED: may need `--shm-size` or `--disable-dev-shm-usage` |

Draft expectations reconciled: the chart runs as UID 0 with `readOnlyRootFilesystem: false`. This image runs as `apps` (non-root, matching upstream's `flaresolverr` user intent) with `--read-only --tmpfs /tmp`. Not privileged. Chromium's sandbox may need `--no-sandbox` under a non-root UID with no user namespaces (UNVERIFIED; check the upstream launch flags before adding it, and state it in the PR).

## 10. Risks, caveats and open questions

- **Blocker candidate: Chromium on Ubuntu 26.04.** The draft says Ubuntu ships Chromium only as a snap. The Debian deb used upstream is not in the Ubuntu archive. Check with `apt-cache policy chromium`. If unavailable, the choices are Chrome for Testing (download, checksum UNVERIFIED) or stopping (a blocker to record).
- **Python 3.15 vs 3.11:** `undetected-chromedriver` and `selenium` compatibility with 3.15 is UNVERIFIED.
- **No arm64 release asset:** arm64 requires the source build path (section 4, step 4). The tag archive URL is UNVERIFIED.
- **No checksum published** for the release archives. Source is pinned by tag only, so the archive is not content-verified. Pin the tag's commit SHA in the Dockerfile if a checksum is required.
- **Solver fragility:** challenge solving depends on the Chromium build and on Cloudflare behaviour (draft, inferred). Expect breakage after browser or site changes.
- **Image size and first start:** Chromium makes the image large and first start slow (draft).
- **Upstream runs as root and writes profiles**: remap per section 9. Verify on `--read-only`.
- **Port 8192** purpose UNVERIFIED. Not exposed until confirmed.
- **Renovate:** the `github-releases` tracker covers the release tag; the archive path and the `v` prefix are UNVERIFIED.

## 11. Build and test steps

```sh
cd apps/flaresolverr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name flaresolverr-probe --read-only --tmpfs /tmp \
  -v flaresolverr-probe-config:/config flaresolverr:3.5.2
docker logs -f flaresolverr-probe
forgetool containers test --image flaresolverr:3.5.2 --config ./apps/flaresolverr/container-test.yaml
docker rm -f flaresolverr-probe; docker volume rm flaresolverr-probe-config
```

Readiness signal: the app's startup line (UNVERIFIED until run), and the port 8191 probe answering. arm64 is built only if the amd64 build fails for an arch-specific reason, per the protocol.

## 12. PR checklist

- Branch `feat/add-flaresolverr`, commit `feat(flaresolverr): add new container`, PR title matches the commit, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section: `🤖 This PR is AI generated.`
- CLA notice: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: the Chromium apt availability on 26.04, the Python 3.15 compatibility, the arm64 build, the `--read-only` run, the CMD and `http` probe status, and the 8192 port.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
