# tdarr — implementation plan
> Source: ./draft.md · Target: apps/tdarr/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 3.09.00 (latest release per GitHub API, published 2026-11-22). Source: https://api.github.com/repos/HaveAGitGat/Tdarr/releases/latest . The chart pins `ghcr.io/haveagitgat/tdarr:3.08.00`, one version behind. |
| Renovate | `datasource=github-releases depName=HaveAGitGat/Tdarr versioning=semver` (best judgement; no renovate config checked for this app). |
| License | UNVERIFIED: GitHub API reports `NOASSERTION` (not detected automatically). Read the LICENSE file in https://github.com/HaveAGitGat/Tdarr before setting `LICENSE` in docker-bake.hcl. |
| Source URL | https://github.com/HaveAGitGat/Tdarr |
| Download | Not on GitHub. Upstream Dockerfile.final downloads the module zip from a Backblaze bucket: `BASE_LINK="https://tdarrs.s3.us-west-000.backblazeb2.com/dev/versions/$VERSION"`, then `/$MODULE` zip per arch (`linux_x64`, `linux_arm64`, `linux_arm`). UNVERIFIED: the exact per-arch zip filenames and that 3.09.00 exists in that bucket. tdarr.io/downloads did not expose links when fetched. |
| Checksum source | None. Upstream Dockerfile.final performs no checksum or signature check (https://raw.githubusercontent.com/HaveAGitGat/Tdarr/9ec31178f6807861c207f8a65a1b8156e46c5b85/docker/Dockerfile.final). |
| Upstream Dockerfile reviewed | Dockerfile.final: `FROM docker.io/haveagitgat/tdarr_acc:base_${VERSION}_${DATE}`; build args VERSION, DATE, MODULE (Tdarr_Server or Tdarr_Node); apt installs curl, unzip, mkvtoolnix, libtesseract-dev; downloads to `/app/$MODULE` (and `/app/Tdarr_Node` for the server); runs the binaries' built-in tests on `/app_test` then deletes it; `ENV WEB_UI_PORT=8265 SERVER_PORT=8266 NODE_PORT=8267 PUID=1000 PGID=1000 UMASK=002 TZ=Etc/UTC HOME=/home/Tdarr inContainer=true`; `EXPOSE ${NODE_PORT} ${WEB_UI_PORT} ${SERVER_PORT}`; `ENTRYPOINT ["/init"]`; no CMD, no USER, no VOLUME. |
| Base image reviewed | https://raw.githubusercontent.com/HaveAGitGat/Tdarr/master/docker/Dockerfile.base : `FROM lsiobase/ubuntu:jammy` (LinuxServer.io, Ubuntu 22.04). Installs ffmpeg (jellyfin-ffmpeg 6 on x86, Ubuntu repo ffmpeg on arm), HandBrakeCLI (built from source on x86, Ubuntu repo on arm), mkvtoolnix, CCExtractor (git commit pin `35e73c1c90ce3ca69394d3523836bb1cdec28f11`), Intel GPU drivers on x86 only. Runs as root, user creation commented out. No checksums on downloads. |
| Ports | 8265 (web UI), 8266 (server), 8267 (node, from ENV NODE_PORT). Compose example publishes 8265 and 8266; node has no own port with `network_mode: service:tdarr`. Source: https://docs.tdarr.io/docs/installation/docker/run-compose |
| Env vars (compose example) | TZ, PUID, PGID, UMASK=002, serverIP, serverPort=8266, webUIPort=8265, internalNode=true, inContainer=true, ffmpegVersion=7, nodeName, auth, apiKey, openBrowser, maxLogSizeMB, cronPluginUpdate, NVIDIA_DRIVER_CAPABILITIES, NVIDIA_VISIBLE_DEVICES. Source: same compose page. The Dockerfile sets WEB_UI_PORT, SERVER_PORT, NODE_PORT, PUID, PGID, UMASK, TZ, HOME. |
| Volumes (compose) | `/app/server` (server only), `/app/configs`, `/app/logs`, `/media`, `/temp` (transcode cache). Server and node must share `/media` and `/temp`. |
| Write paths | `/app/configs`, `/app/logs`, `/app/server`, `/temp`, `/home/Tdarr` (HOME), all from the compose and base Dockerfile. |
| arm64 | Supported in the upstream build path: Dockerfile.final selects `linux_arm64` for aarch64 and `linux_arm` for armv7l. UNVERIFIED: the published `ghcr.io/haveagitgat/tdarr` manifest platforms were not checked. |
| copy-from | Not usable as draft suggests. `COPY --from=ghcr.io/haveagitgat/tdarr:3.08.00` would copy a jammy/LinuxServer-based tree with its own init. Build from the Backblaze zip instead (section 4). |

## 2. Target layout

- `apps/tdarr/Dockerfile`
- `apps/tdarr/docker-bake.hcl`
- `apps/tdarr/settings.yaml`
- `apps/tdarr/container-test.yaml`
- `apps/tdarr/start.sh` (starts the server and, for the single image, the internal node)
- `apps/tdarr/defaults/` only if a shipped config template is needed (UNVERIFIED; the zip may create its own configs in `/app/configs`).
- No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Fits because the draft assigned the ubuntu base, and the upstream LinuxServer base (jammy, root + s6) is not reused. This means the ffmpeg, HandBrake and mkvtoolnix stack is reinstalled from Ubuntu 26.04 packages, not copied from upstream. UNVERIFIED: that `ffmpeg`, `handbrake-cli`, `mkvtoolnix` and `libtesseract-dev` exist in the 26.04 archive; check with `apt-cache policy` in the build. The jellyfin-ffmpeg 6 and HandBrake-from-git builds on x86 are not reproduced in the first pass; record that gap in section 10.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `apt-get install -y --no-install-recommends curl unzip ffmpeg handbrake-cli mkvtoolnix libtesseract-dev` (UNVERIFIED package names), then `rm -rf /var/lib/apt/lists/*`.
3. Map `TARGETARCH` to the upstream names: `amd64` to `linux_x64`, `arm64` to `linux_arm64`. Skip `arm` (armv7) unless the build matrix includes it.
4. Download and extract:
   `curl -fL -o /tmp/Tdarr_Server.zip "https://tdarrs.s3.us-west-000.backblazeb2.com/dev/versions/${VERSION}/<zip-name>"` (zip name UNVERIFIED), then `unzip` into `/app/Tdarr_Server` and `/app/Tdarr_Node`, excluding `*.exe`.
   Record the sha256 of each zip in the Dockerfile at build time; no upstream checksum exists.
5. Do not copy upstream's in-build test run unless it is cheap; if kept, run it against a copy in `/tmp`, never against `/app`.
6. Ensure the binaries are executable: `chmod -R 755 /app/Tdarr_Server /app/Tdarr_Node`.
7. License: `/usr/share/licenses/tdarr/LICENSE` from the upstream repo (see section 1, NOASSERTION caveat).
8. `ENV WEB_UI_PORT=8265 SERVER_PORT=8266 NODE_PORT=8267 UMASK=002 TZ=Etc/UTC HOME=/tmp/home inContainer=true`. Keep PUID/PGID out of the image: `apps` is the runtime user here, so the LinuxServer PUID mapping is not carried over.
9. Tail: `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8265 8266 8267`, `VOLUME /config` (see section 7 for paths), `WORKDIR /app/Tdarr_Server`.

## 5. docker-bake.hcl

- `APP = "tdarr"`, `LICENSE` set from the upstream LICENSE file (NOASSERTION, see section 1), `SOURCE = "https://github.com/HaveAGitGat/Tdarr"`.
- `VERSION` default `"3.09.00"` with `// renovate: datasource=github-releases depName=HaveAGitGat/Tdarr versioning=semver`.
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64, arm64), `group "default"`.
- Validate with `docker buildx bake --print` in `apps/tdarr`.

