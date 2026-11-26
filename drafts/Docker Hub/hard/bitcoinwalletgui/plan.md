# bitcoinwalletgui — implementation plan
> Source: ./draft.md · Target: apps/bitcoinwalletgui/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts
| Item | Value |
|---|---|
| Version | Bitcoin Core 32.1 (bitcoincore.org download page lists 32.1 as latest) |
| Renovate | datasource=github-releases, depName=bitcoin/bitcoin, versioning=loose (tags are `v32.1`; use `extractVersion=^v(?<version>.+)$`). UNVERIFIED: bitcoincore.org publishes before/after the GitHub tag, confirm tag exists |
| License | MIT |
| Source | https://github.com/bitcoin/bitcoin |
| amd64 | https://bitcoincore.org/bin/bitcoin-core-32.1/bitcoin-32.1-x86_64-linux-gnu.tar.gz |
| arm64 | https://bitcoincore.org/bin/bitcoin-core-32.1/bitcoin-32.1-aarch64-linux-gnu.tar.gz |
| Checksum | https://bitcoincore.org/bin/bitcoin-core-32.1/SHA256SUMS (signed by SHA256SUMS.asc; verify the sha256 line, optionally the PGP signature) |
| Upstream Dockerfile | none public (draft). Contents of tarball (bin/bitcoin-qt, bin/bitcoind, bin/bitcoin-cli, share/, COPYING): UNVERIFIED for 32.x layout, inspect after extract |
| Ports | 8333/tcp P2P (draft, inferred; Bitcoin Core default mainnet), 6901 noVNC, 5901 VNC (Docker Hub run examples and chart; see context/dockerhub-ulisses1478-bitcoinwallet-gui.md) |
| Data | datadir /headless/.bitcoin in the draft image; this image uses /config/.bitcoin via `-datadir` |
| Env vars | Bitcoin Core reads none for this wrapper; VNC password var is image-defined (see section 6) |

## 2. Target layout
Dockerfile, docker-bake.hcl, settings.yaml, container-test.yaml, start.sh, defaults/ (bitcoin.conf seed, openbox/xfce autostart). Reuse the desktop stack pattern of apps/kasmvnc (and apps/xvfb): prefer `FROM ghcr.io/trueforge-org/kasmvnc` as a base if it is published and consumable; that would need no DOWNSTREAM_CHANGES for this app (kasmvnc owns that). Open question in section 10.

## 3. Base image
Preferred: kasmvnc-based desktop (web VNC on 3000/3001, built-in noVNC replacement, already rootless). Fallback: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` plus apt `xvfb x11vnc novnc websockify openbox` (lighter than xfce4; tigervnc-standalone-server alternative). Closest siblings: apps/kasmvnc, apps/xvfb.

## 4. Dockerfile
1. `ARG VERSION`, `ARG TARGETARCH`; map amd64 -> x86_64-linux-gnu, arm64 -> aarch64-linux-gnu.
2. `USER root`; apt: Qt xcb runtime libs needed by bitcoin-qt (`libxcb-xinerama0 libxcb-cursor0 libxkbcommon-x11-0 libfontconfig1 libgl1`, UNVERIFIED exact set, determine with `ldd bin/bitcoin-qt`) + the VNC/WM stack if not using kasmvnc. Pin nothing (bitcoin is not from apt).
3. Download tarball and SHA256SUMS; `grep "bitcoin-${VERSION}-${ARCH}.tar.gz" SHA256SUMS | sha256sum -c -`; extract to /app (`tar xzf --strip-components=1 -C /app`).
4. Licenses: `/usr/share/licenses/bitcoinwalletgui/COPYING` from the tarball.
5. `ENV HOME=/config`, `QT_QPA_PLATFORM=xcb`, XDG dirs under /tmp.
6. `USER apps`, `COPY --chmod=0755 . /`, EXPOSE (see 6), `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl
APP=bitcoinwalletgui; VERSION "32.1" with `// renovate: datasource=github-releases depName=bitcoin/bitcoin versioning=loose extractVersion=^v(?<version>.+)$`; LICENSE "MIT"; SOURCE "https://github.com/bitcoin/bitcoin". Standard targets, image-all amd64+arm64. `docker buildx bake --print`.

