# rflood — implementation plan
> Source: ./draft.md · Target: apps/rflood/ · Difficulty: hard · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Chart image | `ghcr.io/hotio/rflood:latest@sha256:92e3c258699714bae99c7471ccf256ef03afb085b1e05fe7cfbc0a3b0c806acb` (unpinned tag) | https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rflood/values.yaml |
| Latest stable version | hotio publishes `release-0.16.29`-style tags (https://hotio.dev/containers/rflood, modified 2026-11-26); latest rtorrent release is `v0.16.29` (GitHub releases HTML). The hotio image's VERSION build arg is not in the fetched Dockerfile. | upstream Dockerfile |
| Renovate | `UNVERIFIED`: no version to track. Pin a rtorrent version and a flood release (see section 4) and use `datasource=github-releases` for each | n/a |
| SPDX license (rtorrent) | GPL-2.0 | https://api.github.com/repos/rakshasa/rtorrent |
| SPDX license (image, flood) | `UNVERIFIED`: flood and hotio licenses not fetched. Set `LICENSE` only after reading the flood repo `LICENSE` at the chosen tag | n/a |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/hotio/rflood/194a3cbe1452/linux-amd64.Dockerfile | fetched |
| Upstream base | `FROM ${UPSTREAM_IMAGE}:${UPSTREAM_TAG_SHA}`, a hotio Alpine (musl) base; not glibc, so it cannot be reused | same Dockerfile |
| Build (rtorrent) | Builder: `apk add build-base linux-headers curl-dev ncurses-dev tinyxml2-dev`; builds `libtorrent-${VERSION}` and `rtorrent-${VERSION}` from `github.com/rakshasa/rtorrent` release tarballs, `--disable-shared --enable-static --enable-aligned`, rtorrent with `--with-xmlrpc-tinyxml2`; `-O3 -flto` | same Dockerfile |
| Final packages (upstream) | `xmlrpc-c-tools nginx openssl mediainfo` (apk) | same Dockerfile |
| Flood binary | `https://github.com/jesec/flood/releases/download/v${VERSION_FLOOD}/flood-linux-x64` to `${APP_DIR}/flood` (prebuilt, not Node at runtime) | same Dockerfile |
| Env vars (upstream) | `IMAGE_STATS`, `FLOOD_AUTH="false"`, `WEBUI_PORTS="3000/tcp"` | same Dockerfile |
| Ports | EXPOSE 3000 (flood web UI); chart `main` port 3000 http. The draft's BitTorrent 6881 TCP/UDP is not in the chart values or the upstream Dockerfile; `UNVERIFIED` | upstream Dockerfile, chart values |
| Config path (chart) | `/config`, enabled | chart values |
| Upstream write paths | `CONFIG_DIR` and `APP_DIR` are used but not defined in this file (defined by the hotio base, `UNVERIFIED`) | upstream Dockerfile |
| Chart security | runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false | chart values |
| Dependencies | None in the chart. Sibling `apps/flood` exists (flood binary, `/app/flood`) | chart values, repo listing |

## 2. Target layout

Files under `apps/rflood/`:

- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`: required
- `defaults/`: only if a seed rtorrent config is shipped (default: not needed, as `start.sh` writes to `/config` only)
- `etc/`: only if an nginx or s6 config is needed (see section 4 step 7). Reason to add it: the upstream image supervises two processes
- `root/`: never used
- `DOWNSTREAM_CHANGES.md`: not needed

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`
- Reason: the upstream base is musl (hotio Alpine). rtorrent is built or installed on glibc ubuntu. `ghcr.io/trueforge-org/python-node` is not needed: flood is a prebuilt binary, so Node is not a runtime dependency. The draft's "alternative runtime image" is not required for this plan.
- Closest sibling: `apps/flood` (same flood binary from the same release URL pattern; reuse its `USER apps` and `COPY --chmod=0755 . /` layout).

## 4. Dockerfile

Step list:

1. `ARG VERSION` (flood release tag), `ARG RTORRENT_VERSION`, `ARG TARGETARCH`; `USER root`.
2. Install rtorrent. First choice: apt package `rtorrent` on the ubuntu base, pinned as `rtorrent=<version>` and checked against `RTORRENT_VERSION` (per the dockerfile rule). `UNVERIFIED`: the Ubuntu 26.04 `rtorrent` package version and whether it matches the hotio build. Fallback: build from the rtorrent and libtorrent release tarballs in a separate build stage (`FROM ghcr.io/trueforge-org/ubuntu:...`), then `COPY --from=build /usr/local/bin/rtorrent /usr/local/bin/rtorrent`. Do not compile in the runtime stage.
3. Install runtime packages: `nginx`, `openssl`, `mediainfo` (apt, pinned where the version matters), `xmlrpc-c` tools only if rtorrent needs them (`UNVERIFIED`). Do not install what the base already has. Cleanup `rm -rf /var/lib/apt/lists/*`.
4. Flood: `curl -fsSL "https://github.com/jesec/flood/releases/download/v${VERSION}/flood-linux-x64" -o /app/flood`, `chmod 755`, then verify the checksum. `UNVERIFIED`: flood publishes no checksum file in the fetched data; pin a self-computed SHA256 and note it.
5. License: copy the rtorrent `COPYING` (GPL-2.0) and the flood `LICENSE` to `/usr/share/licenses/rflood/`.
6. `chown -R apps:apps /app && chmod -R 755 /app`.
7. Process supervision: the upstream image uses s6-overlay (`root/etc/s6-overlay/s6-rc.d`). Two long-running processes (rtorrent and flood) need either s6 service dirs under `etc/` (`COPY --chmod=0755 . /` ships them) or a `start.sh` that starts both and `wait`s. Prefer s6 only if the base has s6; otherwise run flood as the `exec` target and start rtorrent in the background with a readiness wait. `UNVERIFIED`: whether `apps/flood` or another sibling already does this.
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3000`, `VOLUME /config`.

Do not copy from `hotio/rflood`: its image is musl and `COPY --from` of rtorrent would not run on glibc.

## 5. docker-bake.hcl

Same layout as `apps/adguardhome-sync/docker-bake.hcl`, with:

- `APP` = `rflood`
- `VERSION` = the flood release tag to pin (not yet picked). Renovate: `// renovate: datasource=github-releases depName=jesec/flood versioning=semver`
- A second variable `RTORRENT_VERSION` with `// renovate: datasource=github-releases depName=rakshasa/rtorrent versioning=semver`. Pick a version that exists in both the Ubuntu package and the upstream release, `UNVERIFIED`.
- `LICENSE` = the license of what ships. `GPL-2.0-only` is `UNVERIFIED` for the combined image; confirm on the flood repo.
- `SOURCE` = `https://github.com/rakshasa/rtorrent` (the draft's source) and note flood at `https://github.com/jesec/flood` in the PR.

Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Header and `schema_version: 1`, `upstream_env_url: "https://github.com/rakshasa/rtorrent"`.
- `ports`: `3000` tcp required true. Do not list 6881 yet: it is not confirmed by upstream (`UNVERIFIED`). If rtorrent peer ports are confirmed, add `6881` tcp and udp with `required: false` and a matching probe.
- `env`: `TZ` default `Etc/UTC`; `FLOOD_AUTH` default `false` (the upstream value); `UMASK` default `002` (sibling convention, check the flood sibling).
- `volumes`: `/config` `required: true`.
- `dependencies`: none. Note `apps/flood` as a related sibling only.

## 7. start.sh

- Idempotent. Create `/config/rtorrent`, `/config/flood` only when missing. Never write to `/app`.
- Seed a default `.rtorrent.rc` into `/config` with `cp -n` only if missing.
- Start rtorrent in the background (or via s6) with its session directory in `/config`, then `exec /app/flood` with the port and `--rundir`/`--auth` values from env. `FLOOD_AUTH=false` is set as in upstream.
- Bind flood to `0.0.0.0:3000` (other containers connect to it).
- The final long-running process is `exec`'d so signals reach it. If both run under s6, `start.sh` is not the supervisor.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '3000'
http:
- port: '3000'
  path: /
runners:
- entrypoint: /app/flood --help
```

- Every port in `settings.yaml` needs a probe. Only 3000 is listed until 6881 is confirmed.
- `timeoutSeconds` is set from the flood sibling (check its value; the sibling file has no timeout, so `UNVERIFIED` and default to the forgetool default).
- rtorrent is not started by the test runner unless `start.sh` is the entrypoint. Add an rtorrent `--version` runner if the binary is on `PATH` (`UNVERIFIED`).

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps`. Port 3000 is above 1024, so no root is needed.
- The chart runs as root (uid 0, gid 0). Rootless replaces that: `USER apps` only.
- Writes: `/config` (rtorrent session, flood data) and `/tmp` (scratch). Nothing under `/app`.
- The nginx in the upstream image is not needed if flood serves the UI itself. Drop it unless flood needs it (`UNVERIFIED`), since nginx writes to `/var/log` and `/var/cache`, which must go to `/tmp` for a read-only rootfs.
- The draft expected the BitTorrent port to be reachable; `UNVERIFIED`. Peers need a listen port to be reachable from outside.

## 10. Risks, caveats and open questions

- Blocker-level risk: running two processes (rtorrent and flood) under a rootless, read-only layout is the main work (section 4 step 7).
- The `latest` tag in the chart is unpinned, so the port must pin a release. Behaviour otherwise changes between pulls (upstream status).
- `UNVERIFIED`: the rtorrent version available on Ubuntu 26.04 and its compatibility with the flood release.
- `UNVERIFIED`: BitTorrent ports 6881 TCP/UDP. The draft has them, the chart and upstream do not.
- Checksums: no upstream checksum for the flood binary was found; pin a self-computed value and call it out.
- arm64: rtorrent via apt is likely available on arm64, but the flood asset URL is `flood-linux-x64`; there is no arm64 asset in the URL pattern. `UNVERIFIED`. Mark arm64 as unsupported until a `flood-linux-arm64` asset is confirmed.

## 11. Build and test steps

```sh
cd apps/rflood
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name rflood-probe --read-only --tmpfs /tmp \
  -v rflood-probe-config:/config rflood:<VERSION>
docker logs -f rflood-probe
docker rm -f rflood-probe; docker volume rm rflood-probe-config

forgetool containers test --image rflood:<VERSION> --config ./apps/rflood/container-test.yaml
```

Expected readiness signal: flood logs a line that it is listening on port 3000 (`UNVERIFIED` exact text), and the rtorrent process is still alive. Use an empty `/config` each round.

## 12. PR checklist

- Branch `feat/add-rflood`, commit `feat(rflood): add new container`, target `main`.
- PR title matches the commit.
- PR body uses `.github/PULL_REQUEST_TEMPLATE.md`; Notes has `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what was not tested: arm64, BitTorrent peer ports, the two-process start under read-only rootfs (if not run). Do not tick "Built container locally" unless the build ran.
- Confirm `docker buildx bake --print` ran and scratch resources were removed.
