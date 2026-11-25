# backrest — implementation plan
> Source: ./draft.md · Target: apps/backrest/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `1.14.1` (GitHub release `v1.14.1`, published 2026-07-12). Matches the draft's chart tag `ghcr.io/garethgeorge/backrest:v1.14.1`. Source: https://api.github.com/repos/garethgeorge/backrest/releases/latest (read with `gh api`). |
| Renovate | `datasource=github-releases depName=garethgeorge/backrest versioning=semver` (same pattern as `apps/adguardhome-sync`). |
| License | GPL-3.0 (GitHub SPDX `GPL-3.0`). Source: https://api.github.com/repos/garethgeorge/backrest |
| Source URL | https://github.com/garethgeorge/backrest |
| Per-arch download | amd64: https://github.com/garethgeorge/backrest/releases/download/v1.14.1/backrest_Linux_x86_64.tar.gz · arm64: https://github.com/garethgeorge/backrest/releases/download/v1.14.1/backrest_Linux_arm64.tar.gz |
| Checksum source | Published: https://github.com/garethgeorge/backrest/releases/download/v1.14.1/backrest_1.14.1_checksums.txt. sha256 for `backrest_Linux_x86_64.tar.gz` = `acc7835a9c55b3d254f0fa285cacbe87ac912cb7e069d0211924838020e6921c`; for `backrest_Linux_arm64.tar.gz` = `b53718cd6e042e7d99538cb652968ab966a5c53fabd556785648ceb13320a320`. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/garethgeorge/backrest/main/Dockerfile.alpine: `FROM alpine:latest`, single stage. Installs tini, ca-certificates, curl, bash, rclone, openssh, tzdata, docker-cli via apk; `rclone selfupdate --stable`; copies `backrest` to `/backrest` and `docker-entrypoint` to `/docker-entrypoint`; runs `/backrest --install-deps-only`, which puts restic at `/root/.local/share/backrest/restic`, then moves it to `/bin/restic`. `ENTRYPOINT ["/sbin/tini","--","/docker-entrypoint"]`, `CMD ["/backrest"]`. No `USER`, `EXPOSE`, `VOLUME` or `ENV`. |
| Restic | Not pinned in the upstream Dockerfile. Version and per-arch download URL: UNVERIFIED: restic is fetched by `backrest --install-deps-only` at image build time, and no fetched page names its version or URL. |
| Port | 9898 (web UI and API). Source: https://garethgeorge.github.io/backrest/introduction/getting-started ("typically" 9898, configurable). |
| Env vars | UNVERIFIED: the getting-started page names no env var or flag for the data or config directory (`BACKREST_DATA`, `BACKREST_CONFIG` from the draft are not confirmed). Restic credential env vars are set per repository in the UI, names not listed. |
| Config path | Linux default `~/.config/backrest/config.json`. Source: getting-started page. |
| First run | UI asks for an instance ID (cannot change later) and a username and password. Reset by deleting the `users` key in `config.json`. Authentication can be disabled for local installs. Source: getting-started page. |
| Docker example | None on the docs page. |
| arm64 | Release tarball exists for `Linux_arm64`. |

## 2. Target layout

- `apps/backrest/Dockerfile`
- `apps/backrest/docker-bake.hcl`
- `apps/backrest/settings.yaml`
- `apps/backrest/container-test.yaml`
- `apps/backrest/start.sh`

