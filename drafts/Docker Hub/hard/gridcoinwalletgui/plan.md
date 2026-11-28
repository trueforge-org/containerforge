# gridcoinwalletgui — implementation plan
> Source: ./draft.md · Target: apps/gridcoinwalletgui/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 5.5.3.0 (released 2026-11-20, latest). The draft links 5.5.2.0, which is outdated. |
| Renovate | `datasource=github-releases depName=gridcoin-community/Gridcoin-Research versioning=loose` (4-part version, tags have no `v`) |
| License | MIT (GitHub API SPDX `MIT`, checked 2026-11-25) |
| Source URL | https://github.com/gridcoin-community/Gridcoin-Research |
| amd64 asset | Options on the release: `gridcoinresearch-5.5.3.0-x86_64.tar.gz` (sha256 `30d3e1755f99dbad3330e8858f44a0edf47596c6cf7ea34d96c52bf1d149dae5`), `gridcoin-5.5.3.0-x86_64.flatpak` (sha256 `3c61bc53...ce62f`), `gridcoinresearch-qt_5.5.3.0.trixie-1_amd64.deb` (sha256 `008dac730c8f25e2a6b1feb291c196bcaa41a8a4a39bd6cfb981102916245be4`) |
| arm64 asset | `gridcoinresearch-qt_5.5.3.0.trixie-1_arm64.deb` (sha256 `ec0c24a8dc4a6350b084a34ead2e181617869db5d6c1ce979f10011ba934af0b`); bookworm variant `...bookworm-1_arm64.deb` (sha256 `8a551873ea0a652bf5750a2dd80ec233794344d884b3ead281c51235a02c1380`). Draft's `bookworm-2` name is stale. |
| Checksums | GitHub API asset digests (above). The release notes mention a `SHA256SUMS` file only for the Windows installer; no GPG detached signature file named (tag is signed by key A199759F0940A1F1). The Dockerfile should fetch the digest at build time from `https://api.github.com/repos/gridcoin-community/Gridcoin-Research/releases/tags/${VERSION}` and verify with `sha256sum -c`. |
| Upstream Dockerfile | None public (`sublivion/gridcoinwalletgui` image). Unverified provenance. |
| Qt/VNC | Gridcoin Qt wallet runs inside a VNC/noVNC desktop. ContainerForge already has `apps/kasmvnc` (ports 3000 http, 3001 https; openbox autostart seeded from `/defaults/autostart` into `/config/.config/openbox/autostart`) and `apps/xvfb`. |
| Ports | The draft's 5900 and 6080 are inferred. With kasmvnc, the web desktop is 3000/3001. The wallet's own P2P port (32749 mainnet) and RPC (15715) are UNVERIFIED and not exposed by default. |
| Data dir | `~/.GridcoinResearch` (draft: `/headless/.GridcoinResearch/`); with `HOME=/config` this becomes `/config/.GridcoinResearch`. |
| Dependencies | none (BOINC client at `/var/lib/boinc-client/` in the draft's chart is optional, not required for the wallet; UNVERIFIED) |

## 2. Target layout

```
apps/gridcoinwalletgui/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/autostart   # replaces the kasmvnc openbox autostart so it launches the wallet
```

`defaults/` is needed because `include/.dockerignore` allows it and kasmvnc seeds `/config/.config/openbox/autostart` from `/defaults/autostart`. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/kasmvnc:<VERSION from apps/kasmvnc/docker-bake.hcl, currently 1.5.2>@sha256:<UNVERIFIED: digest of the published kasmvnc image; take it from ghcr.io after kasmvnc publishes, or copy the tag form used by other consumers once one exists>`. No app in the repo consumes kasmvnc yet, so the digest cannot be copied from a sibling. Fallback: ubuntu base `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` plus `xvfb`, `x11vnc`, `novnc`, `openbox` from apt. Preference is kasmvnc (it already solves rootless VNC). Closest sibling: `apps/kasmvnc` itself, `apps/steamcmd` for download-and-verify style.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config`.
2. amd64: download `gridcoinresearch-${VERSION}-x86_64.tar.gz`, verify sha256 against the release API digest, extract binaries to `/app/gridcoin/` (UNVERIFIED: tarball layout and whether it ships `gridcoinresearch-qt`; inspect with `tar tzf` before finalising). If the tarball has only the daemon, use the trixie amd64 deb instead.
3. arm64: download `gridcoinresearch-qt_${VERSION}.trixie-1_arm64.deb`, verify sha256, extract with `dpkg-deb -x` to `/app/gridcoin` (do not `dpkg -i`; avoids maintainer scripts and systemd units), then run `ldd` on the binary and apt-install whichever Qt5/boost/db shared libs are missing from Ubuntu 26.04 (package names UNVERIFIED; Debian trixie boost and Qt soname versions may not exist on Ubuntu 26.04, which could make arm64 a blocker).
4. Select by `TARGETARCH` with a `case`; flatpak is not used (needs flatpak runtime and sandbox permissions).
5. Install license/notice files to `/usr/share/licenses/gridcoinwalletgui/` (from the repo `COPYING` at the tag via curl, and any docs in the package).
6. `COPY --chmod=0755 . /` (brings `start.sh` and `defaults/autostart`), `EXPOSE 3000 3001`, `VOLUME /config`, final `USER apps`.
7. Do not reinstall packages the kasmvnc base already has; check `apps/kasmvnc/Dockerfile` for Qt libs (it sets `QT_QPA_PLATFORM` only at build time).

## 5. docker-bake.hcl

`APP="gridcoinwalletgui"`, `LICENSE="MIT"`, `SOURCE="https://github.com/gridcoin-community/Gridcoin-Research"`, `VERSION` default `"5.5.3.0"` under `// renovate: datasource=github-releases depName=gridcoin-community/Gridcoin-Research versioning=loose`. Targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64+arm64; if arm64 proves blocked, restrict `platforms` to amd64 and say so in the PR), group default `image-local`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Schema header, `schema_version: 1`, `upstream_env_url` = SOURCE.
- ports: `3000 tcp` (noVNC/KasmVNC http), `3001 tcp` (https), both `required: false`.
- env (inherited from kasmvnc and read by its init): `TZ` (`"Etc/UTC"`), `CUSTOM_PORT` (`"3000"`), `CUSTOM_HTTPS_PORT` (`"3001"`), `CUSTOM_USER` (`"apps"`), `PASSWORD` (`""`), `SUBFOLDER` (`"/"`); verify each is still read by the kasmvnc root init at the pinned version.
- volumes: `/config` required true (wallet data and blockchain at `/config/.GridcoinResearch`).
- dependencies: none.

