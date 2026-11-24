# ispy-agent-dvr — implementation plan
> Source: ./draft.md · Target: apps/ispy-agent-dvr/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `8.3.2.0` is what the vendor's download API currently returns (`https://www.ispyconnect.com/api/Agent/DownloadLocation4?platform=Linux64&fromVersion=0` -> `Agent_Linux64_8_3_2_0.zip`; `platform=LinuxARM64` -> `Agent_LinuxARM64_8_3_2_0.zip`). The `Linux64` file returned HTTP 200, 77,815,131 bytes, last-modified 2026-11-24. The draft's TrueCharts tag `7.1.8.0` and the draft's links (`8_2_9_0`) are older. The ARM64 file was named by the API; a HEAD request was not run for it (UNVERIFIED reachable). |
| Renovate | UNVERIFIED / none usable: the vendor has no GitHub releases and the product history page (https://www.ispyconnect.com/producthistory?productid=27) is not a renovate datasource. Plan a `// renovate:` comment only if a custom regex manager is added; otherwise bump `VERSION` by hand and say so in a plain comment. The community Docker image `ispysoftware/agentdvr` (tags `latest`, `stable`, `beta`; first official version `7.9.4.0`) could be tracked with `datasource=docker depName=ispysoftware/agentdvr versioning=loose` as a proxy; UNVERIFIED that its tags equal the zip versions. |
| License | Proprietary, closed-source freeware. SPDX: `LicenseRef-Proprietary`. (The docker repo's GPL-3.0 covers only the Dockerfile.) Redistribution of the vendor zip in a public image: UNVERIFIED, must be checked against the vendor terms; downloading at build time into our image is still redistribution. |
| Source URL | https://www.ispyconnect.com/ (docs: https://www.ispyconnect.com/docs/agent/) |
| Download | amd64 `https://files.ispyconnect.com/downloads/Agent_Linux64_${VERSION//./_}.zip`; arm64 `https://files.ispyconnect.com/downloads/Agent_LinuxARM64_${VERSION//./_}.zip`. Checksum: none published (UNVERIFIED); the HTTP `etag` is not a content hash we can rely on. Record a sha256 per version at implementation time. |
| Upstream Dockerfile reviewed | Draft link `doitandbedone/ispyagentdvr-docker` (7.1.8.0 tag; repo is now archived and points to the official `ispysoftware/agentdvr` image). Its master: ubuntu 22.04; apt `wget unzip software-properties-common alsa-utils apt-transport-https libxext-dev fontconfig libva-drm2`, later `libgdiplus tzdata curl`; `ENV MALLOC_TRIM_THRESHOLD_=100000`; zip unpacked to `/agent`; ffmpeg7 tarball fetched into `/agent/ffmpeg7`; `CMD /agent/Agent`; runs as root. The official README (https://github.com/ispysoftware/agentdvr-docker) uses `/AgentDVR` and bundles FFmpeg 9 (LGPL). |
| Env vars | `TZ`; official image also documents `PUID`, `PGID`, `AGENTDVR_WEBUI_PORT` (internal web UI port). Which of them the app itself reads (vs the image entrypoint): UNVERIFIED. |
| Ports | 8090/tcp web UI; 3478/udp TURN; 50000-50100/udp WebRTC range (both docker READMEs). |
| Data paths | Official: `/AgentDVR/Media/XML` (config, JSON since 5.8.4.0), `/AgentDVR/Media/WebServerRoot/Media` (recordings), `/AgentDVR/Media/Models`, `/AgentDVR/Commands`. Old image: `/agent/...`. |

## 2. Target layout

```
apps/ispy-agent-dvr/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No defaults/ (the app creates its own config on first run). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. .NET self-contained vendor zip, so no language base (draft agrees). Closest siblings: `apps/adguardhome-sync` (prebuilt binary download per `TARGETARCH`) and `apps/hytale` (vendor binary).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Arch map: `case "$TARGETARCH" in amd64) A=Linux64;; arm64) A=LinuxARM64;; *) exit 1;; esac`; `V="${VERSION//./_}"`.
3. `apt-get update && apt-get install -y --no-install-recommends unzip libgdiplus fontconfig libva-drm2 alsa-utils tzdata ffmpeg` (draft list is `libgdiplus ffmpeg tzdata`; the other names come from the older upstream Dockerfile; drop what the base already has and what the vendor zip's bundled FFmpeg makes redundant, UNVERIFIED: the zip ships its own ffmpeg or downloads it on first run to the `/AgentDVR` tree, which must then be writable, see section 9). Check each apt name on resolute; these are unpinned runtime libs, not the app, so version alignment does not apply.
4. `curl -fsSL -o /tmp/agent.zip "https://files.ispyconnect.com/downloads/Agent_${A}_${V}.zip"`, `echo "<sha256>  /tmp/agent.zip" | sha256sum -c -` (value recorded per arch at implementation, UNVERIFIED now), `unzip -q /tmp/agent.zip -d /app`, `chmod 755 /app/Agent /app/agent-*.sh`, `chown -R apps:apps /app`? (No: keep `/app` read-only owned by root; see 9.) Remove the zip.
5. Licences: the zip's EULA/third-party files (names UNVERIFIED) into `/usr/share/licenses/ispy-agent-dvr/`; add a short note file stating the vendor licence.
6. `ENV HOME=/config DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/dotnet DOTNET_CLI_HOME=/tmp MALLOC_TRIM_THRESHOLD_=100000 DOTNET_gcServer=0`.
7. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8090 3478/udp 50000-50100/udp`, `VOLUME /config`.

