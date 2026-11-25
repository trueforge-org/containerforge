# debian-bullseye — implementation plan
> Source: ./draft.md · Target: apps/debian-bullseye/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No application version. The draft's container is a rolling `ghcr.io/ich777/debian-bullseye:latest`. There is no release to pin. |
| Renovate | Not applicable: no upstream release stream for the image. Debian suite is fixed by name (`bullseye`). |
| License | Not applicable as a single app license: the image is a Debian userland, and each package carries its own license. UNVERIFIED: a single SPDX for the whole image. |
| Source URL | https://www.debian.org/ (the draft's link). Debian archive for bullseye: https://archive.debian.org/debian/dists/bullseye/ |
| Archive status | `archive.debian.org/debian/dists/bullseye/` exists and lists `Release`, `InRelease` and `Release.gpg`, the Release file dated 2024-08-31 (https://archive.debian.org/debian/dists/bullseye/). Bullseye is past regular support, so apt sources must point at the archive (inferred, UNVERIFIED: the sources list the upstream image uses). |
| Download | No per-app binary. The userland is built from the bullseye archive (debootstrap or a base image). The draft's link is a repository index, not an executable. |
| Checksum source | Debian `Release`/`InRelease` signatures on archive.debian.org. Not a single artifact checksum. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-debian-bullseye/master/Dockerfile: `FROM ich777/novnc-baseimage:bullseye_amd64`, a large desktop package set (xfce4, xorg, firefox-esr, element-desktop from the Element repo, ffmpeg, systemd, cron, and more), RustDesk fetched from GitHub latest (unpinned), `ENTRYPOINT ["/opt/scripts/start.sh"]`, no `USER`, no `VOLUME`, `EXPOSE 8080`. |
| Ports (upstream) | `NOVNC_PORT=8080`, `RFB_PORT=5900` (ENV defaults). The draft's 6080 is not the upstream default. |
| Env vars (upstream, real) | `DATA_DIR=/debian`, `FORCE_UPDATE`, `CUSTOM_RES_W=1280`, `CUSTOM_RES_H=720`, `CUSTOM_DEPTH=16`, `NOVNC_PORT=8080`, `RFB_PORT=5900`, `TURBOVNC_PARAMS="-securitytypes none"`, `NOVNC_RESIZE`, `NOVNC_QUALITY`, `NOVNC_COMPRESSION`, `UMASK=000`, `UID=99`, `GID=100`, `DATA_PERM=770`, `USER=Debian`, `ROOT_PWD="Docker!"` (a hardcoded default root password), `DEV`, `USER_LOCALES="en_US.UTF-8 UTF-8"`. |
| Data path | `/debian` (`DATA_DIR`), not declared as a VOLUME upstream. |
| Dependencies | None. |

## 2. Target layout

Not recommended for ContainerForge as a port (see section 10). If the decision is to proceed anyway, the layout would be the same five files as any app: `apps/debian-bullseye/Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`, plus whatever `defaults/` is needed. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

The draft proposes ubuntu. That does not fit: the desktop is Debian bullseye, so the base would be a Debian-based image, not `ghcr.io/trueforge-org/ubuntu`. The upstream base `ich777/novnc-baseimage:bullseye_amd64` is a third-party Debian userland. A ContainerForge version would start from `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` only if the goal were an Ubuntu desktop, which is out of scope. UNVERIFIED: whether a debootstrap bullseye rootfs can be built in the ContainerForge build without privileges.

## 4. Dockerfile

Not written. Writing it would mean building a full desktop from a 2021-era suite on the archive, which conflicts with section 9 (rootless, read-only rootfs). If a Dockerfile is produced later, its outline is: `debootstrap --variant=minbase bullseye` into a build stage (needs privileges the build cannot give; UNVERIFIED that buildx allows it), then copy the rootfs into the final stage with `COPY --from=`, `USER apps`, `EXPOSE 8080 5900`, `VOLUME /config`.

## 5. docker-bake.hcl

Not written. If the app goes ahead, `VERSION` would need a renovate annotation for a source that exists (none found; the Debian suite name is the only version). Four standard targets and the `default` group as in `apps/adguardhome-sync`.

## 6. settings.yaml

Not written. If the app goes ahead: `ports` 8080 (noVNC) and 5900 (VNC), `volumes` `/config`, `env` only for the variables `start.sh` reads (not `ROOT_PWD`, see section 10), `dependencies: []`.

## 7. start.sh

Not written. A desktop start script would have to run Xvfb, a window manager, x11vnc and noVNC as non-root with `/tmp` for sockets and `/config` for the user profile (UNVERIFIED that Xvfb runs rootless in this image).

## 8. container-test.yaml

Not written. If the app goes ahead: `tcp` probes on 8080 and 5900, an `http` probe on 8080 `/`, and `filePaths` for the noVNC entry point (path UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/debian` (`DATA_DIR`, user home for `Debian`) | `/config` as home (`HOME=/config`) |
| `/opt/scripts/`, `/usr/share/themes/`, `/usr/share/novnc` edits | Read-only in the image; user-level config only under `/config` |
| `sudo`, `systemd`, `rsyslog`, `iptables`, `udev`, `isc-dhcp-client`, `dbus` | Not usable as `USER apps` on a read-only rootfs; remove from the package set |
| Apt-installed desktop apps (firefox-esr, element-desktop, sylpheed, gedit, flameshot, ...) | Out of scope for a ContainerForge base; a desktop app belongs in its own container |
| `ROOT_PWD` | Not used. Drop the hardcoded password. |

Reconcile the draft's expectations: draft expects `runAsUser 0`, no read-only rootfs, `/debian` persistence. Target would be `USER apps`, read-only rootfs compatible, `/config` only. These conflict with a desktop stack that needs systemd and root, so the expectations cannot be met as the upstream image is built.

## 10. Risks, caveats and open questions

- Not an application: the image is the Debian userland itself, so there is no upstream application to port. This is the main reason to skip it.
- Bullseye is past regular support and moved to archive.debian.org. Any apt source must point there (UNVERIFIED for the exact sources the upstream uses).
- The upstream image has security issues: hardcoded `ROOT_PWD=Docker!`, `--no-sandbox` on element-desktop, unpinned RustDesk fetched from GitHub latest, `ulimit` in a RUN step with no effect. None of this should be carried over.
- The chart uses the rolling `latest` tag of a third-party image; the Debian userland can change without a version bump.
- Blocker: root, systemd and a desktop stack are incompatible with `USER apps` and a read-only rootfs (section 9).
- Blocker: debootstrap in a ContainerForge build is UNVERIFIED and likely needs privileges the build does not have.

Recommendation: do not port this as a ContainerForge app. Record it as skipped in the batch and, if the user wants a Debian base for other apps, make a separate base image decision.

## 11. Build and test steps

Not run. No build because the plan recommends skipping. If the user decides to proceed, the protocol steps are `docker buildx bake --print`, `image-local` build, a read-only run with an empty `/config`, and `forgetool containers test`, from `apps/debian-bullseye/`.

## 12. PR checklist

Not applicable while the app is skipped. If it proceeds: branch `feat/add-debian-bullseye`, commit `feat(debian-bullseye): add new container`, PR template with the `🤖 This PR is AI generated.` line in Notes, CLA notice (https://cla-assistant.io/trueforge-org/containerforge; only the user can sign), and an honest list of what is untested.
