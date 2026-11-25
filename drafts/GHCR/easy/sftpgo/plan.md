# sftpgo — implementation plan
> Source: ./draft.md · Target: apps/sftpgo/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest stable | v2.7.6, published 2026-09-19 | https://api.github.com/repos/drakkan/sftpgo/releases/latest (via `gh api`) |
| Renovate | `datasource=github-releases depName=drakkan/sftpgo versioning=semver` | standard for GitHub releases |
| License | AGPL-3.0 | https://api.github.com/repos/drakkan/sftpgo (`license.spdx_id`) |
| amd64 | `https://github.com/drakkan/sftpgo/releases/download/v2.7.6/sftpgo_v2.7.6_linux_x86_64.tar.xz` | release assets, same API response |
| arm64 | `https://github.com/drakkan/sftpgo/releases/download/v2.7.6/sftpgo_v2.7.6_linux_arm64.tar.xz` | release assets |
| Checksums | UNVERIFIED: no checksums file among the release assets; per-asset checksum not confirmed | release assets |
| Upstream Dockerfile | builder `golang:1.27-trixie`, runtime `debian:trixie-slim`, `USER 1000:1000`, `CMD ["sftpgo", "serve"]`, no EXPOSE/VOLUME | https://raw.githubusercontent.com/drakkan/sftpgo/main/Dockerfile |
| Upstream paths | config `/etc/sftpgo/sftpgo.json`, data `/srv/sftpgo/data`, backups `/srv/sftpgo/backups`, state `/var/lib/sftpgo`, share `/usr/share/sftpgo` | same |
| Env vars | `SFTPGO_LOG_FILE_PATH` (empty = stdout); other `SFTPGO_*` UNVERIFIED (not fetched) | same |
| Ports | 2022/tcp SFTP, 8080/http admin and WebDAV per draft; UNVERIFIED on a fetched page (upstream Dockerfile has no EXPOSE) | draft.md, facts/065.md |
| Upstream Dockerfile reviewed | yes | see above |

Draft tag `v2.7.6-plugins` is not used: the plugin binaries are optional and skipped.

## 2. Target layout

Exact files in `apps/sftpgo/`:
- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`: required.
- `defaults/sftpgo.json`: needed to seed `/config/sftpgo.json` on first start (the upstream config is in `/etc/sftpgo`, which is read-only at runtime). Reason: the upstream default config is not writable.
- `etc/`, `scripts/`, `health/`: not needed.
- `root/`: never used.
- `DOWNSTREAM_CHANGES.md`: not needed (not a `FROM` base).

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`
- Fits: upstream is a single static Go binary; the draft says no runtime image is needed.
- Closest sibling: `apps/adguardhome-sync` (prebuilt binary on ubuntu).

## 4. Dockerfile

1. `ARG VERSION` and `ARG TARGETARCH`. Map `amd64` to `x86_64` and `arm64` to `arm64` for the tarball name.
2. `USER root` only for the install step, then `USER apps`.
3. Install `ca-certificates` only if not already in the base (check first; do not re-install).
4. Download the tarball `sftpgo_v${VERSION}_linux_${ARCH}.tar.xz` to `/tmp`, verify against a checksum (UNVERIFIED: no published checksum; document this in the PR), extract the `sftpgo` binary to `/usr/local/bin/sftpgo` and, from the same tarball, the `templates/`, `static/` and `openapi/` folders to `/usr/local/share/sftpgo` (UNVERIFIED tarball layout: inspect it at build time). The web admin needs them, and the seeded `/config/sftpgo.json` must point `templates_path`, `static_files_path` and `openapi_path` there (UNVERIFIED key names; read the upstream default config). Avoid the `.deb`, which installs under `/usr/bin` and `/etc`.
5. Ship license files to `/usr/share/licenses/sftpgo/` (AGPL-3.0 `LICENSE`).
6. `ENV HOME=/config` and point caches to `/tmp`.
7. `COPY --chmod=0755 start.sh /start.sh` and `COPY --chmod=0755 . /` (defaults included).
8. `EXPOSE 2022 8080` only if verified; otherwise leave `EXPOSE` out and rely on `settings.yaml`.
9. `VOLUME /config`, then `USER apps`.