No `defaults/`, `etc/` or `health/` (nothing to seed; the app creates its config on first visit). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Fits because backrest is a Go release binary and runs directly on glibc Ubuntu. The upstream alpine image is musl, so it cannot be used with `COPY --from` (matches the draft's `copy-from: no`). Closest sibling: `apps/adguardhome-sync` (prebuilt tarball, `TARGETARCH`, `/app/<app>`, port 8080).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Map the architecture: `amd64` to `x86_64`, `arm64` to `arm64`, inside a shell `case`. Unknown arch fails the build.
3. Download the tarball to `/tmp`, fetch `backrest_${VERSION}_checksums.txt` from the same release, check with `grep "backrest_Linux_${ARCH}.tar.gz" checksums.txt | sha256sum -c -`. Fail the build on mismatch.
4. Extract into `/app/backrest/` (the draft says the layout follows `/app/containername`). Only the `backrest` binary is needed from the archive. If the archive also carries a `LICENSE`, copy it to `/usr/share/licenses/backrest/`. UNVERIFIED: whether the tarball contains a LICENSE file (check on first download).
5. Restic: needed at runtime. Option A (preferred if verifiable): download the restic release for the same arch from https://github.com/restic/restic/releases with its checksum file, and place it at `/app/backrest/restic`. UNVERIFIED: restic version, asset name and checksum source were not fetched. Option B: run `HOME=/tmp /app/backrest/backrest --install-deps-only` at build time, then copy the restic it places to `/app/backrest/restic`. Option B also needs a check that the restic it fetches is checksum-verified. Pick one after verification and record the restic version in the Dockerfile comment block and in `docker-bake.hcl` as a second renovate-annotated variable.
6. `chown -R apps:apps /app/backrest && chmod -R 755 /app/backrest`, `rm -rf /tmp/*` for the download.
7. Optional (see section 10): install `rclone` and `openssh-client` with apt only if rclone or SFTP repositories are in scope. Not included in the first version.
8. Final stage in the same file: `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 9898`, `VOLUME /config`.

```dockerfile
ARG VERSION
ARG TARGETARCH
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
ARG VERSION
ARG TARGETARCH
USER root
ENV HOME=/config XDG_CONFIG_HOME=/config/.config XDG_DATA_HOME=/config/.local/share
# download, sha256 check, extract to /app/backrest, restic placement (see steps 2-6)
USER apps
COPY --chmod=0755 . /
EXPOSE 9898
VOLUME /config
```

Write the Dockerfile following the exact pattern of `apps/adguardhome-sync/Dockerfile`, not the snippet above verbatim. The `XDG_*` variables are an assumption to verify (section 10).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "backrest"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=garethgeorge/backrest versioning=semver
  default = "1.14.1"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/garethgeorge/backrest"
}
```

- The `VERSION` default is without the `v` prefix; the Dockerfile builds `v${VERSION}` in the download URL and `backrest_${VERSION}_checksums.txt` in the checksum URL.
- `LICENSE`: the upstream GitHub SPDX is `GPL-3.0`. Use `GPL-3.0-only` only if the repo `LICENSE` text confirms it (UNVERIFIED: the "only" suffix); otherwise use `GPL-3.0-or-later`, matching the SPDX reading the repo reports.
- Add the four standard targets and the default group exactly as in `apps/adguardhome-sync/docker-bake.hcl`, with `image-all` platforms `linux/amd64` and `linux/arm64`.
- Validate with `docker buildx bake --print` from `apps/backrest/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/garethgeorge/backrest"
ports:
  - port: 9898
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

- No env vars beyond `TZ` are listed. The draft's `BACKREST_DATA` is not confirmed, so it is not listed (rule: do not invent env vars). Add any verified variable later.
- `dependencies: []`: backrest needs no ContainerForge app. Remote repositories are configured in the UI.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/.config/backrest /config/.local/share/backrest /tmp/restic-cache
cd /config

export HOME=/config
export XDG_CONFIG_HOME=/config/.config
export XDG_DATA_HOME=/config/.local/share
export RESTIC_CACHE_DIR=/tmp/restic-cache

exec /app/backrest/backrest
```

- Idempotent: creates directories only; nothing is seeded. The UI creates `config.json` on first visit.
- Writes only to `/config` (persistent) and `/tmp` (restic cache). Nothing is written to `/app`.
- The backrest listen address is UNVERIFIED. If it binds to `127.0.0.1` only, add the verified flag or env var to bind `0.0.0.0:9898` (section 10). Confirm with the probe in section 11.
- `RESTIC_CACHE_DIR` is a restic environment variable (not confirmed on a fetched page). Keep it, because restic's default cache is under `$HOME/.cache` which is `/config` here, and caches must stay in `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '9898'
http:
- port: '9898'
  path: /
