# virt-manager — implementation plan
> Source: ./draft.md · Target: apps/virt-manager/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 5.1.0 (latest upstream tag `v5.1.0`; Ubuntu 26.04 "resolute" ships `virt-manager 1:5.1.0-1ubuntu0.1` in `resolute-updates`, per Launchpad). The upstream chart image `mber5/virt-manager:latest` is unversioned |
| Renovate | `datasource=github-tags depName=virt-manager/virt-manager versioning=semver extractVersion=^v(?<version>.+)$` for `VERSION`; `PACKAGE_VERSION` is the apt version, bumped by hand like `apps/valkey` (its renovate repology line is disabled) |
| License | GPL-2.0-or-later (`virtManager/app.py` header: "licensed under the GNU GPLv2 or later"; COPYING is GPL v2) |
| Source URL | https://github.com/virt-manager/virt-manager |
| Install method | apt package `virt-manager` from the Ubuntu archive, both amd64 and arm64 (arm64 availability of the package: UNVERIFIED, Ubuntu normally builds it for all archs) |
| Per-arch download | Not applicable (apt) |
| Checksum source | apt repository signatures (GPG) |
| Upstream Dockerfile reviewed | `m-bers/docker-virt-manager` master: `FROM mber5/broadway-baseimage:latest`; env `FAVICON_URL`, `APP_TITLE`, `CORNER_IMAGE_URL`, `HOSTS="[]"`; apt `virt-manager dbus-x11 libglib2.0-bin gir1.2-spiceclientgtk-3.0 ssh at-spi2-core`; ssh config `StrictHostKeyChecking no` for root; `startapp.sh` runs the base `/usr/local/bin/start` (broadwayd + nginx + ttyd), then `gsettings set org.virt-manager.virt-manager.connections uris "$HOSTS"` and `autoconnect "$HOSTS"`, `xmleditor-enabled true`, and starts `dbus-launch virt-manager --no-fork` in a tmux session `ttyd` |
| Upstream README | container port 80 (nginx), env `DARK_MODE` (true/false) and `HOSTS` (for example `"['qemu:///system']"`), volumes `/var/run/libvirt/libvirt-sock`, `/var/lib/libvirt/images`, device `/dev/kvm`, `privileged: true` suggested on AppArmor hosts |
| Broadway | GTK3 Broadway backend serves the GUI over HTTP/WebSocket by `broadwayd`; the base image source (`mber5/broadway-baseimage`) was not fetchable, so exact flags below are UNVERIFIED |

Corrections to the draft: ports 6080/5900 (noVNC/VNC) are guesses; upstream uses GTK Broadway (no VNC) behind nginx on port 80.

## 2. Target layout

```
apps/virt-manager/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` needed (settings are applied through env/gsettings at start). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Reason: Debian-family apt package, no language runtime; the draft agrees ("ubuntu alone is enough"). Closest siblings: `apps/valkey` (apt pin with `PACKAGE_VERSION` and a version/package consistency test), `apps/kasmvnc` (GUI stack running as `apps` with nginx and dbus in /tmp).

## 4. Dockerfile

