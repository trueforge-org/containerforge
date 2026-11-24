# phoronix-test-suite — implementation plan
> Source: ./draft.md · Target: apps/phoronix-test-suite/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 10.8.4 (latest GitHub release, tag `v10.8.4`, published 2022-07-03). Draft pins the same .deb. |
| Renovate | datasource=github-releases, depName=phoronix-test-suite/phoronix-test-suite, versioning=semver |
| License | GPL-3.0-or-later. UNVERIFIED: LICENSE file fetch returned 404 (path differs); confirm in the repo before PR. |
| Source URL | https://github.com/phoronix-test-suite/phoronix-test-suite |
| Download | Arch-independent PHP: `https://github.com/phoronix-test-suite/phoronix-test-suite/releases/download/v10.8.4/phoronix-test-suite-10.8.4.tar.gz` (same file for amd64 and arm64). A `_all.deb` also exists; use the tarball so nothing needs root-level install/sudo. |
| Checksum | None published on the release. UNVERIFIED: record the sha256 in the Dockerfile after downloading once, or accept no verification and say so in the PR. |
| Upstream Dockerfile | None. Only `deploy/docker/ubuntu-pts-docker-build.sh`, reviewed: ubuntu:20.04, packages unzip php-cli apt-utils mesa-utils php-xml git-core apt-file sudo; no ENTRYPOINT, `CMD ["/phoronix-test-suite/phoronix-test-suite","shell"]`; no VOLUME; sets `PTS_USER_PATH_OVERRIDE` and `PTS_DOWNLOAD_CACHE_OVERRIDE` (the only env vars confirmed). |
| Ports | None. CLI job runner. |

## 2. Target layout

