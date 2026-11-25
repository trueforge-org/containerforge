# traggo — implementation plan
> Source: ./draft.md · Target: apps/traggo/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 0.8.3 (tag `v0.8.3`, released 2026-03-01, latest release; matches draft) |
| Renovate | `datasource=github-releases depName=traggo/server` (default `versioning`, semver; tag has a `v` prefix, so the Dockerfile adds `v`) |
| License | GPL-3.0 per GitHub; the tarball LICENSE is GPLv3 ("Version 3, 29 June 2007"). Use SPDX `GPL-3.0-only` (UNVERIFIED: no "or later" wording checked) |
| Source | https://github.com/traggo/server |
| amd64 | https://github.com/traggo/server/releases/download/v0.8.3/traggo_0.8.3_linux_amd64.tar.gz |
| arm64 | https://github.com/traggo/server/releases/download/v0.8.3/traggo_0.8.3_linux_arm64.tar.gz |
| Tarball content | `traggo` (static Go binary, executable), `LICENSE`, `README.md`, `.env.sample` (verified by listing the amd64 archive) |
| Checksum | UNVERIFIED: the release has no checksum asset (only 4 archives). The download is over HTTPS from the GitHub release only |
| Upstream Dockerfile | `docker/Dockerfile`: `FROM scratch`, `WORKDIR /opt/traggo`, `COPY traggo /opt/traggo`, `EXPOSE 3030`, `ENTRYPOINT ["./traggo"]` (reviewed, no env set) |

Env vars the binary reads (`config/config.go`, envconfig prefix `TRAGGO`, defaults in brackets):
`TRAGGO_PORT` [3030], `TRAGGO_LOG_LEVEL` [info], `TRAGGO_DEFAULT_USER_NAME` [admin], `TRAGGO_DEFAULT_USER_PASS` [admin], `TRAGGO_PASS_STRENGTH` [10], `TRAGGO_DATABASE_DIALECT` [sqlite3, the only valid value], `TRAGGO_DATABASE_CONNECTION` [`data/traggo.db`, relative to the working directory].

## 2. Target layout

```
apps/traggo/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`, `etc/`, `scripts/` or `health/` needed: the binary creates its own SQLite database. No `root/`. No `DOWNSTREAM_CHANGES.md` (nothing uses it as a base).

