# mkvtoolnix — implementation plan
> Source: ./draft.md · Target: apps/mkvtoolnix/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Two candidates. (a) jlesage image tag `v26.10.1` (latest, `gh api repos/jlesage/docker-mkvtoolnix/releases/latest`, published 2026-10-25), whose Dockerfile builds MKVToolNix `103.0`. (b) Official MKVToolNix latest stable `v104.0` (https://mkvtoolnix.download/downloads.html, no release date shown). Plan: pin the version the official Ubuntu `resolute` package provides (UNVERIFIED which version that is; check with `apt-cache policy mkvtoolnix` in the build image) and set `VERSION` to that upstream version. |
| Draft vs. fetched | Draft tag `v26.10.1` matches latest jlesage tag. Draft says "Compiled from the mkvtoolnix.download source tarball". Confirmed in upstream Dockerfile (`https://mkvtoolnix.download/sources/mkvtoolnix-${MKVTOOLNIX_VERSION}.tar.xz`), but this plan replaces the compile with the apt route. |
| Renovate | Candidate: `datasource=github-releases depName=jlesage/docker-mkvtoolnix` is a tag tracker of the wrapper, not of MKVToolNix. Better candidate for the upstream version: `datasource=repology` (not used in repo; `apps/valkey` has it disabled for repology networking) or manual pin. Decide before writing `docker-bake.hcl`. UNVERIFIED which datasource the repo uses for apt-based versions. |
| License (repo) | MIT for `jlesage/docker-mkvtoolnix` (GitHub license API). Source: https://github.com/jlesage/docker-mkvtoolnix |
| License (application) | UNVERIFIED: MKVToolNix upstream licence not on a fetched page. Expected GPL-family (to confirm) before setting `LICENSE`. |
| Source URL | https://mkvtoolnix.download/ (website), https://mkvtoolnix.download/doc/ (docs). Upstream wrapper repo: https://github.com/jlesage/docker-mkvtoolnix |
| Official apt route (verified) | Source: https://mkvtoolnix.download/downloads.html. Key: `https://mkvtoolnix.download/gpg-pub-moritzbunkus.gpg`, install to `/etc/apt/keyrings/gpg-pub-moritzbunkus.gpg`. Repo for Ubuntu 26.04: `deb [arch=amd64 signed-by=/etc/apt/keyrings/gpg-pub-moritzbunkus.gpg] https://mkvtoolnix.download/ubuntu/ resolute main`. Packages: `mkvtoolnix` (CLI), `mkvtoolnix-gui` (GUI). Codename `resolute` = Ubuntu 26.04, which is the trueforge base. |
| Architectures (apt) | The downloads page says Ubuntu packages are for "amd64 & arm64". The page's example line uses `arch=amd64`; the arm64 line is UNVERIFIED and must be confirmed by `apt-cache policy` on an arm64 build. |
| Per-arch download | amd64 and arm64 via the apt repo (above). Fallback: AppImage `MKVToolNix_GUI-104.0-x86_64.AppImage` (amd64 only, glibc 2.28+, not used). |
| Checksum source | apt repo signing (GPG-signed pool, key above). The page does not publish a key fingerprint: UNVERIFIED. Plan: verify the fingerprint of the downloaded key by hand once and record it in the PR. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/jlesage/docker-mkvtoolnix/v26.10.1/Dockerfile. Stages: `tonistiigi/xx` (cross helpers), `alpine:3.20` (mkvtoolnix build), `alpine:3.20` (mediainfo build), final `jlesage/baseimage-gui:alpine-3.20-v4.14.0`. Final stage: `WORKDIR /tmp`, `add-pkg` for Boost filesystem, Qt6, flac, tinyxml2, mesa-gl; removes Qt Wayland plugins; empties `/etc/fstab`; installs icon; copies `rootfs/`. `VOLUME ["/storage"]`. No EXPOSE, no USER, no ENTRYPOINT in this file. |
| Upstream README reviewed | https://raw.githubusercontent.com/jlesage/docker-mkvtoolnix/v26.10.1/README.md |
| Ports (real) | 5800/tcp (web GUI), 5900/tcp (VNC). |
| Env vars (real, all optional) | Same set as `mkvcleaver`: `USER_ID=1000`, `GROUP_ID=1000`, `UMASK=0022`, `LANG=en_US.UTF-8`, `TZ=Etc/UTC`, `KEEP_APP_RUNNING=0`, `APP_NICENESS=0`, `CONTAINER_DEBUG=0`, `DISPLAY_WIDTH=1920`, `DISPLAY_HEIGHT=1080`, `DARK_MODE=0`, `WEB_AUDIO=0`, `WEB_HOST_CLIPBOARD_SYNC=1`, `WEB_FILE_MANAGER=0`, `WEB_FILE_MANAGER_ALLOWED_PATHS=AUTO`, `WEB_NOTIFICATION=0`, `WEB_TERMINAL=0`, `WEB_AUTHENTICATION=0`, `SECURE_CONNECTION=0`, `SECURE_CONNECTION_VNC_METHOD=SSL`, `WEB_LISTENING_PORT=5800`, `VNC_LISTENING_PORT=5900`, `VNC_PASSWORD` (none), `ENABLE_CJK_FONT=0`, `INSTALL_PACKAGES` (none). Source: README above. |
| Data / config write paths | `/config` (rw, config, logs, self-signed certs at `/config/certs/` if missing, `.vncpass`). `/storage` (rw, media files). |
| First-start behaviour (README) | Self-signed certs generated if missing (CN/SAN = hostname). `.vncpass_clear` obfuscated into `.vncpass`. `INSTALL_PACKAGES` installed at startup. No env var required to start. |
| Dependencies | None. Draft: `Dependency containers: none`. |

## 2. Target layout

Files under `apps/mkvtoolnix/`:

- `Dockerfile` (required)
- `docker-bake.hcl` (required)
- `settings.yaml` (required)
- `container-test.yaml` (required)
- `start.sh` (required: starts Xvfb, the VNC/web stack and the GUI)
- `defaults/` only if a default config is needed. Reason: none known; start empty.
- `etc/` only if a fontconfig or desktop file must be shipped. Reason: none known.
- `scripts/` only if `start.sh` grows beyond one screen.

Do not create `root/`. Do not create `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (same as `apps/xvfb`, `apps/valkey`, `apps/cni-plugins`; generic Debian/Ubuntu userland per repo base table).
- Why it fits: the official MKVToolNix apt repo has a `resolute` (26.04) component, so the packages match the base's release. No compile is needed, which removes the draft's long build.
- Not the upstream `jlesage/baseimage-gui:alpine-3.20` base (Alpine/musl; s6 layout not available on the trueforge base; UNVERIFIED whether the trueforge ubuntu base ships `add-pkg`/`set-cont-env`, check before use).
- Closest siblings: `apps/xvfb` (Xvfb on the same base), `apps/kasmvnc` (VNC/web on the same base; do not copy its `root/` dir).

## 4. Dockerfile

1. Header: `ARG VERSION`, `ARG TARGETARCH`, `ARG MKVTOOLNIX_PACKAGE_VERSION` (pinned apt version, see section 1).
2. `USER root`.
3. Add the MKVToolNix apt repo in one `RUN`:
   - `apt-get update && apt-get install -y --no-install-recommends ca-certificates wget gnupg`.
   - `mkdir -p /etc/apt/keyrings`, then `wget -O /etc/apt/keyrings/gpg-pub-moritzbunkus.gpg https://mkvtoolnix.download/gpg-pub-moritzbunkus.gpg`.
   - `echo "deb [arch=${TARGETARCH} signed-by=/etc/apt/keyrings/gpg-pub-moritzbunkus.gpg] https://mkvtoolnix.download/ubuntu/ resolute main" > /etc/apt/sources.list.d/mkvtoolnix.download.list` (map `TARGETARCH` amd64/arm64 to the same apt names; arm64 line UNVERIFIED).
   - Check the key fingerprint by hand once and record it in the PR.
4. Install pinned packages: `apt-get install -y --no-install-recommends "mkvtoolnix=${MKVTOOLNIX_PACKAGE_VERSION}" "mkvtoolnix-gui=${MKVTOOLNIX_PACKAGE_VERSION}"` plus `xvfb x11vnc novnc websockify` (package names inferred; UNVERIFIED for `resolute`; `apps/xvfb` already installs `xvfb`). Pin the version like `apps/valkey` does, and check it against `VERSION` with `test "${PKG%%-*}" = "${VERSION}"` (repo rule: version alignment).
5. `apt-get purge` build helpers (`wget`, `gnupg` if not needed), `apt-get clean`, `rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*`. Do not leave the repo list in `/etc/apt/sources.list.d` (remove it after install so the image does not drift).
6. Licence files of the packages into `/usr/share/licenses/mkvtoolnix/` (dockerfile rule "Downloaded software" applies to any file copied out of an archive; the apt package already installs its licence under `/usr/share/doc/`, so copy from there only if missing).
7. `ENV`: `HOME=/config`, `DISPLAY=:0`. Do not set `ENV` for values `start.sh` already defaults.
8. `COPY --chmod=0755 start.sh /start.sh`.
9. Final: `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 5800 5900`, `VOLUME /config`, `CMD ["/start.sh"]`.

No compile stage. Do not add a Go or Python stage.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "mkvtoolnix"
}

