# cloudreve — implementation plan
> Source: ./draft.md · Target: apps/cloudreve/ · Difficulty: medium · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `4.19.1` (latest GitHub release, 2026-09-18; same as the draft) |
| Renovate | `datasource=github-releases`, `depName=cloudreve/cloudreve` (tags have no `v` prefix) |
| License | GPL-3.0 (GitHub SPDX `GPL-3.0`, LICENSE is GNU GPL v3; use `GPL-3.0-only`; UNVERIFIED whether source headers say "or later") |
| Source | https://github.com/cloudreve/Cloudreve (docs https://docs.cloudreve.org/en) |
| Download amd64 | https://github.com/cloudreve/cloudreve/releases/download/4.19.1/cloudreve_4.19.1_linux_amd64.tar.gz (sha256 `287a1f59adb1249af15cd550b191d2fa71132bfd125fead8578f20152c4b99de`, verified by downloading) |
| Download arm64 | https://github.com/cloudreve/cloudreve/releases/download/4.19.1/cloudreve_4.19.1_linux_arm64.tar.gz (sha256 `f55d77e0e5eb8bc699a9a6bb1216b0ee3afa3bfe8d7c9d405ca9845339ae7b0e`, from the release digest) |
| Checksum source | `checksums.txt` release asset (sha256 `ec297db2...`), and GitHub asset digests |
| Archive contents | `LICENSE`, `README.md`, `README_zh-CN.md`, `cloudreve` (single binary) |
| Upstream Dockerfile | Reviewed (commit 9f1e0b8): `alpine:latest`, apk `tzdata vips-tools ffmpeg libreoffice aria2 supervisor font-noto font-noto-cjk libheif libraw-tools`, `WORKDIR /cloudreve`, `ENV CR_ENABLE_ARIA2=1 CR_SETTING_DEFAULT_thumb_ffmpeg_enabled=1 CR_SETTING_DEFAULT_thumb_vips_enabled=1 CR_SETTING_DEFAULT_thumb_libreoffice_enabled=1 CR_SETTING_DEFAULT_media_meta_ffprobe=1 CR_SETTING_DEFAULT_thumb_libraw_enabled=1`, `EXPOSE 5212 443 6888 6888/udp`, `VOLUME /cloudreve/data`, entrypoint starts supervisord (aria2) then `./cloudreve` |
| Config | `data/conf.ini` relative to cwd (flag `-c <path>`); override any key with `CR_CONF_<Section>.<Key>` or `CR_CONF_<Section>__<Key>`. `[System] Listen` default `:5212`; `[Database] Type` default `sqlite` (also mysql, mariadb, postgres; keys `Host`, `Port`, `User`, `Password`, `Name`, `DBFile`, `DatabaseURL`); `[Redis] Server` default `127.0.0.1:6379`, empty disables Redis. Upstream compose uses `CR_CONF_Database.Type=postgres`, `CR_CONF_Database.Host`, `.User`, `.Name`, `.Port`, `CR_CONF_Redis.Server` |
| Ports | 5212 (HTTP, UI and API). 443 only with `[SSL]` configured; 6888 tcp/udp only for the bundled aria2 (not included here) |
| apt ffmpeg (Ubuntu 26.04) | `7:8.0.1-3ubuntu2` (universe) |

## 2. Target layout

```
apps/cloudreve/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` (Cloudreve generates `conf.ini` and the admin account on first start). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`; Go binary plus apt media tools, as the draft says. Closest sibling: `apps/adguardhome-sync` (release tarball on ubuntu, `TARGETARCH` mapping needs no change: asset names use `amd64` / `arm64`).

## 4. Dockerfile

1. `FROM <ubuntu>`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. apt (not in base): `ffmpeg libvips-tools libraw-bin libheif1 fonts-noto-core` with `--no-install-recommends`; package names other than `ffmpeg` are UNVERIFIED on 26.04 (`libheif1`/`libheif-plugin-*` naming, `libraw-bin`, `libvips-tools`). `ffmpeg` is a tool rather than the app, so no `VERSION` alignment is needed; pin `ffmpeg=7:8.0.1-3ubuntu2` only if reproducibility is wanted (`# hadolint ignore=DL3008`). Skip `libreoffice`, `aria2`, `supervisor` (size; see risks). Clean apt lists.
3. Download and verify:
   `curl -fsSL -o /tmp/cloudreve.tar.gz https://github.com/cloudreve/cloudreve/releases/download/${VERSION}/cloudreve_${VERSION}_linux_${TARGETARCH}.tar.gz`, `curl -fsSL -o /tmp/checksums.txt .../checksums.txt`, then `cd /tmp && grep " cloudreve_${VERSION}_linux_${TARGETARCH}.tar.gz\$" checksums.txt | sha256sum -c -` (checksums.txt line format assumed `<hash>  <file>`; UNVERIFIED).
4. `tar xzf` the binary into `/app/` (`cloudreve`), `install -D LICENSE /usr/share/licenses/cloudreve/LICENSE`, `chown -R apps:apps /app && chmod -R 755 /app`, remove `/tmp` files.
5. `ENV HOME=/config CR_SETTING_DEFAULT_thumb_ffmpeg_enabled=1 CR_SETTING_DEFAULT_thumb_vips_enabled=1 CR_SETTING_DEFAULT_media_meta_ffprobe=1 CR_SETTING_DEFAULT_thumb_libraw_enabled=1` (from the upstream Dockerfile; libreoffice and aria2 flags left unset).
6. `WORKDIR /config`, `EXPOSE 5212`, `VOLUME /config`.
7. `COPY --chmod=0755 . /`.
8. Final line `USER apps`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "cloudreve"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=cloudreve/cloudreve
  default = "4.19.1"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/cloudreve/Cloudreve"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```
