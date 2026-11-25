# rstudio — implementation plan
> Source: ./draft.md · Target: apps/rstudio/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Chart pins `ghcr.io/rocker-org/rstudio:4.6.2` (R 4.6.2). Upstream rocker Dockerfile pins `RSTUDIO_VERSION="2026.11.0+203"`. Latest stable RStudio Server version: UNVERIFIED (posit download page did not render a version list). Plan pins the rocker value. |
| Renovate | UNVERIFIED for the deb. Proposed: `datasource=github-releases depName=rstudio/rstudio versioning=loose` (the `+203` build suffix is not strict semver). Confirm on the first bake. |
| License | AGPL-3.0 (`COPYING`, "Version 3, 19 November 2007", https://raw.githubusercontent.com/rstudio/rstudio/main/COPYING) |
| Source URL | https://github.com/rstudio/rstudio |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/rocker-org/rocker-versioned2/500642d/dockerfiles/rstudio_4.6.2.Dockerfile (base `docker.io/library/ubuntu:resolute`, `CMD ["/init"]`, `EXPOSE 8787`, no `USER`, no `VOLUME`, `DEFAULT_USER=rstudio`) |
| Install script reviewed | https://raw.githubusercontent.com/rocker-org/rocker-versioned2/500642d/scripts/install_rstudio.sh |
| Download URL pattern | `https://download2.rstudio.org/server/${UBUNTU_CODENAME}/${ARCH}/rstudio-server-${VERSION//+/-}-${ARCH}.deb`, fallback `https://s3.amazonaws.com/rstudio-ide-build/server/${UBUNTU_CODENAME}/${ARCH}/` (same filename). `ARCH` from `dpkg --print-architecture`. |
| Per-arch | amd64 and arm64 both use the same pattern (the script does not restrict arch). Exact resolute `.deb` filename for `2026.11.0-203`: UNVERIFIED (not listed on any fetched page). |
| Checksum source | None: the rocker script does no checksum or signature check, and no published `.sha256` was found. Plan: compute sha256 on the first verified download and pin it in the Dockerfile, flagged as self-computed. UNVERIFIED that posit publishes one. |
| Ports | 8787 (`EXPOSE 8787`, rocker Dockerfile) |
| Env vars (real, from upstream Dockerfile) | `R_VERSION=4.6.2`, `R_HOME=/usr/local/lib/R`, `TZ=Etc/UTC`, `LANG=en_US.UTF-8`, `S6_VERSION=v2.1.0.2`, `RSTUDIO_VERSION`, `DEFAULT_USER=rstudio`, `CRAN=https://p3m.dev/cran/__linux__/resolute/latest` |
| Apt packages used by rocker install | ca-certificates, gdebi-core, git, libclang-dev, libssl-dev, lsb-release, psmisc, pwgen, sudo, wget (install_rstudio.sh) |
| Data and config paths | `/home/rstudio` (per-user rsession state), `/home/rstudio/.config/rstudio`, `/home/rstudio/workspace` (chart PVC defaults, from draft.md) |
| Auth | PAM against system users (rocker `pam-helper.sh`, `default_user.sh`, `init_userconf.sh`). Login user must exist as a system user. |
| Blockers | `rserver` runs as root and spawns per-user `rsession` processes that write under `/home`; PAM needs system users. Not compatible with `USER apps` or `--read-only` as-is. |

## 2. Target layout

- `apps/rstudio/Dockerfile`
- `apps/rstudio/docker-bake.hcl`
- `apps/rstudio/settings.yaml`
- `apps/rstudio/container-test.yaml`
- `apps/rstudio/start.sh`
- `apps/rstudio/defaults/` only if a seed `rserver.conf` or `rsession.conf` is needed (reason: RStudio reads them from `/etc/rstudio`, so the seed copy would land there and needs a `/config` symlink or a bind-mount remap)
- No `root/` (never used by agents). No `DOWNSTREAM_CHANGES.md` (no downstream `FROM` consumers found for rstudio).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The rocker image also uses `ubuntu:resolute`, which is 26.04, so the base matches. Closest sibling: `apps/adguardhome-sync` (prebuilt download on ubuntu). For the R toolchain, no ContainerForge `r` base exists (none listed in the base-image table), so R comes from apt on the ubuntu base.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install R with apt, pinned against `VERSION`'s R line: `apt-get install -y --no-install-recommends r-base-core` (package name and version for resolute: UNVERIFIED). Add `gdebi-core` and `wget` for the deb install (both listed by rocker `install_rstudio.sh`). Do not reinstall `ca-certificates`, `curl`, `tar` (already in base).
3. Map the arch: `ARCH=$(dpkg --print-architecture)` (script-equivalent; amd64 and arm64 only).
4. Download and install the deb, then verify it:
   ```sh
   RSTUDIO_DEB_VERSION="$(echo "${VERSION}" | tr '+' '-')"
   curl -fL -o /tmp/rstudio-server.deb \
     "https://download2.rstudio.org/server/resolute/${ARCH}/rstudio-server-${RSTUDIO_DEB_VERSION}-${ARCH}.deb"
   echo "<sha256>  /tmp/rstudio-server.deb" | sha256sum -c -
   gdebi -n /tmp/rstudio-server.deb && rm -f /tmp/rstudio-server.deb
   ```
   The sha256 is self-computed after a manual download (no upstream checksum). Fallback S3 mirror only if the primary host fails, in a separate `||` branch.
5. Ship the license: `COPY` of `COPYING` from the source tarball or a `/usr/share/licenses/rstudio/COPYING` written from the fetched file (AGPL-3.0).
6. Move caches and state out of the image layout: `ENV HOME=/config TMPDIR=/tmp XDG_CACHE_HOME=/tmp/.cache`.
7. `RUN chown -R apps:apps /app && chmod -R 755 /app` only if an `/app` dir is created (not needed for the deb itself; RStudio installs under `/usr/lib/rstudio-server`).
8. Tail (same as siblings):
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 8787

   VOLUME /config
   ```
   Note: `USER apps` conflicts with rserver's PAM and root requirement. See section 9 for the required decision before this step is final.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "rstudio"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=rstudio/rstudio versioning=loose
  default = "2026.11.0+203"
}

variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/rstudio/rstudio"
}
```

Then the four standard targets (`image`, `image-local`, `image-all`) and the `default` group copied from `apps/adguardhome-sync/docker-bake.hcl`. `image` passes `args = { VERSION = "${VERSION}" }`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/rstudio/rstudio"
ports:
  - port: 8787
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Only env vars `start.sh` reads are listed. `RSTUDIO_VERSION` is a build arg, not a runtime env. `DEFAULT_USER` is not listed unless the chosen auth mode reads it (see section 9).

## 7. start.sh

Idempotent, seeds only missing files, exec at the end:

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/rstudio /config/home
# Seed config only when missing, never overwrite user state.
[ -f /config/rstudio/rserver.conf ] || touch /config/rstudio/rserver.conf

exec /usr/lib/rstudio-server/bin/rserver \
  --server-daemonize=0 \
  --www-address=0.0.0.0 \
  --www-port=8787 \
  --server-user="${DEFAULT_USER:-apps}" \
  --auth-none=1
```

Key decisions, all UNVERIFIED until tested: `--auth-none=1` (single-user, no PAM login; the flag exists in RStudio Server but was not confirmed on a fetched page) removes the need for system users per login. `rserver` still needs a launch user that matches the rsession owner (`--server-user`). Keep `--www-address=0.0.0.0` so other containers can reach 8787. Writes go to `/config` (rstudio config, workspace) and `/tmp` (caches). Nothing is written to `/app`, and no `/app` tree exists.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
tcp:
  - port: '8787'
http:
  - port: '8787'
    path: /
filePaths:
  - /usr/lib/rstudio-server/bin/rserver
  - /usr/bin/R
  - /usr/share/licenses/rstudio/COPYING
```

`timeoutSeconds: 180` is a judgement (RStudio start is slower than a typical Go daemon); confirm against a sibling of the same family. `tcp` and `http` run against the container itself, so they prove the listener and not cross-container access (checked separately in section 11).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/home/rstudio` (per-user rsession state, `.config/rstudio`, `workspace`) | `HOME=/config`; `rserver` and rsession state under `/config/home` |
| `/tmp` caches | `TMPDIR=/tmp` |
| `/etc/rstudio` (rserver config read from system path) | Read-only at runtime. Use `--config-file=/config/rstudio/rserver.conf` (flag from RStudio docs, UNVERIFIED on a fetched page). |
| `/var/run`, `/var/lib/rstudio-server` | Need `--tmpfs` or a `/config` mapping; test on `--read-only --tmpfs /tmp` and list each failing path in the logs. |

Reconciled expectations from draft.md: the chart runs as UID 0 with `readOnlyRootFilesystem: false`. This plan targets `USER apps` plus `--read-only`, but PAM and rsession's setuid behavior conflict with that. Realistic outcome: a non-root `--auth-none` single-user image is feasible. Full multi-user PAM logins (the chart's current model) are not feasible rootless. This is a product decision, not a build detail, so it is listed as a blocker in section 10.

## 10. Risks, caveats and open questions

- Blocker: multi-user PAM login needs root and system users, so the chart's multi-user behaviour cannot be replicated rootless. Plan targets single-user `--auth-none` only, and the user must accept that scope.
- Blocker: the rocker deb is fetched from posit.co at build time (the build needs that host reachable).
- No upstream checksum: sha256 is self-computed (see section 4).
- Resolute arm64 `.deb` not individually verified: UNVERIFIED.
- `r-base-core` on resolute: version and availability UNVERIFIED. If apt R is older than 4.6.2, the image no longer matches the chart's R version (a version mismatch to record, not hide).
- rocker builds R from source (`install_R_source.sh`). This plan does not reproduce that; it is a deliberate deviation.
- `--auth-none` and `--config-file` flags: UNVERIFIED against the installed deb.
- Per-user rsession writes under `/home` may still fail on `--read-only`; expected to need `/config` remaps.

## 11. Build and test steps

```sh
cd apps/rstudio
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name rstudio-probe --read-only --tmpfs /tmp \
  -p 8787:8787 -v rstudio-probe-config:/config rstudio:2026.11.0+203
docker logs -f rstudio-probe
curl -fsS http://localhost:8787/ >/dev/null && echo "reachable from host"
docker rm -f rstudio-probe; docker volume rm rstudio-probe-config
forgetool containers test --image rstudio:2026.11.0+203 --config ./apps/rstudio/container-test.yaml
```

Expected readiness signal: rserver log line about listening on port 8787 (exact text UNVERIFIED), the process stays up, and `curl` from the host returns the RStudio login page or the auth-none redirect. Repeat with the same `/config` volume to confirm restart safety.

## 12. PR checklist

- Branch `feat/add-rstudio`, commit `feat(rstudio): add new container`, target `main`, PR title matches the commit.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows status.
- Untested and to state honestly: arm64 build, `--auth-none` behaviour, read-only rootfs run, the sha256 value, and the apt R version.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`.
