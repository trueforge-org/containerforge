# neko — implementation plan
> Source: ./draft.md · Target: apps/neko/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v3.2.0, published 2026-10-15 (`https://api.github.com/repos/m1k1o/neko/releases/latest`, read via `gh api`). Draft tag `3.2.0` matches. |
| Renovate | `datasource=github-releases depName=m1k1o/neko versioning=semver` (proposed). The tag has a `v` prefix upstream. UNVERIFIED against a repo-local renovate config. |
| License | Apache-2.0 (`https://api.github.com/repos/m1k1o/neko`). |
| Source URL | https://github.com/m1k1o/neko |
| Upstream layout | Per-app Dockerfiles under `apps/<app>/` with `ARG BASE_IMAGE=ghcr.io/m1k1o/neko/base:latest` (checked `apps/firefox/Dockerfile`). Apps listed: brave, chromium, firefox, google-chrome, kde, microsoft-edge, opera, remmina, tor-browser, ungoogled-chromium, vivaldi, vlc, waterfox, xfce. |
| Base image | `ghcr.io/m1k1o/neko/base` Dockerfile NOT readable (`apps/base` returned 404 via gh api). UNVERIFIED: base OS, user `neko`, supervisord, Xorg, pulseaudio, neko server binary. |
| Firefox | `apps/firefox/Dockerfile`: installs openbox; amd64 and arm64 download Firefox from `https://download.mozilla.org/?product=firefox-latest&os=linux64` (aarch64 variant for arm64), extracts to `/usr/lib/firefox`; armhf uses firefox-esr. Creates `/home/neko/.mozilla`. Copies `supervisord.conf` to `/etc/neko/supervisord/firefox.conf`. Not "latest" pinned: the download is always the current release. |
| Tor Browser | `apps/tor-browser/Dockerfile`: fetches `https://aus1.torproject.org/torbrowser/update_3/release/download-linux-x86_64.json` and parses the `binary` URL, then downloads the tarball. The draft's amd64 link is the JSON, which is the correct intermediate: confirmed. The arm64 link in the draft (dist.torproject.org 16.0.1) is UNVERIFIED. |
| Microsoft Edge | Draft says amd64 only. The `apps/microsoft-edge/Dockerfile` arch branch was not fully read: UNVERIFIED. |
| Other apps | Brave, Chromium, Google Chrome, Remmina, Vivaldi, VLC, XFCE Dockerfiles were not read. Draft's apt and `.deb` sources are UNVERIFIED. |
| Chart | TrueCharts `charts/stable/neko` not fetched. The chart's `braveImage`, `chromiumImage`, `chromeImage`, `edgeImage`, `remminaImage`, `torImage`, `vivaldiImage`, `vlcImage`, `xfceImage` keys are the draft's list, not confirmed. |
| Ports | 8080/http and 52000-52100/udp are the draft's inferences: UNVERIFIED. |

## 2. Target layout

The draft has one main container (neko server) plus nine browser or app sidecars. This plan covers only the main `apps/neko/` container. Each sidecar would be a separate `apps/<app>/` and out of scope here. Proposed files:

- `apps/neko/Dockerfile`
- `apps/neko/docker-bake.hcl`
- `apps/neko/settings.yaml`
- `apps/neko/container-test.yaml`
- `apps/neko/start.sh`
- `apps/neko/root/` is NOT used (reserved for run-time copy-to-rootfs, do not touch).

Config files copied from upstream (supervisord, openbox) would live under `apps/neko/etc/` (reason: the Dockerfile `COPY . /` picks up `etc/`, per `include/.dockerignore`). Only if the base is confirmed to be usable.

## 3. Base image

