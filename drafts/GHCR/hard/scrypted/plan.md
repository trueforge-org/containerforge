# scrypted — implementation plan
> Source: ./draft.md · Target: apps/scrypted/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest stable | v0.147.0, published 2026-09-13, not prerelease. Draft tag v0.123.58 is OUTDATED. | https://api.github.com/repos/koush/scrypted/releases/latest |
| npm package | `@scrypted/server` latest 0.147.0 | https://registry.npmjs.org/@scrypted/server/latest |
| License | npm package: ISC. GitHub repo license: NOASSERTION ("Other"). SPDX for the image is UNVERIFIED until the repo LICENSE is read. | npm registry; https://api.github.com/repos/koush/scrypted/license |
| Renovate | `datasource=npm depName=@scrypted/server` (proposed; not checked against repo renovate config) | npm registry |
| Release assets | None (release has no binary files). Binary source is npm only. | release API |
| Checksum | UNVERIFIED: npm package integrity not checked; no release checksums | release API |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/koush/scrypted/main/install/docker/Dockerfile | fetched (main branch, not pinned) |

Upstream Dockerfile summary:
- Base: `ghcr.io/koush/scrypted-common:${BASE}`, `ARG BASE="noble-full"`. Not a ContainerForge base.
- `ARG SCRYPTED_INSTALL_VERSION="latest"`, then `RUN npx -y scrypted@latest install-server ${SCRYPTED_INSTALL_VERSION}`, `WORKDIR /server`.
- `ENV NODE_OPTIONS="--dns-result-order=ipv4first"`, `ENV SCRYPTED_BASE_VERSION="20250101"`.
- `CMD ["/bin/sh","-c","ulimit -c 0; exec npm --prefix /server exec scrypted-serve"]`.
- No EXPOSE, VOLUME, USER or ENTRYPOINT.
- `ADD https://www.random.org/cgi-bin/randbyte?... skipcache` is a cache buster. Not used in the ContainerForge build.

Ports: UNVERIFIED. Upstream has no EXPOSE. The draft's 10443 (https) and 11080 (http) are inferences; confirm on https://docs.scrypted.app before use.
Data paths: UNVERIFIED. Draft chart paths `/server/volume` and `/media/external` are the only evidence.
Env vars: only `NODE_OPTIONS`, `SCRYPTED_BASE_VERSION` and the build arg `SCRYPTED_INSTALL_VERSION` are confirmed.
Arm64: UNVERIFIED. Draft says yes* (unconfirmed). The npm server is JavaScript, but native dependencies are not checked.

## 2. Target layout

Files in `apps/scrypted/`:
- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`.
- `defaults/` only if a default config is shipped.
- No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- Draft proposes `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` as the runtime image, on the ubuntu foundation.
- Reason: scrypted needs Node.js and Python plugin runtimes. The python-node image covers both.
- Upstream `scrypted-common` (noble, bundles ffmpeg) is NOT used. Install ffmpeg via apt only if the server needs it (UNVERIFIED).
- Closest siblings: `apps/changedetection` and `apps/budge` (python-node).
- Check the python-node image has Node and npm at the expected major version before install (UNVERIFIED).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config`, `ENV NODE_OPTIONS=--dns-result-order=ipv4first`.
2. Install server into `/app/server` at build time: `npm install --prefix /app/server @scrypted/server@${VERSION}` (version pinned, not `latest`).
3. Verify the npm version after install matches `VERSION`.
4. apt: only packages not in base (ffmpeg if required; UNVERIFIED).
5. Caches (npm, pip) go to `/tmp`. Clean up with `rm -rf /tmp/*`.
6. License: ship upstream LICENSE to `/usr/share/licenses/scrypted/` (read from the npm package or repo).
7. `COPY --chmod=0755 . /`, `EXPOSE` of confirmed ports only, `VOLUME /config`, `USER apps`.

## 5. docker-bake.hcl

