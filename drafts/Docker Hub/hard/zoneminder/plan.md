# zoneminder — implementation plan
> Source: ./draft.md · Target: apps/zoneminder/ · Difficulty: hard · Role: main · Verified on 2026-11-23 (partially; github.com was unreachable from the sandbox, see UNVERIFIED items)

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 1.38.6 (draft tag 1.38.6; a third-party release mirror lists 1.38.6 as latest after 1.38.5). Plan targets 1.38.6, same as draft. |
| Renovate | `datasource=github-releases depName=ZoneMinder/zoneminder versioning=semver` |
| License | GPL-2.0-or-later. UNVERIFIED: could not open the repo LICENSE; ZoneMinder is documented as GPL-2.0. Confirm the SPDX id before commit. |
| Source | https://github.com/ZoneMinder/zoneminder |
| Docs | https://zoneminder.readthedocs.io/ (Ubuntu install page read: needs mariadb/mysql, apache with `rewrite headers cgi`, `a2enconf zoneminder`, schema `/usr/share/zoneminder/db/zm_create.sql`, default DB user `zmuser`/`zmpass`, DB settings in `zm.conf` as `ZM_DB_HOST/NAME/USER/PASS`, console at `/zm`, `www-data` in `video` group for local cameras) |
| Draft binary URLs | `https://github.com/ZoneMinder/zoneminder/releases/download/1.38.6/zoneminder-dbg_1.38.6+bookworm1_{amd64,arm64}.deb`. UNVERIFIED: not reachable. This is only the debug-symbols package built for Debian bookworm, NOT the runnable app, and it targets a different distro than ubuntu 26.04. Do not use it. |
| Real package source | Official apt repo `https://zmrepo.zoneminder.com/debian/release-1.38/<codename>/` has `Packages` indexes for `jammy` and `resolute` (Ubuntu 26.04 codename). Versions seen were 1.38.2 and 1.38.3+resolute1; 1.38.6 availability there is UNVERIFIED. Fallback: the PPA `ppa:iconnor/zoneminder-1.38`. UNVERIFIED: PPA name and arm64 coverage. |
| Per-arch downloads | Via apt (amd64, arm64). UNVERIFIED that arm64 is published in zmrepo for resolute. |
| Checksum | apt verifies the repo signing key (fetch the key from zmrepo.zoneminder.com and store it in `/etc/apt/keyrings`; UNVERIFIED key URL). No separate published checksum for GitHub assets known. |
| Upstream Dockerfile | dlandon/zoneminder.unraid (phusion jammy, PPA, apache, php, DB and Tailscale under init). UNVERIFIED: page unreachable; reviewed only via draft description. It is not suitable as-is (root, multi-service). |
| Ports | Apache 80 (and 443 only if TLS is configured). Web UI at `/zm`. ZM also uses the camera/streaming over the same HTTP port (`nph-zms` CGI). |
| Env vars | ZoneMinder itself reads none; config is `/etc/zm/zm.conf` and `/etc/zm/conf.d/*.conf`. Env vars below are ContainerForge conventions consumed by start.sh only. |

## 2. Target layout