## 7. start.sh

Reuse the kasmvnc start flow (do not replace it blindly): `start.sh` of the base seeds `/config/.config/openbox/autostart` from `/defaults/autostart` when missing, so shipping our own `/defaults/autostart` that runs `/app/gridcoin/<qt binary>` (UNVERIFIED binary name, likely `gridcoinresearch-qt` or `gridcoinresearch`) is the main change. If a custom `start.sh` is needed, copy the base logic and only add: `mkdir -p /config/.GridcoinResearch` when missing; export `HOME=/config`; keep caches (`XDG_CACHE_HOME`) in `/tmp`; end with the same `exec` as the base (UNVERIFIED: read `apps/kasmvnc/start.sh` tail and `root/kasminit` when implementing). The wallet should be launched with `-datadir=/config/.GridcoinResearch` (flag UNVERIFIED). Idempotent, no writes to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
tcp:
- port: '3000'
- port: '3001'
filePaths:
- /start.sh
- /defaults/autostart
- /usr/share/licenses/gridcoinwalletgui/COPYING
```

Add a `filePaths` entry for the wallet binary once its name is confirmed. Timeout 180 is a guess (`apps/kasmvnc/container-test.yaml` sets none; UNVERIFIED). Test runs without `PASSWORD`; the password-protected path must be exercised manually.

## 9. Rootless and read-only-rootfs adaptations

- Draft: chart UID 0, writable rootfs; target UID 568, read-only rootfs.
- Wallet writes `~/.GridcoinResearch` (to `/config`), Qt caches and X sockets (to `/tmp`; kasmvnc base already moves most). Set `XDG_RUNTIME_DIR` under `/tmp` if `/config/.XDG` is unwanted (base uses `${HOME}/.XDG`).
- Extra persistence from the draft: `/var/lib/boinc-client/` is not included (optional; UNVERIFIED need); document in the PR.
- VNC password: base `PASSWORD` env; the draft notes it must be set before first use.

## 10. Risks, caveats and open questions

- arm64 may be a blocker: only a Debian-built deb exists and Ubuntu 26.04 may lack matching shared library versions. Fallback: amd64 only.
- Tarball layout and the Qt binary name are unverified.
- kasmvnc image tag/digest is not yet referenced anywhere; confirm it is published.
- Initial chain sync is huge and long; tests cannot cover it.
- Draft's `copy-from arm64: no`; so arm64 must come from the deb.
- No public Dockerfile for the Docker Hub image, so its exact runtime flags are unknown.

## 11. Build and test steps

```sh
cd apps/gridcoinwalletgui
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name gridcoinwalletgui-probe --read-only --tmpfs /tmp \
  -v gridcoinwalletgui-probe-config:/config gridcoinwalletgui:5.5.3.0
docker logs -f gridcoinwalletgui-probe
forgetool containers test --image gridcoinwalletgui:5.5.3.0 --config ./apps/gridcoinwalletgui/container-test.yaml
docker rm -f gridcoinwalletgui-probe; docker volume rm gridcoinwalletgui-probe-config
```

Expected readiness: the KasmVNC/noVNC "listening on 3000" style line from the base, then the wallet window opened (open http://localhost:3000 and verify; also check `/config/.GridcoinResearch/debug.log` appears). Exact log text UNVERIFIED.

## 12. PR checklist

- Branch `feat/add-gridcoinwalletgui`; commit and PR title `feat(gridcoinwalletgui): add new container`.
- PR template filled; Notes contain `🤖 This PR is AI generated.`
- CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- bake print, version alignment, `USER apps`, empty `/config`, read-only rootfs, verified checksums.
- Untested at plan time: everything, especially wallet launch under kasmvnc, arm64 deb libraries, tarball layout, license identifier.
