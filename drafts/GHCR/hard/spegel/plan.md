# spegel — implementation plan
> Source: ./draft.md · Target: apps/spegel/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest stable | v0.8.1 (not prerelease) | `gh api repos/spegel-org/spegel/releases/tags/v0.8.1` |
| Release date | 2026-10-28 | same |
| Renovate | datasource `github-releases`, depName `spegel-org/spegel`, versioning `semver` (derived, not checked against a renovate config) | — |
| License | UNVERIFIED: the license API and repo page were not fetched (403) | — |
| Assets | `spegel_0.8.1_linux_amd64.tar.gz`, `spegel_0.8.1_linux_arm64.tar.gz`, `spegel_0.8.1_linux_arm.tar.gz`, `spegel_0.8.1_checksums.txt` | https://github.com/spegel-org/spegel/releases/download/v0.8.1/ |
| Checksums | amd64 `3e2d2886f1cc846f3439156dea9a4bd003b73fc9ee9e8f96462c153add71f049`; arm64 `469de3a23b37cc7bbac33bb64d2fa2135bacab42b4b231d9d545a4affdd6b9f5`; arm `14344539f7fd373a94387fbfa45087db7a56960c9fbe03d2dbf7ee6651e79181` | https://github.com/spegel-org/spegel/releases/download/v0.8.1/spegel_0.8.1_checksums.txt |
| Upstream Dockerfile (commit 7e2e042) | `FROM gcr.io/distroless/static:nonroot`; `ARG TARGETOS`, `ARG TARGETARCH`; `COPY ./dist/spegel_${TARGETOS}_${TARGETARCH}/spegel /`; `ENTRYPOINT ["/spegel"]`; `USER root:root`; no EXPOSE, VOLUME or ENV | https://raw.githubusercontent.com/spegel-org/spegel/7e2e042/Dockerfile |
| Env vars | none in the upstream Dockerfile. CLI flags not fetched: UNVERIFIED | — |
| Ports | UNVERIFIED: 5000, 9090, 5001 are inferred in the draft and not in fetched files | — |
| arm64 | available (release asset). Draft notes it is not tested on arm64 hosts | release assets, draft.md |

Upstream Dockerfile reviewed: yes. Checksum source: `spegel_0.8.1_checksums.txt`.

## 2. Target layout

- `apps/spegel/Dockerfile`
- `apps/spegel/docker-bake.hcl`
- `apps/spegel/settings.yaml`
- `apps/spegel/container-test.yaml`
- `apps/spegel/start.sh`

No `defaults/` or `etc/` are expected. Do not use `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`
- Why: the upstream image is distroless static, and the binary is a static Go binary. Our rules say runtime stages use ubuntu unless a language base is needed, and a static Go binary needs no runtime beyond ubuntu. A Go build stage is not needed because the release tarball is prebuilt.
- Closest sibling: `apps/adguardhome-sync` (prebuilt binary on ubuntu).

## 4. Dockerfile

1. `ARG VERSION=0.8.1`, `ARG TARGETARCH`. Map `TARGETARCH` to the release name (`amd64`, `arm64`, `arm` for armv7 if supported; confirm the list before enabling arm).
2. Download `https://github.com/spegel-org/spegel/releases/download/v${VERSION}/spegel_${VERSION}_linux_${TARGETARCH}.tar.gz`. Verify it against `spegel_${VERSION}_checksums.txt` with `sha256sum -c` on the matching line. Fail the build on mismatch. Keep the checksum file's values as build-time inputs, or fetch the checksums file and check the line for the arch.
3. `USER root` only for the download and extract. Extract to `/app/` (for example `/app/spegel`).
4. Ship the license text to `/usr/share/licenses/spegel/` if the tarball includes one (UNVERIFIED).
5. ENV: `TMPDIR=/tmp`. No other env is known.
6. `COPY --chmod=0755 . /`
7. `EXPOSE` the confirmed ports only (none confirmed yet; see section 10). `VOLUME` not declared (the node-level paths are host-mounted in the chart and are not ours).
8. `USER apps`, `ENTRYPOINT ["/app/spegel"]`.

