# plextraktsync — implementation plan
> Source: ./draft.md · Target: apps/plextraktsync/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 0.35.23 (PyPI `plextraktsync` 0.35.23; git tag `0.35.23`, commit dated 2026-11-19). Chart tag `ghcr.io/taxel/plextraktsync:0.35.23`. Sources: https://pypi.org/pypi/plextraktsync/json, https://api.github.com/repos/Taxel/PlexTraktSync/tags |
| Release assets | No GitHub Releases (`releases/latest` returns 404). Use the PyPI package. |
| Renovate | `datasource=pypi depName=plextraktsync versioning=pep440` (UNVERIFIED: versioning string; PyPI is the verified source). |
| License | MIT (GitHub API and PyPI classifier). |
| Source URL | https://github.com/Taxel/PlexTraktSync |
| Per-arch downloads | Pure Python, `py3-none-any` wheel: `https://files.pythonhosted.org/packages/8c/0b/f41a3a3695f7560185d252488a9d54f17c05a009d06f8fbc029d01c4d9e4/plextraktsync-0.35.23-py3-none-any.whl`. Same file for amd64 and arm64. Requires Python >=3.10 (base is 3.15). |
| Checksum source | PyPI JSON `digests` field for the wheel (UNVERIFIED: digest values not extracted in this run; read them before pinning with `--require-hashes`). |
| Upstream Dockerfile reviewed | Pinned commit `5f951838eaea4466d078571cc548ac51d5ed2341`: https://api.github.com/repos/Taxel/PlexTraktSync/contents/Dockerfile?ref=5f951838eaea4466d078571cc548ac51d5ed2341. Alpine base (`python:$PYTHON_VERSION-alpine$ALPINE_VERSION`, 3.13 / 3.21), pipenv-built venv, `entrypoint.sh` as `/init`, `VOLUME /app/config`, `VOLUME $HOME`, user uid/gid 1000. The `main` branch Dockerfile differs (UNVERIFIED which one the GHCR 0.35.23 image was built from). |
| entrypoint.sh (pinned) | https://api.github.com/repos/Taxel/PlexTraktSync/contents/entrypoint.sh?ref=5f951838eaea4466d078571cc548ac51d5ed2341. Supports `PUID`/`PGID`, `APP_USER`/`APP_GROUP`; starts as root and drops to the app user with `setpriv`. Not used by ContainerForge (rootless). |
| Env vars (upstream image) | `PTS_CONFIG_DIR=/app/config`, `PTS_CACHE_DIR=/app/config`, `PTS_LOG_DIR=/app/config`, `PTS_IN_DOCKER=1`, `PYTHONUNBUFFERED=1`, `HOME=/app/xdg`, `XDG_*` under `/app/xdg`, `PUID`, `PGID`. |
| Ports | None. |
| Data paths | Config, token and cache in `PTS_CONFIG_DIR` (UNVERIFIED: exact token and settings file names). |
| Dependencies | None at runtime. External: Trakt API application and device authorisation on first run; Plex server with a token. |

## 2. Target layout

- `apps/plextraktsync/Dockerfile`
- `apps/plextraktsync/docker-bake.hcl`
- `apps/plextraktsync/settings.yaml`
- `apps/plextraktsync/container-test.yaml`
- `apps/plextraktsync/start.sh`

No `defaults/`, `etc/`, `scripts/` or `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. Fits a pure-Python pip install into `/app/venv` (already provided by the base). Closest sibling: `apps/bazarr` (python with venv). The upstream Alpine and pipenv stages are dropped: no compile is needed.

## 4. Dockerfile

1. `ARG VERSION`, `USER root`.
2. `/app/venv/bin/pip install --no-cache-dir "plextraktsync==${VERSION}"` (base sets `PIP_NO_CACHE_DIR`). Optionally pin with `--require-hashes` against the PyPI digest (see section 1).
3. Copy the MIT license into `/usr/share/licenses/plextraktsync/LICENSE` by extracting it from the wheel `dist-info` (UNVERIFIED: file name inside the wheel).
4. `chown -R apps:apps /app && chmod -R 755 /app`.
5. `ENV PTS_IN_DOCKER=1 PTS_CONFIG_DIR=/config PTS_CACHE_DIR=/tmp/plextraktsync PTS_LOG_DIR=/config PYTHONUNBUFFERED=1 HOME=/config`. Caches go to `/tmp`, never `/config`.
6. `USER apps`, `COPY --chmod=0755 . /`, `VOLUME /config`.

No EXPOSE (no ports).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "plextraktsync" }
variable "VERSION" {
  // renovate: datasource=pypi depName=plextraktsync versioning=pep440
  default = "0.35.23"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/Taxel/PlexTraktSync" }
```