## 6. settings.yaml
Header + schema_version 1 + upstream_env_url = SOURCE. ports: web desktop port (6080 if noVNC fallback; 3000/3001 if kasmvnc base). 8333 is NOT declared: bitcoin.conf sets `listen=0` (wallet GUI, outbound peers only), so no inbound port needs a probe. Drop raw 5900 VNC unless the fallback stack needs it (no password-less raw VNC exposure). env: TZ; VNC_PW only if the fallback stack reads it (UNVERIFIED: the draft image used the accetto-style VNC_PW, not confirmed for this image). volumes: /config required true (blockchain + wallet; large). dependencies: none.

## 7. start.sh
Seed /config/.bitcoin and bitcoin.conf (`server=0` and `listen=0`, GUI only; set `prune=` option optional) only when missing; start Xvfb/VNC/WM (or call the kasmvnc entry), then `exec /app/bin/bitcoin-qt -datadir=/config/.bitcoin` (desktop autostart) or run it from the WM autostart. Bind noVNC to 0.0.0.0. Caches/temp to /tmp. Never overwrite wallet files. Password for VNC from env, not written into the process list (use a file in /tmp with 0600).

## 8. container-test.yaml
Header; `timeoutSeconds: 120`; `tcp` probe for every port in settings.yaml (only the web desktop port; 8333 is not declared because `listen=0`); `filePaths`: /app/bin/bitcoin-qt, /app/bin/bitcoind, /usr/share/licenses/bitcoinwalletgui/COPYING; a `runners` entry `/app/bin/bitcoin-cli --version`.

## 9. Rootless and read-only-rootfs adaptations
| Upstream write path | Remap |
|---|---|
| /headless/.bitcoin | /config/.bitcoin (-datadir) |
| desktop HOME (.config, .cache, .vnc) | HOME=/config, caches XDG_CACHE_HOME=/tmp |
| X sockets /tmp/.X11-unix, VNC pid | /tmp |
| privileged ports (VNC 5900, 80) | all >1024 |
Draft expected UID 0 and rw rootfs; this plan runs as apps, read-only rootfs, single /config volume replacing /headless/.bitcoin.

## 10. Risks, caveats and open questions
- Full chain needs hundreds of GB and hours; wallet keys live in the datadir: back up /config/.bitcoin/wallets (draft caveat).
- Safer default idea: pruned mode via bitcoin.conf seed (open question, user decision).
- 32.x tarball contents and bitcoin-qt presence UNVERIFIED; if bitcoin-qt is not shipped for aarch64 tarball, arm64 becomes blocked.
- Security: exposing a wallet GUI over VNC needs a password and TLS ingress; never publish raw.
- Base choice (kasmvnc vs ubuntu fallback) undecided; kasmvnc is a heavy build.
- No public upstream Dockerfile for the draft image, so behaviour is rebuilt from scratch.

## 11. Build and test steps
```sh
cd apps/bitcoinwalletgui
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name bitcoinwalletgui-probe --read-only --tmpfs /tmp -v bitcoinwalletgui-probe-config:/config bitcoinwalletgui:32.1
docker logs -f bitcoinwalletgui-probe   # expect desktop/VNC start line and no bitcoin-qt abort ("could not connect to display", missing xcb libs)
docker rm -f bitcoinwalletgui-probe; docker volume rm bitcoinwalletgui-probe-config
forgetool containers test --image bitcoinwalletgui:32.1 --config ./apps/bitcoinwalletgui/container-test.yaml
```
Open the web desktop manually to confirm bitcoin-qt renders and begins header sync.

## 12. PR checklist
- Branch feat/add-bitcoinwalletgui; commit `feat(bitcoinwalletgui): add new container`; PR template; `🤖 This PR is AI generated.` in Notes.
- CLA notice to user: https://cla-assistant.io/trueforge-org/containerforge (only they can sign).
- Untested: everything (no build run), arm64, bitcoin-qt GUI startup, VNC auth, P2P port. Checksum procedure and tarball layout need confirmation on first build.
