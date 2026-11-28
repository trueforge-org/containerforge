# yacreaderlibraryserver — implementation plan
> Source: ./draft.md · Target: apps/yacreaderlibraryserver/ · Difficulty: hard · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Upstream source tag | 10.5.1 (exists: https://github.com/YACReader/yacreader/releases/tag/10.5.1) | wrapper Dockerfile |
| Release date | UNVERIFIED for 10.5.1 (2026-10-09 was the date of 10.4.0) | gh api |
| renovate | `datasource=github-releases depName=YACReader/yacreader versioning=loose` (tag form is plain `10.5.1`, so `semver` may also work; confirm) | derived |
| License | GPL-3.0 (GitHub SPDX for the repo; exact file name at the tag still to confirm) | gh api |
| Source | https://github.com/YACReader/yacreader | draft |
| Binary | None published for Linux (draft; upstream publishes source tarball plus macOS/Windows). | draft |
| Wrapper Dockerfile | https://raw.githubusercontent.com/xthursdayx/yacreaderlibrary-server-docker/f1d5f1b9e32bc19d6ac06873e071ff67f332388a/Dockerfile. Base `ghcr.io/linuxserver/baseimage-ubuntu:resolute`. Build stage installs build-essential, cmake, ninja-build, qt6-base-dev, qt6-tools-dev, qt6-5compat-dev, qt6-l10n-tools, libpoppler-qt6-dev, libarchive-dev, libgl-dev, 7zip, git, curl, ca-certificates. Clones `--depth 1 --branch ${YACR_VERSION}`. Default `7zip` backend: fetches `7z2301-src.7z` from github.com/YACReader/yacreader-7z-deps, SHA-256 verified (`fc459c2314a032231c157fd3257906c070ceed11efd6ffa621c2dfebbbc31281`). CMake flags `-DBUILD_SERVER_STANDALONE=ON -DBUILD_TESTS=OFF -DPDF_BACKEND=poppler -DCMAKE_INSTALL_PREFIX=/app`. Runtime package list derived by `ldd` + `dpkg -S`. Runtime extras: kimageformat6-plugins, libqt6sql6-sqlite, qt6-image-formats-plugins, netcat-openbsd. ENV `HOME=/config`, `LC_ALL=en_US.UTF-8`, `PATH=/app/bin`. `EXPOSE 8080`, `VOLUME ["/config","/comics"]`. Healthcheck `GET /v2/version`. | wrapper Dockerfile |
| Commands | `YACReaderLibraryServer create-library <name> /comics`, `add-library`, `update-library /comics`; web UI at `:8080/webui/settings` | wrapper README https://raw.githubusercontent.com/xthursdayx/yacreaderlibrary-server-docker/f1d5f1b9e32bc19d6ac06873e071ff67f332388a/README.md |
| Port | 8080/tcp (README and Dockerfile). The draft's 62596 is not supported by upstream: replace with 8080. | README, Dockerfile |
| Data paths | `/config` (config, logs, `.yacreaderlibrary` library data), `/comics` (library, read-only expected) | README |
| Per-arch | Source build for both amd64 and arm64 (draft); wrapper arm64 support UNVERIFIED in the captured text. | draft |
| Dependencies | none (SQLite via Qt plugin) | wrapper Dockerfile |

## 2. Target layout

- `Dockerfile` (two stages: build from source on ubuntu, runtime on ubuntu), `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`.
- `defaults/`: none expected.
- `etc/`: only if a default server config is needed (decide after first run).
- Never use `root/` (the wrapper's s6 `root/` tree is not used; see section 4).
- `DOWNSTREAM_CHANGES.md`: not needed.

## 3. Base image

- Final and build stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`.
- Do NOT use `ghcr.io/linuxserver/baseimage-ubuntu` (the wrapper's base): it is outside the ContainerForge base-image rules and brings s6 and linuxserver's user model.
- Closest sibling for a compiled C++/Qt app: none confirmed; find one with `ls apps/ | grep -i qt` or a C++ app before writing. Otherwise use `apps/adguardhome-sync` for layout (prebuilt binary, `USER apps`, `COPY --chmod=0755 . /`).
- Reason: Ubuntu 26.04 (resolute) matches the upstream requirement (CMake >= 3.25, Qt >= 6.4). Confirm the trueforge ubuntu 26.04 image carries these packages or install them in the build stage.

## 4. Dockerfile

1. `ARG VERSION="10.5.1"` (match bake), `ARG DECOMPRESSION_BACKEND="libarchive"` (see section 10 for the backend choice), `ARG PDF_BACKEND="poppler"`.
2. Build stage on trueforge ubuntu: `USER root`, `apt-get install --no-install-recommends` for the build set listed in section 1 (pin the Qt6 and CMake versions to the resolute archive and record them; check against `VERSION`).
3. Source: `git clone --depth 1 --branch ${VERSION} https://github.com/YACReader/yacreader.git /src`.
4. Backend choice: use `libarchive` (apt package `libarchive-dev`, no external tarball, no SHA verification gap). The `7zip` backend pulls `7z2301-src.7z` from a third-party repo; use it only if RAR support is required, and in that case verify the SHA-256 in the Dockerfile as the wrapper does.
5. Build: `cmake -S /src -B /src/build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/app -DBUILD_SERVER_STANDALONE=ON -DBUILD_TESTS=OFF -DDECOMPRESSION_BACKEND=libarchive -DPDF_BACKEND=poppler && cmake --build /src/build --parallel && cmake --install /src/build`.
6. Runtime package list: keep the wrapper's `ldd`/`dpkg -S` step, writing `/runtime-packages.txt`, then in the runtime stage `apt-get install` those packages plus `kimageformat6-plugins`, `libqt6sql6-sqlite`, `qt6-image-formats-plugins` and `curl` (for healthcheck only if used; not needed if the health probe is TCP). Pin versions to the resolute archive and check against `VERSION`.
7. Runtime stage: `COPY --from=build /app /app`. Licence: copy upstream LICENSE/COPYING into `/usr/share/licenses/yacreaderlibraryserver/` (UNVERIFIED file name; find it in `/src` during the build).
8. `ENV HOME=/config LC_ALL=en_US.UTF-8 PATH=/app/bin:${PATH}`. Locale package: install `locales` and generate `en_US.UTF-8` in the build, or drop `LC_ALL` if the app works with `C.UTF-8` (verify).
9. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config /comics`.
10. No s6 services. Start via `start.sh` only.

## 5. docker-bake.hcl

- `APP = "yacreaderlibraryserver"`.
- `VERSION` with renovate annotation (`datasource=github-releases depName=YACReader/yacreader versioning=loose`), default `"10.5.1"`.
- `LICENSE = "GPL-3.0"` (GitHub SPDX; confirm against the LICENSE file at the tag).
- `SOURCE = "https://github.com/YACReader/yacreader"`.
- Standard targets and default group. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/YACReader/yacreader"`.
- `ports`: `- port: 8080, protocol: tcp, required: true`.
- `env`: `TZ` (default `"Etc/UTC"`, required false). Other env vars: none verified in the wrapper README beyond `HOME`/`LC_ALL`; do not invent.
- `volumes`: `- path: /config, required: true`; `- path: /comics, required: false` (library, read-only expected).
- `dependencies`: none.

## 7. start.sh

- Shebang `#!/usr/bin/env bash`.
- Create `/config` subdirs only if missing (`mkdir -p /config/...`), do not overwrite user data.
- Library data: the server takes ownership of `/config` and `.yacreaderlibrary` (wrapper README). Under `USER apps` the app can only write to `/config`; check that it does not try `chown` on `/comics`.
- Run: `cd /config && exec /app/bin/YACReaderLibraryServer` with the upstream server arguments (verify the flags for the standalone server with `--help` at build time; do not guess).
- Bind address: check the server listens on 0.0.0.0 (UNVERIFIED).

## 8. container-test.yaml

- Schema header from the sibling.
- `tcp: - port: '8080'`.
- `http`: `GET /v2/version` on 8080 (the upstream healthcheck endpoint; confirmed in the wrapper Dockerfile).
- `filePaths`: `/app/bin/YACReaderLibraryServer` existence and executable.
- `timeoutSeconds`: a generous value (Qt startup and library scan); pick from a sibling if one exists.
- No DB dependency, so the DB-dependent exception does not apply.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as the linuxserver `abc` user through s6; target is `USER apps`. The wrapper README uses `docker exec -u abc`; the port must use `apps` instead (document in the PR).
- Writes: `/config` (config, logs, library data). `/tmp` for scratch. `/app` is read-only.
- Read-only rootfs: Qt may write caches to `$HOME` (set to `/config`), which is persistent. Redirect Qt cache to `/tmp` via `XDG_CACHE_HOME=/tmp/cache` (verify with the run).
- Draft's security expectations (root, no read-only) are the chart's current values; target is non-root and read-only compatible.
- `/comics` must be readable by `apps`. Document in the PR that the library owner must make comics readable.

## 10. Risks, caveats and open questions

- Build cost: full Qt6 C++ build on both amd64 and arm64. Long build time; plan for it in CI.
- Backend: `libarchive` (chosen here) versus `7zip` (wrapper default, includes RAR5 support). Choosing `libarchive` may drop RAR5 support. Confirm the desired format support before finalising.
- Port: draft says 62596; upstream says 8080. Use 8080.
- Wrapper Dockerfile is third-party (`xthursdayx`); its maintenance is a risk. The plan does not depend on its base image; only its build steps and runtime package derivation are reused.
- Locale and Qt plugin names UNVERIFIED for the trueforge ubuntu base.
- No blocker beyond the build size and the license check.

## 11. Build and test steps

From `apps/yacreaderlibraryserver`:
1. `docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local` (expect a long build).
3. `docker run --rm -d --name yacreader-probe --read-only --tmpfs /tmp -v yacreader-probe-config:/config yacreaderlibraryserver:10.5.1`.
4. `docker logs -f yacreader-probe`. Expected readiness: the server's listening line on 8080 (exact text UNVERIFIED) or a 200 from `GET /v2/version`.
5. `docker rm -f yacreader-probe; docker volume rm yacreader-probe-config`.
6. `forgetool containers test --image yacreaderlibraryserver:10.5.1 --config ./container-test.yaml`.
7. Round limit 10.

## 12. PR checklist

- Branch `feat/add-yacreaderlibraryserver`; commit and title `feat(yacreaderlibraryserver): add new container`.
- Notes: `🤖 This PR is AI generated.`
- CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status). Tell the user.
- PR template at `.github/PULL_REQUEST_TEMPLATE.md`; check only applicable boxes.
- Say what was not tested: arm64 build (long), RAR support choice, locale, and the `/comics` permission model.