## 5. docker-bake.hcl

- `APP = "spegel"`, `SOURCE = "https://github.com/spegel-org/spegel"`, `LICENSE` UNVERIFIED until the upstream license is confirmed.
- `variable "VERSION"` default `"0.8.1"` with the renovate comment: `// renovate: datasource=github-releases depName=spegel-org/spegel versioning=semver`.
- Four standard targets and `group "default" { targets = ["image-local"] }`. `image-all` builds amd64 and arm64 (arm64 is a release asset, but it is untested on arm64 hosts).
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: https://github.com/spegel-org/spegel`.
- `ports`: UNVERIFIED. Only add ports confirmed from the spegel CLI flags or docs (not fetched). Until then, the port list is empty.
- `env`: none confirmed. Do not invent env vars.
- `volumes`: none. Spegel's containerd paths are host paths in the chart and are not part of this image.
- `dependencies`: none.

## 7. start.sh

- The upstream image is the bare binary with ENTRYPOINT. A start.sh is only needed if we add config seeding. Given no confirmed config path, decide in step 1 whether a start.sh is needed; if not, skip it and document in section 10.
- If written: idempotent, no writes to `/app`, `exec /app/spegel` with the arguments from the flags confirmed by the spegel docs (UNVERIFIED).

## 8. container-test.yaml

- forgetool schema header from a sibling app.
- `filePaths`: `/app/spegel` (exists and is executable).
- No `tcp` or `http` probe is possible until the ports are confirmed. Do not invent a probe.
- `timeoutSeconds`: from a sibling of the same startup profile.
- Tests run with no env vars and no containerd, so the binary's real behavior (serving the mirror, metrics) is not tested here. Say so in a comment.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behavior | Remap |
| --- | --- |
| `USER root:root` in upstream Dockerfile | `USER apps`. Check whether spegel needs root to read the containerd socket (it does in the chart via hostPath, see section 10) |
| containerd socket hostPath (chart) | not part of the image. The DaemonSet host access is a deployment concern and is outside the image |
| containerd content dir and registry config dir (chart hostPath) | not part of the image; these must be mounted by the deployer |
| `/app` read-only | binary stays in `/app`, which is fine because nothing is written there at runtime |

Draft security expectations to reconcile: upstream runAsUser 0, readOnlyRootFilesystem false, privileged not set, hostPath access. The target runs as `apps`, read-only rootfs. Host access (containerd socket, host config dirs) cannot be satisfied by a rootless read-only image. This is the main blocker.

## 10. Risks, caveats and open questions

- Blocker: spegel is a node-level DaemonSet that writes containerd registry config and needs the containerd socket via hostPath. A rootless, read-only image cannot do this inside the container. The deployer must provide the hostPath mounts and possibly root. Decide with the user whether this container should exist at all in ContainerForge.
- Caveat: standalone spegel does nothing useful without a containerd cluster and per-node mirror config (inferred in the draft).
- UNVERIFIED: ports (5000, 9090, 5001), CLI flags, env vars, license, and whether a config file is needed.
- arm64 is a release asset but untested on arm64 hosts (draft). Build it, but do not claim arm64 support until tested.
- Checksum verification is available (checksums file), so it is not a risk.

## 11. Build and test steps

1. `cd apps/spegel && docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name spegel-probe --read-only --tmpfs /tmp -v spegel-probe-config:/config <image>:0.8.1`
4. `docker logs -f spegel-probe`. Expected signal: the process stays up and logs its startup line (UNVERIFIED). Without containerd it may exit with an error. That would be a real finding, not a build error. Record it and decide with the user before changing assertions.
5. `forgetool containers test --image <image>:0.8.1 --config ./apps/spegel/container-test.yaml`
6. Clean up: `docker rm -f spegel-probe; docker volume rm spegel-probe-config`.

## 12. PR checklist

- Branch `feat/add-spegel`, commit `feat(spegel): add new container`, target `main`.
- PR template from `.github/PULL_REQUEST_TEMPLATE.md`. Only check boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- State what was not tested: containerd integration, the mirror behavior, arm64 hosts, and every UNVERIFIED item above.
