# backuppc — implementation plan
> Source: ./draft.md · Target: apps/backuppc/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | BackupPC `4.4.0`, the latest GitHub release (published 2020-06-20). Source: https://api.github.com/repos/BackupPC/backuppc/releases/latest (read with `gh api`). The draft and the chart both use the same version. |
| Draft tag vs upstream | Draft says the chart uses `ghcr.io/adferrand/backuppc:4`. Upstream image source is `adferrand/docker-backuppc` at commit `cf90ead82e93b0af92f4d6d1f0ae28b6ff1c1a69`. |
| Renovate | `// renovate: datasource=github-releases depName=backuppc/backuppc versioning=semver` (UNVERIFIED: versioning choice not confirmed on a page; `semver` fits the plain `4.4.0` tag). |
| License | GPL-3.0 (GitHub API `gh api repos/BackupPC/backuppc/license`, SPDX `GPL-3.0`). |
| Source URL | https://github.com/backuppc/backuppc |
| Download | `https://github.com/backuppc/backuppc/releases/download/4.4.0/BackupPC-4.4.0.tar.gz` (657309 bytes). One asset only. Same file for amd64 and arm64 (pure Perl and web code). |
| Checksum source | None published on the release (one asset, no `SHA256SUMS`). UNVERIFIED: no checksum exists to verify against. The upstream Dockerfile does not verify it either. Plan: pin by SHA256 of the downloaded tarball in the Dockerfile and record it in a comment, so the value is reproducible. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/adferrand/docker-backuppc/cf90ead82e93b0af92f4d6d1f0ae28b6ff1c1a69/Dockerfile. Base `docker.io/alpine:3.24.4`, lighttpd (not Apache), supervisord, entrypoint `/entrypoint.sh`, CMD `/usr/bin/supervisord -c /etc/supervisord.conf`, EXPOSE `8080`, VOLUME `/etc/backuppc`, `/home/backuppc`, `/data/backuppc`, USER not set (root). Build ARGs `BACKUPPC_VERSION=4.4.0`, `BACKUPPC_XS_VERSION=0.62`, `RSYNC_BPC_COMMIT=1ad3f70`. |
| Correction to draft | The draft assumed Ubuntu with Apache on ports 80, 443 and 22. The upstream image is Alpine with lighttpd on 8080. The sshd and rsync roles listed in the draft are not in the upstream Dockerfile. This plan follows the upstream image. |
| Ports (real) | `8080` (EXPOSE, lighttpd). Port 22 (sshd) and 443 are NOT in the upstream image; the draft's ports are UNVERIFIED for this build. |
| Runtime env vars (real) | None set in the Dockerfile (only build ARGs). UNVERIFIED: whatever `/entrypoint.sh` reads (script not fetched in this run). |
| Data and config paths (upstream) | `/etc/backuppc`, `/home/backuppc`, `/data/backuppc` (VOLUME). Writes: `/etc/ssh/ssh_config`, `/usr/sbin/sendmail` (symlink), `/etc/lighttpd/{lighttpd,auth,auth-ldap}.conf`, `/etc/supervisord.conf`, `/firstrun`. |
| Build from source in upstream | BackupPC::XS from `https://github.com/backuppc/backuppc-xs.git` (branch `0.62`); rsync-bpc from `https://github.com/backuppc/rsync-bpc.git` (commit `1ad3f70`). Both need a C toolchain. |
| Apt packages (upstream, Alpine names) | rsync, tar, bash, shadow, supervisor, perl and perl modules, samba-client, openssh, openssl, rrdtool, msmtp, lighttpd, lighttpd-mod_auth, apache2-utils, gzip, pigz, ttf-dejavu, tzdata, libstdc++, libgomp, expat. Ubuntu package names are UNVERIFIED and must be checked on the 26.04 archive. |
| Arm64 | Upstream builds for any arch in Alpine. The XS and rsync-bpc builds are compiled per arch. Ubuntu arm64 builds of these are UNVERIFIED. |

## 2. Target layout

