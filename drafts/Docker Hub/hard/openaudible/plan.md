# openaudible — implementation plan
> Source: ./draft.md · Target: apps/openaudible/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `5.3` (https://openaudible.org/swt_version.json: `version` 5.3, `release_date` 2026-11-22; draft tag was `latest`). |
| Renovate | `datasource=github-releases depName=openaudible/openaudible versioning=loose extractVersion=^v(?<version>.+)$` (the deb redirects to `github.com/openaudible/openaudible/releases/download/v5.3/`; GitHub API was rate limited, so the release listing could not be read: UNVERIFIED that every site release is a GitHub release). |
| License | Closed-source "free to try" shareware with a one-time paid licence (openaudible.org/download). No SPDX id: use `LicenseRef-OpenAudible-Proprietary`. Redistribution of the vendor binary inside a public image is UNVERIFIED (README of the wrapper repo says only "free to try shareware"). |
| Source URL | https://openaudible.org/ (wrapper: https://github.com/openaudible/openaudible_docker) |
| Per-arch download | amd64: `https://github.com/openaudible/openaudible/releases/download/v5.3/OpenAudible_5.3_x86_64.deb` (reached via `https://openaudible.org/latest/linux_x86_64_deb`, which answers 302 to that URL). arm64: the manifest lists only `OpenAudible_5.3_aarch64.sh` (installer script, no .deb, sha256 `9b605a8f41a75b5a31b7852b22ff61a3764a6c3aecbad84cc28b30e0c9519248`); draft says arm64 unsupported, stay amd64-only (UNVERIFIED whether the aarch64 .sh would run under the kasmvnc base). |
| Checksum | `swt_version.json` publishes sha256: deb `f75b4eb391382a48b02be2ab6adc2ff40f23ed5bdf531383a92f283b1db569bf` (size 121,692,374), AppImage `0eb759d2e9457286917b16f107ebe332ef2e93c1a6537f282460df0dffd1d3e0`, sh `4c5742c87a254d0b9835f6c81176f03aef4049e0f0745fb9f7d8cb176b6cd971`. Use the deb value. |
| Upstream Dockerfile reviewed | https://github.com/openaudible/openaudible_docker/blob/master/Dockerfile : `FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm`; apt libgtk-3-bin, libwebkit2gtk-4.1-0, pulseaudio, alsa-utils, thunar, xterm; `ENV KASM_AUDIO_ENABLED=1 KASM_AUDIO_QUALITY=medium START_PULSEAUDIO=1 OA_PACKAGING=docker OA_BETA=true OA_KIOSK=true oa_internal_browser=true APP_DIR=/app/OpenAudible XDG_CURRENT_DESKTOP=XFCE`; `EXPOSE 3000`; no VOLUME; `ENTRYPOINT ["/app/entrypoint.sh"]`, `CMD ["/init"]`; `/defaults/autostart` -> `/app/start_openaudible.sh`; the download of OpenAudible happens in the `assets/*.sh` scripts at container start (content not retrieved: UNVERIFIED). |
| Ports / env / volumes | Port 3000 (KasmVNC web). README env: `PUID`, `PGID`, `OA_BETA` (downloads beta unless `false`), `OA_DIR` (host helper). Data in `/config/OpenAudible`. README run line needs `--security-opt seccomp=unconfined` for the latest version. 3001 (TLS) is provided by the ContainerForge `kasmvnc` base (apps/kasmvnc settings list 3000 and 3001). |

## 2. Target layout

```
apps/openaudible/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh                  # prepares /config/OpenAudible, then the kasmvnc entry is used by the base
  defaults/autostart        # overrides the base's /defaults/autostart to launch OpenAudible
```
`defaults/` is allow-listed by `include/.dockerignore`. No `root/` (reserved; the base's `root/` is only used by the kasmvnc app). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/kasmvnc:1.5.2@sha256:870414f75035f215e19dbb5583e163b5d8e603e41ca8fa0e4669323c45fbdc27`

(Digest read from the ghcr.io manifest index for tag `1.5.2` on 2026-11-24; `apps/kasmvnc/docker-bake.hcl` `VERSION` is `1.5.2`.) Why: the draft names the linuxserver kasmvnc wrapper; the repo already has `apps/kasmvnc` (openbox, KasmVNC on 3000/3001, `/config` home, `apps` user, `start.sh` that copies `/defaults/autostart` to `/config/.config/openbox/autostart` when missing). Closest sibling: `apps/rdesktop` (desktop app on a GUI base). Because this image uses `kasmvnc` as a `FROM`, record the dependence in the PR; the reverse (openaudible as a base) does not apply.

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`, `ARG TARGETARCH`, `ARG OPENAUDIBLE_SHA256=f75b4eb391382a48b02be2ab6adc2ff40f23ed5bdf531383a92f283b1db569bf`; `USER root`; `RUN test "${TARGETARCH}" = "amd64"` with a clear error for arm64.
2. Download and verify: `curl -fsSL -o /tmp/openaudible.deb "https://github.com/openaudible/openaudible/releases/download/v${VERSION}/OpenAudible_${VERSION}_x86_64.deb" && echo "${OPENAUDIBLE_SHA256}  /tmp/openaudible.deb" | sha256sum -c -`.
3. `apt-get update && apt-get install -y --no-install-recommends /tmp/openaudible.deb` (apt resolves the deb's dependencies; check what the kasmvnc base already has, upstream also adds `libgtk-3-bin libwebkit2gtk-4.1-0 pulseaudio alsa-utils thunar xterm ca-certificates`). Record the install path with `dpkg -L openaudible` (the upstream scripts use `/app/OpenAudible`; the deb likely installs to `/opt/OpenAudible`: UNVERIFIED) and assert `dpkg-query -W -f='${Version}' openaudible | grep -q "^${VERSION}"` (package name UNVERIFIED).
4. Licence: copy any EULA/licence file the package ships to `/usr/share/licenses/openaudible/`; if the deb has none, write a short `NOTICE` pointing to https://openaudible.org/ (UNVERIFIED which applies).
5. `rm -rf /tmp/* /var/lib/apt/lists/*`.
6. ENV: `OA_PACKAGING=docker`, `OA_KIOSK=true`, `oa_internal_browser=true`, `HOME=/config`, `XDG_CACHE_HOME=/tmp/.cache`, `KASM_AUDIO_ENABLED=1`, `START_PULSEAUDIO=1` (all from the upstream Dockerfile except `OA_BETA`; whether the app reads `OA_KIOSK`/`oa_internal_browser` is as upstream sets them, UNVERIFIED).
7. `USER apps`
8. `COPY --chmod=0755 . /`
9. `EXPOSE 3000 3001`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" {
  default = "openaudible"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=openaudible/openaudible versioning=loose extractVersion=^v(?<version>.+)$
  default = "5.3"
}

variable "LICENSE" {
  default = "LicenseRef-OpenAudible-Proprietary"
}

variable "SOURCE" {
  default = "https://openaudible.org/"
}
```
Plus `target "docker-metadata-action" {}`, `group "default" { targets = ["image-local"] }`, `image` (args `VERSION`), `image-local` (`output = ["type=docker"]`, `tags = ["${APP}:${VERSION}"]`), and `image-all` with `platforms = ["linux/amd64"]` only (amd64-only app; deviation from the standard two-platform list, justified in a comment). Validate: `docker buildx bake --print`. Keep `OPENAUDIBLE_SHA256` as the Dockerfile ARG default and bump it with `VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://openaudible.org/"
ports:
  - port: 3000
    protocol: tcp
    required: false
  - port: 3001
    protocol: tcp
    required: false
env:
  - name: CUSTOM_PORT
    default: "3000"
    required: false
  - name: CUSTOM_HTTPS_PORT
    default: "3001"
    required: false
  - name: CUSTOM_USER
    default: "apps"
    required: false
  - name: PASSWORD
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```
`CUSTOM_PORT`, `CUSTOM_HTTPS_PORT`, `CUSTOM_USER`, `PASSWORD` mirror `apps/kasmvnc/settings.yaml` (inherited behaviour of the base). `OA_BETA` is deliberately not listed: a pinned image cannot switch release channel. No dependency containers (draft: none).

## 7. start.sh

Hook point: the base (`apps/kasmvnc`, no s6; `/start.sh` runs nginx and kclient, `/kasminit` and openbox) runs `/defaults/autostart` from openbox (do not replace the base entrypoint). `defaults/autostart` content: the base's `autostart` plus a line that launches the vendor binary (path from step 3 of section 4), e.g. `exec <openaudible-binary> &`. Because the base copies `/defaults/autostart` to `/config/.config/openbox/autostart` only when missing, existing users keep their file (document: delete it after an image update if the launch line changes).

CONFLICT: `COPY --chmod=0755 . /` would overwrite the base's own `/start.sh` (apps/kasmvnc/start.sh, which seeds openbox config, starts nginx and `exec node index.js`). Do not ship a replacement `/start.sh` that drops that logic: either name this script differently and chain to the base `/start.sh` at the end, or copy the base's logic (UNVERIFIED which is intended). `start.sh` (the repo's required file; invoked by the base `kasminit`, UNVERIFIED how the base calls `/start.sh`: apps/kasmvnc's own `start.sh` is the model) performs, idempotently:
1. `mkdir -p /config/OpenAudible /tmp/.cache`.
2. First-run seeding: nothing else is copied; OpenAudible creates its own settings in `/config/OpenAudible`.
3. Log `OpenAudible ${VERSION} (amd64)`; exit with an error line on non-amd64.
4. Final: hand over to the base (`exec` the same init the kasmvnc image uses; copy the last lines of `apps/kasmvnc/start.sh`, UNVERIFIED which command), so signals reach the desktop session.

No writes to `/app`. Servers listen on all interfaces via the base's KasmVNC (`0.0.0.0:3000/3001`, UNVERIFIED, confirm with `ss -ltn`).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3000'
- port: '3001'
filePaths:
- /usr/share/licenses/openaudible
- /start.sh
- /defaults/autostart
```
Both settings.yaml ports (3000, 3001) have a `tcp` probe, as in `apps/kasmvnc/container-test.yaml`. Add a `filePaths` entry for the vendor binary once its path is known from `dpkg -L`. No env needed to start (the base runs without `PASSWORD`).

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | Remap |
|---|---|
| Runs under linuxserver s6 with `abc` user, PUID/PGID, `chown` at start | Base `apps` user (UID 568); no PUID/PGID handling |
| OpenAudible downloaded and installed at container start into `/app/OpenAudible` (writable) | Installed at build time from the pinned deb, read-only at runtime |
| Config `/config/OpenAudible` | unchanged, persistent (matches draft: "config is /config/OpenAudible, under /config") |
| Tmp/cache (`~/.cache`, browser profile) | `XDG_CACHE_HOME=/tmp/.cache`; embedded webkit profile location UNVERIFIED |
| `--security-opt seccomp=unconfined` in README | Not representable in the image; document it for runtime (the draft's `privileged: no` stays true, seccomp is a separate setting). If the app fails to start under the default profile (webkit sandbox), that is a runtime caveat |
| Draft: UID 0, readOnlyRootFilesystem false | UID 568 and read-only rootfs; KasmVNC and openbox writes already go to `/config`/`/tmp` in the base (UNVERIFIED for the xfce/webkit pieces) |

## 10. Risks, caveats and open questions

- amd64 only (vendor deb). The manifest also offers an aarch64 `.sh` installer, but ContainerForge ships `image-all` for both arches by default; this plan keeps amd64 only, so `image-all` is a deviation and CI matrix handling must be checked (UNVERIFIED how CI treats single-arch apps).
- Proprietary, closed-source: redistribution and the shareware licence terms are UNVERIFIED and may block publishing.
- Needs an Audible account signed in via the browser session; first-run setup in the UI.
- `seccomp=unconfined` required by the vendor README for the latest version (UNVERIFIED for 5.3 under the base's libs).
- The deb's install path and package name are not confirmed (UNVERIFIED); the base `kasmvnc` image is large.
- `OA_BETA=true` upstream default pulls a beta at runtime; this plan pins the stable release.
- UNVERIFIED count: 11 (renovate via GitHub releases, licence terms, aarch64 behaviour, upstream scripts content, install path/package name, env flags read by the app, base hook for `start.sh`, listen address, seccomp need, webkit cache path, CI single-arch handling).

## 11. Build and test steps

```sh
cd apps/openaudible
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create openaudible-probe-config
docker run --rm -d --name openaudible-probe --read-only --tmpfs /tmp -v openaudible-probe-config:/config openaudible:5.3
docker logs -f openaudible-probe
forgetool containers test --image openaudible:5.3 --config ./apps/openaudible/container-test.yaml
docker rm -f openaudible-probe; docker volume rm openaudible-probe-config
```
Readiness: KasmVNC web server up on 3000/3001 (open `http://localhost:3000` in a browser), the desktop shows the OpenAudible window, no crash loop; also repeat with `--security-opt seccomp=unconfined` if the default profile fails and record which one is required. Empty `/config` must start cleanly. Round limit 10; remove container and volume each round.

## 12. PR checklist

- Branch `feat/add-openaudible`; commit and PR title `feat(openaudible): add new container`; target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md` (keep sections, tick only applicable boxes); include source, version `5.3`, base `kasmvnc:1.5.2`, ports/volumes; `🤖 This PR is AI generated.` in Notes; mention amd64-only and the proprietary licence.
- CLA notice for the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested at plan time: build, run, GUI start, Audible sign-in, seccomp requirement, read-only rootfs behaviour of the GUI stack. Do not check "Built container locally" unless done.