## 6. settings.yaml

- Schema header and `schema_version: 1`.
- `upstream_env_url: "https://github.com/HaveAGitGat/Tdarr"`.
- `ports`: 8265 (web UI, required), 8266 (server, required), 8267 (node, required: false unless the single image runs the internal node; decide in section 10).
- `env`: `TZ` (default `Etc/UTC`), `UMASK` (default `002`), `webUIPort` (8265), `serverPort` (8266), `internalNode` (default `true`), `nodeName` (default `InternalNode`), `inContainer` (default `true`), `ffmpegVersion` (default `7`, only if the app reads it; UNVERIFIED). Do not list `PUID`/`PGID`, since they are not honoured in this image.
- `volumes`: `/config` (`required: true`), and `/media` and `/temp` as needed (`/media` is a media mount, not a ContainerForge volume, so it is listed only if the schema allows it).
- `dependencies`: none.

## 7. start.sh

1. Seed `/config` only when missing: create `/config/configs`, `/config/logs`, `/config/server` if absent, and point the app at them with the env or config knob found in the source (UNVERIFIED).
2. Create `/tmp/home` and `/temp` as writable scratch (transcode cache sits under `/temp`; the chart mounts it, so keep `/temp` as the cache path).
3. Start the server in the foreground: `exec /app/Tdarr_Server/Tdarr_Server` (binary name UNVERIFIED), and start the internal node only if `internalNode=true`, using `exec` for the last process.
4. Read config only from the env vars in settings.yaml, with defaults matching the upstream compose example.

