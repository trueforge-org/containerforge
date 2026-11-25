# archivebox — implementation plan
> Source: ./draft.md · Target: apps/archivebox/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `0.9.77` (GitHub tag `v0.9.77`, published 2026-10-27). Draft tag `ghcr.io/archivebox/archivebox:0.9.77` agrees. Source: https://api.github.com/repos/ArchiveBox/ArchiveBox/releases/latest |
| Renovate | `// renovate: datasource=github-releases depName=ArchiveBox/ArchiveBox versioning=semver` (tag has a `v` prefix; renovate strips it for `VERSION`) |
| License | MIT (GitHub SPDX `MIT`, PyPI `MIT`). Source: https://api.github.com/repos/ArchiveBox/ArchiveBox, https://pypi.org/pypi/archivebox/json |
| Source URL | https://github.com/ArchiveBox/ArchiveBox |
| Download | pip wheel `https://files.pythonhosted.org/.../archivebox-0.9.77-py3-none-any.whl` (pure Python, `requires_python >=3.13`). Or GitHub release asset `archivebox-0.9.77-py3-none-any.whl`. Install with `pip install archivebox==0.9.77`. |
| Checksum source | Release asset `SHA256SUMS`. Wheel sha256 `239267554814b9a6c9c0ba9c3880988238c146b34da7805fcf6461e98de15449`, sdist sha256 `a9e9839228a53d6cbf24e48c6e9d3c97329aef5c7c72bb279ea922743a90e687`. PyPI and the GitHub asset digest agree. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ArchiveBox/ArchiveBox/289d6a5904642b02c618e77f225aa28bd201a145/Dockerfile. Multi-stage: `FROM ${ABX_DL_IMAGE}` (default `archivebox/abx-dl:main`) plus `COPY --from=archivebox/sonic:1.4.9`. Python 3.13 venv at `/venv`, Node at `/opt/node`, Chromium and Playwright via the abxpkg plugin pipeline. Final: `WORKDIR /data`, `VOLUME /data`, `EXPOSE 5797`, `ENTRYPOINT ["dumb-init","--","/app/bin/docker_entrypoint.sh"]`, `CMD ["archivebox","server","--init","0.0.0.0:5797"]`. |
| Port | `5797/tcp` (upstream `EXPOSE 5797`, web UI and admin). **Draft says 8000: incorrect for this upstream.** |
| Env vars (real, from upstream image) | `DATA_DIR=/data`, `CONFIG_DIR=/opt/archivebox`, `ABXPKG_LIB_DIR=/opt/archivebox/lib`, `PLAYWRIGHT_BROWSERS_PATH=/opt/archivebox/lib/playwright/cache`, `TMP_DIR=/tmp/archivebox`, `HOME=/home/archivebox`, `XDG_CONFIG_HOME=/home/archivebox/.config`, `XDG_CACHE_HOME=/opt/archivebox/lib/cache`, `CODE_DIR=/app`, `ABX_RUNTIME=archivebox`, `DEFAULT_ARCHIVEBOX_UID=911`, `DEFAULT_ARCHIVEBOX_GID=911`, `ARCHIVEBOX_USER=archivebox`, `TZ=UTC`. Full ArchiveBox runtime env list: UNVERIFIED (not read from the ArchiveBox config source). |
| Data and config write paths | `/data` (DATA_DIR: `index.sqlite3`, `ArchiveBox.conf`, `archive/`, `logs/`, `sources/`, `personas/`), `/opt/archivebox` (CONFIG_DIR, abxpkg libs, caches, Playwright browsers), `/home/archivebox` (HOME), `/tmp/archivebox` (TMP_DIR). |
| arm64 | pip wheel is pure Python, so it installs on any arch (yes). Upstream image is built per `TARGETARCH`. Upstream arm64 image: UNVERIFIED (manifest not checked). |
| Copy-from option | `ghcr.io/archivebox/archivebox:0.9.77` exists per the draft. Per-arch manifest: UNVERIFIED. Not recommended: it carries the full upstream venv and 911 UID layout. |
| Sonic search helper | Upstream `COPY --from=archivebox/sonic:1.4.9 /usr/local/bin/sonic`. Default sonic port `1491`: UNVERIFIED (`etc/sonic.cfg` not fetched). |
| Entrypoint PUID/PGID chown | Draft claims the entrypoint chowns `/data` to PUID:PGID. UNVERIFIED for this upstream image (`docker_entrypoint.sh` not fetched). The upstream image uses fixed UID 911 with no PUID handling in the Dockerfile. |
| Upstream contract | Plugin installs run as UID 911 offline. Verification never runs as root (upstream comment in the Dockerfile). |

