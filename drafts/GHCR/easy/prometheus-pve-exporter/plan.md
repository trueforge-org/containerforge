# prometheus-pve-exporter — implementation plan
> Source: ./draft.md · Target: apps/prometheus-pve-exporter/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | **3.12.0** (PyPI and GitHub release `v3.12.0`, published 2026-11-15). Draft's `ghcr.io/prometheus-pve/prometheus-pve-exporter:3.12.0` tag matches. |
| Renovate | `// renovate: datasource=pypi depName=prometheus-pve-exporter versioning=pep440` |
| License | Apache-2.0 (GitHub SPDX and PyPI `info.license`). |
| Source URL | https://github.com/prometheus-pve/prometheus-pve-exporter |
| Download | PyPI wheel `prometheus_pve_exporter-3.12.0-py3-none-any.whl`, sha256 `ce79b7368aad21cdad237dd076af77db9f66ca6faba62a65c49941829b8286da`. Sdist `prometheus_pve_exporter-3.12.0.tar.gz`, sha256 `a2448f0eada23e8d554d3ac2b43a7e0e0e4381351e0df9879a8d1d1fdd82b8fa`. Pure Python, same on amd64 and arm64. Source: https://pypi.org/pypi/prometheus-pve-exporter/json |
| Checksum source | PyPI sha256 digests above. |
| Python requirement | `requires_python >=3.11` (PyPI). The README says 3.9+; PyPI is authoritative. The python base is 3.15.2, so it is fine. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/prometheus-pve/prometheus-pve-exporter/main/Dockerfile: alpine build, pip-installs the wheel into `/opt/prometheus-pve-exporter`, `USER prometheus` (101), `EXPOSE 9221`, ENTRYPOINT `/opt/prometheus-pve-exporter/bin/pve_exporter`. No VOLUME. |
| Config | Sample `pve.yml` (https://github.com/prometheus-pve/prometheus-pve-exporter/blob/main/pve.yml, via `gh api`): top-level `default:` with `user`, `token_name`, `token_value`. Upstream default `--config.file` is `/etc/prometheus/pve.yml`. Use `/config/pve.yml`. |
| CLI (README.rst) | `--config.file CONFIG_FILE`, `--web.listen-address WEB_LISTEN_ADDRESS` (default `[::]:9221`), `--server.keyfile`, `--server.certfile`, `--log.level`, `--collector.*`. |
| Env vars | None. The README and CLI show no environment variables. |
| Port | 9221/tcp (HTTP metrics). Draft's `9221/http` is confirmed by EXPOSE 9221. |
| Data path | Reads config only. No writes. |

## 2. Target layout

- `apps/prometheus-pve-exporter/Dockerfile`
- `apps/prometheus-pve-exporter/docker-bake.hcl`
- `apps/prometheus-pve-exporter/settings.yaml`
- `apps/prometheus-pve-exporter/container-test.yaml`
- `apps/prometheus-pve-exporter/start.sh`
- `apps/prometheus-pve-exporter/defaults/pve.yml` (template seeded into `/config` only when missing; required because `/config` may start empty)

`defaults/` is allowed by `include/.dockerignore`. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. The base carries `/app/venv` (read-only at runtime; use it directly per the python-runtime rule). Closest sibling: `apps/bazarr` (pip app on the python base) and `apps/python`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG PIP_VERSION`... only if the bake passes them (the python base already takes them; reuse the base's pinned args or omit).
2. `USER root`.
3. `RUN /app/venv/bin/pip install --no-cache-dir "prometheus-pve-exporter==${VERSION}"`. Build-time install only, so `/app/venv` is not written at runtime. Optional: `--require-hashes` with the wheel digest, plus hashes for transitive deps (generate with pip-compile; the wheel digest is above).
4. `ln -s /app/venv/bin/pve_exporter /usr/local/bin/pve_exporter` (optional, for `--help` test).
5. `chown -R apps:apps /app/venv` only if needed for the venv; prefer keeping `/app/venv` root-owned and read-only.
6. `COPY --chmod=0755 start.sh /start.sh`.
7. `USER apps`, `COPY --chmod=0755 . /`.

Environment: `ENV HOME=/config` is not needed (no caches); pip cache is off (`PIP_NO_CACHE_DIR` already set by the base).

## 5. docker-bake.hcl

- `APP = "prometheus-pve-exporter"`
- `VERSION = "3.12.0"` with the renovate annotation above.
- `LICENSE = "Apache-2.0"`, `SOURCE = "https://github.com/prometheus-pve/prometheus-pve-exporter"`.
- Standard targets; `image-all` with `linux/amd64` and `linux/arm64` (pure Python).
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/prometheus-pve/prometheus-pve-exporter"`.
- `ports`: `9221` tcp (required: true).
- `env`: `TZ` default `Etc/UTC` (required: false). No other env vars: none are read by the upstream app.
- `volumes`: `/config` (required: true).
- `dependencies`: none (Proxmox VE is an external API, not a ContainerForge app).

## 7. start.sh

1. `set -euo pipefail`.
2. `mkdir -p /config`. If `/config/pve.yml` is missing, copy `/defaults/pve.yml` (template with placeholder token, never overwrite an existing file).
3. `exec /app/venv/bin/pve_exporter --config.file=/config/pve.yml "--web.listen-address=[::]:9221"` (quote the address so bash does not glob `[::]`) (form `--flag=value` for argparse). Optional: pass `"$@"` for extra flags, with `[::]` bind so the server listens on all interfaces.
4. No writes to `/app`. No cache.

Note: the template token is a placeholder, so the exporter starts but scrapes fail until the user edits `/config/pve.yml`. This is expected behavior, not a test failure.

## 8. container-test.yaml

- Schema header from `apps/python/container-test.yaml`.
- `filePaths`: `/start.sh`, `/app/venv/bin/pve_exporter`, `/config/...` not needed.
- `runners`: `entrypoint: /app/venv/bin/pve_exporter`, `cmd: "--help"` with `expectedOutput` `usage` (the README shows the usage line; exact string UNVERIFIED until run).
- Probe: `tcp` on `9221` (the only port). An `http` probe on `/` is UNVERIFIED (response not fetched); use `tcp` unless verified.
- `timeoutSeconds`: reuse a sibling python value.
- Test runs with empty `/config`: the template is seeded, the exporter starts without a reachable PVE, so the tcp probe passes.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as `prometheus` (uid 101); ContainerForge uses `USER apps`.
- Read-only rootfs: only `/config` (the seeded `pve.yml`) and `/tmp` are written; `/app/venv` is never written at runtime.
- Chart defaults (non-root 568, read-only true, privileged false) match this plan.
- Secrets (`token_value`) live in `/config/pve.yml`, which is persistent storage; document that users should keep it private.

## 10. Risks, caveats and open questions

- The exporter starts without a reachable Proxmox VE, but scraping needs a PVE user or API token with read rights (inferred from the sample config).
- Pip unpinned in the draft: fixed by pinning `3.12.0` (section 5).
- `requires_python >=3.11` vs README 3.9: PyPI used.
- The exact `--help` expected output string is UNVERIFIED until the image runs.
- Blockers: none found.

## 11. Build and test steps

From `apps/prometheus-pve-exporter/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name prometheus-pve-exporter-probe --read-only --tmpfs /tmp -v prometheus-pve-exporter-probe-config:/config <image>:<version>`, then `docker logs -f prometheus-pve-exporter-probe`. Readiness: the exporter logs its listen address on `:9221` (exact string UNVERIFIED until run). Clean up with `docker rm -f prometheus-pve-exporter-probe; docker volume rm prometheus-pve-exporter-probe-config`.
4. `forgetool containers test --image <image>:<version> --config ./apps/prometheus-pve-exporter/container-test.yaml`
5. Round limit 10.

## 12. PR checklist

- Branch `feat/add-prometheus-pve-exporter`, commit `feat(prometheus-pve-exporter): add new container`, PR title matches.
- PR template, `🤖 This PR is AI generated.` in Notes.
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Say what is untested: no build or run done yet.
- Do not check "Built container locally" unless it was built.
