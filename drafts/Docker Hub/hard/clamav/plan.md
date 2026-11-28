# clamav — implementation plan
> Source: ./draft.md · Target: apps/clamav/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 1.5.5 (release tag `clamav-1.5.5`, published 18 Nov; matches the draft) |
| Renovate | `datasource=github-releases depName=Cisco-Talos/clamav extractVersion=^clamav-(?<version>.+)$ versioning=semver` |
| License | GPL-2.0 (COPYING.txt is GPLv2 plus an OpenSSL linking exception; the "only" vs "or later" choice is not settled by COPYING.txt). SPDX for bake: `GPL-2.0-only` is UNVERIFIED (clamav-docker's header says `GPL-2.0-or-later`, but that header is for the docker repo) |
| Source URL | https://github.com/Cisco-Talos/clamav/ |
| amd64 download | `https://github.com/Cisco-Talos/clamav/releases/download/clamav-${VERSION}/clamav-${VERSION}.linux.x86_64.deb` (from the draft) |
| arm64 download | `https://github.com/Cisco-Talos/clamav/releases/download/clamav-${VERSION}/clamav-${VERSION}.linux.aarch64.deb` (from the draft) |
| Checksum | clamav.net publishes **no SHA256**: it publishes a detached `.sig` per .deb and a PGP key at `https://www.clamav.net/downloads/gpg_public_key`. Verify the `.sig`, then compute and pin sha256 per arch in the Dockerfile (the GitHub asset list did not load, so its digests are unconfirmed) |
| Upstream Dockerfile | clamav-docker `clamav/1.5/debian/Dockerfile` reviewed: builds from source on `debian:13-slim`, install prefix `/usr`, config in `/etc/clamav`, user `clamav` UID/GID 1000, ports 3310 (clamd) and 7357 (milter), no VOLUME, runs as root unless `/init-unprivileged` is used |
| Upstream env | `CLAMAV_NO_CLAMD`, `CLAMAV_NO_FRESHCLAMD`, `CLAMAV_NO_MILTERD` (default true), `FRESHCLAM_CHECKS` (default 1), `CLAMD_STARTUP_TIMEOUT` (default 1800), `TZ` |
| Upstream paths | DB `/var/lib/clamav`, logs `/var/log/clamav`, socket `/tmp/clamd.sock`, clamd config `TCPSocket 3310`, `LocalSocket /tmp/clamd.sock` |

## 2. Target layout

- `Dockerfile`: installs the vendor .deb.
- `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`.
- `start.sh`: first-run database download, then freshclam daemon plus clamd.
- `defaults/clamd.conf` and `defaults/freshclam.conf`: seed templates, so paths point at `/config` and `/tmp` (needed because the image's `/etc` is read-only).
- No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Generic userland, nothing but the vendor package is needed. Ubuntu's own `clamav` apt package will not match 1.5.5, so the vendor .deb is used to keep image version equal to the tag. Closest sibling: `apps/adguardhome-sync` (versioned download) and `apps/valkey` (apt-installed daemon).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`; `USER root`.
2. Map arch: `amd64 -> x86_64`, `arm64 -> aarch64`.
3. Download the .deb to `/tmp`, verify with `sha256sum -c` (checksums per arch, see section 1).
4. `apt-get update && apt-get install -y --no-install-recommends /tmp/clamav.deb` so apt resolves library deps (UNVERIFIED which runtime libs the .deb needs; apt resolves them, check `dpkg -I`). Then `rm -rf /var/lib/apt/lists/* /tmp/*`.
5. Copy the license: `mkdir -p /usr/share/licenses/clamav && cp /usr/share/doc/clamav*/copyright ...` or download COPYING.txt for tag `clamav-${VERSION}`.
6. Do not create a new user: the base user `apps` (UID/GID 568) runs everything. Config path is explicit (`--config-file`), so no `clamav` user is needed. Set `DatabaseOwner`/`User` unset in configs (non-root).
7. `ENV HOME=/config TMPDIR=/tmp`.
8. `COPY --chmod=0755 . /`
9. `EXPOSE 3310`, `VOLUME /config`, final `USER apps`.

## 5. docker-bake.hcl

APP `clamav`; VERSION `1.5.5` with `// renovate: datasource=github-releases depName=Cisco-Talos/clamav extractVersion=^clamav-(?<version>.+)$ versioning=semver`; LICENSE `GPL-2.0-only`; SOURCE `https://github.com/Cisco-Talos/clamav/`. Targets: `docker-metadata-action`, `image` (args VERSION, OCI labels), `image-local` (type=docker, tag `${APP}:${VERSION}`), `image-all` (amd64+arm64), group `default` -> `image-local`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/Cisco-Talos/clamav/"`.
- ports: `3310/tcp required: false`.
- env (only those start.sh implements): `CLAMAV_NO_FRESHCLAMD` default `"false"`, `FRESHCLAM_CHECKS` default `"1"`, `CLAMD_STARTUP_TIMEOUT` default `"1800"`, `TZ` default `Etc/UTC`. The milter (7357) is not shipped in v1 of this image, so `CLAMAV_NO_MILTERD` and port 7357 are not listed.
- volumes: `/config` required true (signature DB under `/config/database`).
- dependencies: none. (Optional scan targets are bind mounts, not listed.)

## 7. start.sh

1. `mkdir -p /config/database /config/logs`; copy `/defaults/clamd.conf` and `/defaults/freshclam.conf` to `/config/` only if missing. Configs: `DatabaseDirectory /config/database`, `LocalSocket /tmp/clamd.sock`, `TCPSocket 3310`, `TCPAddr 0.0.0.0`, `Foreground yes`, `LogFile` unset (log to stdout, `LogSyslog no`), freshclam `Foreground yes` and `NotifyClamd /config/clamd.conf`.
2. If `/config/database/main.cvd` and `main.cld` are both missing, run `freshclam --config-file=/config/freshclam.conf` once in the foreground (no network means the script exits non-zero after logging; clamd cannot run without a DB).
3. Unless `CLAMAV_NO_FRESHCLAMD=true`: `freshclam -d --foreground=true --stdout --checks="${FRESHCLAM_CHECKS:-1}" --config-file=/config/freshclam.conf &`.
4. Remove a stale `/tmp/clamd.sock`, then `exec clamd --foreground --config-file=/config/clamd.conf`. freshclam is a background child; with `tini` as PID 1 in the base image it is reaped on stop. Add a `trap 'kill $FRESH_PID' TERM` is not possible after exec, so rely on tini signalling the process group (tini is the ENTRYPOINT in `apps/ubuntu/Dockerfile`, confirmed; whether it signals the whole process group is UNVERIFIED).
5. `CLAMD_STARTUP_TIMEOUT` is only used if a wait loop is kept; otherwise drop it from the env list.

## 8. container-test.yaml

Forgetool schema header. `timeoutSeconds: 300` (database load; sibling values are 120 to 240). `tcp: - port: '3310'`. `runners`: `clamd --version`, `freshclam --version`. `filePaths`: `/usr/bin/clamscan` (UNVERIFIED install path inside the .deb; confirm with `dpkg -c`). The test has no env and possibly no internet, so clamd may not open 3310 until the DB downloads; if CI has no outbound access, this is the key open risk (do not weaken the tcp probe; instead consider baking a minimal `daily.cvd` check or document the finding).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/var/lib/clamav` (DB) | `/config/database` |
| `/var/log/clamav` | stdout only (`LogFile` unset), optional `/config/logs` |
| `/tmp/clamd.sock` | kept in `/tmp` (tmpfs) |
| `/etc/clamav/*.conf` | seeded to `/config` |
| user `clamav` UID 1000 | run as `apps` UID 568; no `User` directive |

Draft expects runAsUser 0 and `/logs`, `/scandir`; we run non-root, read-only rootfs, and mount scan targets read-only wherever the user wants. `/scandir` must be readable by UID 568.

## 10. Risks, caveats and open questions

- clamd does not start until signatures exist; first start needs internet and a few minutes.
- Two daemons in one container with no supervisor; background freshclam is not restarted if it dies.
- .deb checksum and file layout UNVERIFIED (see section 1).
- Resources: docs.clamav.net asks for 3 GiB+ RAM and 5 GiB free disk (Docker: roughly 3-4 GiB RAM); advise limits accordingly.
- Possible clamd config issue when the DB is replaced during reload; `NotifyClamd` uses the TCP/local socket.
- No blockers (glibc, amd64 and arm64 both published).

## 11. Build and test steps

```sh
cd apps/clamav
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create clamav-probe-config
docker run --rm -d --name clamav-probe --read-only --tmpfs /tmp -v clamav-probe-config:/config clamav:1.5.5
docker logs -f clamav-probe
forgetool containers test --image clamav:1.5.5 --config ./apps/clamav/container-test.yaml
docker rm -f clamav-probe; docker volume rm clamav-probe-config
```
Expected readiness: freshclam logs `daily.cvd updated`/`database is up-to-date`, then clamd logs `Listening daemon: PID` and `TCP: Bound to [0.0.0.0]:3310`/`Self checking every 600 seconds`; `ss -ltn` shows 3310.

## 12. PR checklist

- Branch `feat/add-clamav`; commit and PR title `feat(clamav): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested at planning time: .deb sha256 and layout, build, arm64, runtime behaviour without internet, container-test.
