# borg-server — implementation plan
> Source: ./draft.md · Target: apps/borg-server/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | BorgBackup `1.4.5` (pinned in upstream Dockerfile `pip ... borgbackup=="1.4.5"`). Latest borg release tag `1.4.5`, published 2026-07-18T22:36:16Z. Source: https://api.github.com/repos/borgbackup/borg/releases/latest (read with `gh api`). Wrapper repo latest tag `v2.8.46` (https://api.github.com/repos/AnotherStranger/docker-borg-backup/releases). Draft container tag `ghcr.io/anotherstranger/borg-server:2.8.46` maps to the wrapper tag (UNVERIFIED that ghcr publishes it). |
| Renovate (borg) | `// renovate: datasource=pypi depName=borgbackup versioning=pep440` (UNVERIFIED: versioning not checked on a page; pip pins `1.4.5`). |
| License | Borg: BSD-style license text (read via `gh api repos/borgbackup/borg/contents/LICENSE`, "Redistribution and use in source and binary forms, with or without ..."). SPDX id UNVERIFIED (GitHub API reports `NOASSERTION`). Wrapper repo: Apache-2.0 (`gh api repos/AnotherStranger/docker-borg-backup/license`). The image contains borg, so the bake `LICENSE` is the borg license (UNVERIFIED SPDX id, so use `BSD-3-Clause` only after checking the file). |
| Source URL | https://github.com/borgbackup/borg (app); https://github.com/AnotherStranger/docker-borg-backup (wrapper). |
| Download | No release binary. `pip install borgbackup==1.4.5` (PyPI). Pure Python plus C extensions, so arm64 needs a build step. |
| Checksum source | PyPI hashes (pip `--require-hashes` could pin them; not fetched in this run). UNVERIFIED: no checksum read in this run. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/AnotherStranger/docker-borg-backup/2737b502e67417e06a791c10df33d38726df98dd/Dockerfile. `FROM python:3.15.2-alpine3.24@sha256:20a82dbc2783112ddb91d1534603f802d222a3e63e593cd002eb2ac534e70211` (Alpine, musl). Builder runs `pip wheel borgbackup=="${BORGBACKUP_VERSION}"`; runtime installs `openssh-server` plus pinned Alpine packages (`acl-dev`, `zstd`, `lz4`, `xxhash`, `linux-headers`, `openssl`, `bash`, `shadow`, `sed`), creates user `borg` UID 500, `EXPOSE 22`, `VOLUME /home/borg/backups/`, `/var/lib/docker-borg`, `/home/borg/.ssh/`, `CMD ["/entrypoint.sh"]`, no `USER` (root). |
| Upstream entrypoint reviewed | https://api.github.com/repos/AnotherStranger/docker-borg-backup/contents/entrypoint.sh (read with `gh api`). Runs `usermod -p` (random password), `usermod -U borg`, `ssh-keygen -A` on first run, moves host keys to `/var/lib/docker-borg/ssh`, `chmod og-rwx`, symlinks keys into `/etc/ssh`, `usermod -u "$BORG_UID"`, `groupmod -o -g "$BORG_GID"`, writes `/home/borg/.ssh/authorized_keys` from `BORG_AUTHORIZED_KEYS` with `restrict,command="borg serve ${BORG_SERVE_ADDITIONAL_ARGS} --restrict-to-path /home/borg/backups"`, `chown -R borg:borg` on backups and `.ssh` (when `ENSURE_BACKUP_PERMISSIONS=true`), then `exec /usr/sbin/sshd -D -e`. |
| Ports (real) | `22` (EXPOSE, sshd). |
| Env vars (real) | Dockerfile `ENV`: `BORG_SERVE_ADDITIONAL_ARGS=""`, `BORG_UID=""`, `BORG_GID=""`, `ENSURE_BACKUP_PERMISSIONS=true`. Entrypoint also reads `BORG_AUTHORIZED_KEYS` (set by the user, not in `ENV`). |
| Correction to draft | Draft says `BORG_UID` comes from `PUID`. Upstream reads `BORG_UID` and `BORG_GID` directly; there is no `PUID`. Whether the chart maps `PUID` to `BORG_UID` is UNVERIFIED (chart not re-fetched). |
| Capabilities | Draft says the chart adds `SYS_CHROOT` and `KILL`. UNVERIFIED for this run (chart not fetched). |
| Volumes (upstream) | `/home/borg/backups/`, `/var/lib/docker-borg`, `/home/borg/.ssh/`. |
| Arm64 | Upstream has no arch-specific steps. Pip source build on musl. Ubuntu arm64 build UNVERIFIED. |