Validate with `docker buildx bake --print` from `apps/cloudreve/`. Dockerfile `ARG VERSION` must receive exactly this value (no extra defaults).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/cloudreve/Cloudreve"
ports:
  - port: 5212
    protocol: tcp
    required: true
env:
  - name: CR_CONF_Database.Type
    default: "sqlite"
    required: false
  - name: CR_CONF_Database.Host
    default: ""
    required: false
  - name: CR_CONF_Database.Port
    default: ""
    required: false
  - name: CR_CONF_Database.User
    default: ""
    required: false
  - name: CR_CONF_Database.Password
    default: ""
    required: false
  - name: CR_CONF_Database.Name
    default: ""
    required: false
  - name: CR_CONF_Redis.Server
    default: ""
    required: false
  - name: CR_CONF_System.Listen
    default: ":5212"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: postgresql   # exists in apps/ ✅
  - name: valkey       # exists in apps/ ✅
```
The draft says PostgreSQL and Valkey are dependencies; upstream defaults to SQLite and an empty Redis server, so they are optional (`opt_dependencies`), resolving the draft's contradiction. Note that the `.` in env names follows upstream; the `__` form is equivalent.

## 7. start.sh

1. `mkdir -p /config/data` and `cd /config` (Cloudreve resolves `data/conf.ini`, `data/cloudreve.db`, uploads and temp relative to cwd; Docker upstream does the same with `/cloudreve/data`).
2. Do not write `conf.ini`: first start generates it. Do not template secrets into files; DB password stays in `CR_CONF_Database.Password` (read by the app each start, so changed passwords apply on existing data).
3. Binds `:5212` (all interfaces) by default.
4. `exec /app/cloudreve` (add `-c "${CLOUDREVE_CONF:-/config/data/conf.ini}"` only if testing shows it is needed; default location is already `data/conf.ini`).
Temp upload staging stays under `/config/data/temp` (see risks) rather than `/tmp`, because large chunked uploads would exhaust a tmpfs.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '5212'
http:
- port: '5212'
  path: /
filePaths:
- /app/cloudreve
- /usr/bin/ffmpeg
- /usr/share/licenses/cloudreve/LICENSE
```
Probe for the only port, 5212. SQLite default means the container is fully self-testable, so the database-dependency exception does not apply and assertions are not narrowed. The Postgres/Valkey path needs env vars and is run manually (section 11).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
|---|---|
| `/cloudreve/data` (conf.ini, SQLite db, uploads, temp, aria2 session) | `/config/data` via `WORKDIR /config` (draft: chart PVC at `/cloudreve/data`; existing data mounts at `/config/data`) |
| Temp upload dir `data/temp` | stays in `/config/data/temp` (UNVERIFIED that the temp path is configurable) |
| Thumbnail generation (ffmpeg, vips) scratch | `TMPDIR=/tmp` |
| `/etc/localtime` rewrite to Asia/Shanghai in upstream Dockerfile | dropped; `TZ` env instead |

Draft expectations (root, writable rootfs) are replaced by UID 568, read-only rootfs, `/config` for all state. Not privileged.

## 10. Risks, caveats and open questions

- Exact log line for readiness is UNVERIFIED; first-start logs print the initial admin credentials, so check logs once and do not paste them into the PR.
- Database or Redis can be changed only via `conf.ini` or `CR_CONF_*`; switching an existing instance from SQLite to Postgres is a manual migration.
- Dropped features: aria2 offline downloads (supervisor + aria2 + ports 6888), LibreOffice thumbnails. Re-adding aria2 means a second process and extra ports; not planned.
- `CR_CONF_Database.Password` is visible via `docker inspect`; prefer orchestrator secrets.
- Environment variable names contain `.`; some orchestrators reject them, use the `__` form there.
- apt package names for vips/raw/heif tools unverified on Ubuntu 26.04.
- Image grows with ffmpeg and fonts; fonts for CJK thumbnails (`fonts-noto-cjk`) intentionally omitted.

## 11. Build and test steps

Run per `build-test-protocol.instructions.md`, one app only, max 10 rounds:

```sh
cd apps/cloudreve
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create cloudreve-probe-config
docker run --rm -d --name cloudreve-probe --read-only --tmpfs /tmp \
  -v cloudreve-probe-config:/config cloudreve:<VERSION>
docker logs -f cloudreve-probe        # expect: the HTTP listener on `:5212` (port open) and, on first run, the admin credentials in the log
docker rm -f cloudreve-probe; docker volume rm cloudreve-probe-config
forgetool containers test --image cloudreve:<VERSION> --config ./apps/cloudreve/container-test.yaml
```

Always start from an empty `/config` volume and check that the container is still running, with no fatal errors or repeated stack traces. Attempt arm64 only if the amd64 loop is green or the failure is arm64-specific.

## 12. PR checklist

- [ ] Branch `feat/add-cloudreve` from fresh `main`; one app per PR.
- [ ] Commit and PR title: `feat(cloudreve): add new container` (Conventional Commits, target `main`).
- [ ] PR body uses `.github/PULL_REQUEST_TEMPLATE.md`, keeps its sections, and only checks boxes that apply.
- [ ] Notes section contains `🤖 This PR is AI generated.` (no "Generated with ..." line).
- [ ] `docker buildx bake --print` exits 0; `VERSION` in `docker-bake.hcl` matches the Dockerfile `ARG VERSION`.
- [ ] Runtime is rootless (`USER apps`) and works with `--read-only --tmpfs /tmp` and an empty `/config`.
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows status). Only the user can sign it; never sign for them.
- [ ] Untested items stated honestly in the PR: arm64 build, apt package names for vips/raw/heif, Postgres and Valkey wiring, thumbnail generation, large uploads with the temp dir, and SSL/aria2 paths.