- `apps/zoneminder/Dockerfile`
- `apps/zoneminder/docker-bake.hcl`
- `apps/zoneminder/settings.yaml`
- `apps/zoneminder/container-test.yaml`
- `apps/zoneminder/start.sh`
- `apps/zoneminder/etc/` : optional apache snippet (listen on 8080, `ServerName`, PID/log/run dirs in /tmp) copied by `COPY . /`. Needed because the packaged apache config writes to `/var/run`, `/var/log/apache2`.
- `apps/zoneminder/defaults/zm.conf.d/` : seed values for `/config/zm/conf.d` (DB host, name, user, path overrides).
- No `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Fits because the draft says ubuntu alone is enough, apache and PHP come from apt, and Ubuntu 26.04 (resolute) has a zmrepo index. Closest siblings: `apps/bookstack` (apt PHP stack, mariadb-client, external DB) and `apps/valkey` (pinned apt version).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH` (arch handled by apt; no mapping needed), `USER root`.
2. Add the ZoneMinder apt source for `resolute` (key into `/etc/apt/keyrings/zoneminder.gpg`, `deb [signed-by=...] https://zmrepo.zoneminder.com/debian/release-1.38/resolute/ ./`; exact repo line UNVERIFIED, copy from https://zmrepo.zoneminder.com/).
3. `apt-get install -y --no-install-recommends zoneminder=${VERSION}* apache2 libapache2-mod-php mariadb-client ffmpeg` (PHP modules come as zoneminder dependencies; check what the package already pulls in). Pin `zoneminder` to `${VERSION}` and fail the build if `dpkg-query -W -f='${Version}' zoneminder` does not start with `${VERSION}`. Do NOT install mariadb-server (DB is the `mariadb` app).
4. `a2enmod rewrite headers cgi expires`; `a2enconf zoneminder`; remove the default site; switch apache `Listen` to 8080 via `etc/` snippet; point `APACHE_RUN_DIR`, `APACHE_PID_FILE`, `APACHE_LOG_DIR`, `APACHE_LOCK_DIR` to `/tmp/apache2` (set in start.sh env).
5. Relocate writable ZM paths: symlink or configure `ZM_PATH_*`/`ZM_DIR_EVENTS`, `ZM_DIR_IMAGES`, `ZM_DIR_SOUNDS`, `/var/cache/zoneminder`, `/var/log/zm`, `/run/zm` to `/config` or `/tmp` (see section 9). Make `/etc/zm/conf.d` include `/config/zm/conf.d`.
6. Licenses: `mkdir -p /usr/share/licenses/zoneminder && cp /usr/share/doc/zoneminder/copyright /usr/share/licenses/zoneminder/`.
7. `rm -rf /var/lib/apt/lists/*`; `chown -R apps:apps /app` if anything is placed there (nothing expected; app lives in `/usr/share/zoneminder`).
8. `ENV HOME=/config TMPDIR=/tmp`, `USER apps`, then `COPY --chmod=0755 . /`.
9. `EXPOSE 8080` (see risks on 80), `VOLUME /config`.

```dockerfile
# renovate-tracked via docker-bake VERSION
ARG VERSION
USER root
...
USER apps
COPY --chmod=0755 . /
EXPOSE 8080
VOLUME /config
```

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "zoneminder" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=ZoneMinder/zoneminder versioning=semver
  default = "1.38.6"
}
variable "LICENSE" { default = "GPL-2.0-or-later" }   // UNVERIFIED SPDX
variable "SOURCE" { default = "https://github.com/ZoneMinder/zoneminder" }
```
Plus `docker-metadata-action`, `image` (args.VERSION, source and licenses labels), `image-local` (type=docker, tag `${APP}:${VERSION}`), `image-all` (linux/amd64, linux/arm64), `group "default" { targets = ["image-local"] }`, copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/ZoneMinder/zoneminder"
ports:
  - {port: 8080, protocol: tcp, required: true}
env:
  - {name: TZ, default: "Etc/UTC", required: false}
  - {name: ZM_DB_HOST, default: "mariadb", required: false}
  - {name: ZM_DB_NAME, default: "zm", required: false}
  - {name: ZM_DB_USER, default: "zmuser", required: false}
  - {name: ZM_DB_PASS, default: "zmpass", required: false}
volumes:
  - {path: /config, required: true}
dependencies:
  - name: mariadb   # ✅ apps/mariadb exists
    required: true
```
`ZM_DB_*` are the real `zm.conf` keys; start.sh writes them to `/config/zm/conf.d/` (confirm key names against the shipped `/etc/zm/zm.conf`). `TZ` is read by PHP/apache setup in start.sh. Add `ZM_DB_PORT` only if confirmed.

## 7. start.sh

