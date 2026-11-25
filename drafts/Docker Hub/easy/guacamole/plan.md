# guacamole — implementation plan
> Source: ./draft.md · Target: apps/guacd/ (shared with `../guacd/plan.md`, no separate `apps/guacamole/`) · Difficulty: medium (draft says easy) · Role: sidecar (`guacdImage` of the `guacamole` chart) · Verified on 2026-11-23 (checked again on 2026-11-25)

This draft describes the same container as `../guacd/draft.md`: the chart `guacamole` only needs a guacd sidecar, and its image is the same `docker.io/guacamole/guacd:1.6.0` (same Dockerfile link, same reason text, same port). Building it twice would produce two identical images, so the plan is to build `apps/guacd` once, from `../guacd/plan.md`, and let the `guacamole` chart consume `ghcr.io/trueforge-org/guacd`. Every section below states what applies to this draft and points to the exact section of the guacd plan for the full text and snippets.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `1.6.0` (apache/guacamole-server tag `1.6.0`, 2025-06-23, newest non-RC). |
| Renovate | `datasource=github-tags depName=apache/guacamole-server versioning=semver`. |
| License | Apache-2.0 (LICENSE of the 1.6.0 source tarball). |
| Source | https://github.com/apache/guacamole-server (chart row's own source is the same repo; the web client is https://github.com/apache/guacamole-client). |
| Artifact | Source tarball `https://archive.apache.org/dist/guacamole/1.6.0/source/guacamole-server-1.6.0.tar.gz`, sha256 `8bc45675da96d7b6f39728160181e3d4ff3c08f460f6d26de5805b642bf13f2b` (published `.sha256`, matches the downloaded file). No prebuilt binary. |
| Draft claim to correct | "guacd installed from apt ... present in resolute, 26.04" is wrong: packages.ubuntu.com lists `guacd` only for jammy and noble (1.3.0). Build from source. |
| Draft claim to correct | "8080/http (web UI)" belongs to the Guacamole web client image (`guacamole/guacamole`), not to guacd. This image listens on `4822/tcp` only. The draft's own caveat says the same. |
| Chart persistence | `/var/lib/guacamole/recordings` and `/var/lib/guacamole/drive` (guacd side), `/tc-init` emptyDir and configmap seed scripts (web client side, out of scope). |
| Upstream Dockerfile | Same as guacd (alpine, musl, `COPY --from` impossible); reviewed, details in `../guacd/plan.md` section 1. |

## 2. Target layout

Not applicable for `apps/guacamole/`: no folder is created for this draft. The deliverable is `apps/guacd/` with `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh` exactly as in `../guacd/plan.md` section 2. If the maintainers insist on the name `guacamole` for the chart mapping (UNVERIFIED how the chart to app mapping is done), do not copy the files, rename the single app instead.

## 3. Base image

Same as guacd: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the build and final stage (no `apt` guacd package exists, a compiled C daemon needs no runtime image). See `../guacd/plan.md` section 3.

## 4. Dockerfile

Use the two-stage Dockerfile in `../guacd/plan.md` section 4 unchanged: build stage (build dependencies, download plus `sha256sum -c`, `./configure --prefix=/usr/local --disable-guaclog --disable-guacenc`, `make install DESTDIR=/target`, license files, `ldd`/`dpkg -S` runtime package list), final stage (`COPY --from=build /target/ /`, runtime packages, `ldconfig`, `/var/lib/guacamole/{recordings,drive}` owned by `apps`, `ENV HOME=/tmp`, `COPY --chmod=0755 . /`, `EXPOSE 4822`, `VOLUME /config` plus the two paths, final `USER apps`). Nothing is added for the chart's `guacamole` side.

## 5. docker-bake.hcl