1. `ARG VERSION`, `ARG PACKAGE_VERSION`, `ARG TARGETARCH`, `USER root`.
2. Pinned apt install, consistent with `VERSION`:
```dockerfile
RUN test "$(echo "${PACKAGE_VERSION#*:}" | sed 's/-.*//')" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      "virt-manager=${PACKAGE_VERSION}" \
      libgtk-3-bin dbus-x11 libglib2.0-bin gir1.2-spiceclientgtk-3.0 \
      gir1.2-gtk-vnc-2.0 openssh-client at-spi2-core libvirt-clients adwaita-icon-theme \
    && rm -rf /var/lib/apt/lists/*
```
`PACKAGE_VERSION` = `1:5.1.0-1ubuntu0.1`, `VERSION` = `5.1.0`. `libgtk-3-bin` is the package expected to provide `broadwayd` (UNVERIFIED; check `dpkg -L libgtk-3-bin | grep broadway`). `gir1.2-gtk-vnc-2.0` for the VNC console is not in upstream's list (added because virt-manager needs it for VNC graphics: UNVERIFIED, drop if already pulled by `virt-manager` Depends/Recommends). Not re-installed: bash, curl, ca-certificates, tini, jq, openssl (already in the ubuntu base). Pin note: the 1:5.1.0-1ubuntu0.1 build can disappear from the archive after the next security update; bump the two variables together.
3. License files: `mkdir -p /usr/share/licenses/virt-manager && cp /usr/share/doc/virt-manager/copyright /usr/share/licenses/virt-manager/` (path UNVERIFIED).
4. `ENV HOME=/config XDG_CONFIG_HOME=/config XDG_CACHE_HOME=/tmp/cache XDG_RUNTIME_DIR=/tmp/runtime GSETTINGS_BACKEND=keyfile GDK_BACKEND=broadway BROADWAY_DISPLAY=:5`.
5. `USER apps` (last user directive), `COPY --chmod=0755 . /`.
6. `EXPOSE 8085`, `VOLUME /config`, `WORKDIR /config`. Broadway default port is `8080 + display number`, so display `:5` serves on 8085 (rule from GTK docs; UNVERIFIED in this container, confirm with `ss -ltn`).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "virt-manager" }

variable "VERSION" {
  // renovate: datasource=github-tags depName=virt-manager/virt-manager versioning=semver extractVersion=^v(?<version>.+)$
  default = "5.1.0"
}

variable "PACKAGE_VERSION" {
  // NOTE: Ubuntu 26.04 package version, tied to the base image; bump by hand together with VERSION
  default = "1:5.1.0-1ubuntu0.1"
}

variable "LICENSE" { default = "GPL-2.0-or-later" }
variable "SOURCE"  { default = "https://github.com/virt-manager/virt-manager" }
```
`image.args` = `VERSION`, `PACKAGE_VERSION`; standard targets (`docker-metadata-action`, `image`, `image-local` tag `${APP}:${VERSION}`, `image-all` amd64+arm64) and `group "default"`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/virt-manager/virt-manager"
ports:
  - port: 8085
    protocol: tcp
    required: false
env:
  - name: HOSTS
    default: "['qemu:///system']"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /var/run/libvirt
    required: false
  - path: /var/lib/libvirt/images
    required: false
```
`HOSTS` is read by our `start.sh` (same name and meaning as the upstream image). `DARK_MODE`, `APP_TITLE`, `FAVICON_URL`, `CORNER_IMAGE_URL` belong to the m-bers base (nginx page), which we do not use, so they are omitted. Dependencies: none (libvirt runs on the host). Default `HOSTS` differs from upstream (`[]`) because the chart mounts the host libvirt socket; the implementer may keep `[]`.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -e
mkdir -p /config/glib-2.0/settings /tmp/runtime /tmp/cache
chmod 700 /tmp/runtime
export HOSTS="${HOSTS:-['qemu:///system']}"

broadwayd --address 0.0.0.0 --port 8085 :5 &
sleep 1

dbus-run-session -- bash -c '
  gsettings set org.virt-manager.virt-manager.connections uris "$HOSTS"
  gsettings set org.virt-manager.virt-manager.connections autoconnect "$HOSTS"
  gsettings set org.virt-manager.virt-manager xmleditor-enabled true
  exec virt-manager --no-fork
'
```
- gsettings is applied on every start (idempotent), writes go to `/config/glib-2.0/settings/keyfile` via `GSETTINGS_BACKEND=keyfile` and `XDG_CONFIG_HOME=/config`.
- `HOSTS` may contain quotes; it is passed through the environment and not interpolated into another shell string. Do not log it.
- `broadwayd` flags `--address`/`--port` and the positional display `:5` follow GTK docs (UNVERIFIED here). It must bind `0.0.0.0` so other containers/browsers can connect.
- For correct PID-1 handling use `trap 'kill 0' TERM INT` and `wait -n` on the two processes (if virt-manager exits, the container exits), or `exec` virt-manager as the last command (as in the snippet) and accept broadwayd being a background child; tini from the base handles reaping.
- Never write to `/app` (unused). `~/.ssh/known_hosts` goes to `/config/.ssh`; unlike upstream, do not disable `StrictHostKeyChecking` globally; offer `ssh-keyscan` instructions instead (UNVERIFIED UX).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
http:
- port: '8085'
  path: /
filePaths:
- /usr/bin/virt-manager
- /usr/share/licenses/virt-manager/copyright
```
Port 8085 (the only port in settings.yaml) has an http probe. With no env vars, `HOSTS` takes its default and the libvirt connection will fail inside the test (no socket), but the web server itself stays up. No DB dependency.

