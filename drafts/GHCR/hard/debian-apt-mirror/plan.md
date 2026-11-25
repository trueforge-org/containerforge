# debian-apt-mirror — implementation plan
> Source: ./draft.md · Target: apps/debian-apt-mirror/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | apt-mirror 0.5.4. Upstream GitHub latest release is tag `0.5.4`, published 2017-05-29 (https://api.github.com/repos/apt-mirror/apt-mirror/releases/latest). Debian trixie/testing/unstable package is 0.5.4-2 (https://manpages.debian.org/trixie/apt-mirror/apt-mirror.1.en.html). |
| Draft container | `ghcr.io/ich777/debian-mirror:latest`, a third-party rolling tag. We do not inherit it. |
| Renovate | For the tool: `datasource=github-releases depName=apt-mirror/apt-mirror versioning=semver`. Ubuntu's package version (for `apt` pins) is UNVERIFIED for 26.04. |
| License | GPL-2.0 (https://api.github.com/repos/apt-mirror/apt-mirror, LICENSE at https://raw.githubusercontent.com/apt-mirror/apt-mirror/master/LICENSE) |
| Source URL | https://github.com/apt-mirror/apt-mirror |
| Download | No upstream release assets (the 0.5.4 release has no prebuilt binary). Install from the distro archive: `apt:apt-mirror`. Arch-independent package, so amd64 and arm64 are both `yes`. |
| Checksum source | Debian/Ubuntu archive signatures (apt signature chain). Exact package sha256 UNVERIFIED (not fetched). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-debian-mirror/master/Dockerfile: `FROM ich777/debian-baseimage`, packages `apt-mirror xz-utils cron apache2`, Apache DocumentRoot `/var/www`, `EXPOSE 980`, `ENTRYPOINT ["/opt/scripts/start.sh"]`, no `USER`, no `VOLUME`, no `CMD`. |
| Ports (upstream) | `APACHE2_PORT=980` (EXPOSE 980). The draft's 80 is an inference. Use the port we actually serve (section 3 proposes 8080). |
| Env vars (upstream, real) | `DATA_DIR=/debian-mirror`, `MIRROR_DIR=$DATA_DIR/data`, `CONFIG_DIR=$DATA_DIR/config`, `APACHE2_PORT=980`, `CRON_SCHEDULE="0 1 * * *"`, `UID=99`, `GID=100`, `UMASK=0000`, `DATA_PERM=770`, `USER=debian`. |
| apt-mirror config | `/etc/apt/mirror.list` (main config). Default mirror base `/var/spool/apt-mirror/mirror`. `/etc/cron.d/apt-mirror` is a template, daily run only when its line is uncommented (https://manpages.debian.org/trixie/apt-mirror/apt-mirror.1.en.html). |
| Config keys to set | UNVERIFIED in this run: the `set base_path`, `set mirror_path`, `set var_path` keys are expected in `mirror.list`; confirm against the apt-mirror man page or the package's example config before writing start.sh. |
| Data path | Upstream: `/debian-mirror` (`DATA_DIR`). Ours: `/config` (see section 9). |
| Dependencies | None. |

## 2. Target layout

- `apps/debian-apt-mirror/Dockerfile`
- `apps/debian-apt-mirror/docker-bake.hcl`
- `apps/debian-apt-mirror/settings.yaml`
- `apps/debian-apt-mirror/container-test.yaml`
- `apps/debian-apt-mirror/start.sh`
- `apps/debian-apt-mirror/defaults/` only if a seed `mirror.list` template is needed (reason: `/config` is empty on first start). Otherwise write it from `start.sh`.

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Draft proposes ubuntu alone. Proposed base: `ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f` for serving the mirror over HTTP, since apache2 runs as root and does not suit a rootless read-only image. apt-mirror is installed on top of the base. If the nginx base is not a fit, use `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` and serve with nginx from apt (UNVERIFIED that the nginx base has an usable config path; read `apps/it-tools` or `apps/theme-park` first). Closest sibling: `apps/it-tools` (nginx on trueforge base).

## 4. Dockerfile

1. Build the image `FROM` the nginx base (section 3). `USER root` only for installs.
2. `apt-get install -y --no-install-recommends apt-mirror` and clean apt lists. Pin the version to the Debian/Ubuntu package and check it against `VERSION` (`0.5.4`); UNVERIFIED for the Ubuntu 26.04 archive (check `apt-cache policy apt-mirror` in the base).
3. Do not install `apache2` or `cron`. Replace them: nginx serves the mirror, and `start.sh` runs a sync loop with `sleep` (no cron, which needs root). Document this in the PR.
4. Copy the default config template to `/etc/apt/mirror.list.template` (in the image, not `/app`) and the script to `/usr/local/bin/`. Use `COPY --chmod=0755 . /` for the app's own files; keep the app's files in `defaults/` or `start.sh` (allow-list in `include/.dockerignore`).
5. `ENV HOME=/config APACHE_PORT` is not used; for nginx set `NGINX_PORT=8080` (UNVERIFIED that the base reads this variable; check the base's entrypoint).
6. License: `COPY` the upstream LICENSE to `/usr/share/licenses/debian-apt-mirror/LICENSE` (download from the tag, or copy from the apt package's `/usr/share/doc/apt-mirror/copyright`).
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
```

Declare `ARG VERSION` (same value as bake `VERSION`, `0.5.4`) and use it for the apt pin check.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "debian-apt-mirror" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=apt-mirror/apt-mirror versioning=semver
  default = "0.5.4"
}
variable "LICENSE" { default = "GPL-2.0" }
variable "SOURCE" { default = "https://github.com/apt-mirror/apt-mirror" }
```

Standard four targets and `default` group, copied from `apps/adguardhome-sync`. `image-all` builds amd64 and arm64. Run `docker buildx bake --print` from `apps/debian-apt-mirror/` and require exit 0.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/apt-mirror/apt-mirror"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: CRON_SCHEDULE
    default: "0 1 * * *"
    required: false
  - name: UMASK
    default: "022"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Only list env vars the start script reads. The `CRON_SCHEDULE` name is kept from upstream for familiarity only if start.sh implements it; otherwise drop it and use a plain sync interval variable (name to decide during implementation). Do not list upstream `UID`/`GID`/`USER`; the image runs as `apps`.

## 7. start.sh

Outline (confirm the apt-mirror config keys first, section 1):

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/mirror /config/var
if [ ! -s /config/mirror.list ]; then
  cp /etc/apt/mirror.list.template /config/mirror.list   # seed only when missing
fi
# set base_path/mirror_path/var_path in /config/mirror.list to /config/... (UNVERIFIED keys)

nginx_start_in_background_as_apps_here_or_via_base_entrypoint

while true; do
  apt-mirror /config/mirror.list || echo "apt-mirror run failed"
  sleep "${SYNC_INTERVAL:-86400}"
done
```

Requirements: idempotent; seed only when missing; no writes to `/app`; caches to `/tmp`; mirror data under `/config`; bind nginx to `0.0.0.0:8080`; `exec` the long-running process (run the sync loop in the background and `exec` nginx, or the reverse; decide during implementation). Do not start a full sync on first boot without `SYNC` being enabled: the first sync downloads hundreds of GB (section 10).

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
- /usr/bin/apt-mirror
- /usr/share/licenses/debian-apt-mirror/LICENSE
```

One tcp and one http probe for the only port in `settings.yaml`. The http path that returns 200 with an empty mirror is UNVERIFIED (nginx's index may 403 or 404 before the first sync); confirm during the run and choose a path that the server returns 200 for, without weakening the test. The test has no sync data, so the apt-mirror run itself is not tested here (noted in section 10).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/debian-mirror` (`DATA_DIR`), `/debian-mirror/data` (`MIRROR_DIR`), `/debian-mirror/config` (`CONFIG_DIR`) | `/config/mirror`, `/config/var`, `/config/mirror.list` |
| `/var/spool/apt-mirror/mirror` (apt-mirror default base) | `/config/mirror` via `mirror.list` (UNVERIFIED key) |
| `/var/www` (Apache DocumentRoot) | Symlink or nginx `root` pointing at `/config/mirror/<host>/debian` (UNVERIFIED layout) |
| `/etc/apt/mirror.list` (`unstable` changed to `stable`) | Template in the image; the seeded `/config/mirror.list` is the user's copy |
| `/etc/cron.d/apt-mirror` | Not used; a sleep loop in `start.sh` |
| `/tmp` | apt-mirror and nginx temp files |

Reconcile the draft's security expectations: draft expects `runAsUser 0`, no read-only rootfs, extra persistence `/debian-mirror`. Target: `USER apps`, read-only rootfs compatible, one `/config` volume (large), no privileged. The chart must mount `/config` as the large volume; `/debian-mirror` no longer exists.

## 10. Risks, caveats and open questions

- A full Debian mirror is tens to hundreds of GB and the first sync can take hours or days (inferred from the draft; size not verified in this run). The test must not start a full sync.
- Mirror needs outbound access to the Debian archive. Cron-style updates only run while the container is up.
- Debian bullseye is not this app's concern, but a mirror of the trixie/stable archive still depends on the chosen `mirror.list` (section 7). Choose the suite explicitly.
- The draft's `ich777` image pins `:latest` (rolling). We do not inherit it; this is a reason for the rewrite, not a blocker.
- apt-mirror 0.5.4 is from 2017 upstream. The distro package is maintained but the upstream project is quiet; note the risk.
- UNVERIFIED: whether Ubuntu 26.04 ships `apt-mirror` in the archive. If it does not, this is a blocker (stop and report).
- Blocker: a sync loop as the only update mechanism means an unattended container can stop syncing silently. Add a log line per run; do not hide failures.

## 11. Build and test steps

From `apps/debian-apt-mirror/`:

1. `docker buildx bake --print` (exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker volume create debian-apt-mirror-probe-config`
   `docker run --rm -d --name debian-apt-mirror-probe --read-only --tmpfs /tmp -p 8080:8080 -v debian-apt-mirror-probe-config:/config ghcr.io/trueforge-org/debian-apt-mirror:0.5.4`
   `docker logs -f debian-apt-mirror-probe` until idle. Readiness signal: nginx listening on 8080 and the sync loop started (exact lines UNVERIFIED; take them from the first run). Pass also needs the process still running and no fatal errors.
4. `forgetool containers test --image <image>:0.5.4 --config ./container-test.yaml`. If forgetool is unavailable, check the port and the files by hand.
5. Cleanup: `docker rm -f debian-apt-mirror-probe; docker volume rm debian-apt-mirror-probe-config`.

Do not run a real mirror sync in the test loop; verify with a short, narrow `mirror.list` (one suite, one component) if a sync check is wanted.

## 12. PR checklist

- Branch `feat/add-debian-apt-mirror` from `main`.
- Commit `feat(debian-apt-mirror): add new container`, with the Co-Authored-By line from the session attribution.
- PR title `feat(debian-apt-mirror): add new container`.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes; check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user the CLA is required: https://cla-assistant.io/trueforge-org/containerforge (only they can sign it; the `license/cla` check shows status).
- State honestly what is not tested: a real sync, arm64 build and run, and the apt-mirror config keys if not confirmed. Do not tick "Built container locally" unless the build and run were actually done.
- Downstream impact: none expected (not a `FROM` base). Confirm with grep.