Same as `../guacd/plan.md` section 5: `APP=guacd`, `VERSION=1.6.0` with the `github-tags` renovate comment, `LICENSE=Apache-2.0`, `SOURCE=https://github.com/apache/guacamole-server`, and the four standard targets plus the default group. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Same as `../guacd/plan.md` section 6 (port 4822/tcp, env `LOG_LEVEL`, `GUACD_LOG_LEVEL`, `TZ`, volumes `/config` (required by the settings schema, unused), `/var/lib/guacamole/recordings` and `/var/lib/guacamole/drive`, `dependencies: []`). Do not list 8080: this container does not open it. For the chart side, the web client (a separate future app; checked: there is no `apps/guacamole` or `apps/guacd` yet) would list `guacd` as a dependency (✅ once `apps/guacd` exists).

## 7. start.sh

Same as `../guacd/plan.md` section 7: `exec /usr/local/sbin/guacd -f -b 0.0.0.0 -l 4822 -L "${LOG_LEVEL:-${GUACD_LOG_LEVEL:-info}}" "$@"`. The `-b 0.0.0.0` is essential: the web client in the other pod or container connects over the network and guacd defaults to localhost.

## 8. container-test.yaml

Same as `../guacd/plan.md` section 8: `tcp` port `4822`, `filePaths` for `guacd` and the rdp, ssh and vnc client libraries, `timeoutSeconds: 60`. No `http` probe, because nothing speaks HTTP (the draft's 8080 is not a port of this image).

## 9. Rootless and read-only-rootfs adaptations

Same table as `../guacd/plan.md` section 9. Reconciling this draft's expectations: non-root yes (`apps`, the chart used UID 1001 for the web client and 1000 for guacd), `readOnlyRootFilesystem` can be true (the chart's `false` for guacd is not needed), not privileged. The two persistence paths must be mounted volumes on a read-only rootfs, which is the practical form of the draft caveat "recordings and drive paths need writable persistent storage". The draft's expectation that "the rootfs must be writable for the guacd side" is not required here.

## 10. Risks, caveats and open questions

- Decision for the maintainers: ship one `guacd` app and have the `guacamole` chart row reference it, rather than a second identical image. If the tooling that tracks the project-fireball list needs an app named `guacamole`, that is a naming question, not a second Dockerfile.
- The web client (`guacamole/guacamole`, Java/Tomcat, port 8080, needs a database or a user-mapping file and a `GUACD_HOSTNAME`) is not planned here. It would be a separate app and needs its own plan. Partial facts from web research on 2026-11-25: 1.6.0 is the latest release found, an architecture-independent `guacamole-1.6.0.war` is published with a `.sha256` on dlcdn.apache.org, and the upstream 1.6.0 Dockerfile runs it on `tomcat:9-jdk21`; its license was not confirmed there (UNVERIFIED). Until it exists the chart cannot be fully replaced.
- All risks of `../guacd/plan.md` section 10 apply: no apt package in resolute, source build with Ubuntu's FreeRDP 3 (runtime behaviour UNVERIFIED), pinned checksum not renovated, guacd is unauthenticated and must stay on an internal network, arm64 compile time under emulation.

## 11. Build and test steps

Run the commands of `../guacd/plan.md` section 11 with `apps/guacd` and image `guacd:1.6.0` (bake print, `image-local` amd64 build, `docker run --read-only --tmpfs /tmp` with a fresh `/config` volume, second-container connect to port 4822 to prove it is not localhost-only, `forgetool containers test`). Expected readiness signal: guacd logs that it started and listens on `0.0.0.0` port 4822, and the container keeps running. Never build `apps/guacamole` in parallel with `apps/guacd`; there is only one app to build.

## 12. PR checklist

- [ ] One PR, for `apps/guacd` only: branch `feat/add-guacd`, commit and title `feat(guacd): add new container` (no `feat(guacamole): ...` commit, because `apps/guacamole` is not created).
- [ ] PR template filled in; `🤖 This PR is AI generated.` in Notes; mention that both drafts `guacd` and `guacamole` are covered by this app and that the apt route in the drafts was invalid.
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- [ ] `docker buildx bake --print` exits 0.
- [ ] Untested items listed honestly: arm64, a real Guacamole web client session, recordings and drive, and everything the guacd plan marks UNVERIFIED.