## 9. Rootless and read-only-rootfs adaptations

- Draft/chart: UID 0, `readOnlyRootFilesystem: false`, `/root` PVC, `/dev/kvm` device, host libvirt socket mount, privileged "unknown". We run as `apps` (568) on a read-only rootfs: `HOME`/XDG config -> `/config`, runtime dir and cache -> `/tmp`. `/root` PVC becomes `/config`.
- Host access cannot be made rootless by the image alone: the mounted `/var/run/libvirt/libvirt-sock` is usable only if its group matches a supplementary group of `apps` (the ubuntu base adds `apps` to gids 10,20,29,44,39,101,107,129; the host libvirt group id is UNVERIFIED) or via `supplementalGroups` in the chart. `/dev/kvm` is not needed by the GUI itself (only the host libvirtd runs VMs), so mount it only for session-mode `qemu:///session`, which is not supported here.
- Remote connections over ssh (`qemu+ssh://`): keys and `known_hosts` under `/config/.ssh`; no password prompt UI exists without ttyd (upstream used ttyd for passphrases), so key-based auth without a passphrase (or an agent) is required.
- No `privileged` needed in the intended setup (socket mount only).

## 10. Risks, caveats and open questions

- Broadway has no authentication: anyone reaching port 8085 controls libvirt (VM management) with the socket mounted. Strongly document: put behind an authenticating reverse proxy, keep the port off public networks. This is a security-sensitive container.
- Exact `broadwayd` packaging/flags and virt-manager running over GTK3 Broadway (deprecated backend, removed in GTK4) are UNVERIFIED until built.
- Missing upstream features: ttyd passphrase terminal, dark mode toggle, custom title/favicon.
- Host libvirt socket permissions and AppArmor (upstream suggests `privileged: true` on Ubuntu hosts): UNVERIFIED.
- arm64: package availability for arm64 and usefulness unclear (draft marks both archs "yes*").
- Pinned apt version may be removed from the archive; both version variables need manual bumps.
- UNVERIFIED count for this plan: 8 (broadwayd package, broadwayd flags/port, gtk-vnc package, copyright path, arm64 package, libvirt gid, AppArmor, ssh UX).

## 11. Build and test steps

```sh
cd apps/virt-manager
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create virt-manager-probe-config
docker run --rm -d --name virt-manager-probe --read-only --tmpfs /tmp \
  -v virt-manager-probe-config:/config virt-manager:5.1.0
docker logs -f virt-manager-probe
```
Readiness signals: `broadwayd` listening (`docker exec virt-manager-probe ss -ltn | grep 8085`), `curl -s http://localhost:8085/` from outside returns the Broadway HTML client, virt-manager process alive (`pgrep -f virt-manager`), no repeated stack traces (a "cannot connect to libvirt" message is expected without the host socket). Second run with `-v /var/run/libvirt/libvirt-sock:/var/run/libvirt/libvirt-sock` on a host that has libvirt to confirm the connection list is populated. Then:
```sh
forgetool containers test --image virt-manager:5.1.0 --config ./apps/virt-manager/container-test.yaml
docker rm -f virt-manager-probe; docker volume rm virt-manager-probe-config
```

## 12. PR checklist

- Branch `feat/add-virt-manager`; commit and PR title `feat(virt-manager): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; Notes contain `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign it).
- Pre-completion: bake print ok; `VERSION` and `PACKAGE_VERSION` aligned with the Dockerfile test; final `USER apps`; `COPY --chmod=0755 . /`; license copied to `/usr/share/licenses/virt-manager/`.
- State untested: real libvirt connection, arm64, Broadway rendering, socket group permissions, ssh remote connections.
