# seedsync — implementation plan
> Source: ./draft.md · Target: apps/seedsync/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v0.8.6 (GitHub release, published 2020-12-31T04:49:58Z; https://api.github.com/repos/ipsingh06/seedsync/releases/tags/v0.8.6). Docker Hub `ipsingh06/seedsync` newest version tag is `0.8.6` (updated 2020-12-31). The project has no newer release in the data fetched; the "latest release" endpoint was rate-limited, so this is UNVERIFIED as the newest release. Draft Dockerfile pin: commit `ff2a103`. |
| Renovate | GitHub releases: `// renovate: datasource=github-releases depName=ipsingh06/seedsync versioning=semver` (matches the draft's tag `v0.8.6`; the tag has a `v` prefix, so check the repo's tag style in the round). Docker Hub alternative: `datasource=docker depName=docker.io/ipsingh06/seedsync`. |
| License | Apache License 2.0 (README: "distributed under Apache License Version 2.0"). SPDX file and `LICENSE` file: UNVERIFIED (the raw LICENSE path returned 404). Bake `LICENSE` value: `Apache-2.0`, once the license file is confirmed. |
| Source URL | https://github.com/ipsingh06/seedsync |
| Download (amd64) | https://github.com/ipsingh06/seedsync/releases/download/v0.8.6/seedsync_0.8.6_amd64.deb (asset name confirmed in the release JSON; size 14344966 bytes). |
| Download (arm64) | None. The v0.8.6 release has only the amd64 `.deb`. arm64 needs a source build. |
| Checksum source | None published. The GitHub `digest` field is null. Record the SHA256 of the downloaded `.deb` in the Dockerfile after the first fetch, and mark it as a locally computed pin (trust on first use). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ipsingh06/seedsync/ff2a103/src/docker/build/docker-image/Dockerfile: base `python:3.8-slim`, apt (gcc, libssl-dev, lftp, openssh-client, p7zip, bzip2, curl, libnss-wrapper, libxml2-dev, libxslt-dev, libffi-dev), poetry install from `src/python`, Angular and scanfs from `${STAGING_REGISTRY}/seedsync/build/{angular,scanfs}/export` (not public), user `seedsync` uid/gid 1000, `/config` and `/downloads`, `USER seedsync`, `setup_default_config.sh` at build time, `CMD python /app/python/seedsync.py -c /config --html /app/html --scanfs /app/scanfs`, `EXPOSE 8800`. |
| Default config | https://raw.githubusercontent.com/ipsingh06/seedsync/master/src/docker/build/docker-image/setup_default_config.sh: runs `seedsync.py -c /config --html / --scanfs / --exit` to write `/config/settings.cfg`, then replaces `local_path = <replace me>` with `/downloads/`. |
| Port | 8800/tcp (`EXPOSE 8800`). |
| Env vars | None confirmed. The upstream Dockerfile sets no app ENV. Do not invent any (UNVERIFIED for every name). |
| Data/config paths | `/config` (`settings.cfg`, state); `/downloads` (download share, read by the scan daemon). |
| Dependencies | A remote seedbox over SFTP or SSH, configured in the web UI. No database. |
| Chart | TrueCharts values (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/seedsync/values.yaml) fetched; the draft records `/downloads` as the chart PVC. |

## 2. Target layout

- `apps/seedsync/Dockerfile`
- `apps/seedsync/docker-bake.hcl`
- `apps/seedsync/settings.yaml`
- `apps/seedsync/container-test.yaml`
- `apps/seedsync/start.sh` (seeds `/config/settings.cfg` on first start; `exec`s seedsync)
- `apps/seedsync/defaults/settings.cfg` only as a fallback if the default config cannot be generated at build time (section 4 step 7 normally generates it into `/app/seedsync/defaults/settings.cfg` inside the image). Reason: the default file must be seeded into `/config` when missing.
- `apps/seedsync/scripts/` only if the setup script is reused (reason: `.dockerignore` allow-list includes `scripts/`).

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Runtime: `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (the python sibling, which provides `/app/venv` and `apt-get`). Closest sibling: `apps/bazarr`.

Two blockers and a version gap decide the path (section 10):
- The upstream image is Python 3.8. The python sibling is 3.15.2. Poetry lock pins (`src/python/poetry.lock`) have not been checked against 3.15 (UNVERIFIED). Use the `.deb` route (section 4, Route A) first, because it avoids the lock.
- The Angular frontend and `scanfs` come from non-public staging images. The `.deb` may already contain the frontend and scanfs, but its internal layout is UNVERIFIED until extracted.

## 4. Dockerfile

Pick one route in the build round and record it in the PR body.

**Route A (amd64 `.deb`, recommended first):**
1. Build stage on the python base as in `apps/bazarr`: `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Fetch and verify: `curl -fL -o /tmp/seedsync.deb https://github.com/ipsingh06/seedsync/releases/download/v${VERSION}/seedsync_${VERSION}_${TARGETARCH}.deb` (amd64 name confirmed; arm64 name does not exist). Verify `sha256sum -c` against a checksum pinned in the Dockerfile (computed locally; see section 1).
3. Extract without installing system-wide: `dpkg-deb -x /tmp/seedsync.deb /tmp/seedsync-root` (dpkg-deb in the base; UNVERIFIED). Inspect the layout (UNVERIFIED: where the Python code, html and scanfs live, and whether the deb ships its own interpreter or expects `python3`).
4. Move the payload to `/app/seedsync/` (read-only at runtime) and set `chown -R root:root`, `chmod -R 755`.
5. Python dependencies: install into `/app/venv` at build time (`uv pip install --python /app/venv/bin/python ...`) if the deb does not bundle them. The package list must come from the deb's metadata (UNVERIFIED).
6. arm64: not provided by the deb. Options: (a) image-all for amd64 only, with a note; (b) Route B for arm64 (section below). Decide before the bake `image-all` target is finalised.

**Route B (source build, needed for arm64 or if the deb is unusable):**
1. Source: `curl -fL https://github.com/ipsingh06/seedsync/archive/refs/tags/v${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1`. Confirm the tag exists (UNVERIFIED: `v0.8.6` tag name).
2. Python: install from `src/python` with `uv pip install --python /app/venv/bin/python` against `pyproject.toml` (poetry-managed; export the lock to requirements with `poetry export` in a `/tmp` virtualenv, UNVERIFIED that the lock resolves on 3.15).
3. Angular frontend: build with Node (apt `nodejs npm` in a `/tmp` build step, UNVERIFIED version) from the repo's Angular source, output to `/app/seedsync/html`. Do not pull the staging image.
4. scanfs: build from the repo's source (language and toolchain UNVERIFIED: check `src/scanfs`). Output to `/app/seedsync/scanfs`. If the source needs a toolchain the base lacks, note it as a blocker for arm64 or amd64.
5. Copy the python code to `/app/seedsync/python/`.

**Both routes, common steps:**
6. Runtime user: the base runs as `apps`. Do not create `seedsync` (uid 1000). Default config is seeded at first start by `start.sh` (section 7), not at build time (the upstream build-time `setup_default_config.sh` needs a writable `/config`).
7. Default config template: generate with `python /app/seedsync/python/seedsync.py -c /tmp/seedsync-defaults --html / --scanfs / --exit` at build time in `/tmp`, then copy the resulting `settings.cfg` to `/app/seedsync/defaults/settings.cfg` and set `local_path = /downloads/` (the sed from upstream). This keeps `/config` empty at start (rule: seed only when missing). If generation fails in the build, ship a hand-written default and mark UNVERIFIED.
8. SSH: upstream installs `ssh`/`scp` wrappers and a `StrictHostKeyChecking no` config in `/root/.ssh/config`. Recreate the equivalent under `/tmp` only: `HOME` is not `/root` for `apps`. Set `GIT_SSH`/`SSH_CONFIG` via `start.sh` so `~/.ssh` lives in `/tmp/ssh` (UNVERIFIED: how seedsync invokes ssh; check the deb or source). Install `openssh-client` and `lftp` (apt; check the base first, do not reinstall).
9. apt packages (only those missing from the base; verify with `dpkg -l` in the round): `lftp openssh-client p7zip-full p7zip-rar bzip2 curl libnss-wrapper`. Route B also needs `libxml2-dev libxslt-dev libffi-dev` for wheels (UNVERIFIED). Clean apt lists.
10. License: take the license file from the same source (`LICENSE` or `LICENSE.md`, UNVERIFIED path; the raw LICENSE path returned 404) into `/usr/share/licenses/seedsync/`.
11. Final: `USER apps`, `COPY --chmod=0755 . /`, `ENV HOME=/tmp`, `EXPOSE 8800`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "seedsync"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ipsingh06/seedsync versioning=semver
  default = "0.8.6"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/ipsingh06/seedsync"
}