## 2. Target layout

- `apps/archivebox/Dockerfile`
- `apps/archivebox/docker-bake.hcl`
- `apps/archivebox/settings.yaml`
- `apps/archivebox/container-test.yaml`
- `apps/archivebox/start.sh`

No `defaults/`, `etc/`, `health/` unless the start script needs a seed file (for example a default `ArchiveBox.conf`). Reason to add: `start.sh` seeds `/config/data/ArchiveBox.conf` only when missing. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Fits: the pip wheel needs Python `>=3.13`, and 3.15 satisfies that. The base already provides pip. Closest sibling: `apps/bazarr` (pip install of an upstream release into a python base, `USER apps`, `COPY --chmod=0755 . /`).

Node and Chromium are NOT in the python base. Whether ContainerForge needs them is an open question (section 10).

## 4. Dockerfile

1. `ARG VERSION`, `ARG VENDOR`.
2. `FROM` the python base above.
3. `ENV` block: `DATA_DIR=/config/data` (persistent index and archive), `HOME=/tmp` (ephemeral), `XDG_CONFIG_HOME=/config/xdg/config`, `XDG_CACHE_HOME=/tmp/cache`, `TMP_DIR=/tmp/archivebox`, `TZ=UTC`, `PYTHONDONTWRITEBYTECODE=1`, `PIP_CACHE_DIR=/tmp/pip`, `UV_CACHE_DIR=/tmp/uv`. Caches must stay in `/tmp` (dockerfile rules).
4. `USER root`.
5. apt: only packages not in the base. Candidates from the draft are `(inferred)`: `git`, `curl`, `ripgrep`, `chromium`. Install `chromium` only if the extractor set is kept (section 10). Pin each apt version against `VERSION` only where the package is the app itself (not the case here).
6. `pip install --no-cache-dir "archivebox==${VERSION}"` using the wheel, verified first against the sha256 from `SHA256SUMS` (download to `/tmp`, `sha256sum -c`, then install). Remove `/tmp/*` afterwards.
7. License: `install -D` the MIT license text from the sdist (`/usr/share/licenses/archivebox/LICENSE`), since the wheel may not ship it: UNVERIFIED whether the wheel contains `LICENSE`.
8. `COPY --chmod=0755 . /`, then `USER apps`.
9. `EXPOSE 5797`, `VOLUME /config`.
10. Do not set a custom `ENTRYPOINT`. The base image entrypoint is kept, and `start.sh` (section 7) is the run command.

Pseudo-tail:

```dockerfile
USER apps
COPY --chmod=0755 . /
EXPOSE 5797
VOLUME /config
```

## 5. docker-bake.hcl

Standard layout, copied from `apps/bazarr/docker-bake.hcl`:

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "archivebox" }

variable "VERSION" {
  // renovate: datasource=github-releases depName=ArchiveBox/ArchiveBox versioning=semver
  default = "0.9.77"
}

variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/ArchiveBox/ArchiveBox" }

group "default" { targets = ["image-local"] }
# target "image", "image-local" (output=type=docker, tags=${APP}:${VERSION}), "image-all" (linux/amd64, linux/arm64)
```

Validate with `cd apps/archivebox && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/ArchiveBox/ArchiveBox"
ports:
  - port: 5797
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: ARCHIVEBOX_BIND_ADDR
    default: "0.0.0.0:5797"   # UNVERIFIED: only list if the start script reads it
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Rules: list only env vars the app reads. Anything not verified in section 1 is left out until confirmed. `dependencies: []`: sonic is optional and not a dependency container. Note the draft's port 8000 is removed.

## 7. start.sh

