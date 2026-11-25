# mkvcleaver — implementation plan
> Source: ./draft.md · Target: apps/mkvcleaver/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | MKVCleaver `0802` (upstream Dockerfile ARG `MKVCLEAVER_VERSION`, jlesage image `v26.09.1`, latest tag). Sources: https://raw.githubusercontent.com/jlesage/docker-mkvcleaver/v26.09.1/Dockerfile and `gh api repos/jlesage/docker-mkvcleaver/releases/latest` (tag `v26.09.1`, published 2026-09-22). |
| Draft vs. fetched | Draft tag `v26.09.1` matches latest. Draft amd64 link `MKVCleaver_x64_v0802.exe` matches the upstream Dockerfile URL template. |
| Renovate | UNVERIFIED: no datasource tracks the MKVCleaver release, because the binary is hosted on blogs.sapib.ca (HTTP 403 to automated fetch). Candidate: `datasource=github-releases depName=jlesage/docker-mkvcleaver` as a tag tracker only. Decide before writing `docker-bake.hcl`. |
| License (repo) | MIT for `jlesage/docker-mkvcleaver` (GitHub license API). Source: https://github.com/jlesage/docker-mkvcleaver |
| License (application) | UNVERIFIED: MKVCleaver licence not on a fetched page (blogs.sapib.ca returned 403). Needed for `LICENSE` in `docker-bake.hcl`. |
| Source URL | https://blogs.sapib.ca/ (personal blog, per draft). Upstream repo for the wrapper: https://github.com/jlesage/docker-mkvcleaver |
| Per-arch download | amd64: `https://blogs.sapib.ca/apps/download/d47a70b2339c4809edd842ebc45d2efc/MKVCleaver_x64_v${MKVCLEAVER_VERSION}.exe` (template from upstream Dockerfile). arm64: none (no arm64 artifact exists; upstream builds only the x64 Windows exe). |
| Source zip | `https://blogs.sapib.ca/apps/download/source/MKVcleaver-x64-v${MKVCLEAVER_VERSION}-Portable-Source.zip` (upstream Dockerfile). Not needed at runtime. |
| Other downloads (upstream Dockerfile) | AutoIt `https://www.autoitscript.com/files/autoit3/autoit-v3.zip`; MKVToolNix Windows `https://mkvtoolnix.download/windows/releases/${MKVTOOLNIX_VERSION}/mkvtoolnix-64-bit-${MKVTOOLNIX_VERSION}.7z` (default 33.1.0); MediaInfo DLL `https://mediaarea.net/download/binary/libmediainfo0/${MEDIAINFO_VERSION}/MediaInfo_DLL_${MEDIAINFO_VERSION}_Windows_x64_WithoutInstaller.7z` (default 26.01); Winetricks `https://github.com/Winetricks/winetricks/archive/refs/tags/${WINETRICKS_VERSION}.tar.gz` (default 20260125). |
| Checksum source | None. The upstream Dockerfile verifies nothing (winetricks uses `curl -f`). UNVERIFIED whether `build.sh` verifies anything (not fetched). Plan: record SHA-256 of each downloaded file in the Dockerfile at build time and verify on every rebuild. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/jlesage/docker-mkvcleaver/v26.09.1/Dockerfile. Stages: `alpine:3.18` (winetricks), `alpine:3.18` (mkvcleaver build via `/build/build.sh`), final `jlesage/baseimage-gui:alpine-3.18-v4.14.0`. Final stage: `WORKDIR /tmp`, `add-pkg wine`, copies `rootfs/`, `/opt/mkvcleaver`, `/opt/autoit`, `/opt/mkvtoolnix`, `/defaults`. `VOLUME ["/storage"]`. No EXPOSE, no USER, no ENTRYPOINT in this file. |
| Upstream README reviewed | https://raw.githubusercontent.com/jlesage/docker-mkvcleaver/v26.09.1/README.md |
| Ports (real) | 5800/tcp (web GUI, noVNC-style web interface), 5900/tcp (VNC). README names neither noVNC nor the web stack. |
| Env vars (real, all optional) | `USER_ID=1000`, `GROUP_ID=1000`, `UMASK=0022`, `LANG=en_US.UTF-8`, `TZ=Etc/UTC`, `KEEP_APP_RUNNING=0`, `APP_NICENESS=0`, `CONTAINER_DEBUG=0`, `DISPLAY_WIDTH=1920`, `DISPLAY_HEIGHT=1080`, `DARK_MODE=0`, `WEB_AUDIO=0`, `WEB_HOST_CLIPBOARD_SYNC=1`, `WEB_FILE_MANAGER=0`, `WEB_FILE_MANAGER_ALLOWED_PATHS=AUTO`, `WEB_NOTIFICATION=0`, `WEB_TERMINAL=0`, `WEB_TERMINAL_SHELL_PATH=/bin/sh`, `WEB_AUTHENTICATION=0`, `WEB_AUTHENTICATION_ALLOW_INSECURE=0`, `WEB_AUTHENTICATION_TOKEN_VALIDITY_TIME=24`, `SECURE_CONNECTION=0`, `SECURE_CONNECTION_VNC_METHOD=SSL`, `SECURE_CONNECTION_CERTS_CHECK_INTERVAL=60`, `WEB_LOCALHOST_ONLY=0`, `VNC_LOCALHOST_ONLY=0`, `WEB_LISTENING_PORT=5800`, `VNC_LISTENING_PORT=5900`, `VNC_PASSWORD` (none), `ENABLE_CJK_FONT=0`, `INSTALL_PACKAGES` (none), `PACKAGES_MIRROR` (none). Source: README above. |
| Data / config write paths | `/config` (rw, state, logs, certs at `/config/certs/` if missing, `.vncpass_clear` obfuscated to `.vncpass`). `/storage` (rw, host media files). |
| Wine notes (README) | "MKVCleaver is a Windows application running under Wine." Window does not grow past `DISPLAY_WIDTH`/`DISPLAY_HEIGHT`. Label text is blue and hard to read in dark mode; the app hard-codes it. |
| arm64 availability | No arm64 build of MKVCleaver exists (Windows x64 exe only, per draft and upstream Dockerfile). Wine on arm64 is UNVERIFIED for this use. |
| Dependencies | None (no database, no sidecar). Draft: `Dependency containers: none`. |

