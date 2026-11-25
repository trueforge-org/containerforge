# pyload — implementation plan
> Source: ./draft.md · Target: apps/pyload/ · Difficulty: easy · Role (main/sidecar): main · Verified on 2026-11-25

Blocker before any work: `apps/pyload-ng/` already ships the same upstream (pyload-ng on the ContainerForge python base). Creating `apps/pyload/` would duplicate it. Recommended action: do not add a new app; map the TrueCharts `pyload` chart to `apps/pyload-ng` instead. The rest of this plan is kept so the decision can be reversed if a separate app is wanted.

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest version on PyPI | `0.5.0b3.dev102` (2026-10-28), pre-release only; PyPI text: "No stable release yet" | https://pypi.org/pypi/pyload-ng/json |
| Sibling pin in apps/pyload-ng | `0.5.0b3.dev101` | apps/pyload-ng/docker-bake.hcl |
| Draft container tag | `ghcr.io/linuxserver/pyload:version-360b2295` (linuxserver SHA-based) | draft.md |
| Renovate | `datasource=pypi depName=pyload-ng`, versioning: pep440 (prerelease tags; proposed, not in repo yet) | PyPI |
| License | AGPL-3.0 (PyPI `agpl3`); sibling LICENSE uses `AGPL-3.0-or-later` | https://pypi.org/pypi/pyload-ng/json, apps/pyload-ng/docker-bake.hcl |
| Source | https://github.com/pyload/pyload · home https://pyload.net | PyPI, draft.md |
| Per-arch download | Pure-Python wheel `pyload_ng-0.5.0b3.dev102-py3-none-any.whl` (same for amd64 and arm64) | PyPI |
| Checksum source | PyPI file hashes (sha256 per file, not extracted): UNVERIFIED value | PyPI JSON |
| Upstream Dockerfile | linuxserver/docker-pyload@6242e553c60d: Alpine 3.11, `pip install` of passlib, pillow, pycrypto, pycurl, pyopenssl; `EXPOSE 8000 7227`; `VOLUME /config /downloads`; no ENV | https://raw.githubusercontent.com/linuxserver/docker-pyload/6242e553c60d/Dockerfile |
| Ports | 8000 (web UI), 7227 (RPC) | Upstream EXPOSE |

UNVERIFIED: the linuxserver image's `pip` dependency list is not pinned, so the exact extras needed for the TrueCharts image are unknown.

## 2. Target layout

Not applicable as a new app (see blocker). If created anyway, `apps/pyload/`:
- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`, `defaults/` (only if a default config file is seeded, with reason).
- No `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

- FROM `ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (same as the sibling).
- Closest sibling: `apps/pyload-ng`.

## 4. Dockerfile

Copy the sibling `apps/pyload-ng/Dockerfile` shape:
1. `ARG VERSION`, `ENV HOME="/config"`, `USER root`, `WORKDIR /app`.
2. `apt-get install` only packages not in the base; pin them if added. Sibling installs build-essential, ffmpeg, tesseract, etc.; decide per need, do not copy blindly.
3. `pip install uv`, then `uv pip install --pre "pyload-ng[all]==${VERSION}" "flask-compress<1.18"` (flask-compress workaround because the python base lacks `_zstd`).
4. `mkdir -p /config /downloads`, `chown -R 568:568 /config /downloads`, clean `/root/.cache` and `/tmp/*`.
5. Optional: `COPY --from=ghcr.io/linuxserver/unrar:...` for `unrar`. Only if the app needs RAR; the linuxserver image pin must be verified before use (UNVERIFIED digest).
6. `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /config`.
7. `EXPOSE 8000 7227`, `VOLUME /config /downloads`. Note `/downloads` is not in the ContainerForge `/config`-only model; keep it only if the chart writes there, and document it as a second volume.

## 5. docker-bake.hcl

- `APP = "pyload"` (if created), `VERSION` default `0.5.0b3.dev102` with `// renovate: datasource=pypi depName=pyload-ng versioning=pep440`.
- `LICENSE = "AGPL-3.0-or-later"` (matches sibling; confirm against upstream COPYING: UNVERIFIED).
- `SOURCE = "https://github.com/pyload/pyload"`.
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64, arm64), `group "default"`.
- Validate: `cd apps/pyload && docker buildx bake --print`.

## 6. settings.yaml

- Schema header `# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json`, `schema_version: 1`.
- `upstream_env_url: https://github.com/pyload/pyload`.
- `ports`: 8000 (http, required), 7227 (tcp, required only if RPC is enabled; check the sibling's value).
- `env`: only variables the app and start.sh really read. Check the sibling `settings.yaml` and `start.sh` first; do not invent names.
- `volumes`: `/config` (state), `/downloads` (if kept).
- `dependencies`: none.

## 7. start.sh

- Idempotent. Seed `pyload.cfg` into `/config` only when missing (sibling copies `defaults/pyload.cfg`).
- Never write to `/app`. Caches to `/tmp`.
- Bind the web UI to `0.0.0.0`; check the bind address in the config, do not assume.
- `exec` the final pyload process so signals reach it.
- Expected readiness log line: UNVERIFIED (check the sibling's container-test assertion and the pyload log on first start).

## 8. container-test.yaml

- forgetool header copied from sibling.
- `tcp` probe on 8000 and, if declared, 7227. `timeoutSeconds` from `apps/pyload-ng/container-test.yaml`.
- `filePaths` for `/config/pyload.cfg` (seeded file).

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps` (UID 568). `/config` and `/downloads` owned 568.
- Read-only rootfs: pip cache and any temp under `/tmp` only. Confirm the app does not write its install under `/usr` at runtime.
- No privileged mode, no extra persistence beyond `/config` and `/downloads`.
- Draft's security expectations (non-root possible, read-only true, privileged no) are consistent with the sibling.

## 10. Risks, caveats and open questions

- Duplicate of `apps/pyload-ng` (see blocker). Decide first.
- Pre-release only on PyPI (`0.5.0b3.dev*`). Stable release not available; pin and track carefully.
- `version-360b2295` in the chart is a linuxserver commit tag; mapping to a PyPI version is UNVERIFIED.
- Sibling `VERSION` is `0.5.0b3.dev101`; upstream is now `dev102`. A bump is a separate change.
- First start needs an admin account created in the web UI (draft caveat, not verified against upstream docs).
- Draft's `read-only-rootfs: possible` depends on the `/config` seeding and `/tmp` writes.

## 11. Build and test steps

1. `cd apps/pyload && docker buildx bake --print` (exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name pyload-probe --read-only --tmpfs /tmp -v pyload-probe-config:/config pyload:<version>`, then `docker logs -f pyload-probe`. Expected: process alive, web UI listening on 8000 (readiness string: UNVERIFIED).
4. Clean up: `docker rm -f pyload-probe; docker volume rm pyload-probe-config`.
5. `forgetool containers test --image pyload:<version> --config ./apps/pyload/container-test.yaml`.
6. arm64 only if an arm64-specific failure occurs.

## 12. PR checklist

- Branch `feat/add-pyload`, commit `feat(pyload): add new container`. Do not open a PR while the duplicate question is unresolved.
- PR body: template at `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only what applies.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State untested items honestly (arm64, forgetool run, UI behaviour) if not run.