- `variable "APP" { default = "scrypted" }`
- `variable "VERSION" { // renovate: datasource=npm depName=@scrypted/server versioning=semver` then `default = "0.147.0"`.
- `variable "LICENSE" { default = "ISC" }` (confirm against the repo LICENSE; the GitHub API says NOASSERTION, so set to the SPDX value confirmed in the LICENSE file).
- `variable "SOURCE" { default = "https://github.com/koush/scrypted" }`
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all`, `group "default"`.
- Validate with `cd apps/scrypted && docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: https://github.com/koush/scrypted`.
- `ports`: only ports confirmed on docs.scrypted.app. Until confirmed, list only the web UI port the server actually binds, verified in a run (UNVERIFIED).
- `env`: `NODE_OPTIONS` (default `--dns-result-order=ipv4first`), plus any variables start.sh reads after verification.
- `volumes`: `/config` persistent. Map upstream `/server/volume` to `/config/volume`.
- `dependencies`: none.

## 7. start.sh

- Idempotent. Create `/config/volume` only when missing.
- Point the server's volume directory at `/config/volume` (exact env or flag UNVERIFIED).
- Plugins downloaded at runtime need writes: put them under `/config`, and caches under `/tmp`.
- Bind to `0.0.0.0`.
- Finish with `exec npm --prefix /app/server exec scrypted-serve` (or the server's direct entry, verified in the image).

## 8. container-test.yaml

- forgetool schema header.
- `tcp` probe on each port listed in settings.yaml, with `timeoutSeconds` from a sibling node/python app.
- `filePaths`: `/app/server/node_modules/@scrypted/server` (UNVERIFIED: the install layout is unconfirmed until the first build) and no `/config` seed path unless `start.sh` creates one.
- The test starts with no env vars: the server must start without any device or camera.

## 9. Rootless and read-only-rootfs adaptations

- Upstream: root, no read-only rootfs (draft; chart values). ContainerForge: `USER apps` and read-only rootfs.
- Write paths: plugin installs and server volume → `/config`; npm/pip caches → `/tmp`.
- Privileged: unknown in the chart. Camera and GPU access need hardware passthrough, which is not expressible in the test, and host networking may be needed for mDNS (UNVERIFIED).
- Expected: non-root yes, read-only yes, privileged unknown (to verify).

## 10. Risks, caveats and open questions

- Draft version is outdated (v0.123.58 vs v0.147.0). Confirm the version used by the chart before pinning.
- Draft base jammy and scrypted-common are not used; the python-node choice is a deviation that must be checked against the server's runtime needs.
- Plugins download at first start; the first run needs internet and is slow. The test must not depend on plugin download.
- Camera discovery and mDNS need host networking (inferred).
- Arm64 and license SPDX are unverified.
- The draft lists `full`, `lite` and `nvidia` image variants. This plan covers one CPU image only; the nvidia/CUDA variant is out of scope and not planned (UNVERIFIED whether a GPU image is wanted).
- Blockers: privileged/hardware access; unknown ports and data paths; license SPDX unclear; base image choice.

## 11. Build and test steps

1. `cd apps/scrypted && docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name scrypted-probe --read-only --tmpfs /tmp -v scrypted-probe-config:/config scrypted:<version>`, then `docker logs -f scrypted-probe`.
4. Readiness: the server's startup line (UNVERIFIED; capture from the first run) with the process alive and no fatal errors.
5. `forgetool containers test --image scrypted:<version> --config ./apps/scrypted/container-test.yaml`.
6. Cleanup: `docker rm -f scrypted-probe; docker volume rm scrypted-probe-config`.
- Not run here: no docker build was run for this plan.

## 12. PR checklist

- Branch `feat/add-scrypted`, commit `feat(scrypted): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; check only applicable boxes.
- Notes: `🤖 This PR is AI generated.`
- CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; tell the user).
- Say what is untested: arm64, hardware, plugin downloads, unconfirmed ports.
