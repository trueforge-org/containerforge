# fileshelter — implementation plan

> Source: ./draft.md · Target: apps/fileshelter/ · Difficulty: hard (C++ source build, Wt + Boost) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 6.4.0 (tag `v6.4.0`, published 2026-03-01, GitHub "Latest"; same as draft). Release notes: per-file download button, Boost build fixes, updated Docker image versions |
| Renovate | `datasource=github-releases depName=epoupon/fileshelter versioning=semver` (tags are `vX.Y.Z`; the Dockerfile adds the `v` prefix) |
| License | GPL-3.0 (GitHub API `GPL-3.0`; `COPYING` in repo root). `LICENSE` in bake: `GPL-3.0-only` (UNVERIFIED whether upstream headers say "only" or "or-later"; check `COPYING` and source headers before commit). The bundled Wt library is GPL-2.0 with OpenSSL exception (GitHub API reports NOASSERTION for emweb/wt, UNVERIFIED), so ship its license text too |
| Source URL | https://github.com/epoupon/fileshelter (tarball `https://github.com/epoupon/fileshelter/archive/refs/tags/v${VERSION}.tar.gz`) |
| Per-arch binaries | None. Compile on both arches (amd64, arm64) |
| Checksum source | None published for source tags. Pin by tag; no checksum available (UNVERIFIED: no `.sha256` release asset seen; release has "2 assets", names not retrievable) |
| Upstream Dockerfile reviewed | `Dockerfile-release` at commit bcdddfa (alpine 3.23, two-stage). Builds Wt 4.12.3 from source (`emweb/wt` tag `4.12.3`) with `-DCMAKE_CXX_STANDARD=20 -DSHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=OFF -DENABLE_LIBWTTEST=OFF -DCONNECTOR_FCGI=OFF` and std implementations for date/filesystem/any, then builds fileshelter with `-DCMAKE_BUILD_TYPE=Release -DCMAKE_UNITY_BUILD=ON -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=TRUE`, runs `make test` |
| Build deps (upstream) | boost-dev, bzip2, ca-certificates, cmake, coreutils, curl, g++, libarchive-dev, libconfig-dev, make, openssl-dev, pkgconfig, tar, zlib-dev |
| Runtime deps (upstream) | libssl3, libcrypto3, zlib, boost-program_options, boost-thread, libarchive, libconfig++ |
| Port | 5091 (EXPOSE in upstream, `listen = "0.0.0.0:5091"` in `conf/fileshelter.conf`). The draft guessed 8080; that is wrong |
| Config | Binary takes optional argv[1] config path, default `/etc/fileshelter.conf` (`src/fileshelter/main/main.cpp`). Sample at `conf/fileshelter.conf`, libconfig syntax |
| Data | `working-dir` (config key, default `/var/fileshelter`, must be writable). Wt config `wt_config.xml` and `user_messages.xml` are generated inside it; shares and sqlite DB live there |
| Env vars | The app reads none. All settings are config-file keys, so env vars in this image are an image-level feature that start.sh maps into the generated config (see section 7) |
| Wt latest | 4.15.0 (2026-10-28). Upstream pins 4.12.3; keep 4.12.3 (UNVERIFIED that fileshelter 6.4.0 compiles against newer Wt) |

## 2. Target layout

```
apps/fileshelter/
  Dockerfile          multi-stage: build Wt + fileshelter, copy into ubuntu runtime
  docker-bake.hcl     APP/VERSION/WT_VERSION/LICENSE/SOURCE
  settings.yaml
  container-test.yaml
  start.sh            seeds /config/fileshelter.conf, rewrites working-dir and listen, exec fileshelter
  defaults/fileshelter.conf   copy of upstream conf/fileshelter.conf with working-dir = "/config" and docroot/approot paths adjusted
```

`defaults/` is needed because `/config` starts empty and the config must be seeded. No `root/`. No `DOWNSTREAM_CHANGES.md` (nothing builds FROM this image).

## 3. Base image

Runtime stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Native glibc C++ app, no language runtime needed. Build stage uses the same ubuntu image plus `build-essential cmake` etc. Closest sibling: `apps/kasmvnc` (ubuntu build stage compiling C++ with cmake, then copying into the final image).

## 4. Dockerfile