variable "VERSION" {
  // NOTE: VERSION is the MKVToolNix version the apt package provides, not the jlesage tag.
  // renovate: UNVERIFIED datasource/depName (no repology/apt tracker confirmed for this repo; see plan section 10)
  default = "UNVERIFIED"   // set to the upstream version the `resolute` package provides, verified at build time (not 104.0 or 103.0 by guess)
}

variable "PACKAGE_VERSION" {
  default = "UNVERIFIED"   // full apt version string, for example <ver>-1build1; set after apt-cache policy
}

variable "LICENSE" {
  default = "UNVERIFIED"   // application licence to confirm; repo wrapper is MIT
}

variable "SOURCE" {
  default = "https://mkvtoolnix.download/"
}
```

- `VERSION` and `ARG VERSION` must match. `PACKAGE_VERSION` and `ARG MKVTOOLNIX_PACKAGE_VERSION` must match.
- Keep the four standard targets (`image`, `image-local`, `image-all`) and the `default` group as in `apps/adguardhome-sync`. `image-all` may list `linux/amd64` and `linux/arm64` only after the arm64 apt line is proven.
- Validate with `cd apps/mkvtoolnix && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://mkvtoolnix.download/"
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
  - name: DISPLAY_WIDTH
    default: "1920"
    required: false
  - name: DISPLAY_HEIGHT
    default: "1080"
    required: false
  - name: VNC_PASSWORD
    default: ""
    required: false