- `apps/phoronix-test-suite/Dockerfile`
- `apps/phoronix-test-suite/docker-bake.hcl`
- `apps/phoronix-test-suite/settings.yaml`
- `apps/phoronix-test-suite/container-test.yaml`
- `apps/phoronix-test-suite/start.sh`
No `root/`, no `defaults/` (nothing to seed), no DOWNSTREAM_CHANGES.md (not used as a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. PHP CLI app, so plain ubuntu plus apt PHP. Closest sibling: `apps/adguardhome-sync` (download to /app) and `apps/bookstack` (PHP from apt, runner-only test).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH` (arch not needed for the download; kept for consistency).
2. `USER root` for installs only.
3. `apt-get install -y --no-install-recommends php-cli php-xml php-zip php-curl php-gd unzip build-essential cmake autoconf` (UNVERIFIED which PHP extensions PTS requires; php-cli and php-xml confirmed by upstream script, rest inferred). Not pinned: PHP is not the app version. Clean `/var/lib/apt/lists`.
4. `curl -fL -o /tmp/pts.tar.gz https://github.com/phoronix-test-suite/phoronix-test-suite/releases/download/v${VERSION}/phoronix-test-suite-${VERSION}.tar.gz`; verify sha256 if one is recorded; `tar xzf ... -C /app --strip-components=1`.
5. Licenses: `mkdir -p /usr/share/licenses/phoronix-test-suite && cp /app/COPYING /usr/share/licenses/phoronix-test-suite/` (UNVERIFIED file name in tarball; check).
6. `chown -R apps:apps /app && chmod -R 755 /app`.
7. `ENV HOME=/config PTS_USER_PATH_OVERRIDE=/config/pts PTS_DOWNLOAD_CACHE_OVERRIDE=/config/download-cache` (persistent test profiles/results, per the draft's /var/lib persistence). Compile scratch via `TMPDIR=/tmp`.
8. `USER apps`, then `COPY --chmod=0755 . /`, `VOLUME /config`. No EXPOSE (no ports).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "phoronix-test-suite" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=phoronix-test-suite/phoronix-test-suite versioning=semver
  default = "10.8.4"
}
variable "LICENSE" { default = "GPL-3.0-or-later" }
variable "SOURCE" { default = "https://github.com/phoronix-test-suite/phoronix-test-suite/" }
```
Plus `docker-metadata-action`, `image` (args.VERSION, OCI source/licenses labels), `image-local` (type=docker, tag `${APP}:${VERSION}`), `image-all` (linux/amd64, linux/arm64), `group "default"` = image-local. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Schema header + `schema_version: 1`, `upstream_env_url: "https://github.com/phoronix-test-suite/phoronix-test-suite/"`.
- ports: `[]` (none).
- env: `PTS_USER_PATH_OVERRIDE` default `/config/pts`; `PTS_DOWNLOAD_CACHE_OVERRIDE` default `/config/download-cache`; `TZ` default `Etc/UTC`; all required false.
- volumes: `/config` required true.
- dependencies: none.

## 7. start.sh

`#!/usr/bin/env bash`; `mkdir -p "$PTS_USER_PATH_OVERRIDE" "$PTS_DOWNLOAD_CACHE_OVERRIDE" /tmp/pts`; `export TMPDIR=/tmp`; seed nothing else (idempotent); no writes to /app. Final: `exec /app/phoronix-test-suite "${@:-shell}"` keeps upstream default of `shell`. Open question: without a TTY `shell` exits immediately; decide whether to keep alive with `exec sleep infinity` when no args (recommend: if no args and stdin is not a TTY, `exec sleep infinity` so the container can be `exec`ed into).

## 8. container-test.yaml

Schema header (container-test.schema.json). No ports, so no tcp/http probe is possible. Use `timeoutSeconds: 120`, `mainRunner: enabled: false`, and runners as in bookstack: `test -x /app/phoronix-test-suite`, `php --version`, `/app/phoronix-test-suite version`. Add `filePaths` for `/app/phoronix-test-suite` and `/usr/share/licenses/phoronix-test-suite`.

## 9. Rootless and read-only-rootfs adaptations

- Draft expects root and writable rootfs (readOnlyRootFilesystem false); we run `USER apps` with read-only rootfs.
- Write paths: PTS user dir (default `~/.phoronix-test-suite`, remapped via PTS_USER_PATH_OVERRIDE to /config/pts), download cache (/config/download-cache), test install/compile scratch (inside PTS user path; large, persists in /config; scratch under /tmp via TMPDIR).
- Draft extra persistence /var/lib/phoronix-test-suite and .../test-results map to /config/pts and /config/pts/test-results (single volume).
- Upstream `sudo`/apt-driven dependency installs by PTS (`--install-dependencies`) cannot work rootless: build deps are baked into the image.

## 10. Risks, caveats and open questions

- Last release is from 2022; upstream master moved on. Decide whether to track releases or tags (UNVERIFIED newer versions).
- Benchmarks download profiles and compile at runtime: needs internet, build tooling in image (large), and `/config` space; /tmp tmpfs size may be too small for compiles.
- Hardware/GPU tests need host devices passed in; results reflect host.
- Many test profiles assume root or install system packages; some will fail rootless.
- No checksum and no arm64-specific binary issues (pure PHP) but benchmark profiles may lack arm64 support.
- Not a long-running service: define the container command behaviour (see section 7).

## 11. Build and test steps

```sh
cd apps/phoronix-test-suite
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name phoronix-test-suite-probe --read-only --tmpfs /tmp \
  -v phoronix-test-suite-probe-config:/config phoronix-test-suite:10.8.4
docker logs -f phoronix-test-suite-probe
forgetool containers test --image phoronix-test-suite:10.8.4 --config ./apps/phoronix-test-suite/container-test.yaml
docker rm -f phoronix-test-suite-probe; docker volume rm phoronix-test-suite-probe-config
```
Expected: container stays running (keep-alive mode) and `/app/phoronix-test-suite version` prints 10.8.4; no readiness log line exists since there is no server.

## 12. PR checklist

- Branch `feat/add-phoronix-test-suite`; commit `feat(phoronix-test-suite): add new container`; PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Honest list of untested: build, read-only run, container test, arm64, any real benchmark run, license file name, checksum.