1. Stage `build` (`FROM` the ubuntu line above, `USER root`), `ARG VERSION`, `ARG WT_VERSION`.
2. `apt-get install -y --no-install-recommends build-essential cmake pkg-config curl ca-certificates libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-system-dev libarchive-dev libconfig++-dev libssl-dev zlib1g-dev libsqlite3-dev` (package names are the Ubuntu equivalents of the upstream list; UNVERIFIED on 26.04, confirm with `apt-cache policy`). Boost needs >= 1.70.
3. Build Wt: download `https://github.com/emweb/wt/archive/${WT_VERSION}.tar.gz`, `cmake -DCMAKE_INSTALL_PREFIX=/opt/fileshelter -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=20 -DSHARED_LIBS=ON -DBUILD_EXAMPLES=OFF -DENABLE_LIBWTTEST=OFF -DCONNECTOR_FCGI=OFF -DWT_CPP17_FILESYSTEM_IMPLEMENTATION=std -DWT_CPP17_ANY_IMPLEMENTATION=std`, `make -j$(nproc) && make install`. Fileshelter needs Wt components Wt, Dbo, DboSqlite3 and HTTP, so keep the built-in HTTP connector and sqlite3 backend enabled (do not pass flags that disable them).
4. Build fileshelter: download `https://github.com/epoupon/fileshelter/archive/refs/tags/v${VERSION}.tar.gz`, `PKG_CONFIG_PATH=/opt/fileshelter/lib/pkgconfig cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/fileshelter -DCMAKE_PREFIX_PATH=/opt/fileshelter -DCMAKE_UNITY_BUILD=ON -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=TRUE`, `make -j$(nproc) install`. Unity build plus LTO is the RAM-heavy part; allow `-j$(nproc)` to be lowered with a build arg if CI runs out of memory. Skip `make test` or keep it as a non-fatal step.
5. Strip binaries and `.so` files; copy `COPYING` of fileshelter and Wt's `LICENSE`/`COPYING` into `/opt/fileshelter/licenses/`.
6. Final stage (ubuntu line), `ARG VERSION`, `ARG TARGETARCH`, `USER root`: install runtime packages only (`libboost-program-options1.xx`, `libboost-thread1.xx`, `libarchive13t64`, `libconfig++9v5`, `libssl3t64`, `zlib1g`, `libsqlite3-0`; real names via `apt-cache search`, UNVERIFIED). Base already has `ca-certificates`, `curl`.
7. `COPY --from=build /opt/fileshelter /usr/local` so `/app` stays free; share data goes to `/usr/local/share/fileshelter` (approot/docroot) and `/usr/local/share/Wt/resources`. Run `ldconfig` after copying libs. Move licenses to `/usr/share/licenses/fileshelter/`.
8. `ENV HOME=/config`. No other caches.
9. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 5091`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "fileshelter" }

variable "VERSION" {
  // renovate: datasource=github-releases depName=epoupon/fileshelter versioning=semver
  default = "6.4.0"
}

variable "WT_VERSION" {
  // renovate: datasource=github-releases depName=emweb/wt versioning=loose
  default = "4.12.3"
}

variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/epoupon/fileshelter" }
```

Plus group `default` -> `image-local`, targets `image` (args `VERSION`, `WT_VERSION`, OCI labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64 + arm64), as in `apps/adguardhome-sync/docker-bake.hcl`. Note: a renovate bump of Wt beyond 4.12.x should be a deliberate PR (add `allowedVersions` if needed). Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/epoupon/fileshelter"
ports:
  - port: 5091
    protocol: tcp
    required: false
env:
  - { name: TZ, default: "Etc/UTC", required: false }
  - { name: FILESHELTER_UPLOAD_PASSWORDS, default: "", required: false }   # comma separated, maps to upload-passwords
  - { name: FILESHELTER_MAX_SHARE_SIZE, default: "100", required: false }  # MB, maps to max-share-size
  - { name: FILESHELTER_BEHIND_REVERSE_PROXY, default: "false", required: false }
volumes:
  - path: /config
    required: true
```

Write it in the expanded block style used by siblings (not flow style). The `FILESHELTER_*` names are an image convention (the app reads none); keep the set small and only include those that start.sh really maps. Dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /config
[[ -s /config/fileshelter.conf ]] || cp /defaults/fileshelter.conf /config/fileshelter.conf
# working dir /config, listen 0.0.0.0:5091 are already set in the seeded file
# map optional env vars into the file with sed, only when set; escape special characters
exec /usr/local/bin/fileshelter /config/fileshelter.conf
```