- `set -euo pipefail`; export `TZ`, `APACHE_RUN_DIR=/tmp/apache2`, `APACHE_PID_FILE`, `APACHE_LOG_DIR`, `APACHE_LOCK_DIR`; `mkdir -p` those, plus `/tmp/zm`, `/config/zm/{conf.d,events,images}` only when missing.
- Seed `/config/zm/conf.d/` from `/defaults/zm.conf.d/` with `cp -n`; then rewrite a generated `99-env.conf` EVERY start from `ZM_DB_*` (values written with `printf '%s'`, not via shell interpolation into sed, to survive special characters; file mode 600; password never on the command line).
- Wait for MariaDB with a bounded retry loop (`mariadb-admin ping`); on first run, if the `zm` schema is absent, import `/usr/share/zoneminder/db/zm_create.sql` as the app DB user (needs the DB and user to exist; creating them is the `mariadb` app's job, document in section 10). Log "waiting for database" and keep the process alive instead of exiting.
- Start `zmpkg.pl start` (backgrounded under a small supervision loop, writing PID/log under `/tmp`), then `exec apache2 -DFOREGROUND` bound to 0.0.0.0:8080. Single `exec` final command; trap SIGTERM to run `zmpkg.pl stop`.
- Never write to `/app` or `/usr/share/zoneminder`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 240
tcp:
  - port: '8080'
# narrowed: requires external mariadb; full functional test not feasible in single-container suite
# http probe of /zm/ only if the schema shape is confirmed (copy from a sibling that uses http)
filePaths:
  - /usr/share/zoneminder/www/index.php   # UNVERIFIED path
  - /usr/bin/zmpkg.pl
  - /usr/sbin/apache2
```
Every settings.yaml port (8080) has a tcp probe. Timeout 240 copied from `apps/bookstack`. The DB-narrowing exception applies only if the 3 criteria hold; ZM web UI will show a DB error page without a DB but apache still listens, so keep the tcp probe real and the comment above. The http probe is left as a comment until the schema shape is confirmed.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/cache/zoneminder` (events, images, temp; draft persistence) | `/config/zm/events` persistent; temp parts to `/tmp/zm` |
| `/var/log/zm`, `/var/log/apache2` | `/tmp/zm/log`, `/tmp/apache2` |
| `/run/zm`, `/var/run/apache2`, apache PID | `/tmp/zm`, `/tmp/apache2` |
| `/etc/zm/conf.d` | include `/config/zm/conf.d` |
| PHP sessions / tmp | `session.save_path=/tmp` and `TMPDIR=/tmp` |

Draft expects root (UID 0), no read-only rootfs, capability KILL, camera devices, extra `/var/cache/zoneminder` PVC. Plan runs as `apps` (non-root), read-only rootfs compatible, no privileged. Port 80 is not bindable as non-root without sysctl, so use 8080 (settings/tests use 8080). Camera devices: pass `/dev/video*` with `video` group via the orchestrator (`supplementalGroups`); network cameras need nothing. KILL cap is not needed for non-root signals to own processes. Event storage moves from `/var/cache/zoneminder` to `/config/zm/events` (single volume; document that the draft's second PVC is merged unless a user mounts one at that path).

## 10. Risks, caveats and open questions

- Draft's .deb is a bookworm `dbg` package: wrong artifact and wrong distro. Plan uses the zmrepo resolute apt packages instead; confirm 1.38.6 exists there, else target the newest published 1.38.x and say so in the PR.
- arm64 availability in zmrepo/PPA: UNVERIFIED. If missing, ship amd64 only (`image-all` platforms trimmed) and note it.
- Multi-service (zmpkg daemons + apache): supervised from start.sh; if zmpkg fails, container should exit non-zero rather than hide it.
- Database must pre-exist (mariadb app, user `zmuser` with full rights on `zm`). Schema import on first start; schema upgrades via `zmupdate.pl` on version change: UNVERIFIED flags, test during upgrade.
- ZoneMinder 1.38 PHP version compatibility with Ubuntu 26.04 PHP: UNVERIFIED.
- Apache `/zm` alias, `ScriptAlias` and `nph-zms` path must be reachable as non-root; check `PATH_ZMS`.
- Tailscale from the draft image is out of scope.
- CPU/disk heavy; needs large event storage; shared memory (`/dev/shm`) size must be raised for multiple cameras (ZM uses `/dev/shm`, not writable on read-only rootfs unless mounted).
- Possible `setuid/setgid` or `www-data` user assumptions in ZM scripts (`zm.conf` `ZM_WEB_USER`/`ZM_WEB_GROUP`): must be set to `apps`. UNVERIFIED key names.

## 11. Build and test steps

```sh
cd apps/zoneminder
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker network create zm-net
docker run -d --name zm-db --network zm-net -e MARIADB_ROOT_PASSWORD=... <mariadb image>   # create zm db/user per mariadb app docs
docker volume create zoneminder-probe-config
docker run --rm -d --name zoneminder-probe --network zm-net --read-only --tmpfs /tmp --tmpfs /dev/shm \
  -e ZM_DB_HOST=zm-db -v zoneminder-probe-config:/config zoneminder:1.38.6
docker logs -f zoneminder-probe
forgetool containers test --image zoneminder:1.38.6 --config ./apps/zoneminder/container-test.yaml
docker rm -f zoneminder-probe zm-db; docker volume rm zoneminder-probe-config; docker network rm zm-net
```
Expected readiness: apache listening on 8080 (no AH fatal errors), `zmpkg.pl` start message / "waiting for database" retry loop with process alive, and `curl http://localhost:8080/zm/` returns HTML. Also run once without any DB (as the test does) and confirm the container stays up. Cap at 10 rounds.

## 12. PR checklist

- Branch `feat/add-zoneminder`; commit `feat(zoneminder): add new container`; title identical; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keeping sections; check only boxes that apply.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` check shows status).
- State honestly what is untested: image build, run on read-only rootfs, arm64, camera device access, DB schema import and upgrade, and every UNVERIFIED item above (license SPDX, zmrepo 1.38.6 availability, key URL, zm.conf key names, file paths).
- Pre-completion: bake --print exits 0, Dockerfile/bake version aligned, final `USER apps`, `COPY --chmod=0755 . /` present, empty `/config` starts.
