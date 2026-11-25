# raspberrymatic — implementation plan
> Source: ./draft.md · Target: apps/raspberrymatic/ · Difficulty: hard · Role: main · Verified on 2026-11-25

**Status: blocked. Not a fit for a ContainerForge app as drafted.** The image is a full buildroot OS with its own init, hardware drivers and root. Sections 2 to 9 record what a port would need, so the decision can be made with the facts in front of it.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | Latest upstream release `3.89.14.20261121` (OpenCCU, https://api.github.com/repos/OpenCCU/OpenCCU/releases/latest via `gh api`). The draft pins `3.89.11.20260919` (`generic-x86_64.zip`), which is older. |
| Draft chart image | `ghcr.io/jens-maus/raspberrymatic:latest@sha256:4b22b4f407c42375be1d13442f55fd0477f6713db0a0168db7bccfe9c44533da` (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/raspberrymatic/values.yaml). |
| Renovate | Proposed `datasource=github-releases depName=OpenCCU/OpenCCU versioning=loose` (the tag is a dotted build number). UNVERIFIED against this repo's renovate config. |
| License | Apache-2.0 for OpenCCU/OpenCCU (`gh api repos/OpenCCU/OpenCCU`, `license.spdx_id`). The RaspberryMatic repo license: UNVERIFIED. |
| Source URL | https://github.com/jens-maus/RaspberryMatic (image source); https://github.com/OpenCCU/OpenCCU (release assets). |
| Download (latest) | Per arch: `OpenCCU-3.89.14.20261121-generic-x86_64.zip` and `OpenCCU-3.89.14.20261121-generic-aarch64.zip`. Also `OpenCCU-3.89.14.20261121-oci_amd64.tgz` and `-oci_arm64.tgz`, plus `lxc_*` and `ccu3.tgz` (https://github.com/OpenCCU/OpenCCU/releases/download/3.89.14.20261121/). |
| Checksum source | Per-asset `<name>.sha256` sidecar file (listed in the release). Content not fetched: UNVERIFIED (signed redirect not followed). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/jens-maus/RaspberryMatic/master/buildroot-external/board/oci/Dockerfile: `FROM scratch`, `ARG TARGETARCH`, `ARG tar_prefix=rootfs`, `ADD $tar_prefix$TARGETARCH.tar /`, `CMD ["/sbin/init"]`, `STOPSIGNAL SIGTERM`, no `ENV`, no `USER`, no `VOLUME`. `HEALTHCHECK` checks `/var/status/startupFinished` and either `/usr/local/HMLGW` or `curl http://localhost/login.htm`. |
| Ports (upstream EXPOSE) | 80, 22, 161, 443, 1900, 1901, 1902, 5987, 1999, 2000, 2001, 2010, 8088, 8181, 9099, 9292, 9293, 10000, 41999, 42000, 42001, 42010, 43438, 43439, 48181, 48899, 49292, 49880. |
| Chart ports | `ccu`: 2001, 2010, 9292, 8181 (all enabled). `main`: 10581 (http) -> 80 (values.yaml). |
| Chart persistence | `config` -> `/usr/local` (pvc default); `control` hostPath `/run/udev/control`; `modules` hostPath `/lib/modules` (readOnly); `sys` hostPath `/sys` (values.yaml). |
| Chart security | `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`; no `privileged`, `capabilities` or `hostNetwork` set (values.yaml). |
| Dependencies | None. |

## 2. Target layout

Not applicable: no `apps/raspberrymatic/` files until the blockers in section 10 are resolved.

## 3. Base image

Not applicable. The image is a buildroot rootfs with its own `/sbin/init`. The ContainerForge bases (ubuntu, python, java, nginx) do not fit. An OS image cannot be rebuilt on the ubuntu base without large rework (the draft's own reason).

## 4. Dockerfile

Not applicable. The only viable upstream path is `ADD`ing the rootfs tar from the release (`generic-*.zip` or `oci_*.tgz`). That needs root, `/sbin/init` as PID 1, and `/sys` plus `/lib/modules` host mounts, all of which conflict with the ContainerForge rules (`USER apps`, read-only rootfs).

## 5. docker-bake.hcl

Not applicable until a port is approved. If it is: `VERSION` `3.89.14.20261121` with the renovate annotation above, `LICENSE = "Apache-2.0"`, `SOURCE = "https://github.com/OpenCCU/OpenCCU"`, and the standard four targets. Use `image-local` with amd64 and arm64 assets both present.

## 6. settings.yaml

Not applicable until the ports and env are confirmed. The chart's ports (2001, 2010, 9292, 8181, 80) are candidates only. Upstream `EXPOSE` lists 28 ports: none should be listed without a probe in `container-test.yaml`.

## 7. start.sh

Not applicable: the image has no application start script. Its entrypoint is `/sbin/init`, which the ContainerForge process model does not use (`exec` of a single app).

## 8. container-test.yaml

Not applicable until the container can run unprivileged. The upstream healthcheck (`/var/status/startupFinished`, `http://localhost/login.htm`) is a possible readiness signal, but the image's boot path needs `/sys` and `/lib/modules`, which the test runner does not provide.

## 9. Rootless and read-only-rootfs adaptations

- Runs as root with `/sbin/init`. ContainerForge requires `USER apps`. Not compatible.
- `/sys` and `/lib/modules` hostPath mounts and `/run/udev/control` are kernel and device interfaces. They cannot be replaced inside a container.
- The chart's `config` mount is `/usr/local`, which is a system path in the OS image, not app state. A remap would be a rework of the OS layout.
- HomeMatic radio (`2001`, `2010`) and USB hardware need device passthrough at deploy time.

## 10. Risks, caveats and open questions

Blockers (any one stops the port):
1. **Full OS image.** It runs `/sbin/init`, several daemons and drivers. It is not an application container.
2. **Root and kernel access.** Needs `/sys`, `/lib/modules` and `/run/udev/control`. Conflicts with the rootless rule. The chart has no `privileged`, but the host mounts need a compatible kernel.
3. **Hardware.** HomeMatic radio and USB devices require passthrough.
4. **Upstream churn.** The project was renamed to OpenCCU and the draft's pinned version is out of date. The `latest` tag in the chart is not pinned.
5. **Upstream EXPOSE list is large** (28 ports, mostly internal). Listing them in `settings.yaml` would violate the rule to list only ports the container opens.

Draft facts confirmed or corrected: the amd64 and arm64 assets exist (corrected version); the Dockerfile is `FROM scratch` with `CMD /sbin/init` (confirmed, not a language base). The license and checksum sidecar file are confirmed in the release list; the sidecar content is UNVERIFIED.

## 11. Build and test steps

Not applicable while blocked. Do not run `docker buildx bake` for this app until a port is approved.

## 12. PR checklist

Not applicable while blocked. If a port is approved: branch `feat/add-raspberrymatic`, commit `feat(raspberrymatic): add new container`, PR template with `🤖 This PR is AI generated.` in Notes, CLA notice to the user (https://cla-assistant.io/trueforge-org/containerforge, only the user can sign), and an honest list of what was not built or run.
