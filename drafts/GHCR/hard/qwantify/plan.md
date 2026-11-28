# qwantify — implementation plan
> Source: ./draft.md · Target: apps/qwantify/ · Difficulty: hard · Role: main · Verified on 2026-11-25

**Status: blocked. Do not start the port until the blockers in section 10 are resolved.** Sections 2 to 9 record what a port would need, so the decision can be made with the facts in front of it.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | No stable release: upstream tag `v0.4.0` (published 2024-05-19), and the repo has not been pushed since 2024-05-19 (https://api.github.com/repos/wanjohiryan/qwantify, via `gh api`). Stale upstream. |
| Draft chart image | `ghcr.io/wanjohiryan/qwantify:20.04@sha256:008fae84dc4d9c80eeddb9b2dc2438c0ba92a8c3a3776835a7a24321f7ea6ce1` (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/qwantify/values.yaml). |
| Renovate | UNVERIFIED: no release binaries and no confirmed versioning source. |
| License | AGPL-3.0 (`gh api repos/wanjohiryan/qwantify`, `license.spdx_id`). Source: https://github.com/wanjohiryan/qwantify |
| Source URL | https://github.com/wanjohiryan/qwantify (default branch `master`). |
| Download | None. Release `v0.4.0` has no assets (`gh api repos/wanjohiryan/qwantify/releases/latest`). Build from source only; the repo has `go.mod` and `package.json` at its root. |
| Per-arch | amd64: compile. arm64: UNVERIFIED (no build instructions fetched). |
| Checksum source | None (no release assets). UNVERIFIED. |
| Draft Dockerfile link | `gamevm/base/Dockerfile` at commit `2d4c204` resolves (fetched: Go 1.18 server build, Node 14 client build, `nvcr.io/nvidia/cudagl:11.2.2-runtime-ubuntu20.04` runtime; see context/qwantify-gamevm-dockerfile.md). The same path on `master` returns HTTP 404 (https://raw.githubusercontent.com/wanjohiryan/qwantify/master/gamevm/base/Dockerfile). The repo also has `docker/base/Dockerfile`. |
| Dockerfile in repo | https://raw.githubusercontent.com/wanjohiryan/qwantify/master/docker/base/Dockerfile: `FROM ubuntu:jammy` (`ARG UBUNTU_RELEASE=22.04`), one stage, no Go or Node build, no CUDA. Installs systemd, xvfb, pulseaudio, ffmpeg, openssh-server, Docker Engine. Downloads `warp-ubuntu-amd64` (amd64 only). `ENTRYPOINT ["/scripts/entrypoint.sh"]`, no `USER` (root), `VOLUME ["/certs"]`, no `EXPOSE`. |
| Entrypoint | https://raw.githubusercontent.com/wanjohiryan/qwantify/master/docker/base/entrypoint.sh: reads `USER`, `PASSWD`, `TZ`, `DISPLAY` (default `:0`), `WARP_HOST` (default `localhost`), `WARP_PORT` (default `4443`), `WARP_ADDRESS`, `NAME` (random if unset), `URL`. Writes `/etc/localtime`, `/etc/timezone`, `/dev/input/js0-3`, `/home/$USER`. Ends `exec /sbin/init --log-level=err` (systemd as PID 1). |
| Chart service | `main` port `10603` -> targetPort `8080` (values.yaml). |
| Chart env | `APPFILE: /game.exe`, `APPPATH: /games` (values.yaml). The game binary is supplied by the user, not by the image. |
| Chart persistence | `games` -> `/games` (type not specified). |
| Chart security | `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`; `privileged` and `capabilities` not set. |
| Dependencies | None found. |

**Mismatch to resolve first:** the draft says the image is a CUDA base on Ubuntu 20.04 with a Go and Node build. None of the fetched sources confirms this. The repo's Dockerfile is Ubuntu 22.04 (`jammy`) with the WARP and systemd stack. Which Dockerfile builds `ghcr.io/wanjohiryan/qwantify:20.04` is UNVERIFIED.

## 2. Target layout

If the blockers clear: `apps/qwantify/Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`. Add `defaults/` or `etc/` only with a reason named at that time. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` for the final stage, with a build stage only if a source build is chosen. The draft's `python-node` alternative is not needed: no Python or Node runtime is confirmed for the app.

## 4. Dockerfile

Not applicable until the source of the app is confirmed. A source build would need the Go or Node toolchain in a build stage and `COPY --from=` into the ubuntu stage (per the Go rules). The upstream stack (systemd as PID 1, WARP client, Docker Engine, sshd) is not needed for a single-app container and should not be ported as-is.

## 5. docker-bake.hcl

Not applicable until `VERSION` can be pinned. No upstream release exists to pin (`v0.4.0` has no assets). Once a commit or tag is chosen, use `datasource=git-refs` with the repo URL and `currentValue=master` (the fenrus precedent), and `LICENSE = "AGPL-3.0-only"` as confirmed by the license file.

## 6. settings.yaml

Not applicable until the ports and env are confirmed. Candidates from the chart only: port `8080` (chart target), env `APPFILE`, `APPPATH`. Do not list `WARP_PORT` (4443) or the draft's UDP range `52000-52100` (not confirmed in any source).

## 7. start.sh

Not applicable until the app's real start command is known. The repo's `entrypoint.sh` starts no application: it only configures the user, timezone and `/dev/input` nodes, then runs systemd. Its `/dev/input` writes and `chown -R /home/$USER` are not compatible with a read-only rootfs without a rewrite.

## 8. container-test.yaml

Not applicable until the app starts without a game file. The chart sets `APPFILE=/game.exe`, which the image does not ship. A test with no env vars would start the entrypoint with no game and would need the `filePaths` path noted in the test rules. Probe plan if the blockers clear: `tcp` on 8080.

## 9. Rootless and read-only-rootfs adaptations

- Chart runs as root. ContainerForge needs `USER apps`. The entrypoint's `sudo`, `passwd`, `chown -R`, and `/dev/input` writes all need a rewrite.
- `readOnlyRootFilesystem` is `false` in the chart. A port would need `/tmp` for caches and `/config` for state. The game files in `/games` are user data.
- `/certs` (VOLUME in the repo Dockerfile) and `/home/admin/.ssh` are upstream state; they have no place in a single-app image.
- GPU access (`--device=/dev/dri`, from the repo's run comment) is a runtime device, not a Dockerfile setting. It is not in the chart values.

## 10. Risks, caveats and open questions

Blockers (any one stops the port):
1. **Wrong or stale source.** The draft's Dockerfile link is 404, and the upstream release is `v0.4.0` from 2024 with no assets. Which Dockerfile produces the `20.04` tag is UNVERIFIED.
2. **amd64 only.** The WARP binary is `warp-ubuntu-amd64`. arm64 is not supported by the upstream stack, so `image-all` cannot be published as-is.
3. **GPU device required.** The app needs `/dev/dri` (and the CUDA base in the draft, if it is real). Not testable in the standard container test.
4. **systemd as init and root by default.** Incompatible with `USER apps` and read-only rootfs without a rewrite.
5. **User-supplied game binary.** The image cannot run without `/games/game.exe` (APPFILE). The container test cannot exercise the app path.
6. **Upstream stale.** No release since 2024, no maintenance signal.

Draft caveats confirmed or not: the 52000-52100/udp media range and the Go and Node build are UNVERIFIED. The 20.04 end-of-life point is not relevant to the repo's jammy Dockerfile (jammy is still supported until 2027) but matters to the chart's `20.04` tag.

## 11. Build and test steps

Not applicable while blocked. Once unblocked, the protocol is: `docker buildx bake --print`, then build amd64 with `image-local`, then the probe run on `--read-only --tmpfs /tmp` with an empty `/config`, then `forgetool containers test`. Do not run any of these while the status is blocked.

## 12. PR checklist

Not applicable while blocked. If the port proceeds: branch `feat/add-qwantify`, commit `feat(qwantify): add new container`, PR template with `🤖 This PR is AI generated.` in Notes, CLA notice to the user (https://cla-assistant.io/trueforge-org/containerforge, only the user can sign), and an honest list of what was not built or run.

## Fix attempt (2026-11-28)

No container files written: a port would have meant inventing most of the runtime, so the blockers below are recorded instead.

Resolved by this attempt:
- The repo `github.com/wanjohiryan/qwantify` now 301-redirects to `https://github.com/wanjohiryan/Arc3dia` (renamed). Use that URL.
- Which Dockerfile builds the chart's `20.04` image: very likely `gamevm/base/Dockerfile` at commit `2d4c204c8902da9026fc15baf21eab0fedc0f0dd` (the path 404s on `master`, and the `docker/base` Dockerfile is Ubuntu 22.04 with systemd, so it is not it). Evidence: its `gamevm/base/entrypoint.sh` runs `cd "${APPPATH}" && wine "${APPFILE}"` (matches chart env `APPFILE=/game.exe`, `APPPATH=/games`), `VOLUME /games` matches the chart mount, and `ENV NEKO_BIND=:8080` matches chart targetPort 8080. The ghcr tag list could not be read (ghcr returns UNAUTHORIZED), so the link between that commit and the `20.04` digest is still inferred.
- What that image is: a fork of m1k1o/neko. Stage 1 `golang:1.18-bullseye` builds `server/cmd/neko/main.go` (needs libclipboard, X11 and GStreamer dev libs). Stage 2 `node:14-bullseye-slim` builds `client/`. Runtime is `nvcr.io/nvidia/cudagl:11.2.2-runtime-ubuntu20.04` with supervisord (as root) running dbus, Xvfb, pulseaudio, neko and a `game` program (`/etc/entrypoint.sh`, wine or `vglrun wine`), plus VirtualGL 3.0.2 (amd64 .deb from sourceforge), WineHQ staging, winetricks and `d3dx11_43`. Env defaults: `NEKO_PASSWORD=neko`, `NEKO_PASSWORD_ADMIN=admin`, `NEKO_BIND=:8080`, `DISPLAY=:99.0`, `REFRESH=60`, `DPI=96`, `CDEPTH=24`, `VGL_DISPLAY=egl`.

Still blocking (needs a maintainer decision, not more research):
- It is a Wine, Xvfb, VirtualGL and NVIDIA-GPU stack that supervisord runs as root, so `USER apps` and a read-only rootfs need a real redesign (X sockets in `/tmp`, pulseaudio, dbus, `/home/neko`, `/var/log/neko`). The setuid VirtualGL libraries (`chmod u+s`) are not compatible with the repo rules.
- Upstream is stale (last push 2024-05-19, no release assets), amd64 only (VirtualGL amd64 .deb, WineHQ staging on Ubuntu 20.04), and the user supplies the game binary, so no probe beyond `tcp 8080` is possible.
- The `master` branch of the repo no longer has `gamevm/base`, so a port must pin commit `2d4c204c8902da9026fc15baf21eab0fedc0f0dd` with `datasource=git-refs` or build from that tarball, and no licence or checksum is published for it beyond the AGPL-3.0 repo licence.
- A cleaner route is to build on the existing ContainerForge `neko` app (a draft exists at `drafts/GHCR/hard/neko`) and add wine on top, rather than porting this fork. That is a new design, not a fix of this draft.
