# headphones — implementation plan
> Source: ./draft.md · Target: apps/headphones/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v0.6.4 (GitHub release tag https://github.com/rembo10/headphones/releases/tag/v0.6.4). linuxserver builds from the **master** branch commit, not this tag. Chart image is `ghcr.io/linuxserver/headphones:version-a78f38c1`, and the commit behind that label is UNVERIFIED. We pin the tag for reproducibility; this differs from linuxserver and is a decision to state in the PR. |
| Release date | UNVERIFIED: the tag page shows two timestamps (2025-07-01 and 2025-06-01). |
| Renovate | `datasource=github-releases depName=rembo10/headphones versioning=semver` (tag `v0.6.4` is semver with a `v` prefix; the same style as `apps/nzbhydra2`). |
| License | GPL-3.0: the LICENSE file at v0.6.4 is the GNU GPL v3 text (https://raw.githubusercontent.com/rembo10/headphones/v0.6.4/LICENSE). Whether the copyright headers say "or later" is UNVERIFIED, so the SPDX id is `GPL-3.0-only` or `GPL-3.0-or-later` depending on that check. |
| Source URL | https://github.com/rembo10/headphones |
| Download | https://github.com/rembo10/headphones/archive/refs/tags/v0.6.4.tar.gz (source archive; the release has no binary asset). |
| Checksum source | None for the release archives. UNVERIFIED upstream checksum. Pin the local sha256 of the downloaded tarball in the Dockerfile after computing it in the build (not done in this plan run). |
| Python dependencies | **None at v0.6.4.** There is no `requirements.txt` in the tarball; dependencies are vendored under `lib/`. `requirements-dev.txt` is for development only. So no pip step is needed for this tag. The linuxserver master commit may differ (UNVERIFIED). |
| Python version | Code keeps Python 2 compatibility shims (`sys.version_info` checks). Compatibility with the 3.15 python base is UNVERIFIED and must be proven in the run step. |
| Packages (upstream) | linuxserver installs `ffmpeg flac mc python3` on alpine 3.17 and compiles `shntool-3.0.10` from `patches/` (https://raw.githubusercontent.com/linuxserver/docker-headphones/2eda0d5edcbb/Dockerfile). |
| Run command | `s6-setuidgid abc python3 /app/headphones/Headphones.py --datadir=/config` (root/etc/s6-overlay/s6-rc.d/svc-headphones/run). |
| CLI | `-p/--port` forces the port; `--datadir` sets where config and DB live (Headphones.py at v0.6.4). |
| Port | 8181/tcp (web UI). `HTTP_PORT` default is 8181 (`headphones/config.py` line 139). |
| Config seeding | linuxserver copies `/defaults/config.ini` to `/config/config.ini` only when missing (init-headphones-config/run). The defaults file sets `http_host = 0.0.0.0`, `launch_browser = 1`, `check_github = 1`, `cue_split_shntool_path = "/usr/bin"`, `download_dir = ""`, `destination_dir = ""`. |
| Env vars (real) | `TZ` only (readme-vars.yml). The app reads no other environment variables. |
| Data path | `/config` (`config.ini`, database and logs under the datadir). |
| Dependencies | None. Indexers and download clients are configured in the web UI. |
| Chart security | `runAsUser: 0`, `readOnlyRootFilesystem: false`, persistence `/config`, service port 10064 to 8181 (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/headphones/values.yaml). |
| Deprecation notice | linuxserver `99-deprecation`: "This image is deprecated. We will not offer support for this image and it will not be updated." |

## 2. Target layout

Files in `apps/headphones/`:
- `Dockerfile`
- `docker-bake.hcl`
- `settings.yaml`
- `container-test.yaml`
- `start.sh`
- `defaults/config.ini` (seed file, copied only when `/config/config.ini` is missing; this is the one extra directory the app needs, because the upstream config defaults must be seeded into `/config`)

No `etc/` or `health/`. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (digest from `apps/bazarr/Dockerfile`). It fits because headphones is pure Python with no pip dependencies at v0.6.4: the base's Python runs the app directly. Closest sibling: `apps/bazarr` (Python app from a downloaded release, `USER apps`, `WORKDIR /config`, `start.sh` that `exec`s `/usr/local/bin/python`). Python's `/usr/local/bin/python` is the path bazarr uses; confirm it exists in the base during the build.

## 4. Dockerfile

1. `FROM` line above. `ARG VERSION`, `ENV` for Python behaviour: `PYTHONDONTWRITEBYTECODE=1` so Python does not try to write `__pycache__` under the read-only `/app` (see section 9).
2. `USER root`. Install runtime packages only if they are missing from the base (check with `command -v ffmpeg flac shntool`):
   ```dockerfile
   RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         ffmpeg \
         flac \
         shntool \
    && rm -rf /var/lib/apt/lists/*
   ```
   The apt versions are not tied to `VERSION`, so no pin is needed. shntool comes from apt rather than linuxserver's source compile (package name and version to check in the 26.04 archive, UNVERIFIED). Confirm `/usr/bin/shntool` exists, because `cue_split_shntool_path` is `/usr/bin` in the defaults.
3. Download the source archive and extract it into `/app/headphones`, verifying the local sha256 pin:
   ```dockerfile
   ARG VERSION
   ARG HEADPHONES_SHA256="<sha256 of v0.6.4.tar.gz, computed in the build>"
   RUN mkdir -p /app/headphones \
    && curl -fsSL -o /tmp/headphones.tar.gz \
         "https://github.com/rembo10/headphones/archive/refs/tags/${VERSION}.tar.gz" \
    && echo "${HEADPHONES_SHA256}  /tmp/headphones.tar.gz" | sha256sum -c - \
    && tar xzf /tmp/headphones.tar.gz -C /app/headphones --strip-components=1 \
    && rm -f /tmp/headphones.tar.gz \
    && chown -R root:root /app/headphones \
    && chmod -R 755 /app/headphones
   ```
   The `HEADPHONES_SHA256` value is a placeholder: compute it from the downloaded archive in the build and pin it (not an upstream checksum). Do not commit the placeholder.
4. License: copy `/app/headphones/LICENSE` to `/usr/share/licenses/headphones/LICENSE` (the archive has it, so no separate download is needed).
5. Seed file: `defaults/config.ini` comes from the repo's `root/defaults/config.ini` at v0.6.4 (or the linuxserver file, adjusted). Make these changes in our copy: `launch_browser = 0` (no browser in a container), `check_github = 0` (no outbound update check, which would write under `/app`), and `http_host = 0.0.0.0`. The `http_port` line is not in the file; the code default 8181 applies. Document each change in the PR.
6. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /
   WORKDIR /config
   EXPOSE 8181
   VOLUME /config
   ```
   Confirm the `defaults/` directory is copied by `COPY . /`, which the `.dockerignore` allow-list permits.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "headphones"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=rembo10/headphones versioning=semver
  default = "v0.6.4"
}

variable "LICENSE" {
  default = "GPL-3.0-only"   // confirm the copyright headers before committing: -only or -or-later
}

variable "SOURCE" {
  default = "https://github.com/rembo10/headphones"
}
```
Then the default group, `image`, `image-local` and `image-all` targets copied from `apps/nzbhydra2/docker-bake.hcl`. `VERSION` must equal the Dockerfile `ARG VERSION`, and it includes the `v` prefix in both files. Validate with `cd apps/headphones && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/rembo10/headphones"
ports:
  - port: 8181
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: UMASK
    default: "002"
    required: false
volumes:
  - path: /config
    required: true
```
- `env`: only `TZ` is read by the app's readme; `UMASK` is the sibling convention (bazarr, nzbhydra2). Keep `UMASK` only because the ContainerForge runtime uses it for file modes; confirm that is how the base handles it, and drop it otherwise.
- `dependencies`: none. Do not invent database or service dependencies.
- `HTTP_PORT` is not exposed as an env var in `settings.yaml`: the app reads it from `config.ini`, and `start.sh` does not override it.

## 7. start.sh

```bash
#!/usr/bin/env bash

if [[ ! -f /config/config.ini ]]; then
    cp /defaults/config.ini /config/config.ini
fi

cd /app/headphones
exec \
    /usr/local/bin/python \
        /app/headphones/Headphones.py \
            --datadir=/config
```
- Idempotent: seeds `/config/config.ini` only when missing, so user state is never overwritten (start-script rule). The `if` uses the file test, not a directory check.
- Never writes to `/app`. `cd /app/headphones` is needed because the app resolves its `lib/` and `data/` relative to its own file; that is a read, not a write.
- `exec` so Python is the PID 1 handoff target.
- Use `/usr/local/bin/python` as bazarr does (no PATH reliance). Confirm the path in the base.
- No env reads other than `TZ` (set by the base) and `HOME` if any.
- Bind address: `http_host = 0.0.0.0` is in the seeded config, so the server listens on all interfaces. Confirm with `ss -ltn` in the run step.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8181'
http:
- port: '8181'
  path: /
filePaths:
- /app/headphones/Headphones.py
- /defaults/config.ini
- /usr/share/licenses/headphones/LICENSE
- /start.sh
```
- Every port in `settings.yaml` (8181) has a `tcp` and an `http` probe.
- `timeoutSeconds: 180` matches the most common sibling value. Confirm headphones starts within it on an empty `/config` (Python startup plus CherryPy-style server start; UNVERIFIED).
- The test runs without env vars, so no required-env path needs `filePaths`. The app has no required env vars.
- No database dependency, so the narrowed exception does not apply: write full probes as above.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `--datadir` (config.ini, DB, logs) | `/config` (start.sh) |
| `__pycache__` next to the `.py` files under `/app/headphones` | Prevented by `PYTHONDONTWRITEBYTECODE=1` in the Dockerfile. If the app still tries to write, set `PYTHONPYCACHEPREFIX=/tmp/pycache` instead; never write under `/app`. |
| Update check (`check_github = 1` in upstream defaults) | Set to `0` in our seed file; confirm nothing else writes under `/app` on update. |
| Downloads and encoding scratch (`download_dir`, `destination_dir`, `cue_split` temp files) | Default values are empty, so the app uses its own paths; they must resolve under `/config` or `/tmp`. Set them under `/config` in a later change if needed (UNVERIFIED which default the app uses for the scratch dir). |
| `/tmp` | Ephemeral scratch. Caches go here, never `/config`. |
| Runtime user | `USER apps` (uid 568). Linuxserver runs as root and drops to `abc`; ContainerForge runs as `apps`. |

Run with `--read-only --tmpfs /tmp` and an empty `/config` volume, which proves the empty-`/config` start and the read-only root.

## 10. Risks, caveats and open questions

- **Version drift from linuxserver.** linuxserver builds master; this plan pins v0.6.4 (a 2025 tag). Master may have fixes or changes that v0.6.4 lacks. State this in the PR and, if the user wants master, switch to a commit pin with the same sha256 pattern.
- **Python 3.15 compatibility.** The upstream code has Python 2 shims and was last tagged in 2025 for a 3.x runtime. Whether it runs on the 3.15 base is UNVERIFIED and is the main runtime risk.
- **Release date ambiguous.** Two timestamps on the tag page; do not use either until confirmed.
- **License SPDX id.** `GPL-3.0-only` vs `-or-later` depends on headers that were not checked (blocker for `docker-bake.hcl` `LICENSE`).
- **Checksum pin.** No upstream checksum; the `HEADPHONES_SHA256` value must be computed and pinned. Placeholder until then.
- **shntool package.** The apt package name and version on 26.04 are UNVERIFIED; linuxserver compiles it from source.
- **Manual setup.** Indexer and download client accounts are set in the web UI; out of scope for the container test.
- **arm64 not built here.** Pure Python, so arm64 should work, but it is not run in this plan.

## 11. Build and test steps

Run from `apps/headphones` (protocol: `.github/instructions/build-test-protocol.instructions.md`):

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`. Compute and pin `HEADPHONES_SHA256` from the downloaded archive in this step.
3. Empty-`/config` run, read-only root:
   ```sh
   docker volume create headphones-probe-config
   docker run --rm -d --name headphones-probe --read-only --tmpfs /tmp \
     -v headphones-probe-config:/config headphones:v0.6.4
   docker logs -f headphones-probe
   docker exec headphones-probe ss -ltn    # confirm 0.0.0.0:8181
   docker rm -f headphones-probe; docker volume rm headphones-probe-config
   ```
   Expected readiness: the process stays up, the log shows the CherryPy/web server start on port 8181 (exact text UNVERIFIED until run), and no traceback.
4. `forgetool containers test --image headphones:v0.6.4 --config ./apps/headphones/container-test.yaml`. If forgetool is not available, check the probes by hand as in step 3.
5. arm64 only if the amd64 build fails for an arm64 reason, per the protocol.
6. Remove scratch containers and volumes between rounds (round limit 10).

## 12. PR checklist

- Branch `feat/add-headphones`; commit `feat(headphones): add new container`; target `main`.
- PR title in Conventional Commits form: `feat(headphones): add new container`.
- PR description from `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Only check what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows the status).
- State what was not tested: arm64 build (if not run), Python 3.15 run (if it fails), and the version difference from linuxserver's master build.
- Downstream check: none (not a `FROM` base).
- Pre-completion checklist from AGENTS.md / copilot-instructions.md, including `docker buildx bake --print` output.