group "default" {
  targets = ["image-local"]
}
```

Plus the four standard targets from `apps/bazarr/docker-bake.hcl`. `image-all` is `linux/amd64` and `linux/arm64` only if Route B is used for arm64; with Route A, keep `image-all` with the amd64 platform only, and say so in the PR (the `image-all` target exists in every app, so declare it honestly). Validate with `docker buildx bake --print` from `apps/seedsync/`. Note: the `VERSION` default `0.8.6` must match the Dockerfile `ARG VERSION`, and the tag has no `v` prefix in the Hub tags.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/ipsingh06/seedsync"
ports:
  - port: 8800
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /downloads
    required: false
dependencies: []
```

Discipline: no env var is listed because none is confirmed (section 1). Do not add invented names. `/downloads` is listed because the scan daemon reads it and the chart mounts it; it is optional. `dependencies: []` because no ContainerForge app is required (the seedbox is external).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -eu

CONFIG_DIR=/config
SETTINGS="${CONFIG_DIR}/settings.cfg"
DEFAULTS=/app/seedsync/defaults/settings.cfg

mkdir -p "${CONFIG_DIR}" /tmp/ssh

# Seed the default config only when it is missing or empty (never overwrite user state).
if [ ! -s "${SETTINGS}" ]; then
    cp "${DEFAULTS}" "${SETTINGS}"
