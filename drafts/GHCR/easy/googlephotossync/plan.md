# googlephotossync — implementation plan
> Source: ./draft.md · Target: apps/googlephotossync/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `3.2.5` (GitHub release `3.2.5`, published 2024-07-14). Source: https://api.github.com/repos/gilesknap/gphotos-sync/releases/latest (via `gh api`). Draft tag matches. |
| Renovate | `// renovate: datasource=pypi depName=gphotos-sync` (pip package). UNVERIFIED: the PyPI name was not checked on a fetched page; confirm on https://pypi.org/project/gphotos-sync/ before commit. |
| License | Apache-2.0 (GitHub API `license.spdx_id`, https://api.github.com/repos/gilesknap/gphotos-sync/license). Note: draft Overview does not state a license; `docker-bake.hcl` must use `Apache-2.0`, not the sibling default. |
| Source URL | https://github.com/gilesknap/gphotos-sync |
| Download (all arches) | `https://github.com/gilesknap/gphotos-sync/releases/download/3.2.5/gphotos_sync-3.2.5-py3-none-any.whl` (asset listed in the release). Also `gphotos_sync-3.2.5.tar.gz` in the same release. Pure-Python wheel, so no per-arch URL. |
| Checksum source | None published as a release asset (no `sha256` file in the release listing). UNVERIFIED: no upstream checksum. Pin the wheel by version and verify with `pip install --require-hashes` if a hash is taken from a trusted run, or document the gap. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/gilesknap/gphotos-sync/master/Dockerfile: build stage `python:3.11`, runtime `python:3.11-slim`, venv at `/venv`, `pip install .`, `ENTRYPOINT ["gphotos-sync"]`, `CMD ["--version"]`, no `USER` (root), no `VOLUME`, no `EXPOSE`, only env `PATH`. |
| Ports | None. The tool is a one-shot CLI that downloads photos; it does not listen. |
| Config and data paths | UNVERIFIED: the default token file and download directory were not confirmed from a fetched page. Draft expects downloads and OAuth tokens under `/config`; confirm the CLI flags (for example a config or download directory option) in the upstream docs at https://gilesknap.github.io/gphotos-sync before writing `start.sh`. |
| Env vars | UNVERIFIED: no env var was confirmed from a fetched page. Only the Dockerfile `PATH` is confirmed. Do not add env vars until the CLI options are checked. |
| Dependencies | None (no database). |
| Architecture | UNVERIFIED for upstream image platforms. Pure-Python wheel implies both `amd64` and `arm64` should work on the python base; the draft's `yes*` is still unconfirmed. Build-test both. |

## 2. Target layout

- `apps/googlephotossync/Dockerfile`
- `apps/googlephotossync/docker-bake.hcl`
- `apps/googlephotossync/settings.yaml`
- `apps/googlephotossync/container-test.yaml`
- `apps/googlephotossync/start.sh`

No `defaults/`, `etc/`, `health/` or `scripts/` needed (no config seeding beyond the token directory, which `start.sh` creates). Never use `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` for the final stage (the draft's `python` runtime). Fits because the app is a pure-Python pip package and the python base already provides `/app/venv`, pip, and the `apps` user. Closest sibling: `apps/k8s-sidecar` (python base, venv under `/app`, pip install from a wheel or sdist). A pip-only app does not need the ubuntu base directly; the python base already sits on ubuntu.

Note on the draft's Foundation line: the draft names ubuntu as foundation and python as runtime. The python base is itself built on `ghcr.io/trueforge-org/ubuntu:26.04`, so use the python base only.

## 4. Dockerfile

Single stage is enough (no compilation). Steps:

1. `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e...` with `ARG VERSION` and `ARG VENDOR` only if the bake target passes them. Keep `VERSION` aligned with `docker-bake.hcl`.
2. `USER root`, then install nothing with apt (no apt packages required; confirm `pip` is already in the base, which `python/Dockerfile` confirms via `/app/venv`).
3. Install into a dedicated venv under `/app/venv` only at build time, with the wheel downloaded from the release:
   ```dockerfile
   ARG VERSION
   RUN set -eux; \
       curl -fL -o /tmp/gphotos_sync.whl \
         "https://github.com/gilesknap/gphotos-sync/releases/download/${VERSION}/gphotos_sync-${VERSION}-py3-none-any.whl"; \
       /app/venv/bin/pip install --no-cache-dir /tmp/gphotos_sync.whl; \
       rm -f /tmp/gphotos_sync.whl
   ```
   Note: the venv in the python base is already at `/app/venv`, so no extra `python -m venv` is needed. `PIP_NO_CACHE_DIR=1` is already set in the base.
4. License: the wheel's `dist-info` carries the Apache-2.0 license; copy it to `/usr/share/licenses/googlephotossync/` (`mkdir -p` then copy from the venv `dist-info` `LICENSE*` files). If none is present, note it in section 10.
5. `chown -R apps:apps /app/venv` and `chmod -R 755 /app/venv`, as the python base does.
6. Tail (matches sibling layout):
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /
   ENV PATH=/app/venv/bin:$PATH \
       HOME=/config
   VOLUME /config
   ```
   Add `HEALTHCHECK` only if a usable probe exists; there is no listening port, so do not copy the python sibling's health check (`/healthcheck.sh` needs a port or HTTP target). Decide in section 8.
7. Entrypoint: `ENTRYPOINT` is not needed when `start.sh` is the command. `start.sh` reaches `/start.sh` through `COPY --chmod=0755 . /` (no separate COPY), and end `start.sh` with `exec gphotos-sync ...`.
8. No `EXPOSE`.

## 5. docker-bake.hcl

- `target "docker-metadata-action" {}`
- `variable "APP" { default = "googlephotossync" }`
- `variable "VERSION" { // renovate: datasource=pypi depName=gphotos-sync  default = "3.2.5" }` (see section 1 for the renovate check)
- `variable "LICENSE" { default = "Apache-2.0" }`
- `variable "SOURCE" { default = "https://github.com/gilesknap/gphotos-sync" }`
- `group "default" { targets = ["image-local"] }`
- `target "image"` with `args = { VERSION = "${VERSION}" }` and labels `org.opencontainers.image.source` = `${SOURCE}`, `org.opencontainers.image.licenses` = `${LICENSE}`
- `target "image-local"` inherits `image`, `output = ["type=docker"]`, `tags = ["${APP}:${VERSION}"]`
- `target "image-all"` inherits `image`, `platforms = ["linux/amd64", "linux/arm64"]` (both are build-tested, see section 11)

Validate with `cd apps/googlephotossync && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/gilesknap/gphotos-sync"
ports:
  []
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  []
```

- `ports`: none (confirmed: the tool does not listen).
- `env`: only `TZ` (standard). Do not add app env vars until the CLI options are confirmed (section 1, UNVERIFIED). Any env var added must be read by `start.sh`.
- `volumes`: `/config` (token and download storage, per the draft; confirm the path in section 1).
- `dependencies`: none.

## 7. start.sh

Rules: idempotent, empty `/config` safe, no writes to `/app`, caches in `/tmp`, `exec` the final process.

1. `set -euo pipefail`; `export HOME=/config` (token and cache location, see caches below).
2. `mkdir -p /config/googlephotos /tmp/gphotos-cache`; set `XDG_CACHE_HOME=/tmp/cache` so pip-style caches never land in `/config`.
3. Pass the token and download directory as CLI options (exact flags UNVERIFIED, see section 1). Do not seed any file; the tool creates its token on the first interactive sign-in.
4. On first run with no token, the tool needs an interactive browser authorization. `start.sh` should print a clear log line that the user must complete the OAuth step and that the token is written to `/config`. It must not loop or exit silently.
5. Final line: `exec gphotos-sync <flags> "$@"` (or the flags the upstream docs use for a sync run). Use `--version` only as the image default `CMD` if needed.
6. Never write secrets to logs or the process list; read any client secret path from a file under `/config`, not from an env var on the command line.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
filePaths:
- /start.sh
- /app/venv/bin/gphotos-sync
```

- No `tcp` or `http` probes: `settings.yaml` lists no ports, and the tool is a one-shot sync that does not listen.
- `runners` (if forgetool supports a version check): run `gphotos-sync --version` and assert exit 0. Confirm the schema allows it before adding it; do not invent fields.
- The test runs with no env vars and no token, so the interactive OAuth branch is not exercised. Note this in section 10, and run that path manually per section 11.
- `timeoutSeconds`: use a value matching the python sibling (`apps/k8s-sidecar`, `apps/bazarr`). Confirm the sibling value before writing it.

## 9. Rootless and read-only-rootfs adaptations

- Runtime user: `USER apps` (final stage). Build stage runs as root only for the wheel install into `/app/venv`, and `/app/venv` is chowned to `apps`.
- Upstream writes: upstream runs as root with no volume. The token file and download directory are written under `$HOME`, which `start.sh` sets to `/config`, so no upstream path needs remapping beyond `HOME` and the CLI download-directory flag.
- Caches: pip and any temp files go to `/tmp` (`PIP_NO_CACHE_DIR=1` already in base; `XDG_CACHE_HOME=/tmp/cache`).
- `/app` stays read-only: no writes into the venv at runtime.
- Read-only test: `docker run --read-only --tmpfs /tmp -v googlephotossync-probe-config:/config ...` should start far enough to print the OAuth message without errors.
- Draft security expectations (`runAsUser 0`, `readOnlyRootFilesystem: false`, `/storage` PVC) are chart values. ContainerForge runs `USER apps` and `/config`; the chart values must be remapped to `/config`, which is a chart-side change outside this app.

## 10. Risks, caveats and open questions

- Draft caveat confirmed as a user step: a Google OAuth client must be created by the user in Google Cloud, and the first sign-in needs an interactive browser authorization. Not testable in CI.
- Draft caveat (inferred, not verified): Google Photos API access is restricted, so full-library downloads may be limited. UNVERIFIED: no current Google documentation was fetched; treat as a runtime risk.
- Upstream release is `3.2.5` from 2024-07-14, over a year old at the plan date. Check for a newer release before writing `VERSION` (the release listing returned only `3.2.5` as latest).
- UNVERIFIED: the wheel's `Requires-Python` vs the base Python 3.15.2 was not checked; confirm at build.
- Checksum: no upstream checksum asset. Document the gap in the PR.
- Architecture: pure-Python wheel should work on both arches, but no arch-specific upstream claim is confirmed. Build and test both.
- Exact CLI flags, config/download directory flags and env vars are UNVERIFIED (section 1). Do not add them to `settings.yaml` until confirmed on https://gilesknap.github.io/gphotos-sync.
- Blockers: none for the image build. The first real sync needs user-side Google credentials, so a full functional test is not possible in CI.

## 11. Build and test steps

From `apps/googlephotossync/`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name googlephotossync-probe --read-only --tmpfs /tmp -v googlephotossync-probe-config:/config googlephotossync:3.2.5`, then `docker logs -f googlephotossync-probe`. Expected readiness signal: the tool prints its version or the OAuth prompt and does not exit with a traceback. Clean up with `docker rm -f googlephotossync-probe; docker volume rm googlephotossync-probe-config`.
4. `forgetool containers test --image googlephotossync:3.2.5 --config ./apps/googlephotossync/container-test.yaml`
5. Optional arm64: `docker buildx bake --set image-local.platform=linux/arm64 image-local` (only if the amd64 build is clean; the draft marks arm64 as unconfirmed).

## 12. PR checklist

- Branch: `feat/add-googlephotossync`
- Commit: `feat(googlephotossync): add new container`
- Title: `feat(googlephotossync): add new container`
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- Use `.github/PULL_REQUEST_TEMPLATE.md`, check only the boxes that apply.
- Say what was not tested: the interactive OAuth sign-in, real Google Photos downloads, and any arm64 build not run.
