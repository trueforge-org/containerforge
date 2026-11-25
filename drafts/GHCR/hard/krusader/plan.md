# krusader — implementation plan
> Source: ./draft.md · Target: apps/krusader/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Chart image | `ghcr.io/ich777/krusader:latest` (draft; unpinned) |
| Upstream wrapper Dockerfile reviewed | `https://raw.githubusercontent.com/ich777/docker-krusader/master/Dockerfile`. `FROM ich777/novnc-baseimage:bookworm_amd64` (amd64 only). |
| Application binary | Debian/Ubuntu apt package `krusader` (wrapper: `apt install krusader` from Debian bookworm, `deb.debian.org`). No upstream release binary. |
| Application version | UNVERIFIED: the Debian package version was not fetched. Ubuntu 26.04 package version and availability UNVERIFIED (check packages.ubuntu.com before the Dockerfile is written). |
| Renovate | Apt-packaged, so no upstream release tag. Use the Ubuntu package version as `VERSION` with a `datasource=repology` or `datasource=deb` annotation (UNVERIFIED which datasource the repo supports for Ubuntu). |
| License | KDE Krusader source: no SPDX value returned by `gh api repos/KDE/krusader` (license field null). UNVERIFIED: Krusader is GPL-licensed upstream per its project page, not confirmed here. The `LICENSE` in bake must be confirmed before writing. |
| Source URL | https://github.com/KDE/krusader; docs https://docs.kde.org/?application=krusader; site https://krusader.org/ (draft; not fetched in this run) |
| Wrapper env (defaults) | `DATA_DIR=/krusader`, `CUSTOM_RES_W=1280`, `CUSTOM_RES_H=768`, `CUSTOM_DEPTH=16`, `NOVNC_PORT=8080`, `RFB_PORT=5900`, `TURBOVNC_PARAMS="-securitytypes none"`, `UMASK=000`, `UID=99`, `GID=100`, `DATA_PERM=770`, `USER="krusader"`, `USER_LOCALES="en_US.UTF-8 UTF-8"` (wrapper Dockerfile) |
| Wrapper EXPOSE / VOLUME / USER | `EXPOSE 8080`; no VOLUME; no USER (runs as root) (wrapper Dockerfile) |
| Wrapper ENTRYPOINT | `/opt/scripts/start.sh` (wrapper Dockerfile); the script is in the wrapper's `/scripts/` and is not fetched |
| Wrapper apt packages | krusader, breeze-icon-theme, kompare, krename, bzip2, lzma, xz-utils, lhasa, zip, unzip, arj, unace, rar, unrar, p7zip-full, rpm, konsole, gedit, dbus-x11, keditbookmarks, feh, fonts-takao, fonts-arphic-uming, fonts-noto-cjk (wrapper Dockerfile) |
| Checksum source | None. Apt packages are signed by the distro repo; the GPG/apt signing path is the trust root. |
| Per-arch | amd64: wrapper base is amd64 only. arm64: UNVERIFIED for both the Ubuntu krusader package and the GUI stack. |
| Ports | 8080/http (noVNC, `NOVNC_PORT`) and 5900/tcp (VNC, `RFB_PORT`), both confirmed as wrapper env defaults. |
| Data paths | `DATA_DIR=/krusader` (wrapper); chart also mounts `/mnt/user` (draft, chart-specific host path; UNVERIFIED whether the app needs it). |

## 2. Target layout

- `apps/krusader/Dockerfile`
- `apps/krusader/docker-bake.hcl`
- `apps/krusader/settings.yaml`
- `apps/krusader/container-test.yaml`
- `apps/krusader/start.sh` (replaces wrapper `/opt/scripts/start.sh`)
- `apps/krusader/etc/` only if a `supervisord`-style or Xvfb config is needed (reason: none yet; decide in section 9)

No `root/`. No `DOWNSTREAM_CHANGES.md`. The wrapper's `/scripts/`, `/conf/`, `/icons/` and locale tar are not copied: they belong to the ich777 base and are replaced by the plan below.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the final stage. The app is a desktop program, so the base is plain Ubuntu userland with apt. No java, python or node base fits.