## 2. Target layout

Exact file list for `apps/borg-server/`:
- `Dockerfile`: required.
- `docker-bake.hcl`: required.
- `settings.yaml`: required.
- `container-test.yaml`: required.
- `start.sh`: required. Replaces upstream `entrypoint.sh`. Generates host keys into `/config`, writes `authorized_keys`, and `exec`s sshd.
- `etc/`: needed for a read-only `sshd_config` default (`etc/ssh/sshd_config`), copied with `COPY --chmod=0755 . /`. Reason: sshd reads its config from `/etc/ssh` in the image; `start.sh` points sshd at it with `-f`.
- `defaults/`: needed only if a default `authorized_keys` or sshd config is seeded to `/config` (reason: idempotent seeding).
- `root/`: NEVER used.
- `DOWNSTREAM_CHANGES.md`: not needed (no other app uses this as a FROM base).

## 3. Base image

Runtime stage: `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (the repo python base, matching upstream Python 3.15.2). The repo python base is Ubuntu-based (`apps/python/Dockerfile` starts from `ghcr.io/trueforge-org/ubuntu:26.4`), so `apt-get` for `openssh-server` works. Do not use the upstream Alpine base. Closest siblings: `apps/bazarr` (python with pip deps on the python base) and `apps/python` (venv in `/app/venv`). Ubuntu base for borg-only (no python) is NOT used because the pip step is the main runtime.

## 4. Dockerfile

1. `ARG VERSION=1.4.5` (borg version; tag can be wrapper version separately), `ARG TARGETARCH`, `ARG PIP_VERSION` etc. as the python base requires. `VERSION` must equal the bake default.
2. `USER root`.
3. Install apt packages (check the python base first; install only what is missing): `openssh-server`, `openssh-client`, `acl`, `libacl1-dev` only if pip needs to build borg from source (build-only, removed in the same `RUN`), `libzstd1`, `liblz4-1`, `libxxhash0` (UNVERIFIED names on 26.04). Use `--no-install-recommends`.
4. Install borg into the venv at build time (not at runtime): `pip install --no-cache-dir "borgbackup==${VERSION}"` into `/app/venv` (the python base `VENV_FOLDER` is `/app/venv`). Pip cache goes to `/tmp` (`PIP_CACHE_DIR=/tmp/pip`). Verify with `borg --version`.
5. Create the `borg` service dirs: `mkdir -p /run/sshd` (sshd privilege separation, see section 9), and note the `borg` user is NOT created as UID 500; the app runs as `apps` (568).
6. `ENV HOME=/config PATH=/app/venv/bin:$PATH BORG_SERVE_ADDITIONAL_ARGS="" BORG_UID="" BORG_GID="" ENSURE_BACKUP_PERMISSIONS=true`. `BORG_UID` and `BORG_GID` are read by `start.sh` only if the rootless design allows it (section 9).
7. Licenses: `install -D -m 0644 /app/venv/lib/python3.15/site-packages/borg-*.dist-info/LICENSE /usr/share/licenses/borg-server/LICENSE` (path UNVERIFIED; check the installed dist-info). Add the wrapper's Apache-2.0 license text from upstream `LICENSE` (UNVERIFIED: the wrapper repo's LICENSE file path; not fetched here).
8. `chown -R apps:apps /app/venv`? NO. Keep `/app/venv` root-owned and read-only (python-runtime rule). Only ensure readability: `chmod -R a+rX /app/venv`.
9. Remove build-only packages and `/tmp/*` in the same `RUN`.
10. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 22
VOLUME /config
WORKDIR /config
```

`EXPOSE 22` is kept as upstream. Port choice is section 9. `VOLUME` is `/config` only; backups go to `/config/backups` (see section 9).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "borg-server"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=borgbackup versioning=pep440
  default = "1.4.5"
}

variable "LICENSE" {
  default = "BSD-3-Clause"
}

variable "SOURCE" {
  default = "https://github.com/borgbackup/borg"
}
```

`LICENSE` is UNVERIFIED: the borg LICENSE text is BSD-style, but the exact SPDX id must be checked on the file before commit. Then the default group, `image`, `image-local`, `image-all` targets from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print` from `apps/borg-server/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/AnotherStranger/docker-borg-backup"
ports:
  - port: 2222
    protocol: tcp
    required: true
env:
  - name: BORG_SERVE_ADDITIONAL_ARGS
    default: ""
    required: false
  - name: ENSURE_BACKUP_PERMISSIONS
    default: "true"
    required: false
  - name: BORG_AUTHORIZED_KEYS
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Port `2222` is the rootless choice (section 9); upstream is `22`. Do not list `BORG_UID` or `BORG_GID` until the root decision is made. Every env name here is read by upstream (`BORG_AUTHORIZED_KEYS` and `ENSURE_BACKUP_PERMISSIONS` from the entrypoint). `dependencies:` none.

## 7. start.sh

Plan (not a copy of upstream; upstream `usermod`, `groupmod`, `chown` need root):

```bash
#!/usr/bin/env bash
set -eu

mkdir -p /config/ssh /config/backups /config/.ssh /tmp/borg-run

# Host keys: generate once into /config/ssh only when missing
if [ ! -f /config/ssh/ssh_host_ed25519_key ]; then
  ssh-keygen -q -t ed25519 -N "" -f /config/ssh/ssh_host_ed25519_key
fi
chmod -R og-rwx /config/ssh

# authorized_keys from BORG_AUTHORIZED_KEYS, restricted to /config/backups
if [ -n "${BORG_AUTHORIZED_KEYS:-}" ]; then
  printf '%s\n' "${BORG_AUTHORIZED_KEYS}" | sed -re "/^\\s*(\$|#)/! s|^|restrict,command=\"borg serve ${BORG_SERVE_ADDITIONAL_ARGS:-} --restrict-to-path /config/backups\" |" > /config/.ssh/authorized_keys
  chmod og-rwx /config/.ssh/authorized_keys
fi

exec /usr/sbin/sshd -D -e -f /etc/ssh/sshd_config -o "HostKey /config/ssh/ssh_host_ed25519_key" -o "Port 2222" -o "PidFile /tmp/borg-run/sshd.pid"
```

Key points:
- Idempotent: `ssh-keygen` only when the key is missing; `mkdir -p` only.
- Writes only to `/config` and `/tmp`. Never `/app` or `/etc`.
- `authorized_keys` is written only when `BORG_AUTHORIZED_KEYS` is set (matches upstream behavior). The `sed` escape of `$` and `#` lines is copied from upstream; re-check quoting on real keys.
- The `--restrict-to-path` changes from `/home/borg/backups` to `/config/backups` (remap).
- `exec` sshd so signals reach it.
- `BORG_UID` and `BORG_GID` are NOT applied (no `usermod` without root). Document this as a difference.
- The random password step (`usermod -p`) is dropped: the account is not a login account (key auth only).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '2222'
filePaths:
- /app/venv/bin/borg
- /config/ssh/ssh_host_ed25519_key
- /usr/share/licenses/borg-server/LICENSE
```

Every port in `settings.yaml` has a `tcp` probe. `/config/ssh/ssh_host_ed25519_key` in `filePaths` is checked only if `start.sh` generated it in the test run (empty `/config`), which it does. No `http` probe: sshd has no HTTP. `timeoutSeconds: 120` is a starting value; check a sibling of the same family.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/lib/docker-borg` (VOLUME, host keys) | `/config/ssh` (generated by `start.sh`). |
| `/home/borg/backups` (VOLUME) | `/config/backups`. |
| `/home/borg/.ssh` (VOLUME, `authorized_keys`) | `/config/.ssh`. Note `.ssh` must be a real directory (not a symlink). |
| `/etc/ssh` (host key symlinks, `sshd_config`) | Read-only config in the image under `etc/ssh/`; host keys passed with `-o HostKey`. |
| `/var/run/sshd` and sshd privilege-separation dir | `/run/sshd` created at build time. Not writable at runtime; keep it root-owned in the image (UNVERIFIED that sshd accepts it read-only). |
| `usermod`, `groupmod`, `chown` (`BORG_UID`, `BORG_GID`, `ENSURE_BACKUP_PERMISSIONS`) | Dropped. The image runs as `apps` (568) and cannot change UIDs. |
| sshd port 22 | Port 2222, because a non-root process cannot bind below 1024. |
| `/tmp` | sshd pidfile and scratch. |

Security expectations from the draft (`runAsUser 0`, `readOnlyRootFilesystem false`, `SYS_CHROOT` and `KILL` capabilities) are NOT met by this plan. Target: `apps` (568), read-only rootfs, no extra capabilities. This is a rework, flagged as a blocker in section 10.

## 10. Risks, caveats and open questions

- Blocker (rootless): upstream design depends on root for `usermod`, `groupmod`, `chown` and port 22. This plan changes that. The user must decide whether the app stays rootless (this plan) or keeps the upstream root design (not read-only-rootfs compatible). sshd as non-root with `Port 2222` and host keys in `/config` is UNVERIFIED in practice; test it.
- Blocker (privsep): OpenSSH privilege separation normally needs a `sshd` user and a root-owned `/run/sshd`. Non-root sshd may refuse to start without `UsePrivilegeSeparation` settings. UNVERIFIED; test the `-o` flags.
- Blocker (UID): borg refuses repositories whose owner does not match the running UID. The draft's `BORG_UID` (from `PUID`) mapping is not possible without root; repositories must be owned by `apps` (568) or be migrated. UNVERIFIED how existing users' repos are owned.
- `PUID` vs `BORG_UID`: draft is wrong (upstream has no `PUID`). Chart mapping UNVERIFIED.
- Capabilities `SYS_CHROOT`, `KILL` from the chart: UNVERIFIED, not required for the rootless plan.
- sshd and borg share one container and one log stream (draft inference). The `exec sshd` approach runs only sshd; borg is spawned by sshd per connection.
- Python venv: borg 1.4.5 is pinned by pip. The C extensions build on musl upstream; on the Ubuntu python base they are glibc. Build success on arm64 is UNVERIFIED.
- Draft's `openssh-server` version and pinned apt names (upstream pins Alpine versions like `openssh-server 10.3_p1-r1`) do NOT transfer to Ubuntu: pick Ubuntu package versions and check them against the base.
- Wrapper license (Apache-2.0) and borg license SPDX are UNVERIFIED for the bake `LICENSE`.
- copy-from: NOT usable (upstream image is Alpine/musl, and the borg binary is a Python package).
- Draft's Difficulty: hard. Keep it.

## 11. Build and test steps

From `apps/borg-server/`:

1. `docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name borg-server-probe --read-only --tmpfs /tmp -v borg-server-probe-config:/config borg-server:1.4.5`. Then `docker logs -f borg-server-probe`. Readiness signal: sshd "Server listening on 0.0.0.0 port 2222" line and the process still running. Cleanup: `docker rm -f borg-server-probe; docker volume rm borg-server-probe-config`.
4. `forgetool containers test --image borg-server:1.4.5 --config ./apps/borg-server/container-test.yaml`.
5. Repeat step 3 with an empty `/config` on every round.

Not tested: arm64 build, a real borg client push, `BORG_AUTHORIZED_KEYS` restriction behavior, repo ownership migration.

## 12. PR checklist

- Branch: `feat/add-borg-server`.
- Commit: `feat(borg-server): add new container`.
- PR title: `feat(borg-server): add new container`.
- PR body: use `.github/PULL_REQUEST_TEMPLATE.md`. Check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign; the `license/cla` check shows status.
- Tell the user about the rootless and port 2222 change (upstream uses 22 and root) and the removed `BORG_UID` mapping.
- Untested list: arm64, real borg client, sshd non-root start, repo ownership, chart capabilities, any UNVERIFIED value.
- Do NOT check "Built container locally" unless section 11 was run.