Rules: seed only when missing; never write to `/usr/local` or `/app`; `working-dir = "/config"` (Wt writes `wt_config.xml`, sqlite DB and shares there); `listen = "0.0.0.0:5091"`; `tls-*` stays disabled; temp files go to `/tmp` (Wt uses `TMPDIR`; `export TMPDIR=/tmp`). Password env values must be escaped for libconfig strings (quote `"` and `\`) and must not be echoed. The `exec` keeps signals reaching the process. Binary install path (`/usr/local/bin/fileshelter`) must match the prefix used in the build.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '5091'
http:
- port: '5091'
  path: /
filePaths:
- /usr/local/bin/fileshelter
```

Check the schema for the exact `filePaths` shape against a sibling that uses it before committing; `http` form follows `apps/nzbhydra2/container-test.yaml`. Compiled apps start fast, so 60 s is a starting point (sibling `kasmvnc` uses the default; adjust after the first run). No env vars are needed to start, so no required-env paths are hidden.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/fileshelter` (working-dir, DB, shares, `wt_config.xml`) | `/config` via `working-dir` in the seeded config |
| `/etc/fileshelter.conf` | `/config/fileshelter.conf`, passed as argv[1] |
| Wt temp / upload spool | `TMPDIR=/tmp` (UNVERIFIED which dir Wt uses for upload spooling; confirm by uploading a large file under `--read-only`) |
| `/usr/share/...` resources | read-only install under `/usr/local/share`, no writes |

Draft expectations: chart runs as UID 0, `readOnlyRootFilesystem: false`, persistence `/var/fileshelter`. Here the image runs as `apps` (568) with a read-only rootfs, and all state goes to `/config` instead of `/var/fileshelter`. Document in the PR that existing `/var/fileshelter` data must be moved to the `/config` volume. No privileges or extra capabilities are needed.

## 10. Risks, caveats and open questions

- Heavy native build (Wt + LTO unity build): long CI time and high RAM; arm64 may run under emulation and be very slow. Draft says arm64 is unchecked; upstream's Docker image is built for multiple arches (UNVERIFIED), so it should compile.
- Wt 4.12.3 vs 4.15.0: stay on 4.12.3 until tested.
- Upstream is alpine/musl; glibc build is not covered by upstream CI, and Boost 1.8x on Ubuntu 26.04 may trip header changes (6.4.0 contains "build fixes for newer Boost").
- Wt `docroot`/`approot`/`wt-resources` paths in the seeded config must match the new prefix (`/usr/local/share/...`), otherwise the UI serves 404s.
- No checksum for the source tarball; supply-chain pin is the tag only.
- `LICENSE` string needs confirmation (GPL-3.0-only vs or-later) and should mention Wt if the image license must reflect bundled libraries.
- Draft port 8080 was an inference and is replaced by 5091.

## 11. Build and test steps

```sh
cd apps/fileshelter
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name fileshelter-probe --read-only --tmpfs /tmp \
  -v fileshelter-probe-config:/config fileshelter:6.4.0
docker logs -f fileshelter-probe
# also: curl -fsS http://127.0.0.1:5091/ from a second container on the same network
forgetool containers test --image fileshelter:6.4.0 --config ./apps/fileshelter/container-test.yaml
docker rm -f fileshelter-probe; docker volume rm fileshelter-probe-config
```

Readiness signal: Wt's HTTP server startup lines (UNVERIFIED exact text, expect something like "Wt: initializing built-in wthttpd" / "listening on 0.0.0.0:5091"), process still running, no `Config file ... not found` errors. Cap at 10 rounds. Also upload a file and open the share link to prove `/config` writes and read-only behavior.

## 12. PR checklist

- Branch `feat/add-fileshelter`; commit `feat(fileshelter): add new container`; PR title the same, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only boxes that apply.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` check shows status).
- Be honest about what is untested (until done): no image build, no arm64 build, no run on read-only rootfs, no forgetool run, Wt/Boost package names on Ubuntu 26.04 unverified, `LICENSE` value unconfirmed.
- Pre-completion list: minimal app-scoped change, bake `--print` ran, Dockerfile/bake version aligned (`VERSION`, `WT_VERSION`), rootless, empty `/config` works, no downstream `FROM` consumers.