Exact file list for `apps/backuppc/`:
- `Dockerfile`: required.
- `docker-bake.hcl`: required.
- `settings.yaml`: required.
- `container-test.yaml`: required.
- `start.sh`: required. It replaces the upstream `/entrypoint.sh`. It seeds `/config` on first run and starts the web UI and supervisor.
- `etc/`: needed for `/etc/lighttpd/*.conf` and `/etc/supervisord.conf` (see section 9). Reason: those files live in the image and are copied with `COPY --chmod=0755 . /`.
- `defaults/`: needed for the default `lighttpd.conf` and `backuppc/config.pl` seed (copied to `/config` by `start.sh` only when missing). Reason: Idempotent seeding rule.
- `scripts/`: not needed unless `start.sh` grows beyond one file.
- `root/`: NEVER used.
- `DOWNSTREAM_CHANGES.md`: not needed (no other app uses this as a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The brief's ubuntu base is used. Upstream Alpine (`alpine:3.24.4`) does not run as a copy source (musl), so no `COPY --from` shortcut exists. Closest siblings: `apps/adguardhome-sync` (prebuilt binary on ubuntu) and `apps/valkey` (pinned apt version, health dir). Perl apps with apt packages on ubuntu are the pattern here; no Perl-specific sibling was confirmed in this run.

## 4. Dockerfile

Step list (one `FROM` for build and one for final, or one stage if the build only uses apt):

1. `ARG VERSION=4.4.0`, `ARG TARGETARCH`, `ARG BACKUPPC_XS_VERSION=0.62`, `ARG RSYNC_BPC_COMMIT=1ad3f70`. `ARG VERSION` must equal the `docker-bake.hcl` default.
2. `USER root`.
3. Install apt packages (Ubuntu names, UNVERIFIED): `rsync`, `openssh-server`, `openssh-client`, `apache2-utils` or `lighttpd` (see section 10), `perl`, `libarchive-zip-perl`, `libxml-rss-perl`, `libcgi-pm-perl`, `libfile-listing-perl`, `libjson-xs-perl`, `libtime-parsedate-perl`, `samba-client`, `rrdtool`, `msmtp`, `par2`, `pigz`, `tzdata`. Use `--no-install-recommends` and `rm -rf /var/lib/apt/lists/*`. Do not reinstall anything the base already has (check `coreutils`, `curl`, `tini`, `ca-certificates`, `bash`).
4. Build dependencies (`gcc`, `g++`, `make`, `autoconf`, `automake`, `libperl-dev`, `libacl1-dev`, `git`) in the same `RUN` as steps 5 to 10 (installed, used and purged in one `RUN`, so they do not persist in a layer).
5. Clone and build BackupPC::XS: `git clone --depth 1 --branch "${BACKUPPC_XS_VERSION}" https://github.com/backuppc/backuppc-xs.git /tmp/backuppc-xs && cd /tmp/backuppc-xs && perl Makefile.PL && make -j"$(nproc)" && make test && make install`.
6. Build rsync-bpc: `git clone https://github.com/backuppc/rsync-bpc.git /tmp/rsync-bpc && cd /tmp/rsync-bpc && git checkout "${RSYNC_BPC_COMMIT}" && ./configure --disable-md2man --disable-openssl --disable-xxhash --disable-zstd --disable-lz4 && make && make install`. Keep the disable flags from upstream.
7. Download the BackupPC tarball and verify its SHA256: `curl -fL -o /tmp/BackupPC-${VERSION}.tar.gz "https://github.com/backuppc/backuppc/releases/download/${VERSION}/BackupPC-${VERSION}.tar.gz"` then `echo "<sha256>  /tmp/BackupPC-${VERSION}.tar.gz" | sha256sum -c -`. The SHA256 value must be computed once by hand from the file (not in this run; UNVERIFIED value).
8. Extract to `/app/backuppc` (`tar -xzf ... -C /app --strip-components=1` or to a versioned dir), then `chown -R apps:apps /app && chmod -R 755 /app` (the `apps` user is UID/GID 568 from the ubuntu base).
9. License: `install -D -m 0644 /app/backuppc/LICENSE /usr/share/licenses/backuppc/LICENSE`. Verify the path in the tarball (UNVERIFIED).
10. Remove `/tmp/backuppc-xs`, `/tmp/rsync-bpc`, `/tmp/BackupPC-*.tar.gz`, and `apt-get purge` the build dependencies in the same `RUN`.
11. Environment: `ENV HOME=/config XDG_CONFIG_HOME=/config` (ubuntu base sets these already; keep them). Caches to `/tmp`.
12. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /config
```

Note `/etc/backuppc`, `/home/backuppc` and `/data/backuppc` are NOT `VOLUME`s here; `start.sh` maps them to `/config` (see section 9). `COPY --chmod=0755 . /` is mandatory.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "backuppc"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=backuppc/backuppc versioning=semver
  default = "4.4.0"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/backuppc/backuppc"
}
```

Note: GitHub reports `GPL-3.0` (not `-only`). Use the SPDX form the upstream LICENSE file states (UNVERIFIED: check the header of the LICENSE file before committing). Then the default group, `image`, `image-local` (`tags = ["${APP}:${VERSION}"]`) and `image-all` (amd64 and arm64), copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print` from `apps/backuppc/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/backuppc/backuppc"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Only real env vars are listed. Upstream has no runtime env (UNVERIFIED for `/entrypoint.sh`). Do not add `BACKUPPC_*` names. Ports: only `8080` is confirmed (EXPOSE). Port 22 is NOT listed unless sshd is kept (see section 10). `dependencies:` none.

## 7. start.sh

Plan (copy the seeding pattern from `apps/adguardhome-sync/start.sh`):

```bash
#!/usr/bin/env bash
set -eu

mkdir -p /config/etc /config/home /config/data /tmp/backuppc-run
# Seed defaults only when missing (no overwrite of user state)
cp -n /defaults/lighttpd.conf /config/etc/lighttpd.conf 2>/dev/null || true
# Map upstream /home/backuppc to /config/home and /data/backuppc to /config/data (symlinks inside /config are allowed; see section 9)
...
exec /usr/bin/supervisord -c /etc/supervisord.conf
```

Key points:
- Idempotent: `cp -n` and `mkdir -p` only. Never overwrite existing `/config` files.
- Writes only to `/config` and `/tmp`. No write to `/app`.
- Binds lighttpd to `0.0.0.0:8080` (set `server.bind` or `server.port` in the seeded conf; the Alpine conf defaults are not confirmed, so check them, UNVERIFIED).
- `exec` the final process (supervisord) so signals reach it.
- Apply no secret from env in the process list.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/backuppc/bin/BackupPC
- /usr/share/licenses/backuppc/LICENSE
```

Every `settings.yaml` port has a probe. The HTTP path `/` may return a login redirect; confirm the status before fixing `path` (UNVERIFIED). `timeoutSeconds: 120` is a starting value; check a sibling of the same family.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap for this app |
| --- | --- |
| `/etc/backuppc` (VOLUME) | `/config/etc` (seeded by `start.sh`). |
| `/home/backuppc` (VOLUME, WORKDIR, setup) | `/config/home`. A build-time symlink `/home/backuppc -> /config/home` (created as root, as the fenrus-style plans do) is possible and may be simpler than rewriting paths; the app may also need `$Conf{TopDir}` set in the seeded config. Set BackupPC `$Conf{...}` paths in the seeded config instead. |
| `/data/backuppc` (VOLUME, backup storage) | `/config/data` (root-owned storage is replaced by `apps` UID 568 ownership). Backups of large data need a bind mount; not decided here. |
| `/etc/ssh/ssh_config` (StrictHostKeyChecking) | Not needed unless sshd is kept (section 10). Do not edit `/etc`. |
| `/usr/sbin/sendmail` symlink | Not allowed in a read-only rootfs. Drop it or use `msmtp` via `PATH` in `start.sh`. |
| `/etc/lighttpd/*.conf` | Keep in the image as read-only defaults under `etc/`, and point lighttpd at `/config/etc/lighttpd.conf` through `start.sh`. |
| `/etc/supervisord.conf` | Keep in the image as read-only; supervisord log and pid files go to `/tmp`. |
| `/firstrun` | Remove the step; no file in `/` is writable. |
| `/tmp` | Caches and pidfiles only. |

Security expectations from the draft (chart: `runAsUser 0`, `readOnlyRootFilesystem false`, root-owned data) are NOT met by this plan. Target: UID 568 (`apps`), `readOnlyRootFilesystem` true. This changes the chart behaviour and is a hard blocker for root-owned backup storage (see section 10). `privileged`: not set (default false), keep it that way. Extra persistence: `/config` only.

## 10. Risks, caveats and open questions

- Blocker (UNVERIFIED): BackupPC expects root to write backup repositories and to set file ownership in `/data`. Running as `apps` (568) on read-only rootfs changes that. Decide whether to keep root, and if so, the image cannot be rootless.
- Blocker: the upstream image runs sshd (`openssh`) and rsync for backup clients, but the draft's sshd and port 22 are not confirmed in the Dockerfile. Decide whether sshd is part of this app. If yes, sshd needs root to bind 22 and writes `/etc/ssh`; a rootless sshd needs a high port and pregenerated host keys in `/config`.
- Web server choice: upstream uses lighttpd, the draft assumed Apache. Pick lighttpd to match upstream (preferred) or Apache for the Ubuntu sibling pattern. Not decided here.
- Ubuntu package names for every apt entry in section 4 are UNVERIFIED on the 26.04 archive. Check each with `apt-cache policy` in the base.
- The tarball checksum value is UNVERIFIED until computed by hand.
- XS and rsync-bpc source builds on Ubuntu arm64 are UNVERIFIED (upstream is Alpine).
- Chart values (`runAsUser 0`, extra persistence paths, `readOnlyRootFilesystem false`) are from the draft and were not re-fetched.
- Admin password and client SSH keys are set by hand after first start (draft inference, UNVERIFIED).
- copy-from: not usable (upstream image is musl/Alpine). Plan uses the apt/source route only.
- Draft's Difficulty: hard. Keep it.

## 11. Build and test steps

From `apps/backuppc/` (protocol order):

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name backuppc-probe --read-only --tmpfs /tmp -v backuppc-probe-config:/config backuppc:4.4.0`, then `docker logs -f backuppc-probe`. Readiness signal: the lighttpd or supervisord "started" line and an open `8080` port. Cleanup: `docker rm -f backuppc-probe; docker volume rm backuppc-probe-config`.
4. `forgetool containers test --image backuppc:4.4.0 --config ./apps/backuppc/container-test.yaml`.
5. Repeat step 3 with an empty `/config` on every round.

Not tested here: arm64 build, backups through the web UI, client SSH, and any rsync path.

## 12. PR checklist

- Branch: `feat/add-backuppc`.
- Commit: `feat(backuppc): add new container`.
- PR title: `feat(backuppc): add new container`.
- PR body: use `.github/PULL_REQUEST_TEMPLATE.md` sections and checkboxes. Check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign; the `license/cla` check shows status.
- Untested list: arm64, backups, client SSH, chart values, any UNVERIFIED package name.
- Do NOT check "Built container locally" unless the build and run in section 11 were done.