fi

export HOME=/tmp
exec python /app/seedsync/python/seedsync.py \
    -c "${CONFIG_DIR}" \
    --html /app/seedsync/html \
    --scanfs /app/seedsync/scanfs
```

Notes:
- Route A: the command comes from the deb's entry point (UNVERIFIED); replace the `python` line with the deb's launcher. `exec` in all cases.
- Upstream says the process must run inside a shell so the container does not exit when a child exits. `exec` handles this only if the process is a long-running foreground process; check in the round.
- `/app` is never written to at runtime. Scan state and logs go under `/config` (upstream logs to `~/.seedsync/log`; with `HOME=/tmp` that is `/tmp/.seedsync/log`, which is not persistent: decide whether logs should be in `/config`; UNVERIFIED where upstream writes them when `-c` is set).
- Bind address: UNVERIFIED that seedsync listens on all interfaces. Check the default in `settings.cfg` (`web_address` or equivalent, UNVERIFIED key name) and set it to `0.0.0.0` in the seed step if needed.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8800'
http:
- port: '8800'
  path: /
filePaths:
- /app/seedsync
- /app/seedsync/defaults/settings.cfg
- /usr/share/licenses/seedsync
```

- The scan daemon polls `/downloads` continuously. In the test, `/downloads` is empty (the test has no volume set up for it), which should still start (UNVERIFIED).
- The test runs with no env vars and no seedbox credentials. The app must start unconfigured (the default config path). Credential-dependent code paths are not run by the test; they are not in `filePaths`. Per the protocol, run one manual start with a seeded `/config/settings.cfg` to check the UI loads.
- Path `/app/seedsync` is a directory; the `filePaths` entry for a directory is UNVERIFIED for forgetool. Use a file inside the tree (e.g. `/app/seedsync/html/index.html`) if the directory check is rejected.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config` (settings, state) | `/config` (kept; persistent). Seeded only when missing. |
| `/downloads` | `/downloads` (optional volume; the app reads and writes downloads here, so it must be writable by `apps` if the chart mounts it writable). |
| `/root/.ssh/config`, `/root/.ssh` | `HOME=/tmp`, `/tmp/ssh`. Ephemeral; known_hosts is not persistent (accepted: the upstream disabled it anyway with `StrictHostKeyChecking no`). |
| `~/.seedsync/log` (UNVERIFIED path when `-c` is used) | Redirect to `/config` if it is written there; otherwise accept `/tmp`. |
| `/app/html`, `/app/scanfs`, python code (upstream: root-owned after COPY) | `/app/seedsync/*`, root-owned, read-only at runtime. |
| Upstream runs as uid 1000 (`seedsync`) | Runtime is `USER apps`. The chart's root override (`runAsUser: 0`) is not carried over. |

Security expectations from the draft (non-root no; read-only rootfs no; privileged no) are replaced: the image runs non-root and is read-only-rootfs capable, provided `/downloads` and `/config` are writable volumes and `HOME` is `/tmp`.

## 10. Risks, caveats and open questions

- **Staging images (blocker for Route B):** the Angular and scanfs images in the upstream Dockerfile are on a private staging registry. Route B rebuilds them from source; the toolchain and source layout are UNVERIFIED. If the source build is impossible, the only amd64 path is Route A.
- **arm64 (blocker):** the release has no arm64 `.deb`. arm64 needs Route B. Until a successful arm64 build, do not claim arm64 support. The Docker Hub `0.8.6` tag lists arm64 and arm images (fetched), but those were built upstream and their source route is UNVERIFIED; do not reuse them.
- **Python version:** upstream is 3.8. The python sibling is 3.15.2. Route B's poetry lock may not resolve on 3.15 (UNVERIFIED). Route A's deb may bundle its own Python (UNVERIFIED).
- **Age:** the release is from 2020. The Docker Hub tags are not updated since 2020-12-31, and the upstream repo's last push is UNVERIFIED (not fetched). Expect security and dependency gaps; say so in the PR.
- **Background scanner:** the scan daemon runs continuously and is CPU and I/O heavy on large libraries (draft caveat, inferred).
- **Credentials:** the app needs a seedbox (SFTP/SSH) configured in the UI before it does anything useful. The test cannot cover this.
- **Checksum:** no published checksum; the local pin is trust on first use.
- **Blockers:** Route B needs the upstream toolchain to work on ubuntu 26.04 and on arm64; that is UNVERIFIED. Route A is blocked for arm64 by design.

## 11. Build and test steps

From `apps/seedsync/`:

1. `docker buildx bake --print`: must exit 0.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Empty `/config`, read-only:
   ```sh
   docker volume create seedsync-probe-config
   docker run --rm -d --name seedsync-probe --read-only --tmpfs /tmp \
     -v seedsync-probe-config:/config seedsync:<version>
   docker logs -f seedsync-probe   # expect the web server to start and report a listen line on 8800
   ```
   Pass: the container stays up, logs a readiness line, no traceback. Then `docker rm -f seedsync-probe; docker volume rm seedsync-probe-config`.
4. Restart on the same volume to confirm `settings.cfg` is kept (not reseeded).
5. `forgetool containers test --image seedsync:<version> --config ./container-test.yaml`. If `forgetool` is unavailable, check port 8800 and `/` by hand.
6. arm64: only if Route B was chosen and the arm64 build step is run; otherwise state that arm64 was not built.

## 12. PR checklist

- Branch `feat/add-seedsync` from `main`; commit `feat(seedsync): add new container`; PR title the same.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md` with every section and checkbox kept; tick only what applies.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign; the `license/cla` check shows status.
- Say what was not tested: arm64 (no `.deb`; Route B untested unless built), the seedbox connection, the scan daemon under load, and the upstream checksum (none published).
- State which route was used (A or B) and why, and the chosen `image-all` platforms.
- No `DOWNSTREAM_CHANGES.md` (seedsync is not a `FROM` base).