volumes:
  - path: /config
    required: true
  - path: /storage
    required: false
dependencies: []
```

- Only list env vars that `start.sh` or the stack reads. Remove any that the chosen stack does not use (`LANG` was removed: the planned `start.sh` does not read it).
- `/storage` is listed because the app reads and writes media there (README), not because it is needed to start.

## 7. start.sh

Shebang `#!/usr/bin/env bash`, `set -euo pipefail`.

1. Defaults: `DISPLAY_WIDTH`, `DISPLAY_HEIGHT`, `VNC_PASSWORD` (empty), `WEB_LISTENING_PORT=5800`, `VNC_LISTENING_PORT=5900`.
2. `mkdir -p /config /config/certs /tmp/.X11-unix`. Seed nothing into `/config` unless missing; do not overwrite user state.
3. If `VNC_PASSWORD` is set, create `/config/.vncpass` with `x11vnc -storepasswd` (writes to `/config`, not `/app`).
4. Start Xvfb: `Xvfb "$DISPLAY" -screen 0 "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x24" &`, then wait until the display answers.
5. Start `x11vnc -display "$DISPLAY" -rfbport "$VNC_LISTENING_PORT" -forever -shared -listen 0.0.0.0` (add `-rfbauth /config/.vncpass` when the file exists) and `websockify --web /usr/share/novnc "$WEB_LISTENING_PORT" localhost:"$VNC_LISTENING_PORT" &`. Bind 0.0.0.0 for the web and VNC ports (repo rule: listen on all interfaces).
6. Run `exec mkvtoolnix-gui` as the last step. Supervise the background Xvfb/x11vnc/websockify jobs (a `wait -n` loop or a small supervisor). The exact mechanism is UNVERIFIED and decided at implementation time; all long-running processes must stay alive and signals must reach them.
7. Never write to `/app` (none is used). No writes outside `/config` and `/tmp`.

Optional: `mkvtoolnix` (CLI tools) is also installed. Keep the CLI in the image; the GUI is the default role per the draft.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '5800'
- port: '5900'
http:
- port: '5800'
  path: /
