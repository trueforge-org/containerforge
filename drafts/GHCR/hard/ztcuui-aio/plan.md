# ztcuui-aio — implementation plan
> Source: ./draft.md · Target: apps/ztcuui-aio/ · Difficulty: hard · Role: main · Verified on 2026-11-25

Recommendation up front: this container is a poor port candidate. Upstream is archived, its last release is 2024, its base is Debian bullseye (end of life), it runs root with two supervised services under s6, and it needs `/dev/net/tun`. The plan below is the path if the user still wants it.

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest tag | v2024.1.28-r1, published 2024-01-28 (draft matches) | https://api.github.com/repos/kmahyyg/ztncui-aio/releases/tags/v2024.1.28-r1 |
| Repo status | archived: true | https://api.github.com/repos/kmahyyg/ztncui-aio |
| Renovate | datasource=github-releases depName=kmahyyg/ztncui-aio versioning=loose (renovate config not checked) | UNVERIFIED: not fetched |
| License | GPL-3.0 | https://api.github.com/repos/kmahyyg/ztncui-aio |
| amd64 asset | https://github.com/kmahyyg/ztncui-aio/releases/download/v2024.1.28-r1/ztncui-aio-x86_64.tar.zst | GitHub API |
| arm64 asset | https://github.com/kmahyyg/ztncui-aio/releases/download/v2024.1.28-r1/ztncui-aio-aarch64.tar.zst | GitHub API |
| Checksum source | UNVERIFIED: no checksum asset seen | — |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/kmahyyg/ztncui-aio/v2024.1.28-r1/Dockerfile | fetched |

Upstream Dockerfile summary:
- Stages: `jsbuilder` on `debian:bullseye-slim` (Node 18 via nodesource, runs `build-ztncui.sh`); `gobuilder` on `golang:bullseye` (`CGO_ENABLED=0`, `build-gobinaries.sh` builds `argon2g`, `fileserv`, `ztnodeid`); `runner` on `debian:bullseye-slim`.
- Runner installs s6-overlay v3.1.3.0 (noarch plus `$OVERLAY_S6_ARCH`, not set by default in the file), creates the `zerotier-one` user and group with UID/GID 2222, and runs the ZeroTier installer.
- `ENV DEBIAN_FRONTEND=noninteractive`, `ENV AUTOGEN_PLANET=0`.
- `EXPOSE 3000/tcp 3180/tcp 8000/tcp 3443/tcp`.
- `VOLUME /opt/key-networks/ztncui/etc /etc/zt-mkworld /var/lib/zerotier-one`.
- `ENTRYPOINT ["/init"]` (s6). No USER (root).

Ports: the draft's 3443 (web UI) and 9993/udp (ZeroTier) — 3443 is confirmed on EXPOSE; 9993/udp is UNVERIFIED (not in EXPOSE, ZeroTier default per draft). Real env vars beyond `AUTOGEN_PLANET`: UNVERIFIED.

## 2. Target layout

Files in `apps/ztcuui-aio/`:
- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`: required.
- `root/` must not be used.
- `defaults/`: seed config for `/opt/key-networks/ztncui/etc` only if needed.
- `etc/s6-overlay/` service tree: needed only if the s6 layout is kept (see section 4). Reason: two supervised services.
- No `DOWNSTREAM_CHANGES.md`; not a `FROM` base.

## 3. Base image

- Draft proposes `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` with the ubuntu alternative.
- Preferred: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`, because the zerotier daemon and Node are both needed and python is unused. Node is then installed from the release tarball or apt under root in a build stage.
- Closest sibling: none confirmed (`apps/changedetection`, `apps/budge` use python-node). UNVERIFIED.

## 4. Dockerfile

Use the prebuilt release tarball (`.tar.zst`), not the upstream build, since the release is for both arches and avoids rebuilding Go and Node.