Closest sibling: none that runs a desktop. `apps/ubuntu` is the base itself; for a GUI with a VNC front end, check siblings with `ls apps | grep -iE 'vnc|novnc|desktop'` before writing the Dockerfile (not run in this plan). The ich777 `novnc-baseimage` is not used: it is amd64 only, Debian bookworm, and not a ContainerForge base.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config DATA_DIR=/config/krusader`.
2. Install the app and the display stack with `--no-install-recommends`. Package names for the display stack are UNVERIFIED for Ubuntu 26.04:
   ```dockerfile
   RUN apt-get update && apt-get install -y --no-install-recommends \
       krusader=<pinned-version> \
       xvfb fluxbox x11vnc novnc websockify \
       dbus-x11 fonts-dejavu-core \
     && rm -rf /var/lib/apt/lists/*
   ```
   Pin `krusader` to the version checked against `VERSION` (section 5). Do not install the wrapper's extra archive tools (`rar`, `unrar`, `arj`, `unace`, `lhasa`) unless they are confirmed in the Ubuntu archive and wanted; `unrar` and `rar` are not redistributable in every archive and need a license check (UNVERIFIED).
3. Remove everything the desktop does not need to keep the image small (no `gedit`, no `konsole` unless the user asks for them).
4. Ship the Krusader license to `/usr/share/licenses/krusader/` once confirmed.
5. `chown -R root:root /usr/share/licenses` only; the app runs as `apps`.
6. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 8080
   VOLUME /config
   WORKDIR /config
   ```
   Port 5900 is used inside the container by VNC; expose it only if the design keeps the raw VNC port (section 9).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "krusader"
}

variable "VERSION" {
  // renovate: datasource=UNVERIFIED depName=UNVERIFIED (Ubuntu krusader package version; datasource to be confirmed)
  default = "UNVERIFIED"
}

variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/KDE/krusader"
}
```

`VERSION` and `LICENSE` must be filled with confirmed values before the file is final; the placeholders are not valid. The four standard targets and the default group are copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/KDE/krusader"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: CUSTOM_RES_W
    default: "1280"
    required: false
  - name: CUSTOM_RES_H
    default: "768"
    required: false
  - name: CUSTOM_DEPTH
    default: "16"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Port 8080 is the noVNC web UI, confirmed as a wrapper default. Port 5900 is listed only if the final design exposes it. The env names are the wrapper's; each is kept only if `start.sh` reads it. `UID`, `GID`, `UMASK`, `DATA_PERM`, `USER` are not listed: the ContainerForge image runs as `apps` and does not use them.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/krusader /config/.fluxbox

export HOME=/config
export DISPLAY=:99

Xvfb :99 -screen 0 "${CUSTOM_RES_W:-1280}x${CUSTOM_RES_H:-768}x${CUSTOM_DEPTH:-16}" &

fluxbox &

x11vnc -display :99 -forever -shared -nopw -rfbport 5900 &

cd /config/krusader
exec websockify --web=/usr/share/novnc 8080 localhost:5900
```

This is a sketch: `websockify` must be the last process (`exec`) for signal handling, which the sketch does by running the others in the background. The background processes need a supervisor or a wait loop; decide in section 9. Writes go to `/config` and `/tmp` only. The `x11vnc -nopw` line is UNVERIFIED for production use and is a security issue: a password or a bind to localhost must be decided before the PR (section 10). `ENV` for `DATA_PERM`, `UMASK` and `USER` are dropped, as in section 6.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /usr/bin/krusader
- /usr/share/novnc
```

Every port in `settings.yaml` has a probe: 8080 has `tcp` and `http`. The `http` path `/` on noVNC is expected to return 200 (UNVERIFIED, confirm on the running container). The test runs with no env vars, so the defaults in `start.sh` carry the run. Timeout 180 is a guess for Xvfb plus fluxbox startup; adjust from the real log.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/krusader` (wrapper `DATA_DIR`, containerpath, chart PVC) | `/config/krusader` |
| `/mnt/user` (chart datapath, host bind) | Not in ContainerForge; users mount host data at their own path. Open question for the user (see section 10). |
| Home directory session state (fluxbox, Xvfb, konsole) | `/config` (`HOME=/config`), with `/config/.fluxbox` created in `start.sh` |
| X sockets and runtime files | `/tmp/.X11-unix` on `--tmpfs /tmp` |

Design decision (blocker): the GUI stack has to run as the non-root `apps` user and keep running on `--read-only --tmpfs /tmp`. The draft's caveat that fluxbox and Xvfb write session state under home is covered by `HOME=/config`. Whether the wrapper's `/opt/scripts/start.sh` does anything else (for example chowning `/krusader`) is UNVERIFIED; the wrapper script was not fetched. If a supervisor is needed, add one under `etc/` and say why in the PR.

Reconciled draft expectations: chart runs as root and `readOnlyRootFilesystem: false`; ContainerForge does not need either. Not privileged. "No other security settings" in the chart stays true. Chart `/mnt/user` is a host-specific mount, not a ContainerForge volume.

## 10. Risks, caveats and open questions

- Desktop app on noVNC: a browser is needed to use it. The VNC front end must not be open without auth on a network: `-nopw` in section 7 is a placeholder. Decide: password via `VNC_PASSWORD` env (new variable, add to settings only if implemented) or bind to localhost behind noVNC.
- The Ubuntu 26.04 `krusader` package version, its availability, and its arm64 availability are UNVERIFIED.
- The display stack package names (`xvfb`, `fluxbox`, `x11vnc`, `novnc`, `websockify`) are inferred from the draft, not confirmed on packages.ubuntu.com.
- Multi-process startup under one `exec`: the sketch runs three background processes. A proper supervisor or a `wait` loop is needed for a clean PID 1 and for clean shutdown.
- `unrar`/`rar` licensing and redistribution in the Ubuntu archive: UNVERIFIED. Left out of the plan by default.
- Host-owned bind mounts keep host ownership (draft caveat): file permissions must be checked on a real mount.
- Hard difficulty: GUI stack, VNC, noVNC, and read-only rootfs. Not musl-only, not GPU, not privileged. arm64 UNVERIFIED.

## 11. Build and test steps

```sh
cd apps/krusader
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name krusader-probe --read-only --tmpfs /tmp \
  -p 8080:8080 -v krusader-probe-config:/config krusader:<VERSION>
docker logs -f krusader-probe
forgetool containers test --image krusader:<VERSION> --config ./apps/krusader/container-test.yaml
docker rm -f krusader-probe; docker volume rm krusader-probe-config
```

Replace `<VERSION>` with the value set in section 5. Expected readiness signal: UNVERIFIED (noVNC and Xvfb log lines not confirmed). Required: the process stays up, `curl -I http://localhost:8080/` returns 200 from the host, and the noVNC page loads in a browser. Run on an empty `/config` and again after a restart.

## 12. PR checklist

- Branch `feat/add-krusader`, commit and PR title `feat(krusader): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge); only the user can sign it. The `license/cla` check shows the status.
- Say in the PR what was not tested: arm64, the Ubuntu package version, the noVNC login, the browser session, the `/mnt/user` mount behavior, and the read-only rootfs run.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; `VERSION` and `LICENSE` are not placeholders.