## 2. Target layout

Files under `apps/mkvcleaver/`:

- `Dockerfile` (required)
- `docker-bake.hcl` (required)
- `settings.yaml` (required)
- `container-test.yaml` (required)
- `start.sh` (required: starts Xvfb, the VNC/web stack and MKVCleaver under Wine)
- `defaults/` only if a default `/config` file is needed (for example a Wine prefix template or a VNC password template). Reason: unknown until the Wine prefix behaviour is tested; start empty.
- `etc/` only if a fontconfig or Wine registry file must be shipped. Reason: none known yet.
- `scripts/` only if `start.sh` grows beyond one screen. Reason: keep it inline first.

Do not create `root/` (repo rule: reserved, agents must not touch it). Do not create `DOWNSTREAM_CHANGES.md` (this app is not a `FROM` base).

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the final stage (copy from `apps/xvfb/Dockerfile` and `apps/adguardhome-sync/Dockerfile`; the draft's "Foundation: ubuntu" matches the repo rule for generic userland).
- Why it fits: the app is a Windows exe run under Wine; no native Linux runtime is needed beyond Wine itself, so ubuntu alone is enough (draft: "Runtime image: none").
- Not the upstream `jlesage/baseimage-gui:alpine-3.18` base. It is Alpine (musl) and its s6 service layout is not available on `ghcr.io/trueforge-org/ubuntu`. UNVERIFIED whether the trueforge ubuntu base ships s6-overlay or `add-pkg`/`set-cont-env`; check with `docker run --rm <base> sh -c 'ls /etc/s6-overlay /usr/bin/add-pkg'` before using them.
- Closest siblings: `apps/xvfb` (Xvfb on the same base, no runtime), `apps/kasmvnc` (VNC/web desktop on the same base, ports 3000/3001 and an openbox autostart pattern). Do not copy kasmvnc's `root/` directory.

## 4. Dockerfile

1. Header: `ARG VERSION`, `ARG TARGETARCH`, `ARG MKVTOOLNIX_VERSION`, `ARG WINE_PACKAGE_VERSION` (pinned apt version, see below). No `# hadolint ignore` unless a rule fires.
2. `USER root`, then one `RUN` for installs:
   - `apt-get install -y --no-install-recommends wine xvfb x11vnc novnc websockify fonts-dejavu-core`. Package names are inferred (UNVERIFIED for `resolute`). Check `apt-cache policy` for each name in the build image first, then pin the Wine version like `apps/valkey` does (`PACKAGE_VERSION`).
   - `apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*`.
3. Download and verify the Windows artifacts in one `RUN` with `set -eu`:
   - MKVCleaver exe: `curl -fL -o /tmp/MKVCleaver.exe "https://blogs.sapib.ca/apps/download/d47a70b2339c4809edd842ebc45d2efc/MKVCleaver_x64_v${VERSION}.exe"` then `echo "<sha256>  /tmp/MKVCleaver.exe" | sha256sum -c -`. The SHA-256 is not published upstream; record the one observed from a trusted download in the Dockerfile comment block at build-time, and note it in section 10.
   - MKVToolNix 7z (`MKVTOOLNIX_VERSION`, default 33.1.0 from upstream): same pattern. Extract with `7z` (package `p7zip-full`, UNVERIFIED for resolute) into `/opt/mkvtoolnix`.
   - AutoIt zip: `https://www.autoitscript.com/files/autoit3/autoit-v3.zip`, extract to `/opt/autoit`.
   - MediaInfo DLL 7z (`MEDIAINFO_VERSION`, default 26.01): extract into `/opt/mkvtoolnix` next to the MKVToolNix exes (upstream copies all of `/opt/mkvtoolnix`).
   - Winetricks is only needed if the app needs a Windows runtime package. UNVERIFIED which winetricks verbs MKVCleaver needs; default: skip winetricks and add it only if a test shows a missing runtime.
4. Install the app: `mkdir -p /opt/mkvcleaver && mv /tmp/MKVCleaver.exe /opt/mkvcleaver/`. Ship the upstream licence files of the Windows archives into `/usr/share/licenses/mkvcleaver/` (dockerfile rule "Downloaded software"). Application licence is UNVERIFIED (see section 1).
5. Clean scratch: `rm -rf /tmp/*` in the same `RUN` that downloads.
6. `ENV` (only the values the app or wrapper reads; match `settings.yaml`):
   - `HOME=/config` (upstream-style; keeps Wine prefix under `/config`, see section 9).
   - `WINEPREFIX=/tmp/wine` (ephemeral prefix; see section 9 for the persistence decision).
   - `WINEDEBUG=-all` (silence Wine logs; reduces log noise for the protocol's log check).
   - `DISPLAY=:0`.
   - Do not put `ENV` for values that `start.sh` already defaults.
7. Copy stage: `COPY --chmod=0755 start.sh /start.sh`.
8. Final: `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 5800 5900`, `VOLUME /config`, `CMD ["/start.sh"]`. Ports match section 6.

Do not use `USER apps:apps`. `start.sh` must not write to `/app` (none is used here).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "mkvcleaver"
}

variable "VERSION" {
  // renovate: UNVERIFIED datasource/depName; see plan section 10 (no tracker for blogs.sapib.ca releases)
  default = "0802"
}

variable "MKVTOOLNIX_VERSION" { default = "33.1.0" }
variable "MEDIAINFO_VERSION" { default = "26.01" }

variable "LICENSE" {
  default = "UNVERIFIED"   // set after the MKVCleaver licence is confirmed; repo wrapper is MIT
}

variable "SOURCE" {
  default = "https://blogs.sapib.ca/"
}
```

- `VERSION` must match the Dockerfile `ARG VERSION` (`0802`). Default `VERSION` is the MKVCleaver version, not the jlesage tag `v26.09.1`.
- Keep the four standard targets (`image`, `image-local`, `image-all`) and the `default` group exactly as `apps/adguardhome-sync/docker-bake.hcl` does. Do not add `platforms` for arm64 to `image-all` until an arm64 build is proven; set `image-all` to `linux/amd64` only.
- Validate: `cd apps/mkvcleaver && docker buildx bake --print` (must exit 0).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://blogs.sapib.ca/"
ports:
  - port: 5800
    protocol: tcp
    required: false
  - port: 5900
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: LANG
    default: "en_US.UTF-8"
    required: false
  - name: DISPLAY_WIDTH
    default: "1920"
    required: false
  - name: DISPLAY_HEIGHT
    default: "1080"
    required: false
  - name: VNC_PASSWORD
    default: ""
    required: false
  - name: WEB_AUTHENTICATION
    default: "0"
    required: false
volumes:
  - path: /config
    required: true
  - path: /storage
    required: false
dependencies: []
```

- Only list env vars that `start.sh` or the stack reads. Start from the list above and drop any the app does not read (rule: do not invent env vars). Keep `DISPLAY_WIDTH/HEIGHT` and `VNC_PASSWORD` because the stack reads them.
- `/storage` is the host media mount (README). List it because the app reads files from it; it is not required to start.
- `dependencies: []` (no ContainerForge dependency).

## 7. start.sh

Shebang `#!/usr/bin/env bash`, `set -euo pipefail`. Steps:

1. Defaults: `DISPLAY_WIDTH="${DISPLAY_WIDTH:-1920}"`, `DISPLAY_HEIGHT="${DISPLAY_HEIGHT:-1080}"`, `VNC_PASSWORD="${VNC_PASSWORD:-}"`, `WEB_LISTENING_PORT="${WEB_LISTENING_PORT:-5800}"`, `VNC_LISTENING_PORT="${VNC_LISTENING_PORT:-5900}"`.
2. `mkdir -p /config /config/certs /tmp/wine` and seed nothing unless missing (rule: seed `/config` only when missing; do not overwrite user state).
3. If `VNC_PASSWORD` is set, write `/config/.vncpass` with `x11vnc -storepasswd` (writes to `/config`, not `/app`). Only run this path when set, and test it by hand (not covered by the empty-env test; see section 8).
4. Start Xvfb in the background: `Xvfb "$DISPLAY" -screen 0 "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x24" &`, wait until `$DISPLAY` answers (poll with `xdpyinfo` or a `/tmp/.X11-unix/X0` check, UNVERIFIED tool availability).
5. Start `x11vnc -display "$DISPLAY" -rfbport "$VNC_LISTENING_PORT" -forever -shared -listen 0.0.0.0` (add `-rfbauth /config/.vncpass` when the file exists). Start `websockify --web /usr/share/novnc "$WEB_LISTENING_PORT" localhost:"$VNC_LISTENING_PORT" &`. Bind 0.0.0.0 for the web port (repo rule: servers must listen on all interfaces).
6. Launch the app under Wine, last: `cd /opt/mkvcleaver && exec wine /opt/mkvcleaver/MKVCleaver.exe`. Because `exec` replaces the shell, the Xvfb/x11vnc/websockify jobs must be supervised; use a small loop with `wait -n` or start them under a supervisor. Decide in implementation; UNVERIFIED which approach keeps all processes alive.
7. Wine prefix: `WINEPREFIX=/tmp/wine` is recreated every start (slow first start, per draft). If persistence is needed, use `/config/wine` and seed it only when missing (section 9).
8. Never write to `/app` (none exists here) or to `/opt`.

Process model: the final long-running process must be the app or a supervisor that forwards signals. Do not leave the app as a background job with no supervisor.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '5800'
- port: '5900'
http:
- port: '5800'
  path: /
filePaths:
- /opt/mkvcleaver/MKVCleaver.exe
- /opt/mkvtoolnix
- /usr/share/licenses/mkvcleaver
- /start.sh
```

- Every port in `settings.yaml` has a tcp probe (5800, 5900). The http probe covers the web UI on 5800.
- `timeoutSeconds: 300` is a starting value: Wine prefix creation is slow on first start (draft caveat). Compare with sibling `apps/kasmvnc` before finalising; UNVERIFIED.
- The test runs with no env vars, so the `VNC_PASSWORD` path is not covered. Add its file (for example `/start.sh`) to `filePaths` and test the password path by hand per the build protocol.
- Do not add `runners:` checks that depend on Wine startup until a manual run proves the exact command.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap / decision |
| --- | --- |
| `/config` (config, logs, certs, `.vncpass`) | Keep at `/config` (persistent volume). |
| Wine prefix (default `~/.wine` under `HOME=/config`) | Default: `WINEPREFIX=/tmp/wine` (ephemeral, recreated each start; no persistent Windows settings). Option: `/config/wine` seeded only when missing. Decide with the maintainer; the draft does not say. |
| `/tmp` (Xvfb socket, Wine temp, `/tmp/.X11-unix`) | Keep at `/tmp` (the protocol runs with `--tmpfs /tmp`). |
| `/storage` (media files) | Mounted volume, not written by the wrapper. The app writes output media there when the user uses it. Ownership: host UID must match `USER_ID`/`GROUP_ID`; document this in the PR. |
| `/opt/mkvcleaver`, `/opt/mkvtoolnix`, `/opt/autoit` | Image content, read-only at runtime. Wine must not write here. UNVERIFIED that the app never writes next to its exe; check during the first run. |

Security expectations from the draft (TrueCharts values) are not ContainerForge rules; reconcile as follows:

- Draft: `runAsUser 0`, `readOnlyRootFilesystem false`, capabilities added (CHOWN, SETGID, SETUID, FOWNER, DAC_OVERRIDE, KILL, NET_BIND_SERVICE). ContainerForge target: `USER apps`, `--read-only --tmpfs /tmp` compatible, no added capabilities. Expect the Xvfb/Wine stack to need some of these; find out by running it, not by assuming. If Wine needs a capability, record it under section 10 as a blocker.
- Draft: privileged not set. Keep it not privileged.
- Ports 5800/5900 are above 1024 (no `NET_BIND_SERVICE` needed).

## 10. Risks, caveats and open questions

Blockers (must be resolved before PR):

- Application licence unknown (blogs.sapib.ca 403). `LICENSE` in `docker-bake.hcl` cannot be set honestly until confirmed.
- No checksum published for the MKVCleaver exe or the Windows archives. Record the SHA-256 from a trusted download and verify it on rebuild; document the trust decision in the PR.
- Upstream host is a personal blog. Availability is uncertain (draft caveat). Consider mirroring the exe only if its licence allows; do not mirror without a licence.
- Wine on `resolute` (26.04) is UNVERIFIED. Confirm the package name and version before writing the pin.
- The GUI stack (Xvfb, x11vnc, novnc, websockify) is not present in the trueforge ubuntu base and its package availability is UNVERIFIED. This is the largest unknown.
- No arm64 build (blocker for `image-all` multi-arch). `image-all` stays amd64-only until proven.
- Read-only rootfs and rootless Wine: UNVERIFIED that Wine runs as `apps` with `--read-only --tmpfs /tmp`. If it does not, record it as a blocker and stop (protocol round limit is 10).

Caveats (from the draft, `inferred`, to verify):

- First start is slow (Wine prefix creation, Xvfb start). Tune `timeoutSeconds`.
- The app is usable only through VNC/noVNC. There is no non-GUI mode.
- Long-term availability of the Windows archives (upstream status).

Open questions for the maintainer:

- Renovate datasource for `VERSION` (section 5).
- `/tmp` versus `/config/wine` for the Wine prefix (section 9).
- Whether the `VNC_PASSWORD` path is worth shipping in v1 (section 8).

## 11. Build and test steps

From `apps/mkvcleaver/` (one app at a time, per the build protocol):

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run with an empty `/config` and read-only rootfs:
   ```sh
   docker volume create mkvcleaver-probe-config
   docker run --rm -d --name mkvcleaver-probe --read-only --tmpfs /tmp \
     -v mkvcleaver-probe-config:/config mkvcleaver:0802
   docker logs -f mkvcleaver-probe   # tail until idle
   ```
   Expected readiness signal (UNVERIFIED until run): Xvfb and x11vnc started, `websockify` listening on 5800, and the MKVCleaver window or Wine start-up line. Failure signals: process exit, Wine crash loop, repeated stack traces.
4. Cleanup: `docker rm -f mkvcleaver-probe; docker volume rm mkvcleaver-probe-config`.
5. Test suite (CI mirror): `forgetool containers test --image mkvcleaver:0802 --config ./apps/mkvcleaver/container-test.yaml`. If forgetool is not available, check ports 5800 and 5900 and the file list by hand.
6. Password path (not covered by the suite): run once with `VNC_PASSWORD=...` and check `/config/.vncpass` exists.
7. arm64: do not build unless the amd64 build fails for an arm64-specific reason (protocol rule).

## 12. PR checklist

- Branch: `feat/add-mkvcleaver` from `main`.
- Commit: `feat(mkvcleaver): add new container` (Conventional Commits, app as scope).
- PR title matches the commit. Target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keeping sections and checkboxes. Only tick "Built container locally" if it was built.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows status). Only the user can sign it.
- State what was not tested: arm64, the VNC password path, the Wine prefix persistence choice, any real MKVCleaver job on a media file, and the licence and checksum decisions.
- Do not add `DOWNSTREAM_CHANGES.md` (not a `FROM` base).
- Pre-completion: `docker buildx bake --print` ran; `Dockerfile`, `docker-bake.hcl` and `settings.yaml` versions aligned; `USER apps` in the final stage.
