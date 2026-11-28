# obsidian — implementation plan
> Source: ./draft.md · Target: apps/obsidian/ · Difficulty: hard · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest stable Obsidian desktop | v1.15.1 (tag shown as latest; date 12 Nov, year from changelog link 2026-11-12) | https://github.com/obsidianmd/obsidian-releases/releases/latest |
| Asset names | UNVERIFIED: the release page says "Assets 11" but lists no names. The draft's `obsidian_1.15.1_amd64.deb` and `Obsidian-1.15.1-arm64.AppImage` are not confirmed. The GitHub API returned 403 | same page; api.github.com |
| Renovate (proposed) | `datasource=github-releases depName=obsidianmd/obsidian-releases versioning=semver` (tag `v1.15.1`; versioning inferred) | release page |
| License (SPDX) | UNVERIFIED: no license named on the release page or in the upstream image README. Obsidian is closed-source | release page |
| Checksums | UNVERIFIED: none checked | — |
| Upstream image | `ghcr.io/sytone/obsidian-remote:0.1.1` (third-party, not Obsidian). Dockerfile at commit ac1c8e6c956b252782a0a6acf2aa3172cd4105a3 | https://raw.githubusercontent.com/sytone/obsidian-remote/ac1c8e6c956b252782a0a6acf2aa3172cd4105a3/Dockerfile |
| Upstream base | `FROM ghcr.io/linuxserver/baseimage-rdesktop-web:focal` (Ubuntu 20.04, linuxserver s6 with a web desktop) | same |
| Upstream Obsidian version | `ARG OBSIDIAN_VERSION=0.15.9`. The image pins 0.15.9, not 1.15.1. The draft's version does not match the upstream image | same |
| Upstream download | `https://github.com/obsidianmd/obsidian-releases/releases/download/v$OBSIDIAN_VERSION/Obsidian-$OBSIDIAN_VERSION.AppImage`, no arch handling, no checksum. Extracted with `--appimage-extract` at build time, so no FUSE is needed at runtime | same |
| Upstream apt | `curl libnss3 dbus-x11 uuid-runtime` (`--no-install-recommends`) | same |
| Upstream env | `CUSTOM_PORT=8080`, `GUIAUTOSTART=true`, `HOME=/vaults`, `TITLE=Obsidian v$OBSIDIAN_VERSION` | same |
| Upstream EXPOSE | 8080, 27123, 27124 (purpose of 27123/27124 UNVERIFIED) | same |
| Upstream VOLUME | `/config`, `/vaults` | same |
| Upstream USER / ENTRYPOINT | not set in the Dockerfile (inherited from the linuxserver base, not fetched) | same |
| Upstream README env | `PUID=911`, `PGID=911`, `TZ=Etc/UTC`, `CUSTOM_USER=abc`, `PASSWORD=abc` (README says both "abc" and "no auth if unset"; conflict), `TITLE`, `FM_HOME=/config`, `SUBFOLDER`, `DOCKER_MODS`, `INSTALL_PACKAGES`, `KEYBOARD` (no default stated) | https://raw.githubusercontent.com/sytone/obsidian-remote/main/README.md |
| Upstream README ports | 8080 (HTTP), 8443 (HTTPS). 8443 is not in the Dockerfile EXPOSE | same |
| arm64 | UNVERIFIED for Obsidian (arm64 AppImage not confirmed). The upstream image has no arch handling and is amd64-only in effect | Dockerfile |
| Dependencies | none | draft |

Draft corrections: the draft's "Obsidian v1.15.1" arm64 AppImage is unconfirmed, and the upstream image runs 0.15.9 on amd64 only. The plan treats the version as a choice, not a copy of the draft.

## 2. Target layout

- `apps/obsidian/Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`.
- `etc/`: needed for the web-desktop supervision config if one is used (see section 4). Reason: the supervision files must be in the image, and `etc/` is on the allow-list.
- `defaults/`: optional. Used only if a first-run config seed is needed.
- `root/`: never used. The upstream `COPY root/ /` is not carried over.
- `DOWNSTREAM_CHANGES.md`: not applicable.

Sibling pattern: no direct sibling. The closest prebuilt-binary pattern is `apps/adguardhome-sync`. For any web GUI or VNC stack, check `apps/` for an existing desktop-style image before writing one from scratch. If none exists, record that in section 10.

## 3. Base image

- Default: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`.
- Not the linuxserver `baseimage-rdesktop-web`. Using it would bring in the s6 and PUID/PGID model, which conflicts with the ContainerForge rootless model.
- Go and Python: not applicable.

## 4. Dockerfile

Blocking decision first (see section 10): the GUI stack. If the GUI is approved, the steps are:
1. `ARG VERSION=1.15.1`, and `ARG TARGETARCH`. The version must equal the bake default.
2. `USER root` for installs: the Electron runtime needs `libnss3`, a display server (`xvfb` for headless rendering), and a web/VNC front end (for example noVNC plus a VNC server). The exact packages are UNVERIFIED and must be checked against the 26.04 archive at build time, then pinned.
3. Download the AppImage (amd64 only, unless arm64 is confirmed) from the v1.15.1 release. Verify with a checksum once one is found (UNVERIFIED, none exists yet). Do not run it with FUSE: extract at build time with `--appimage-extract` into `/app/obsidian/`, as the upstream image does.
4. Ship the license file to `/usr/share/licenses/obsidian/`, but only after the license is confirmed.
5. `ENV HOME=/tmp` for the runtime; vaults in `/vaults` (see section 6); config in `/config`. Electron caches go to `/tmp` (`XDG_CACHE_HOME=/tmp/cache`, `XDG_CONFIG_HOME` mapped to `/config` if config must persist).
6. `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `VOLUME /vaults`, final `USER apps`.