1. `ARG VERSION`, `ARG TARGETARCH`. Map `amd64` to `x86_64` and `arm64` to `aarch64` for the asset name.
2. Download the tarball to `/tmp`. Extract with `zstd -d` and `tar -x` to a `/tmp` staging directory. UNVERIFIED: tarball layout; inspect after the first download.
3. Copy the web UI tree to `/opt/key-networks/ztncui` and the Go helper binaries to `/usr/local/bin` (chmod 0755).
4. Install zerotier-one from apt under `USER root` in the build stage, pinned to a version (check against VERSION and the release date). Do not install on top of an existing base package.
5. Ship license notices for ztncui and zerotier to `/usr/share/licenses/ztcuui-aio/`.
6. `ENV HOME=/config`, `ENV TMPDIR=/tmp`.
7. Move state to `/config`: symlink or env to redirect `/var/lib/zerotier-one`, `/etc/zt-mkworld`, and `/opt/key-networks/ztncui/etc` under `/config`. UNVERIFIED: the app honors these paths via env or only via fixed paths. This is the largest open risk.
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3443`, `VOLUME /config`. This holds only if zerotier-one can run unprivileged without TUN; otherwise see section 9 (UNVERIFIED, likely a needs-human decision).

Do not run s6 as `apps`. s6 needs root to start services. If s6 is kept, the container runs as root, which breaks the rootless rule. See section 9.

## 5. docker-bake.hcl

- `APP`: `ztcuui-aio`.
- `VERSION`: `// renovate: datasource=github-releases depName=kmahyyg/ztncui-aio versioning=loose` and `default = "2024.1.28-r1"`. Strip the `v` in asset URLs if needed.
- `LICENSE`: `GPL-3.0`.
- `SOURCE`: `https://github.com/kmahyyg/ztncui-aio`.
- Standard targets and group `default` with `image-local`.
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/kmahyyg/ztncui-aio"`.
- `ports`: 3443/tcp (`required: true`). 9993/udp only if confirmed. Other EXPOSE ports (3000, 3180, 8000) are UNVERIFIED for this app's purpose; list only those the app uses.
- `env`: `TZ` only. Add `AUTOGEN_PLANET` only if `start.sh` honors it. Do not invent others.
- `volumes`: `/config` (`required: true`). Note: the draft's three paths map to subpaths of `/config`.
- `dependencies`: none.

## 7. start.sh

- Idempotent: create `/config/zerotier-one`, `/config/zt-mkworld`, `/config/ztncui-etc` only when missing.
- Seed the ztncui config only when `/config/ztncui-etc` is empty.
- Never write to `/app` or `/opt/key-networks` at runtime except through `/config` links.
- Start the zerotier daemon, then the web UI, as `exec` of the final process. If two services are needed, the script must run a supervisor. UNVERIFIED: whether s6 is required.
- Listen on `0.0.0.0` for the web UI. Check the ztncui config default.

## 8. container-test.yaml

- forgetool schema header.
- `tcp: - port: '3443'` (the port serves HTTPS; a tcp probe suffices, an http probe would need TLS support), with `timeoutSeconds` from a sibling.
- The test runs without `/dev/net/tun`. ZeroTier may not start. The test must not rely on the daemon. If the daemon is required for the web UI to answer, the test is an honest failure, which is a finding, not a reason to weaken it. Report it to the user.
- `filePaths`: `/opt/key-networks/ztncui` and `/usr/local/bin` helpers if the schema allows.

## 9. Rootless and read-only-rootfs adaptations

- Blocker: zerotier-one needs `/dev/net/tun` and `CAP_NET_ADMIN`. Rootless `apps` cannot create the TUN device. Run as root only if the chart grants `NET_ADMIN` and the device. This conflicts with the USER apps rule, so this app cannot meet the rootless rule as written.
- Read-only rootfs: the zerotier state and ztncui config must live in `/config`. Feasible only if the paths are relocatable (section 4, step 7).
- Upstream runs as root with s6. Our image should keep s6 only if the process model needs supervision. Otherwise, run one service and document the other as external.
- Chart expectations (root, extra persistence on three paths, NET_ADMIN/CHOWN-type caps) are the chart's job. The image must not hard-code caps.

## 10. Risks, caveats and open questions

- Archived upstream repository, last release January 2024. Consider not porting, or porting only after checking for a maintained fork.
- Debian bullseye base in upstream is end of life. Our Ubuntu base changes the Go and Node stack; the release tarball avoids rebuilding but the binaries must run on glibc Ubuntu 26.04. Verify.
- Three persistent state paths. Losing them loses the ZeroTier identity and network config.
- `/dev/net/tun` and root-level network access.
- Port 9993/udp and the other EXPOSE ports UNVERIFIED for purpose.
- Checksums of release assets not published.
- arm64 asset exists but was not run.

## 11. Build and test steps

From `apps/ztcuui-aio/`, per the build-test protocol:
1. `docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name ztcuui-aio-probe --read-only --tmpfs /tmp --tmpfs /run --cap-add NET_ADMIN --device /dev/net/tun -v ztcuui-aio-probe-config:/config ztcuui-aio:2024.1.28-r1` (flags are a starting point; confirm they are needed). Expected readiness: web UI listening on 3443. Confirm the line after the first run.
4. `forgetool containers test --image ztcuui-aio:2024.1.28-r1 --config ./container-test.yaml`.
5. Clean up: `docker rm -f ztcuui-aio-probe; docker volume rm ztcuui-aio-probe-config`.
6. arm64 build only if amd64 fails for an arm64 reason.

## 12. PR checklist

- Branch `feat/add-ztcuui-aio`, commit `feat(ztcuui-aio): add new container`, target `main`.
- Title: `feat(ztcuui-aio): add new container`.
- PR description from `.github/PULL_REQUEST_TEMPLATE.md`, keeping sections and checkboxes. Check only the boxes that apply.
- Notes: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Untested list: every build and probe step not run; TUN and NET_ADMIN behaviour; relocatable state paths; arm64; the archived upstream status.