## 5. docker-bake.hcl

`APP = "ispy-agent-dvr"`, `VERSION = "8.3.2.0"` (renovate comment per section 1, or a plain "bump by hand" comment), `LICENSE = "LicenseRef-Proprietary"`, `SOURCE = "https://www.ispyconnect.com/"`. Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64, arm64), `group "default"`; `args.VERSION`. `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.ispyconnect.com/"
ports:
  - {port: 8090, protocol: tcp, required: true}
  - {port: 3478, protocol: udp, required: false}
  - {port: 50000, protocol: udp, required: false}   # range 50000-50100
env:
  - {name: TZ, default: "Etc/UTC", required: false}
volumes:
  - {path: /config, required: true}
dependencies: []
```
Add `AGENTDVR_WEBUI_PORT` only after confirming the app reads it (UNVERIFIED; the schema probably takes one entry per port, so list the UDP range as the first port plus a comment, or per port if the schema/siblings allow). No dependency containers exist or are needed (ffmpeg comes from apt).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /config/Media/XML /config/Media/WebServerRoot/Media /config/Media/Models /config/Commands
cd /app
exec /app/Agent
```
The vendor binary decides where `Media/`, `Commands/` and `ffmpeg` live relative to its working directory/assembly directory (UNVERIFIED). Because `/app` is read-only, the plan is to symlink at build time `/app/Media -> /config/Media` and `/app/Commands -> /config/Commands` (symlinks in `/app` are created at build, nothing is written to `/app` at runtime), or `cd /config` and test whether the Agent honours its working directory. This is the main implementation unknown. Web UI port: default 8090; override via `port.txt` (old Dockerfile comment) or `AGENTDVR_WEBUI_PORT` (UNVERIFIED), listening on all interfaces (UNVERIFIED default).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8090'
http:
- port: '8090'
  path: /
filePaths:
- /app/Agent
- /usr/share/licenses/ispy-agent-dvr/NOTICE
```
UDP ports 3478 and 50000-50100 are listed in settings.yaml; the test schema's tcp/http probes cannot check UDP (UNVERIFIED whether forgetool has a UDP probe; if not, state in the PR why those are not probed). The `/` path may redirect to a login/setup page; accept what the app returns (UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations

- Chart/upstream: root (`runAsUser 0`), `readOnlyRootFilesystem false`, PVCs `/agent/Media/XML`, `/agent/Media/WebServerRoot/Media`, `/agent/Commands`, `/agent/ffmpeg6`. Here: `USER apps`, read-only rootfs; all four become subfolders of the single `/config` volume (mapped by symlinks or working directory, section 7). No `/config` in the chart; this is a deliberate change that migrating users must follow (copy old XML into `/config/Media/XML`).
- Upstream writes: settings JSON, recordings, models, commands, ffmpeg download (optional GPL build is downloaded into the config volume), logs (`logs.html`), .NET single-file extraction -> `/tmp/dotnet`. Everything else -> `/config` or `/tmp`.
- Hardware: camera and GPU acceleration need `/dev/dri/renderD128` (+ `card0`, AMD `/dev/kfd`), `/dev/snd` and a matching group (`--group-add`); not privileged. These are runtime flags, not image changes. Ports are > 1024, so no root needed.

## 10. Risks, caveats and open questions

- Closed-source, vendor-hosted download; the URL pattern could change; checksum not published (draft caveat). Redistribution rights UNVERIFIED.
- Draft versions (7.1.8.0 chart tag, 8.2.9.0 link) are outdated; 8.3.2.0 was current on the verification date, and vendor updates often (`fromVersion` API even offers in-app updates; the in-app updater cannot write to read-only `/app`; disable with a documented caveat, UNVERIFIED how).
- Whether the agent runs unprivileged and from a read-only install dir: UNVERIFIED (official image supports `PUID`, suggesting non-root works).
- WebRTC/TURN needs UDP 3478 and 50000-50100 reachable; the chart's LoadBalancer services assume a cluster with external IPs (draft caveat).
- Some features may need a paid iSpy account (draft caveat, inferred).
- FFmpeg: vendor bundle vs apt `ffmpeg`; decide after inspecting the zip contents.
- arm64 zip not HEAD-checked.

## 11. Build and test steps

```sh
cd apps/ispy-agent-dvr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name ispy-agent-dvr-probe --read-only --tmpfs /tmp \
  -v ispy-agent-dvr-probe-config:/config ispy-agent-dvr:8.3.2.0
docker logs -f ispy-agent-dvr-probe
forgetool containers test --image ispy-agent-dvr:8.3.2.0 --config ./apps/ispy-agent-dvr/container-test.yaml
docker rm -f ispy-agent-dvr-probe; docker volume rm ispy-agent-dvr-probe-config
```
Expected readiness: a Agent log line that the web server is listening on 8090 (exact text UNVERIFIED), TCP 8090 open, no exception stack traces, container stays up. Also open `http://<host>:8090` from outside the container.

## 12. PR checklist

- Branch `feat/add-ispy-agent-dvr`; commit/PR title `feat(ispy-agent-dvr): add new container`; target `main`.
- PR template filled, only applicable boxes checked; Notes contain `🤖 This PR is AI generated.`
- CLA reminder: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Mention the proprietary licence and the unpublished checksum.
- Untested unless run: both-arch build, read-only run with the vendor binary, symlink/working-directory mapping, UDP ports, camera/GPU devices, forgetool. State this in the PR.