filePaths:
- /app/backrest/backrest
- /app/backrest/restic
- /start.sh
```

- Timeout is an estimate; use the value the sibling Go app uses if one exists, otherwise 60. Mark as a choice.
- The http probe on `/` is UNVERIFIED for the status code. Confirm 200 on a running container before merging. Do not loosen it to any status.
- No required env var is needed to start (the UI sets the first user), so no `filePaths` for env-only code paths.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/root/.local/share/backrest/restic` (restic placement) | Build-time copy to `/app/backrest/restic`. Nothing written at runtime. |
| `~/.config/backrest/config.json` (`/root/.config`) | `HOME=/config`, `XDG_CONFIG_HOME=/config/.config` → `/config/.config/backrest/config.json`. Persistent. |
| restic cache (`$HOME/.cache/restic`) | `RESTIC_CACHE_DIR=/tmp/restic-cache` (ephemeral). |
| draft chart `/data` PVC (`BACKREST_DATA`) | Not used: the draft does not name the variable and no path is confirmed. Persistent state lives under `/config`. Existing chart users must move their `/data` content into `/config` (migration note). |
| draft chart `/cache` PVC | Mapped to `/tmp` (draft already says this). |
| `/bin/restic` (upstream) | `/app/backrest/restic`. Backrest must find restic there: UNVERIFIED how backrest discovers restic (PATH or its data dir). Set `PATH=/app/backrest:$PATH` in the Dockerfile `ENV` if PATH lookup applies. |

Security expectations (draft) reconciled: runs as `apps` (UID from the base, the chart default 568 matches), `readOnlyRootFilesystem` compatible with `--read-only --tmpfs /tmp`, not privileged. Upstream runs as root; this image does not.

## 10. Risks, caveats and open questions

- Restic version and checksum: UNVERIFIED. Choose option A or B from section 4 after confirming the restic release asset and its checksum file. Keep restic renovate-annotated.
- Listen address and config env vars: UNVERIFIED. Check backrest's source (`garethgeorge/backrest`, `cmd/` and `internal/config`) on the pinned tag before writing `start.sh`.
- `XDG_CONFIG_HOME` and `XDG_DATA_HOME` behavior: UNVERIFIED on a fetched page. Confirm that the config lands under `/config` on the first run.
- Backup source paths must be mounted into the container and readable by UID `apps` (draft caveat, inferred). Document in the app's settings description, not in a Dockerfile comment.
- rclone and openssh: the upstream image bundles them for remote repositories. Not included in the first version. If a user needs rclone or SFTP repositories, a follow-up change must add them with apt, pinned to the Ubuntu 26.04 version (UNVERIFIED package versions).
- docker-cli: upstream bundles it for Docker-based backups. Not included; no socket is mounted.
- Two release binaries (backrest and restic) must be upgraded together. Renovate covers backrest; restic needs its own annotation (section 5).
- No blockers: Go binary, glibc-compatible, amd64 and arm64 release tarballs exist, no privilege needed.

## 11. Build and test steps

```sh
cd apps/backrest
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker volume create backrest-probe-config
docker run --rm -d --name backrest-probe --read-only --tmpfs /tmp \
  -p 9898:9898 -v backrest-probe-config:/config backrest:1.14.1
docker logs -f backrest-probe        # wait for the server-listening line
curl -sSI http://127.0.0.1:9898/      # confirm the UI answers from the host

forgetool containers test --image backrest:1.14.1 --config ./apps/backrest/container-test.yaml

docker rm -f backrest-probe
docker volume rm backrest-probe-config
```

- Expected readiness signal: a backrest "listening" or "started" line in the log, UNVERIFIED wording. The pass criterion is the protocol's: process alive, a readiness line, no fatal error.
- Repeat with a restart on the same `/config` volume to confirm the first-run state survives.
- Run `docker buildx bake --set image-all.platform=linux/arm64 image-all` only if the arm64 build is in scope (the protocol says arm64 only for arm64-specific failures).

## 12. PR checklist

- Branch `feat/add-backrest`, commit `feat(backrest): add new container`, PR title the same, target `main`.
- PR body uses `.github/PULL_REQUEST_TEMPLATE.md`, keeps the sections, checks only what applies.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- Untested to state honestly in the PR: arm64 runtime, the restic version and checksum (until verified), the http probe status, and the listen address.
- Confirm `docker buildx bake --print` passes, bake `VERSION` equals the Dockerfile `ARG VERSION`, and no assertion was weakened.
