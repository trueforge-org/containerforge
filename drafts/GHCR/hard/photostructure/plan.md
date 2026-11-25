# photostructure — implementation plan
> Source: ./draft.md · Target: apps/photostructure/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | Draft chart tag `ghcr.io/photostructure/server:2026.9.4-beta` is a beta build. Current npm release: `photostructure` 2026.10.3 (dist-tags `alpha`, `beta`, `latest`, `stable` all 2026.10.3, published 2026-10-28). Source: https://registry.npmjs.org/photostructure/latest. Docker Hub tag scheme: `stable` and `latest` point to the same image per stable release (https://photostructure.com/server/photostructure-for-docker/). The image tag for 2026.10.3 is UNVERIFIED: not checked on Docker Hub. |
| Renovate | `datasource=npm depName=photostructure versioning=semver` (npm package). UNVERIFIED: confirm `versioning` because the version is calendar-style (`YYYY.M.N`). |
| License | Proprietary. npm `license` field is `SEE LICENSE IN LICENSE.md`; GitHub repo reports `NOASSERTION` (https://api.github.com/repos/photostructure/photostructure-for-servers). Not an SPDX open-source license. See section 10 (blocker). |
| Source URL | https://github.com/photostructure/photostructure-for-servers |
| Download (binary) | npm tarball `https://registry.npmjs.org/photostructure/-/photostructure-2026.10.3.tgz`, integrity `sha512-egPc2OOs129dMYXXVB2wgeBs9RknpJCfDgti1angAO1jZcsCdw5UPt5x8DFb/cUhadqK9YDR6VleqxZBvSdwDA==` (registry metadata). Bin: `photostructure` → `photostructure.js`. Engines: UNVERIFIED (not read). |
| Per-arch | Image published for `linux/amd64` and `linux/arm64` (https://photostructure.com/server/photostructure-for-docker/). Notes: x64 needs SSE4 and AVX; arm64 runs on Raspberry Pi 4 and later. The npm package is JS; native parts (libjpeg-turbo, exiftool, sqlite3 tooling) need per-arch checking. |
| Checksum source | npm `integrity` (sha512) from registry metadata. Pin with `npm install --integrity`, or verify the tarball hash in the Dockerfile. |
| Upstream Dockerfile reviewed | https://api.github.com/repos/photostructure/photostructure-for-servers/contents/Dockerfile?ref=42bd6d0e2f7c2a5abaaa1948cb9591c591163467 (read via `gh api`, base64 decoded). Builder: `photostructure/base-tools-debian@sha256:69e6b1…` runs `npm ci --omit=dev` to compile native modules. Final: `node:24-trixie-slim` with apt packages `ca-certificates libjpeg-turbo-progs libreadline8t64 locales-all passwd perl procps ripgrep tini tzdata wget`, renames the `node` user to `photostructure`, `COPY --from=builder`, `EXPOSE 1787`, `HEALTHCHECK wget http://localhost:${PS_HTTP_PORT:-1787}/ping`, `ENTRYPOINT ["/usr/bin/tini", "--", "/opt/photostructure/docker-entrypoint.sh"]`, no `USER`. |
| Env (real, docs) | `PUID`, `PGID` (upstream entrypoint remaps the account; not applicable here, see section 9), `TZ`, `PS_LIBRARY_DIR` (aliases `PS_LIBRARY_PATH`, `PS_LIBRARY`), `PS_CONFIG_DIR`, `PS_HTTP_PORT` (default 1787), `PS_LOG_LEVEL` (`warn`/`info`/`debug`), `PS_LOG_STDOUT`, `PS_TRY_SOFT_DELETES=false`, `PS_NO_PUID_CHOWN=1`, `XDG_DATA_HOME`, `PIXI_HOME`. Defaults for most: not stated in the fetched page. |
| Ports | 1787/tcp (EXPOSE, docs). |
| Paths | `/ps/library` (required, RW), `/ps/tmp` (local cache, 16–32 GB free, needed only for remote libraries), `/ps/originals` (optional), `/ps/logs` (optional), `/ps/config` (optional, system settings and FFmpeg install), `/ps/host/machine-id` (optional read-only, license matching). |
| First run | Asks whether to install FFmpeg. Fetches it from conda-forge via Pixi (~700 MB) into `pixi/linux-<arch>` under the system settings dir. Consent saved as `codec-install-consent.env`. Needs no privilege escalation. Imports need at least 2 GB RAM (1 GB gives `ENOMEM`). |
| Auth | No built-in authentication as of v2026.4.7 (docs). Publish on `127.0.0.1` only. |
| Dependencies | None (draft agrees). |
| Health | `GET /ping` on `PS_HTTP_PORT` (upstream HEALTHCHECK). |
| License key | UNVERIFIED: docs do not describe key entry or storage. |

## 2. Target layout

- `apps/photostructure/Dockerfile`
- `apps/photostructure/docker-bake.hcl`
- `apps/photostructure/settings.yaml`
- `apps/photostructure/container-test.yaml`
- `apps/photostructure/start.sh`
- `defaults/`, `etc/`, `health/`, `scripts/` only if needed (not planned).

Never `root/`. No `DOWNSTREAM_CHANGES.md`: not a `FROM` base for another container.

## 3. Base image

- Runtime: `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (from the brief), as the draft states. Closest siblings: `apps/changedetection` and `apps/budge` (node-based python-node images).
- Node version in python-node: UNVERIFIED. Upstream uses `node:24-trixie-slim`. The app needs a Node version it supports: check `engines` in the npm package (section 1 UNVERIFIED) before choosing.
- Alternative: `ghcr.io/trueforge-org/ubuntu` plus a Node install. Not preferred: python-node already ships Node.
- Builder stage for native modules: required, because `npm install` compiles native modules (upstream builder). Use the same `python-node` base as a build stage (`AS build`), install `build-essential` and `python3` there only, then `COPY --from=build` the `node_modules` tree. UNVERIFIED: whether python-node already has build tools.

## 4. Dockerfile

1. `ARG VERSION`. `ARG TARGETARCH`.
2. `FROM <python-node> AS build`, `USER root`, `WORKDIR /opt/photostructure`.
   - `apt-get install -y --no-install-recommends build-essential python3` (only if not already in the base; check first).
   - `ENV npm_config_cache=/tmp/npm`.
   - `npm install --omit=dev --no-audit --no-fund photostructure@${VERSION}` into `/opt/photostructure`. Verify the registry `integrity` for `${VERSION}` against the value pinned in the Dockerfile (ARG or comment, section 1).
   - Remove build packages: `apt-get purge -y build-essential python3 && apt-get autoremove -y`.
3. Final stage `FROM <python-node>`, `USER root` for installs only:
   - `apt-get install -y --no-install-recommends libjpeg-turbo-progs locales-all perl procps ripgrep tini tzdata wget` (versions not pinned: none of these are `apps/valkey`-style pinned tools; record resolved versions in the PR). `tini` and `wget` are already in the base `ubuntu` image (`apps/ubuntu/Dockerfile`), so drop them from this install line unless the python-node image lacks them (UNVERIFIED). Skip `passwd`/`usermod` tooling: the base runs as `apps`. Remove `/var/lib/apt/lists/*`.
   - `COPY --from=build --chown=root:root /opt/photostructure /opt/photostructure`.
   - `chmod -R 755 /opt/photostructure`.
   - License: `COPY` the npm package `LICENSE.md` to `/usr/share/licenses/photostructure/LICENSE.md`.
4. `ENV PATH="/opt/photostructure:/opt/photostructure/tools:${PATH}" HOME=/config PS_CONFIG_DIR=/config/system PS_LIBRARY_DIR=/config/library PS_HTTP_PORT=1787 PS_LOG_STDOUT=1 PS_NO_PUID_CHOWN=1 PIXI_HOME=/config/pixi`. (Paths are ContainerForge decisions, see section 9; `PS_LIBRARY_DIR` location is the open point in section 10.)
5. `COPY --chmod=0755 . /`, `USER apps`.
6. `EXPOSE 1787`, `VOLUME /config`. Do not set `ENTRYPOINT`/`CMD`: the base `ubuntu` image already has `ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]`, which execs `/start.sh` (see `apps/ubuntu/Dockerfile`, `apps/budge/Dockerfile`).

No `ARG` other than `VERSION` and `TARGETARCH`. Do not copy the upstream repo tree (it is not an npm artifact).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "photostructure"
}

variable "VERSION" {
  // renovate: datasource=npm depName=photostructure versioning=semver
  default = "2026.10.3"
}

variable "LICENSE" {
  default = "LicenseRef-PhotoStructure-Proprietary"
}

variable "SOURCE" {
  default = "https://github.com/photostructure/photostructure-for-servers"
}
```

`LICENSE` is a placeholder until section 10 is decided: the `docker-bake.hcl` `LICENSE` MUST be the license of the software in the image (repo rule), so a proprietary license cannot be expressed as SPDX. Do not merge until the user decides how to record it. The four standard targets and the default group follow `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/photostructure/photostructure-for-servers"
ports:
  - port: 1787
    protocol: tcp
    required: false
env:
  - name: PS_HTTP_PORT
    default: "1787"
    required: false
  - name: PS_LOG_LEVEL
    default: "info"
    required: false
  - name: PS_LIBRARY_DIR
    default: "/config/library"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- Only the variables the app reads and that the plan uses. `PUID`, `PGID`, `PS_NO_PUID_CHOWN` are not listed: ContainerForge runs as `apps` and does not remap accounts.
- `PS_LIBRARY_DIR` default `/config/library`: a ContainerForge path decision (section 9), not an upstream default. Mark it so in the PR.
- `dependencies`: none. Omit the key or leave empty, matching siblings.

## 7. start.sh

Idempotent, empty-`/config` safe, never writes to `/opt/photostructure`:

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/library /config/system /config/pixi /tmp/photostructure

# Only seed when missing: never overwrite existing user state
export PS_LIBRARY_DIR="${PS_LIBRARY_DIR:-/config/library}"
export PS_CONFIG_DIR="${PS_CONFIG_DIR:-/config/system}"
export PS_HTTP_PORT="${PS_HTTP_PORT:-1787}"

cd /opt/photostructure
exec photostructure serve --host 0.0.0.0 --port "${PS_HTTP_PORT}"
```

- `photostructure serve ...` is a placeholder command. The CLI flags and the `serve` subcommand are UNVERIFIED: not in the fetched docs. Check `photostructure --help` in the built image, or read `photostructure.js` in the npm package, before committing. The upstream image starts through `docker-entrypoint.sh`, which was not read.
- Bind to `0.0.0.0` (other containers and the host reach it). UNVERIFIED: whether the server binds all interfaces by default.
- Exec the final process so the signal chain works (tini is PID 1 via the base entrypoint).
- FFmpeg first-run consent is interactive in the upstream flow. Decide how `start.sh` answers it (default: leave the prompt to the web UI, never block startup). UNVERIFIED: whether a non-interactive env var exists.
- Caches: `/tmp/photostructure` for scratch, `PIXI_HOME` under `/config/pixi` (persistent, large: the consent state lives there). Per the rule, caches MUST go to `/tmp`; the FFmpeg install is persistent by design, so set `PIXI_HOME` only if the user accepts ~700 MB in `/config`. Open question, section 10.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240
tcp:
- port: '1787'
http:
- port: '1787'
  path: /ping
```

- Timeout 240s: first start initialises the library and may fetch FFmpeg. Check a sibling of the same family before finalising.
- The test runs with no env vars: the default path (`/config/library`, port 1787) is tested. The FFmpeg install is a user action in the web UI, so it is not in the test.
- `timeoutSeconds` is a top-level key (as in `apps/changedetection/container-test.yaml`). The `tcp` probe covers the settings.yaml port.
- UNVERIFIED: `/ping` returns 200 without a license. Confirm with a run; if it does not, use `tcp` only and say so.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap in ContainerForge | Reason |
| --- | --- | --- |
| `/ps/library` (required) | `/config/library` (`PS_LIBRARY_DIR`) | Persistent library and cache (`.photostructure/cache` by default). |
| `/ps/tmp` | `/tmp/photostructure` | Scratch disk. Note: `/tmp` is ephemeral (ramdisk). The docs require 16–32 GB free for remote libraries, and a tmpfs may not hold that. Open point, section 10. |
| `/ps/logs` | `/config/logs` (set `PS_LOG_DIR` if it exists: UNVERIFIED env name) or `/config/library/.photostructure/logs` (default) | Persistent logs; default already under the library. |
| `/ps/config` | `/config/system` (`PS_CONFIG_DIR`) | System settings and consent file. |
| FFmpeg install (`PIXI_HOME`) | `/config/pixi` | Persistent, ~700 MB. Only if the user accepts; see section 10. |
| `/ps/originals` | Not mounted by default | Optional scan location, user-mounted. |
| `/ps/host/machine-id` | Not mounted | Optional license matching; omit unless the user asks. |
| `/.running-in-container` marker | Not needed | Created by upstream Dockerfile for PhotoStructure's Docker detection. Check whether PhotoStructure still needs it when `PS_IS_DOCKER` is not set (docs say the file marker is used). Create it at build time under `/` only if required by the app, as root. |
| `chown` of library support dirs on start | Disabled (`PS_NO_PUID_CHOWN=1`) | The container runs as `apps`; chown at startup is not possible. |

- The draft's security expectations (chart `runAsUser 0`, `runAsGroup 0`, `readOnlyRootFilesystem false`) are not carried over: ContainerForge runs as `apps` and expects read-only rootfs. The `apps` UID is set by the base; the library permissions must allow `apps` to write `/config`.
- `tini` is PID 1 through the base image entrypoint; `start.sh` execs the app. Nothing to decide.
- No `privileged`, no extra capabilities.

## 10. Risks, caveats and open questions

- BLOCKER (license): PhotoStructure is proprietary (`SEE LICENSE IN LICENSE.md`, GitHub `NOASSERTION`). ContainerForge's `LICENSE` in `docker-bake.hcl` must match the software. The user must decide whether a proprietary app is in scope for this repo before any PR is opened. Also check the license allows redistribution inside a third-party image.
- BLOCKER (version): the chart uses `2026.9.4-beta`. The current npm release is `2026.10.3`. The draft pins a beta, and the plan uses the latest npm release. The user must choose; the choice changes section 5.
- Process/start command: `photostructure serve ...` is a placeholder (section 7). The real command and entrypoint behaviour were not read. Blocker until verified by running the npm package in the built image.
- Library location and cache: the docs require large writable storage (library cache, `/ps/tmp` 16–32 GB). `/tmp` is ephemeral and may be a tmpfs. Decide: mount a separate volume at `/tmp` is not allowed (rule: `/tmp` is ephemeral). Treat the cache as `/config` only if the user accepts a large persistent cache. Open point.
- FFmpeg install on first run: ~700 MB via Pixi/conda-forge at runtime, needs internet. Conflicts with a clean read-only startup unless the consent is kept out of the default path. Open point.
- arm64: the image is published for arm64 (docs), but the npm package contents and helper binaries per arch were not checked. Do not claim arm64 is tested.
- No authentication (docs): publish as `127.0.0.1` for local use. Document in the PR.
- Node version: python-node Node version UNVERIFIED (section 3).
- Upstream base `photostructure/base-tools-debian` is used only as a build stage in the upstream image. Not used here.
- Blockers: license (above) and version (above) must be decided before implementation. Everything else is implementable once they are settled.

## 11. Build and test steps

Step 0: `npm view photostructure@2026.10.3 engines bin license` and download the tarball to a scratch directory outside the repo. Record the integrity, the bin entry, and the Node engine. Check the `LICENSE.md` text.

From `apps/photostructure/`, one app only, in protocol order:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Probe run with an empty config volume:
   ```sh
   docker volume create photostructure-probe-config
   docker run --rm -d --name photostructure-probe --read-only --tmpfs /tmp \
     -v photostructure-probe-config:/config photostructure:2026.10.3
   docker logs -f photostructure-probe
   ```
   Pass signal: server listening on port 1787 (exact text UNVERIFIED until run), process still running, no `ENOMEM`, no stack trace. Cleanup: `docker rm -f photostructure-probe; docker volume rm photostructure-probe-config`.
4. `forgetool containers test --image photostructure:2026.10.3 --config ./container-test.yaml` (if forgetool is unavailable, check `GET /ping` on port 1787 by hand).

Run the test command via `haiku-triage` per the repo rules. Round limit: 10. Do not run this build until section 10's blockers are answered.

## 12. PR checklist

- Branch: `feat/add-photostructure` from `main`.
- Commit: `feat(photostructure): add new container`.
- PR title matches the commit.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows status). Only the user can sign.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Check only the boxes that apply.
- State the license decision explicitly in the PR (section 10).
- Say what was not tested: arm64 image, FFmpeg first-run install, licence key flow, long-running library scan on `--read-only`.
- Not applicable: DOWNSTREAM_CHANGES.md (not a `FROM` base).