Four standard targets and the default group as in `apps/adguardhome-sync`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Taxel/PlexTraktSync"
ports:
  []
env:
  - name: PUID
    default: "1000"
    required: false
  - name: PGID
    default: "1000"
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

`PUID` and `PGID` are read by the upstream entrypoint only. ContainerForge runs rootless, so they are not read by `start.sh`; list them only if the image honours them (UNVERIFIED: decide before merge; the rule "do not invent env vars the app does not read" applies, so the default is to omit them). Upstream config env vars `PTS_*` are set in the image and should not be user-facing unless confirmed.

## 7. start.sh

- `mkdir -p /config`; create nothing else. The tool creates its token and config on first run (device authorisation).
- `export PTS_CONFIG_DIR=/config PTS_CACHE_DIR=/tmp/plextraktsync PTS_LOG_DIR=/config`.
- Run mode: the draft describes one sync process; the chart runs a CronJob. Decide one of: (a) run one sync then exit (container test then fails the "process stays running" criterion), or (b) loop with a sleep interval. Option (b) needs an interval env var, which must be confirmed in the upstream docs before it is named (UNVERIFIED).
- `cd /config`, then `exec /app/venv/bin/plextraktsync <args>` (UNVERIFIED: exact CLI subcommand and arguments; confirm with `plextraktsync --help` in the built image).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
runners:
- entrypoint: /app/venv/bin/plextraktsync
  cmd: "--version"
  expectedOutput: "0.35.23"
filePaths:
- /usr/share/licenses/plextraktsync/LICENSE
```

No `tcp` or `http` probes (no ports). The `--version` flag is UNVERIFIED: confirm it exists; if not, use an import check `/app/venv/bin/python -c` with a space-free code string, as `apps/python` does. Do not weaken the check to a presence-only test.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `PTS_CONFIG_DIR`, `PTS_LOG_DIR` (`/app/config`) | `/config` |
| `PTS_CACHE_DIR` (`/app/config`) | `/tmp/plextraktsync` (caches stay out of `/config`) |
| `HOME` / `XDG_*` (`/app/xdg`) | `HOME=/config` for user files, XDG caches under `/tmp` |
| pipenv venv (`/root/.local`) | `/app/venv` at build time |

Draft expectations reconciled: chart runs as UID 0 with writable root; this image runs as `apps` (uid 568 in the base) and works with `--read-only --tmpfs /tmp`. Not privileged. The chart mounts `/app/config`; this image uses `/config`, so users must move existing data.

## 10. Risks, caveats and open questions

- Run mode (section 7) is the main open decision. The chart uses a CronJob; the image must match the chosen mode, or the readiness check fails.
- First run needs interactive Trakt device authorisation; a container test cannot complete it. Keep the test to version and file checks, and state this in the PR.
- Trakt API application and Plex server are external: the sync does nothing without them.
- Two upstream Dockerfiles exist (pinned commit vs `main`); plan follows the pinned one that the draft links (section 1).
- Pinned commit is Alpine/musl-based; the copy-from option in the draft is `no` for good reason (the image cannot be copied onto glibc ubuntu), and the pip route avoids it.
- PID 1: `exec` the CLI when there is no loop.
- arm64: pure Python; expected to work (not built).

## 11. Build and test steps

```sh
cd apps/plextraktsync
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name plextraktsync-probe --read-only --tmpfs /tmp \
  -v plextraktsync-probe-config:/config plextraktsync:0.35.23
docker logs -f plextraktsync-probe
forgetool containers test --image plextraktsync:0.35.23 --config ./apps/plextraktsync/container-test.yaml
docker rm -f plextraktsync-probe; docker volume rm plextraktsync-probe-config
```

Expected readiness signal: the CLI version line or the first sync start message; confirm the exact text after the image is built (UNVERIFIED). Confirm that an empty `/config` starts and that a second start with the same volume does not fail.

## 12. PR checklist

- Branch `feat/add-plextraktsync`, commit `feat(plextraktsync): add new container`, PR title matches, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge); only the user can sign it, and the `license/cla` check shows status.
- Say what was not tested: the build, the run on `--read-only`, the first-run Trakt authorisation, the Plex sync, arm64.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