## 5. docker-bake.hcl

- `APP = "sftpgo"`, `VERSION = "2.7.6"` with `// renovate: datasource=github-releases depName=drakkan/sftpgo versioning=semver`.
- `LICENSE = "AGPL-3.0"`, `SOURCE = "https://github.com/drakkan/sftpgo"`.
- Four standard targets and `group "default" { targets = ["image-local"] }`. `image-all` lists `linux/amd64` and `linux/arm64`.
- Validate with `docker buildx bake --print` from `apps/sftpgo`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/drakkan/sftpgo"`.
- `ports`: 2022/tcp (SFTP, required), 8080/tcp (HTTP admin, required); both UNVERIFIED until confirmed from the upstream docs.
- `env`: only the vars start.sh reads: `TZ` (default `Etc/UTC`), `SFTPGO_LOG_FILE_PATH` (default empty).
- `volumes`: `/config` (required).
- `dependencies`: none (embedded SQLite default; UNVERIFIED that no external DB is required).

## 7. start.sh

- Idempotent. Seed `/config/sftpgo.json` from the defaults only when missing.
- Create `/config/data` and `/config/backups` when missing, and point `users_base_dir` and backup paths there through the seeded config (not by editing `/etc`).
- Write nothing to `/usr/local` or `/app`.
- Listen on `0.0.0.0` for SFTP and HTTP.
- Final command: `exec sftpgo serve -c /config`. Use `-c` and `-d` only if the flags are confirmed.

## 8. container-test.yaml

- Schema header from the forgetool schemas used by siblings.
- `filePaths`: `/start.sh`, `/usr/local/bin/sftpgo`, `/config/sftpgo.json` (after seeding).
- `tcp` probe on each port in `settings.yaml`, `timeoutSeconds` matching the sibling family.
- No env vars are passed, so the default config path is the one tested.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as `1000:1000`. The `apps` user is the ContainerForge default; check its UID in the base image before relying on it.
- Upstream writes to `/srv/sftpgo` and `/var/lib/sftpgo`. Remap all to `/config` with the seeded config. Logs go to stdout (`SFTPGO_LOG_FILE_PATH` empty).
- The chart's four PVCs (`/srv/sftpgo/backups`, `/var/lib/sftpgo`, `/srv/sftpgo/data`, `/shareaccess`) collapse into `/config` subdirectories. Mark `/shareaccess` as an open question.
- Chart security (runAsUser 0, readOnlyRootFilesystem false) is NOT copied. Target: rootless `apps`, read-only rootfs OK.

## 10. Risks, caveats and open questions

- Checksum not published as an asset: UNVERIFIED; the PR must say so.
- Ports 2022 and 8080 are from the draft, not confirmed on a fetched page.
- The `-plugins` image tag is not used; optional plugins are skipped.
- The first admin account is created in the web UI on first use (draft, inferred).
- Blockers: none known (no musl-only, no GPU, no privileged need).

## 11. Build and test steps

```sh
cd apps/sftpgo
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name sftpgo-probe --read-only --tmpfs /tmp \
  -v sftpgo-probe-config:/config sftpgo:2.7.6
docker logs -f sftpgo-probe
forgetool containers test --image sftpgo:2.7.6 --config ./apps/sftpgo/container-test.yaml
docker rm -f sftpgo-probe; docker volume rm sftpgo-probe-config
```

Expected readiness signal: a log line showing the SFTP and HTTP listeners starting (exact text to be confirmed from a run).

## 12. PR checklist

- Branch `feat/add-sftpgo`, commit `feat(sftpgo): add new container`, title in Conventional Commits form.
- Notes section includes `🤖 This PR is AI generated.`
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`; check only the boxes that apply.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State what was not tested: the arm64 build, and any UNVERIFIED port or checksum.