## 3. Base image
`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

The binary is a static Go executable and needs nothing but ca-certificates (already in the base). Closest sibling: `apps/adguardhome-sync` (Go release tarball into `/app`).

## 4. Dockerfile
1. `ARG VERSION`, `ARG TARGETARCH` (Docker's `amd64`/`arm64` match the upstream asset names, so no mapping is needed).
2. `USER root`.
3. One `RUN`: `mkdir -p /app /usr/share/licenses/traggo`, `curl -fsSL -o /tmp/traggo.tar.gz "https://github.com/traggo/server/releases/download/v${VERSION}/traggo_${VERSION}_linux_${TARGETARCH}.tar.gz"`, `tar xzf /tmp/traggo.tar.gz -C /app traggo`, `tar xzf ... -C /usr/share/licenses/traggo LICENSE`, `chown -R apps:apps /app && chmod -R 755 /app`, `rm /tmp/traggo.tar.gz`. No checksum step is possible (see section 1); note this in a comment.
4. `ENV TRAGGO_DATABASE_CONNECTION=/config/traggo.db TRAGGO_PORT=3030 HOME=/config` (HOME is set only as the project convention; the binary writes nothing else).
5. `USER apps`, then `COPY --chmod=0755 . /`.
6. `EXPOSE 3030`, `VOLUME /config`, `WORKDIR /config`.

No apt packages. No `ENTRYPOINT`; `start.sh` is the entrypoint like the sibling.

## 5. docker-bake.hcl
- `APP = "traggo"`
- `VERSION`: preceded by `// renovate: datasource=github-releases depName=traggo/server`, default `"0.8.3"`
- `LICENSE = "GPL-3.0-only"`, `SOURCE = "https://github.com/traggo/server"`
- Targets `docker-metadata-action`, `image` (args VERSION, OCI source/licenses labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (linux/amd64, linux/arm64), `group "default" { targets = ["image-local"] }`. Copy the layout of `apps/adguardhome-sync/docker-bake.hcl`.
- Validate with `docker buildx bake --print`.

## 6. settings.yaml
```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/traggo/server"
ports:
  - port: 3030
    protocol: tcp
    required: true
env:
  - {name: TRAGGO_PORT, default: "3030", required: false}
  - {name: TRAGGO_LOG_LEVEL, default: "info", required: false}
  - {name: TRAGGO_DEFAULT_USER_NAME, default: "admin", required: false}
  - {name: TRAGGO_DEFAULT_USER_PASS, default: "admin", required: false}
  - {name: TRAGGO_PASS_STRENGTH, default: "10", required: false}
  - {name: TRAGGO_DATABASE_CONNECTION, default: "/config/traggo.db", required: false}
  - {name: TZ, default: "Etc/UTC", required: false}
volumes:
  - path: /config
    required: true
dependencies: []
```
Write the entries in the multi-line style of the siblings. `TRAGGO_DATABASE_DIALECT` is left out on purpose (only `sqlite3` exists). Dependencies: none.

## 7. start.sh
```bash
#!/usr/bin/env bash
export TRAGGO_DATABASE_CONNECTION="${TRAGGO_DATABASE_CONNECTION:-/config/traggo.db}"
export TRAGGO_PORT="${TRAGGO_PORT:-3030}"
mkdir -p "$(dirname "${TRAGGO_DATABASE_CONNECTION}")"
cd /config
exec /app/traggo
```
Idempotent, nothing written to `/app`, the DB is created by the app when missing, and the Go HTTP server listens on all interfaces (`Addr: ":<port>"` in `server/server.go` at v0.8.3; still connect from outside the container during the run test).

## 8. container-test.yaml
```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
http:
- port: '3030'
  path: /
filePaths:
- /app/traggo
- /usr/share/licenses/traggo/LICENSE
```
The HTTP probe covers the only port in `settings.yaml`. The test runs with no env vars, so the default admin/admin user is created, which is fine. Not a DB-dependent app, so no narrowing.

## 9. Rootless and read-only-rootfs adaptations
- Upstream writes `data/traggo.db` relative to the working directory: remapped to `/config/traggo.db` through env and `WORKDIR /config`.
- No other write path is known (UNVERIFIED: check for SQLite `-wal`/`-journal` files, which sit next to the DB in `/config`, and for temp files in `/tmp`). The app also reads optional config files: `.env*` next to the binary, `$HOME/.config/traggo/server.ini` and `/etc/traggo/server.ini`.
- Draft expects non-root (568) and readOnlyRootFilesystem true: both hold with `USER apps` and `/config` + `/tmp` as the only writable paths. No extra `/data` persistence, the draft's "not under /config by default" caveat is solved by the env override.

## 10. Risks, caveats and open questions
- Default credentials are `admin`/`admin` until changed: document that `TRAGGO_DEFAULT_USER_PASS` should be set (the draft's "open until the first admin" caveat is really this default account).
- No upstream checksum, so integrity relies on the HTTPS GitHub download.
- Pass strength env is only applied to new users (UNVERIFIED).
- No blockers: static binary, amd64 and arm64 both published, no privileges needed.

## 11. Build and test steps
```sh
cd apps/traggo
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name traggo-probe --read-only --tmpfs /tmp -v traggo-probe-config:/config traggo:0.8.3
docker logs -f traggo-probe   # expect "Creating default user." and "Start listening", no panic
curl -fsS http://<container-ip>:3030/ >/dev/null
docker rm -f traggo-probe; docker volume rm traggo-probe-config
forgetool containers test --image traggo:0.8.3 --config ./apps/traggo/container-test.yaml
```
Readiness signal: the log line `Start listening` (from `main.go`), the process stays up and port 3030 answers.

## 12. PR checklist
- Branch `feat/add-traggo`, commit `feat(traggo): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only the true boxes.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- List untested items honestly: arm64 build, no checksum verification, listen address from outside the container, and anything not run locally.