filePaths:
- /usr/bin/mkvmerge
- /usr/bin/mkvinfo
- /usr/bin/mkvtoolnix-gui
- /start.sh
```

- Every port in `settings.yaml` has a tcp probe. The http probe covers the web UI.
- `filePaths` must be checked against the installed package layout after the first build (UNVERIFIED exact paths; `mkvmerge`/`mkvinfo` in `/usr/bin` is typical for the apt package).
- `timeoutSeconds` is a starting value. Compare with `apps/kasmvnc` and tune after a run.
- The test runs with no env vars, so the `VNC_PASSWORD` path is not covered. Test it by hand per the protocol.
- `runners:` check for `mkvmerge --version` is possible and gives a real CLI assertion. Add it only after the command output is confirmed on the built image (UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap / decision |
| --- | --- |
| `/config` (config, logs, certs, `.vncpass`) | Keep at `/config` (persistent). |
| `HOME` | `/config`. Caches (`XDG_CACHE_HOME`, Qt cache) go to `/tmp` (protocol rule). Set `XDG_CACHE_HOME=/tmp/cache` in `ENV` if the GUI writes there. UNVERIFIED which Qt path is used. |
| `/tmp` (Xvfb socket, scratch) | Keep at `/tmp` (protocol runs with `--tmpfs /tmp`). |
| `/storage` (media) | Mounted volume. Ownership follows `USER_ID`/`GROUP_ID` on the host; document in the PR. |
| `/etc/fstab` | Upstream empties it to hide devices. Under `--read-only` `/etc` is not writable, so do the edit at build time (as upstream does) rather than in `start.sh`. |
| Qt Wayland plugins | Upstream removes them. Not required here unless the package pulls them in; check the image size. |

Security expectations from the draft (TrueCharts values): `runAsUser 0`, `readOnlyRootFilesystem false`, capabilities added (NET_BIND_SERVICE, KILL). ContainerForge target is `USER apps`, read-only rootfs with `/tmp` and `/config` writable, no added capabilities. Ports 5800/5900 are above 1024, so NET_BIND_SERVICE should not be needed. Check KILL need during the run; do not add it without proof.

## 10. Risks, caveats and open questions

Blockers (must be resolved before PR):

- Application licence not confirmed (MKVToolNix upstream).
- Version pin: the apt version for `resolute` is UNVERIFIED. The jlesage wrapper uses 103.0, official latest is 104.0. Pick one and state it in the PR.
- apt key fingerprint not published on the page: verify by hand and record.
- arm64 apt line UNVERIFIED. Confirm before `image-all` lists arm64.
- The GUI stack (Xvfb, x11vnc, novnc, websockify) package availability on `resolute` is UNVERIFIED.
- Read-only rootfs with the Qt6 GUI: UNVERIFIED. Protocol round limit is 10; stop and record if it fails.

Caveats (draft, `inferred`):

- Source compile is avoided by the apt route. The draft's "source compile" plan is not used.
- Files written under `/storage` are owned by the container user (`USER_ID`); host permissions must be planned.
- GUI only through VNC/noVNC.

Open questions for the maintainer:

- Ship the GUI at all, or only the CLI tools? The draft says role `main` with ports 5800/5900; the CLI-only option removes the whole VNC stack and changes ports, `settings.yaml`, and `container-test.yaml`.
- Renovate datasource for `VERSION` (section 5).

## 11. Build and test steps

From `apps/mkvtoolnix/` (one app at a time, per the build protocol):

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run with empty `/config` and read-only rootfs:
   ```sh
   docker volume create mkvtoolnix-probe-config
   docker run --rm -d --name mkvtoolnix-probe --read-only --tmpfs /tmp \
     -v mkvtoolnix-probe-config:/config mkvtoolnix:<VERSION>
   docker logs -f mkvtoolnix-probe   # tail until idle
   ```
   Expected readiness signal (UNVERIFIED until run): Xvfb and VNC listening, websockify on 5800, GUI started. Failure: exit, crash loop, stack traces.
4. Cleanup: `docker rm -f mkvtoolnix-probe; docker volume rm mkvtoolnix-probe-config`.
5. Test suite: `forgetool containers test --image mkvtoolnix:<VERSION> --config ./apps/mkvtoolnix/container-test.yaml`. If forgetool is not available, check ports and files by hand.
6. CLI check: `docker run --rm mkvtoolnix:<VERSION> mkvmerge --version` (confirms the apt package; UNVERIFIED exact output).
7. arm64: only if the amd64 build fails for an arm64-specific reason, or once the arm64 apt line is proven.

## 12. PR checklist

- Branch: `feat/add-mkvtoolnix` from `main`.
- Commit: `feat(mkvtoolnix): add new container`.
- PR title matches the commit. Target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keeping sections and checkboxes. Tick "Built container locally" only if it was built.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows status). Only the user can sign it.
- State what was not tested: arm64, the VNC password path, the chosen version against the upstream latest, the apt key fingerprint check, and any real media job.
- Do not add `DOWNSTREAM_CHANGES.md` (not a `FROM` base).
- Pre-completion: bake-print ran; `VERSION`/`ARG VERSION` and `PACKAGE_VERSION` aligned; `USER apps` in the final stage.