- Seed `/config/data` (and `/config/data/archive`, `/config/data/logs`, `/config/data/tmp`) with `mkdir -p` only when missing.
- If `/config/data/index.sqlite3` is missing, run `archivebox init --setup` once (idempotent; skip when the index exists). Run as `apps` (container already is).
- `export DATA_DIR=/config/data` (or the value the image uses) before every archivebox command.
- `cd /config/data` then `exec archivebox server --init 0.0.0.0:5797` (bind all interfaces, `exec` for PID 1 handoff). Do NOT pass `--init` on subsequent starts if the index exists: UNVERIFIED whether `--init` is harmful on re-runs; check before shipping.
- Never write to `/app` or the Python venv.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 300
tcp:
- port: '5797'
http:
- port: '5797'
  path: /health/
filePaths:
- /usr/local/bin/archivebox
- /usr/share/licenses/archivebox/LICENSE
```

- `timeoutSeconds: 300`: the archivebox init step is slow. Timeout is UNVERIFIED against a sibling of the same family; adjust after the first run.
- `http` path `/health/` is the upstream healthcheck path with the `admin.archivebox.localhost` host header. Verify that a plain `/health/` returns `OK` without a host match; if not, use `path: /` and state why.
- Coverage: the one port in `settings.yaml` has a tcp and an http probe.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | ContainerForge remap |
| --- | --- |
| `/data` (DATA_DIR, VOLUME) | `/config/data` (persistent) |
| `/opt/archivebox` (CONFIG_DIR, abxpkg libs, Playwright cache) | `/tmp/archivebox/lib` (ephemeral). Anything installed here at run time is lost on restart. Acceptable only if no plugin needs to persist. |
| `/home/archivebox` (HOME, XDG config) | `/config/xdg/config`, `/tmp` for cache |
| `/tmp/archivebox` (TMP_DIR) | unchanged, `/tmp` is writable under `--read-only --tmpfs /tmp` |
| UID 911 (upstream) | `apps` user from the base. Its numeric UID is UNVERIFIED against 911. Do not change the base user. |

Upstream asks for passwordless sudo in CI and root for apt. Under ContainerForge, do not install packages at run time. Everything must be present at build time.

## 10. Risks, caveats and open questions

- **Difficulty hard, main risk: the extractor stack.** The full upstream image pulls Chromium, Node, sonic and many extractor binaries through abxpkg. A pip-only image will not run most extractors. Decide the scope before building: (a) pip-only core with archive types that need no browser; or (b) full stack, which is multi-GB and needs root for apt at build time. Option (a) is recommended for a first PR.
- Image size: upstream budget is 1025 MiB compressed (comment in upstream Dockerfile). Full stack will exceed that if it is brought in.
- Draft caveat "entrypoint chowns /data to PUID:PGID": UNVERIFIED (see section 1). The ContainerForge version does not need it because the directories are created in `/config` at start.
- Sonic search: optional. Without it, ArchiveBox search falls back to ripgrep or an in-process search. Verify before claiming. Not in the first PR.
- `--read-only` runs: ArchiveBox writes lock and temp files. Confirm with a real run; add paths only if the log shows a real `Read-only file system` error.
- Blockers: none confirmed. Possible blocker is the full extractor stack if the team requires it in this PR.

## 11. Build and test steps

From `apps/archivebox/` (after the files exist):

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker volume create archivebox-probe-config`
4. `docker run --rm -d --name archivebox-probe --read-only --tmpfs /tmp -v archivebox-probe-config:/config ${APP}:${VERSION}` (use `archivebox:0.9.77`)
5. `docker logs -f archivebox-probe` until idle. Expected readiness signal: `Starting server` / `0.0.0.0:5797` with the process still running, no traceback.
6. `forgetool containers test --image archivebox:0.9.77 --config ./container-test.yaml`
7. Cleanup: `docker rm -f archivebox-probe; docker volume rm archivebox-probe-config`.

arm64 build only if amd64 fails for an arch-specific reason.

## 12. PR checklist

- Branch `feat/add-archivebox`, commit `feat(archivebox): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`. Keep every section and checkbox. Check only what applies.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows the status.
- State what was not tested (for example arm64, full extractor stack).
- Do not check "Built container locally" unless the build ran.
