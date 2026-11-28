# mysql-workbench — implementation plan
> Source: ./draft.md · Target: apps/mysql-workbench/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Draft pins **8.0.47** (Oracle Ubuntu 24.04 amd64 deb, confirmed HEAD 200). Latest listed on the release notes page is **26.10.0.1** (dated 2026-11-25, the page says it may not be released yet). Plan: pin 8.0.47 unless 26.10.0.1 has an installable deb. Source: https://dev.mysql.com/doc/relnotes/workbench/en/ |
| Difference from draft | Draft names 8.0.47; upstream release notes list 26.10.0.1 as newest. The 26.x deb URL is UNVERIFIED (no deb URL on the page). |
| Renovate | UNVERIFIED: no renovate datasource fits the Oracle CDN deb. Proposed: pin with a comment and a manual bump (open question, section 10). |
| License | GitHub reports `NOASSERTION` for mysql/mysql-workbench (https://api.github.com/repos/mysql/mysql-workbench via `gh api`). Upstream is GPL-2.0 by convention; UNVERIFIED from a LICENSE file in this run. Confirm before setting `LICENSE`. |
| Source URL | https://github.com/mysql/mysql-workbench (C++, not archived) |
| Download amd64 | https://cdn.mysql.com/Downloads/MySQLGUITools/mysql-workbench-community_8.0.47-1ubuntu24.04_amd64.deb (HEAD 200, Content-Length 26531000) |
| Download arm64 | **None.** https://cdn.mysql.com/Downloads/MySQLGUITools/mysql-workbench-community_8.0.47-1ubuntu24.04_arm64.deb returns HTTP 404. Oracle publishes amd64 only for this build. |
| Checksum source | MD5 only: https://cdn.mysql.com/Downloads/MySQLGUITools/mysql-workbench-community_8.0.47-1ubuntu24.04_amd64.deb.md5 (value `15254a0e6c954d005b05ddbe0110d16e`). No SHA256 list was found. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linuxserver/docker-mysql-workbench/4113f475a942/Dockerfile. Base `ghcr.io/linuxserver/baseimage-selkies:arch` (Arch Linux, glibc). Installs `gnome-keyring libsecret mysql-workbench seahorse` via pacman; moves `/usr/sbin/mysql-workbench` to `mysql-workbench-real`; `ENV TITLE="MySQL Workbench" NO_GAMEPAD=true PIXELFLUX_WAYLAND=true`; `VOLUME /config`; `EXPOSE 3001`. |
| Ports | 3001 (EXPOSE in upstream). Draft's 3000 is UNVERIFIED. |
| Env vars (real) | Only the image ENV values above are confirmed. No MySQL connection env var is read by the workbench itself (connections are stored in the GUI profile). |
| Data path | `/config` (VOLUME in upstream). Profile location: UNVERIFIED. |
| arm64 | No arm64 deb from Oracle (404). The upstream linuxserver image is Arch-based; arm64 for it is UNVERIFIED and irrelevant to our route. |

## 2. Target layout

- `apps/mysql-workbench/Dockerfile`
- `apps/mysql-workbench/docker-bake.hcl`
- `apps/mysql-workbench/settings.yaml`
- `apps/mysql-workbench/container-test.yaml`
- `apps/mysql-workbench/start.sh`

No `defaults/`, `etc/`, `health/` unless a default profile is needed (reason to add later). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Fits because the app is a prebuilt Ubuntu 24.04 deb and the base is Ubuntu 26.04. Closest sibling for GUI apps: `apps/kasmvnc` or `apps/xvfb` (both exist; not inspected in this run). The upstream linuxserver base is Arch, which we do not reuse.

## 4. Dockerfile

1. `# syntax=docker/dockerfile:1`, `FROM <ubuntu digest>`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Fail fast on unsupported arch, because only amd64 exists:
   ```dockerfile
   RUN set -eux; \
     if [ "$TARGETARCH" != "amd64" ]; then echo "mysql-workbench: no $TARGETARCH deb from Oracle" >&2; exit 1; fi
   ```
3. Download and verify the deb (checksum is MD5 only, so also pin a SHA256 computed by us and say so in a comment):
   ```dockerfile
   RUN set -eux; \
     curl -fsSL -o /tmp/mysql-workbench.deb \
       "https://cdn.mysql.com/Downloads/MySQLGUITools/mysql-workbench-community_${VERSION}-1ubuntu24.04_amd64.deb"; \
     echo "15254a0e6c954d005b05ddbe0110d16e  /tmp/mysql-workbench.deb" | md5sum -c -; \
     echo "<sha256 computed locally>  /tmp/mysql-workbench.deb" | sha256sum -c -
   ```
   The MD5 literal is from the Oracle `.md5` file in section 1 (confirmed). The SHA256 is UNVERIFIED until computed at build time. Do not invent it.
4. Install with apt so dependencies resolve, then remove the deb:
   ```dockerfile
   RUN apt-get update && \
     DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends /tmp/mysql-workbench.deb && \
     rm -f /tmp/mysql-workbench.deb && \
     rm -rf /var/lib/apt/lists/* /tmp/*
   ```
   Dependency drift (24.04 deb on 26.04) is UNVERIFIED. If apt fails, record the unmet packages and stop (section 10). Do not force `dpkg --force-depends`.
5. Verify the install: `dpkg -s mysql-workbench-community` must succeed; the binary is `/usr/bin/mysql-workbench` (UNVERIFIED path, confirm with `dpkg -L`).
6. License: copy `/usr/share/doc/mysql-workbench-community/copyright` to `/usr/share/licenses/mysql-workbench/` if present (UNVERIFIED path).
7. Final tail:
   ```dockerfile
   ENV HOME=/config \
       XDG_CACHE_HOME=/tmp/.cache
   USER apps
   COPY --chmod=0755 . /
   EXPOSE 3001
   VOLUME /config
   ```
   `COPY --chmod=0755 . /` is mandatory.

## 5. docker-bake.hcl

```hcl
variable "APP" {
  default = "mysql-workbench"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=mysql/mysql-workbench versioning=loose
  default = "8.0.47"
}

variable "LICENSE" {
  default = "GPL-2.0-only" // UNVERIFIED, confirm from LICENSE before merge
}

variable "SOURCE" {
  default = "https://github.com/mysql/mysql-workbench"
}
```

Renovate line is a placeholder: the datasource does not produce the Oracle deb URL (section 10). Replace it with the chosen mechanism once decided. Four standard targets and the default group as in `apps/adguardhome-sync`. For `image-all`, set platforms to `linux/amd64` only (not both arches) with a comment, because arm64 cannot be built. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/mysql/mysql-workbench"
ports:
  - port: 3001
    protocol: tcp
    required: false
env:
  - name: TITLE
    default: "MySQL Workbench"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: mariadb
```

- Port 3001 only if the display/web layer serves it (section 10).
- `opt_dependencies` with `- name: mariadb` (apps/mariadb exists; the draft lists no dependency containers, so this is an addition of the plan, optional; format as in `apps/bookstack/settings.yaml`): the workbench connects to a server but does not need one to start. 
- No Workbench-specific env vars are invented.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/.mysql/workbench /tmp/.cache

export HOME=/config
export XDG_CACHE_HOME=/tmp/.cache

cd /config
exec /usr/bin/mysql-workbench
```

- Idempotent: profile dir is created only when missing; no writes to `/app` (the deb installs under `/usr`, which is read-only at runtime).
- Caches go to `/tmp`.
- Workbench writes its profile under `$HOME` (UNVERIFIED path). Set `HOME=/config` so it persists.
- The binary needs a display: fail with a clear message if `DISPLAY` and `WAYLAND_DISPLAY` are both unset (section 10).
- `exec` for PID 1 handoff.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '3001'
filePaths:
- /usr/bin/mysql-workbench
```

- Every `settings.yaml` port has a probe (3001).
- `filePaths` covers the binary (UNVERIFIED path, confirm with `dpkg -L`).
- `timeoutSeconds`: UNVERIFIED; take from a sibling GUI app when one is chosen. Use a generous value for a GUI start.
- No env vars are set by the test, so the display path is untested here (section 10).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config` profile (`$HOME`) | `HOME=/config`, persistent. |
| Caches | `XDG_CACHE_HOME=/tmp/.cache`. |
| Keyring (gnome-keyring, libsecret) | Not in the deb install; if the Workbench needs it, it will fail to store passwords. Open question (section 10). Do not run `gnome-keyring-daemon` as root. |
| `IPC_LOCK` capability (draft's chart security) | Not needed by the app; not carried over. Verify no code path requires it. |

Draft's security expectations (root, `readOnlyRootFilesystem: false`, `IPC_LOCK` and common root caps) are not carried over. Target: `USER apps`, read-only rootfs, writable `/tmp` and `/config` only.

## 10. Risks, caveats and open questions

- **Blocker: display layer.** Same as firefox: needs X11 or Wayland. Options: use `apps/kasmvnc` or `apps/xvfb` (not inspected in this run) or reject.
- **Blocker: dependency drift.** The 24.04 deb on 26.04 may not install; if so, stop and report, do not force-install.
- **Blocker: version.** 8.0.47 is pinned; 26.10.0.1 may not be downloadable yet. Pick one and document.
- **Renovate has no datasource** for the Oracle CDN deb (section 5). Decide a manual or custom mechanism.
- **Checksum is MD5 only** from Oracle; we add a locally computed SHA256 pin and say so.
- **arm64 is not possible** from Oracle. `image-all` must be amd64-only (section 5). Document in the PR.
- **Keyring and password storage** in the GUI may not work under read-only rootfs.
- **Licence** unverified (`NOASSERTION` on GitHub).
- Upstream linuxserver base (Arch) is not reused, and nothing from it is `COPY --from`-ed (draft's copy-from arm64 is `no`; copy-from amd64 is not recommended because it copies an Arch userland).
- No database is needed to start the app; a server is needed only to use it (`opt_dependencies`).

## 11. Build and test steps

From `apps/mysql-workbench`:

1. `docker buildx bake --print` (exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run and parse logs (no arm64 build):
   ```sh
   docker run --rm -d --name mysql-workbench-probe --read-only --tmpfs /tmp \
     -v mysql-workbench-probe-config:/config mysql-workbench:8.0.47
   docker logs -f mysql-workbench-probe
   ```
   Expected readiness: process still running after the startup window and port 3001 open. Also confirm `dpkg -s mysql-workbench-community` reports installed at build time.
4. Cleanup: `docker rm -f mysql-workbench-probe; docker volume rm mysql-workbench-probe-config`.
5. Test suite: `forgetool containers test --image mysql-workbench:8.0.47 --config ./apps/mysql-workbench/container-test.yaml`.

## 12. PR checklist

- Branch: `feat/add-mysql-workbench`. Commit: `feat(mysql-workbench): add new container`. Title matches the commit.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes; check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State what is untested: display layer, install on 26.04 (dependency drift), keyring, and the SHA256 pin (computed locally, not from upstream).
- Downstream: none (not a `FROM` base), so no `DOWNSTREAM_CHANGES.md`.