The `apps` user must be able to run the Electron binary and the display server. Check this in the run step.

## 5. docker-bake.hcl

- `APP = "obsidian"`.
- `VERSION` with `// renovate: datasource=github-releases depName=obsidianmd/obsidian-releases versioning=semver` and `default = "1.15.1"`.
- `LICENSE`: BLOCKED until the license is confirmed. Do not set a guessed SPDX id.
- `SOURCE = "https://github.com/obsidianmd/obsidian-releases"`.
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (platforms `linux/amd64` only, unless arm64 is confirmed), and `group "default"`.
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Header and `schema_version: 1`. `upstream_env_url: https://obsidian.md/` (or the obsidian-releases repo; pick one and match `SOURCE`).
- `ports`: 8080 (`protocol: tcp`, required; the web UI is covered by the http probe), and 8443 (tcp, only if HTTPS is implemented, otherwise omit, UNVERIFIED).
- `env`: `CUSTOM_PORT` (default 8080), `TITLE`, and any variable `start.sh` reads. Do not list `PUID`, `PGID`, `CUSTOM_USER`, `PASSWORD` unless the port of that behaviour is implemented. Do not invent `DOCKER_MODS` or `INSTALL_PACKAGES`, because they are linuxserver mechanics that this image does not have.
- `volumes`: `/config` (Obsidian settings) and `/vaults` (vaults). Both are listed because both are written.
- `dependencies`: none.

## 7. start.sh

- Idempotent. Creates `/vaults` and `/config` subdirectories only when missing. Never writes to `/app`.
- Starts the display server, the VNC or web front end, then Obsidian with `exec` as the final process, or uses a small supervisor. Choose one and document why. Plain `exec` plus background children is not PID-1-safe, so a tiny supervisor may be needed (UNVERIFIED need).
- Binds to `0.0.0.0` on the web port so other containers can reach it.
- Obsidian's `--no-sandbox` flag may be needed in a container. UNVERIFIED: check the Electron behaviour in the run step, and do not add the flag without a reason in the log.

## 8. container-test.yaml

- Forgetool schema header.
- `tcp` probe on 8080, `http` probe on `/`. Add a `tcp` probe on 8443 only if HTTPS is implemented.
- `timeoutSeconds` from the sibling that has a GUI or the largest startup, to be decided at build time.
- `filePaths`: `/app/obsidian/` (the extracted binary) and `/config` or `/vaults` directories, as needed.
- Because the GUI starts from a config path that a test without env vars never sets, add any such path to `filePaths`.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root (chart `runAsUser 0`). Target: `USER apps`. Electron and Xvfb must run as `apps`.
- `HOME` moves off `/vaults`. Upstream sets `HOME=/vaults`, which is persistent storage; ContainerForge caches must go to `/tmp`. Keep `/vaults` only for vault data.
- `--read-only --tmpfs /tmp`: Electron writes caches to `/tmp`, and the display socket goes to `/tmp/.X11-unix` (must be writable). Confirm.
- Draft security expectations: `privileged: no` (per the chart), `runAsUser 0` (chart). Target is non-root, read-only rootfs, no privileged mode. If a FUSE mount is required, that conflicts with rootless (see section 10).

## 10. Risks, caveats and open questions

- Blocker, license: Obsidian is closed-source and no license is named on the release page. Redistribution of the AppImage/deb inside an image must be checked. Until then, `LICENSE` and the image build cannot be finalised.
- Blocker, GUI: the app is an Electron desktop app. The upstream uses a full linuxserver desktop/VNC stack. A rootless, read-only ContainerForge build needs a display server and a web front end, which is large and untested. This is the main reason the difficulty is hard.
- Version mismatch: draft says 1.15.1; upstream image pins 0.15.9 on amd64. Choose the version deliberately.
- arm64: the Obsidian arm64 AppImage is UNVERIFIED, and the upstream image is amd64 only. Plan is amd64 first.
- FUSE: AppImage extraction at build time avoids FUSE at runtime. If extraction fails, a privileged or fuse-enabled container would be needed, which is not acceptable here.
- Ports 27123 and 27124 in the upstream EXPOSE are UNVERIFIED. Do not list them in settings.yaml until their use is confirmed.
- Third-party upstream: the image is by sytone, not Obsidian. The plan does not copy its Dockerfile wholesale.
- Authentication: the README says the default password is "abc" and also says there is no auth when unset. Behaviour is UNVERIFIED; the plan does not carry the password default. Decide auth before exposing a port.
- Vaults are created or opened in the UI (manual setup, per the draft).

## 11. Build and test steps

1. `cd apps/obsidian && docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run on an empty `/config` volume and a fresh `/vaults` volume, with `--read-only --tmpfs /tmp`:
   ```sh
   docker volume create obsidian-probe-config
   docker volume create obsidian-probe-vaults
   docker run --rm -d --name obsidian-probe --read-only --tmpfs /tmp \
     -v obsidian-probe-config:/config -v obsidian-probe-vaults:/vaults obsidian:1.15.1
   docker logs -f obsidian-probe
   ```
   Expected readiness signal: the web front end listening on 8080, and Obsidian's window or server process still running. Flag any Electron or display error.
4. `forgetool containers test --image obsidian:1.15.1 --config ./apps/obsidian/container-test.yaml`, or check the probes by hand if forgetool is not available.
5. Clean up: `docker rm -f obsidian-probe; docker volume rm obsidian-probe-config obsidian-probe-vaults`.

## 12. PR checklist

- Branch `feat/add-obsidian`, commit `feat(obsidian): add new container`, target `main`.
- Notes: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`; check only the boxes that apply.
- Say what was not tested: the GUI under rootless read-only, arm64, and the UNVERIFIED license and asset names.
- Do not check "Built container locally" unless the image was built and run.