Proposed `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`.
Reason: the draft's guess. Upstream builds on `ghcr.io/m1k1o/neko/base`, which is NOT confirmed. Using the ContainerForge base means reinstalling everything the neko base gives (Xorg, openbox, pulseaudio, supervisord, the neko server), which is a large rework. This is the main open decision. Closest sibling: none for a desktop stack; check `apps/` for a KDE/VNC or Xorg-based app before starting.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Fetch the neko server binary from the release (`https://github.com/m1k1o/neko/releases`). UNVERIFIED: the asset names and checksum file were not checked. Confirm before writing the download line.
3. Install the desktop stack with apt, pinned where a sibling pins: Xorg, openbox, pulseaudio, supervisor. Confirm the package names on the ubuntu 26.04 base.
4. Install ONE browser for the main image, or none. The draft's nine browsers are sidecars, so the main image does not need them.
5. Ship the upstream licence (Apache-2.0) to `/usr/share/licenses/neko/`.
6. `ENV HOME=/config`. Browser profile dirs go under `/config`, caches under `/tmp`.
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
EXPOSE 52000-52100/udp
VOLUME /config
```

## 5. docker-bake.hcl

Standard targets from `apps/adguardhome-sync`. Values:

- `APP` = `neko`
- `VERSION` = `v3.2.0`, with `// renovate: datasource=github-releases depName=m1k1o/neko versioning=semver`
- `LICENSE` = `Apache-2.0`
- `SOURCE` = `https://github.com/m1k1o/neko`

Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/m1k1o/neko"
ports:
  - port: 8080
    protocol: tcp
    required: true
  - port: 52000
    protocol: udp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

The port range 52000-52100 is one item per port only if forgetool allows ranges; UNVERIFIED. Do not list env vars until `start.sh` and the neko server config are read. Dependencies: none declared, but the chart's sidecar images are a runtime link to other apps, not a dependency in the forgetool sense.

## 7. start.sh

To be written after the base is confirmed:
- Create `/config/neko` and the browser profile on first start only.
- Seed config files only when missing.
- Start supervisord in the foreground with `exec`.
- Listen on `0.0.0.0:8080`.
- No writes to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
```

No udp probe: `emby` and `gluetun` list udp ports in `settings.yaml` and their tests use tcp only; the udp port 52000 is therefore not probed (reason: the test schema has only tcp/http checks as used by siblings).

## 9. Rootless and read-only-rootfs adaptations

- Upstream chart runs as root with `runAsUser 0` and `shm` needs. `USER apps` is required here, so the Xorg/X11 server must run without root. This is a rework item.
- Browsers need a large `/dev/shm`. This is a runtime option, not an image setting: document it in the PR.
- `--read-only --tmpfs /tmp` is possible only if Xorg, pulseaudio and the browser write under `/tmp` or `/config`. Confirm each.
- WebRTC over UDP 52000-52100 needs host networking or explicit port mapping: a runtime concern.

## 10. Risks, caveats and open questions

- BLOCKER: upstream neko base not confirmed. Without it the image is a full desktop rebuild.
- BLOCKER: the draft's chart is one app, but the working set is ten images. Split into one main plus nine apps.
- Browser downloads (Firefox, Tor Browser) are "latest" with no checksum: needs a decision on how to pin or verify.
- Microsoft Edge arm64 and Tor arm64 status are UNVERIFIED.
- Chromium, Brave, Chrome, Vivaldi, Remmina, VLC, XFCE Dockerfiles were not read.
- The draft's Xorg, supervisord and pulseaudio list is inferred from the neko base, not confirmed.

## 11. Build and test steps

From `apps/neko/`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name neko-probe --read-only --tmpfs /tmp --shm-size=1g -v neko-probe-config:/config ghcr.io/trueforge-org/neko:v3.2.0`, then `docker logs -f neko-probe`. Expected readiness line: UNVERIFIED until the server runs.
4. `forgetool containers test --image <image>:<version> --config ./apps/neko/container-test.yaml`.
5. Clean up: `docker rm -f neko-probe; docker volume rm neko-probe-config`.

## 12. PR checklist

- Branch `feat/add-neko`, commit `feat(neko): add new container`.
- PR template from `.github/PULL_REQUEST_TEMPLATE.md`, with `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows the status).
- State what was not tested: the browser sidecars, arm64, WebRTC media, and the neko base (UNVERIFIED). Do not tick "Built container locally" unless the build ran.
- Do not open this PR until the base-image decision in section 3 is made and the sidecar split in section 10 is agreed.
