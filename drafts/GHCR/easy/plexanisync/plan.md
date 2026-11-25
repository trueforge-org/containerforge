# plexanisync — implementation plan
> Source: ./draft.md · Target: apps/plexanisync/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | v1.4.4, published 2026-07-11 (https://api.github.com/repos/RickDB/PlexAniSync/releases/latest). Chart tag `ghcr.io/rickdb/plexanisync:1.4.4`. |
| Release assets | None. The release has no binary; the tag source is the artifact. |
| Renovate | `datasource=github-tags depName=RickDB/PlexAniSync versioning=semver` (UNVERIFIED: datasource choice; no release assets exist, so github-releases would find nothing). |
| License | GPL-3.0 (GitHub API `license.spdx_id`, https://api.github.com/repos/RickDB/PlexAniSync). |
| Source URL | https://github.com/RickDB/PlexAniSync |
| Per-arch downloads | Pure Python, architecture independent. Same tarball for amd64 and arm64: `https://github.com/RickDB/PlexAniSync/archive/refs/tags/v1.4.4.tar.gz` (UNVERIFIED: tarball asset URL not fetched; the GitHub tag archive form is standard). |
| Checksum source | None published by upstream. Pin the tag's commit SHA and verify the archive against it (UNVERIFIED: commit SHA of tag v1.4.4 not retrieved in this run). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/RickDB/PlexAniSync/v1.4.4/Docker/PlexAniSync/Dockerfile. Stage 1 `FROM python:3.12` pip installs `requirements.txt` to `--user`. Stage 2 `FROM python:3.12-slim`, `WORKDIR /plexanisync`, copies `PlexAniSync.py`, `requirements.txt`, `custom_mappings_schema.json`, the `run/` scripts and the `plexanisync/` package, `CMD ["/plexanisync/runsync.sh"]`. No EXPOSE, VOLUME or USER. |
| runsync.sh | https://api.github.com/repos/RickDB/PlexAniSync/contents/Docker/PlexAniSync/run/runsync.sh?ref=v1.4.4. Loops `python PlexAniSync.py`, then sleeps `${INTERVAL}`. Exits only when `INTERVAL <= 0`. If `SETTINGS_FILE` is unset it runs `settingsupdater.py` first, which writes `settings.ini`. |
| Settings file | `PlexAniSync.py` reads `SETTINGS_FILE`, defaulting to `settings.ini` relative to the working directory (https://api.github.com/repos/RickDB/PlexAniSync/contents/PlexAniSync.py?ref=v1.4.4). Sections `ANILIST` and `PLEX`. |
| Env vars (upstream image) | `PLEX_SECTION=Anime`, `PLEX_URL=http://127.0.0.1:32400`, `PLEX_TOKEN=''`, `ANI_USERNAME=''`, `ANI_TOKEN=''`, `INTERVAL=3600`, `SETTINGS_FILE` (unset by default). |
| Ports | None. |
| Data paths | `settings.ini` in the working directory. No other persistent state found in the reviewed files. |
| Dependencies | None at runtime. External: a Plex server and AniList credentials. |

## 2. Target layout

- `apps/plexanisync/Dockerfile`
- `apps/plexanisync/docker-bake.hcl`
- `apps/plexanisync/settings.yaml`
- `apps/plexanisync/container-test.yaml`
- `apps/plexanisync/start.sh`
- `apps/plexanisync/run/settingsupdater.py` is needed only if the env-to-`settings.ini` mapping is kept. Reason: the upstream `runsync.sh` calls it. It must go in a path the `.dockerignore` allow-list covers, so use `defaults/` or `scripts/`, not `run/`. Note: `root/` must never be used.

No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. Fits a pure-Python pip install into `/app/venv`, which the base already provides. Closest sibling: `apps/bazarr` (python, venv). No runtime `ubuntu` stage is needed.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH` not needed (no per-arch download).
2. `USER root`, then download the tag archive for `VERSION` into `/tmp`, verify the pinned commit SHA, and extract the tree.
3. `/app/venv/bin/pip install --no-cache-dir -r requirements.txt` from the extracted tree (the base sets `PIP_NO_CACHE_DIR`). Pip cache stays out of `/config`.
4. Copy `PlexAniSync.py`, `custom_mappings_schema.json`, `plexanisync/` and the run script to `/app/plexanisync/`. Copy the license to `/usr/share/licenses/plexanisync/LICENSE`.
5. `chown -R apps:apps /app && chmod -R 755 /app`, then remove `/tmp` scratch.
6. `ENV PYTHONUNBUFFERED=1 SETTINGS_FILE=/config/settings.ini INTERVAL=3600 PLEX_SECTION=Anime`. Do not set `PLEX_URL`, `PLEX_TOKEN` or credentials as image defaults.
7. `USER apps`, `COPY --chmod=0755 . /`, `VOLUME /config`.

No EXPOSE (no ports).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "plexanisync" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=RickDB/PlexAniSync versioning=semver
  default = "1.4.4"
}
variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/RickDB/PlexAniSync" }
```

Four standard targets and the default group as in `apps/adguardhome-sync`. Validate with `docker buildx bake --print`. Note: upstream SPDX reads `GPL-3.0`; use the exact SPDX id of the license file (UNVERIFIED which of `GPL-3.0` / `GPL-3.0-only` the license text uses).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/RickDB/PlexAniSync"
ports:
  []
env:
  - name: PLEX_SECTION
    default: "Anime"
    required: false
  - name: PLEX_URL
    default: "http://127.0.0.1:32400"
    required: false
  - name: PLEX_TOKEN
    default: ""
    required: false
  - name: ANI_USERNAME
    default: ""
    required: false
  - name: ANI_TOKEN
    default: ""
    required: false
  - name: INTERVAL
    default: "3600"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  []
```

Credentials are `required: false` with an empty default, because the settings rule forbids `required: true` with an empty default unless `start.sh` generates or handles it, and the image must start without env vars (test runs with none). `start.sh` reads them and warns, but does not fail startup (see section 7); document in the PR that they are needed for a real sync. Upstream `PLEX_URL` default is `http://127.0.0.1:32400`; keep it as-is.

## 7. start.sh

- Create `/config` if missing. If `/config/settings.ini` is missing, generate it from the env (via the copied settings updater, or a minimal `printf` template with the `ANILIST` and `PLEX` sections). Never overwrite an existing file.
- `cd /config` so relative paths resolve there (`PlexAniSync.py` reads `settings.ini` from cwd unless `SETTINGS_FILE` is set).
- Export `SETTINGS_FILE=/config/settings.ini`.
- Loop: `while true; do /app/venv/bin/python /app/plexanisync/PlexAniSync.py || echo "sync failed"; [ "${INTERVAL}" -gt 0 ] || break; sleep "${INTERVAL}"; done` (mirrors upstream `runsync.sh`; `set -u` safe defaults).
- Tokens are read from env only; do not write them into the process list or logs.
- Use `exec` only where the loop is the final process; otherwise the loop runs as the main process (PID 1 handoff note in section 10).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
runners:
- entrypoint: test -f /app/plexanisync/PlexAniSync.py
- entrypoint: /app/venv/bin/python
  cmd: "-c __import__('plexanisync');print('import'+'-ok')"
  expectedOutput: import-ok
filePaths:
- /app/plexanisync/PlexAniSync.py
- /usr/share/licenses/plexanisync/LICENSE
```

No `tcp` or `http` probes (no ports). Import name `plexanisync` is UNVERIFIED (package directory name in the upstream tree; confirm before merge). The test runs without env vars, so the path that requires credentials is not exercised; list the settings-generation code path in `filePaths` where applicable.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `settings.ini` in working dir (`/plexanisync`) | `/config/settings.ini`, selected via `SETTINGS_FILE` |
| pip `--user` install to `/root/.local` | `/app/venv` at build time (read-only at runtime) |
| Python bytecode and cache | `PYTHONDONTWRITEBYTECODE=1` (base sets it) |

Draft expectations reconciled: chart runs as UID 0 with writable root; the image runs as `apps` and works with `--read-only --tmpfs /tmp`, no write outside `/config` and `/tmp`. Not privileged.

## 10. Risks, caveats and open questions

- No Plex server and no AniList credentials in CI: `PlexAniSync.py` logs a fatal error and exits. The upstream loop keeps running after a failed run, so the container stays up with errors in the log. The protocol's "no fatal errors" criterion (section 3 step 3 of the build protocol) will not pass without a mock. This is an external-service blocker; the database exception does not apply (no DB). Decide before merge: a fake Plex/AniList endpoint in the test, or a narrower readiness signal (process alive plus startup banner) with a documented reason.
- Draft says `pip install` from repo; upstream installs `requirements.txt` plus a copy of the tree. Match upstream, not the draft.
- Chart runs a PyInstaller build; the image is plain Python. Output may differ (inferred, draft caveat).
- Settings file gotcha: the chart mounts `settings.ini` as a secret at `/plexanisync/settings.ini`. Users must move it to `/config/settings.ini`.
- PID 1: the loop is the main process. Prefer `exec` on the final Python call only if the loop is removed; otherwise use the base's init if present (UNVERIFIED which init the python base uses).
- arm64: pure Python, no arch-specific code; expected to work (not built).

## 11. Build and test steps

```sh
cd apps/plexanisync
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name plexanisync-probe --read-only --tmpfs /tmp \
  -v plexanisync-probe-config:/config plexanisync:1.4.4
docker logs -f plexanisync-probe
forgetool containers test --image plexanisync:1.4.4 --config ./apps/plexanisync/container-test.yaml
docker rm -f plexanisync-probe; docker volume rm plexanisync-probe-config
```

Expected readiness signal: the start banner from `start.sh` and a `PlexAniSync` log line; no `sync failed` on each iteration once credentials are supplied (test with fake values to exercise the loop, per section 10). Also restart with a populated `/config/settings.ini` and confirm it is not overwritten.

## 12. PR checklist

- Branch `feat/add-plexanisync`, commit `feat(plexanisync): add new container`, PR title matches, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge); only the user can sign it, and the `license/cla` check shows status.
- Say what was not tested: the build, the run on `--read-only`, the readiness path with real or fake Plex/AniList, arm64.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