## 8. container-test.yaml

- Schema header copied from the sibling.
- `tcp` probes: 8265 (web UI) and 8266 (server). If the node port is in settings.yaml with `required: true`, add 8267.
- `http` probe on `/` on 8265 (UNVERIFIED that it returns 200 without auth; compose sets `auth=true`, so assert the redirect or 401 and say so in a comment).
- `timeoutSeconds`: take the value from the closest sibling with a large service (UNVERIFIED sibling).
- `filePaths`: `/app/Tdarr_Server` binary and `/config/configs`.
- Test runs with no env vars, so `internalNode` and GPU paths are not exercised. The GPU variant is out of scope.
- No DB dependency, so the narrowing exception does not apply.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root with PUID/PGID mapping (LinuxServer s6). Here the container runs as `apps`, so all writes go to `/config` or `/tmp`. Verify that ports 8265, 8266, 8267 are above 1024 (they are).
- `/app` stays read-only at runtime. The upstream `/app/configs`, `/app/logs`, `/app/server` become `/config/configs`, `/config/logs`, `/config/server` through the knobs found in section 7.
- `/temp` (transcode cache) and `HOME` go to `/tmp`, unless the transcode cache must persist, in which case it needs a `/config` path and the PR must say why.
- No privileged, no GPU device mapping in the base image. The draft's security expectations (runAsUser 0, readOnlyRootFilesystem false, extra persistence) describe the TrueCharts chart, not this image.

## 10. Risks, caveats and open questions

- UNVERIFIED: the exact Backblaze zip names per arch and whether 3.09.00 is published there. The fetched `tdarr.io/downloads` page had no links.
- UNVERIFIED: whether the upstream dev path (`/dev/versions/`) is the stable one. The Dockerfile uses it, so the stable URL may differ.
- UNVERIFIED: Ubuntu 26.04 package names for ffmpeg, handbrake-cli, mkvtoolnix, libtesseract-dev.
- Gap: x86 uses jellyfin-ffmpeg 6, HandBrake built from source, and Intel GPU drivers. This first pass drops them unless the test shows they are needed.
- UNVERIFIED: license (NOASSERTION from GitHub). Do not set LICENSE until the LICENSE file is read.
- Caveat: no checksum is published; the build relies on HTTPS to the bucket.
- Caveat: transcoding needs CPU or GPU headroom and scratch space in `/temp`.
- Caveat: plugin and ffmpeg downloads may happen at runtime, so an offline host can fail on first use (draft, inferred).
- Blockers: several processes (server, internal node, ffmpeg, HandBrake) from one image, and the upstream image runs as root with s6. Rootless needs the process layout and the write-path remap above. Not a musl or privileged blocker.

## 11. Build and test steps

```sh
cd apps/tdarr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker rm -f tdarr-probe 2>/dev/null; docker volume rm tdarr-probe-config 2>/dev/null
docker run --rm -d --name tdarr-probe --read-only --tmpfs /tmp \
  -v tdarr-probe-config:/config tdarr:3.09.00
docker logs -f tdarr-probe
forgetool containers test --image tdarr:3.09.00 --config ./apps/tdarr/container-test.yaml
docker rm -f tdarr-probe; docker volume rm tdarr-probe-config
```

- Expected readiness signal: the server logs that the web UI and server ports are listening (8265, 8266). The exact line is UNVERIFIED until the first build.
- Empty `/config` start must be tested on a fresh volume.
- The upstream in-build test run, if kept, is the closest thing to a functional check for the binaries.

## 12. PR checklist

- Branch `feat/add-tdarr`, commit `feat(tdarr): add new container`, PR title matches.
- PR body uses `.github/PULL_REQUEST_TEMPLATE.md`, keeps its sections and checkboxes, and only ticks the boxes that apply.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge . Only the user can sign it.
- Say what was not tested (arm64, GPU, transcoding, the Backblaze URL shape, the UNVERIFIED items above, and any dropped x86 tooling). Do not tick "Built container locally" unless the build ran.
