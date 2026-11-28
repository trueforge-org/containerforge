# channels-dvr — implementation plan
> Source: ./draft.md · Target: apps/channels-dvr/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | Channels DVR is closed source and rolling. `setup.sh` reads the current version from `https://cdn.channelsdvr.net/dvr/latest.txt` (override with `DVR_VERSION`). The `fancybits/channels-dvr:latest` and `:tve` tags carry no semver |
| Renovate | Not applicable with a standard datasource. Use a pinned `VERSION` read from the vendor download manifest (UNVERIFIED URL) with a `custom.regex` manager, or leave Renovate off and rebuild on a schedule |
| License | Proprietary, closed source, vendor EULA, needs a Channels subscription/trial. SPDX: `LicenseRef-Proprietary`. Redistribution of the binary inside a public image is UNVERIFIED (fancybits publishes its own image) |
| Source URL | https://getchannels.com/dvr-server/ |
| Download | Official script `curl -f -s https://getchannels.com/dvr/setup.sh \| DOWNLOAD_ONLY=1 sh` creates `./channels-dvr` and downloads the server (per community docs); Docker images use `DOWNLOAD_ONLY=1`. Per-version files on `https://cdn.channelsdvr.net/dvr`: `channels-dvr-$os-$arch`, `ffmpeg-$os-$arch`, `ffprobe-$os-$arch`, `comskip-$os-$arch`, `ffmpeg-dl-$os-$arch`, `$os-$arch.sha256` (the script resolves them; `DVR_OS`/`DVR_ARCH` override) |
| Checksum | A per-version `$os-$arch.sha256` file exists on the CDN, but `setup.sh` downloads it and does NOT verify it; verify it yourself if you want a check |
| Upstream Dockerfile | None public (draft: `-`). The fancybits/jonathanfinley community Dockerfiles exist but were not retrievable (404 for `fancybits/channels-dvr`); the community `jonathanfinley/channels-dvr_docker` Dockerfile was listed in search but not read |
| Port | 8089/tcp web UI (draft). Docker doc: `--net=host`, `--device /dev/dri`, volumes `/channels-dvr` (server + data) and `/shares/DVR` (recordings) |

## 2. Target layout

`Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`. No `defaults/`. No `DOWNSTREAM_CHANGES.md`. The tve variant is a separate tag upstream (UNVERIFIED what it contains); this plan covers the standard image only.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The server download bundles its own `ffmpeg`, `ffprobe`, `comskip` and `ffmpeg-dl` binaries (verified in `setup.sh`), no language runtime. Closest sibling: `apps/adguardhome-sync`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `mkdir -p /app && cd /app && curl -fsS https://getchannels.com/dvr/setup.sh | DOWNLOAD_ONLY=1 sh` (the script picks the arch; it has no target-dir option and always writes `./channels-dvr` under the current directory, which is `/app` here). Runtime libs the binary needs (ffmpeg libs, `libva`, `intel-media-va-driver` for `/dev/dri`) are UNVERIFIED; check with `ldd` and add only missing apt packages.
3. Verify: no upstream checksum; fail the build if the binary does not run `--version` (UNVERIFIED flag), and record the version into `VERSION`-matching check.
4. License: vendor EULA text to `/usr/share/licenses/channels-dvr/` if shipped, else a README note.
5. `ENV HOME=/config`, plus `CHANNELS_DVR_DATA` only if upstream supports it (UNVERIFIED, see section 9).
6. `chown -R apps:apps /app`, `COPY --chmod=0755 . /`, `EXPOSE 8089`, `VOLUME /config`, `USER apps`.

## 5. docker-bake.hcl

APP `channels-dvr`; VERSION = the vendor build version (UNVERIFIED how to obtain; placeholder is not allowed, resolve it when porting) with a comment `// renovate: ...` using a regex/custom manager or an explicit note; LICENSE `LicenseRef-Proprietary`; SOURCE `https://getchannels.com/dvr-server/`. Four standard targets, default `image-local`. `docker buildx bake --print`.

## 6. settings.yaml

Schema header, `schema_version: 1`, `upstream_env_url: "https://getchannels.com/dvr-server/"`. ports: 8089/tcp. env: `TZ` default `Etc/UTC` only; do not list unverified vars. volumes: `/config` (required), `/shares/DVR` (recordings; required false). dependencies: none.

## 7. start.sh

1. `mkdir -p /config /shares/DVR` (ignore failure when the recordings path is a read-only mount).
2. Seed nothing; the server creates its own data directory.
3. `cd /app/channels-dvr/latest` and `exec ./channels-dvr` (setup.sh puts the executable in `channels-dvr/<version>/` with a `latest` symlink) with the data-dir argument/env pointing to `/config` (UNVERIFIED: the official image keeps data in `/channels-dvr` next to the executable). The server must listen on all interfaces (it does by default, UNVERIFIED).

## 8. container-test.yaml

Schema header, `timeoutSeconds: 180`. `tcp: - port: '8089'`; `http: - port: '8089' path: /` (UNVERIFIED path). `filePaths: - /app/channels-dvr/latest/channels-dvr`. No env needed to start; licence activation happens in the UI.

## 9. Rootless and read-only-rootfs adaptations

- Upstream keeps the executable and its data in one writable `/channels-dvr` and self-updates the binary in place; neither fits a read-only `/app`. Needs experiments: find a flag/env for the data dir, and disable self-update (UNVERIFIED if possible). If impossible, copy the binary into `/config` at first start (documented deviation).
- Draft expects runAsUser 568, read-only rootfs, `/shares/DVR` PVC; recordings go to `/shares/DVR` (extra mount, kept) and settings/db to `/config`.
- `/dev/dri` (hardware transcoding) requires the `apps` user in groups `video`/`render` (base already adds supplemental groups 44 and 107, UNVERIFIED mapping).
- Tuner discovery uses multicast/broadcast, which needs host networking at deploy time (deployment concern, not an image change).

## 10. Risks, caveats and open questions

- Possible blocker: closed-source redistribution rights and no version feed for Renovate.
- Self-update and writable binary directory conflict with read-only rootfs.
- Per-arch URLs and version source are known (section 1) but the vendor can change setup.sh; the sha256 is not verified by setup.sh.
- Needs a paid or trial licence to be useful; tuners and host networking.
- Hardware transcoding needs GPU device access (not required for startup).

## 11. Build and test steps

```sh
cd apps/channels-dvr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create channels-dvr-probe-config
docker run --rm -d --name channels-dvr-probe --read-only --tmpfs /tmp -v channels-dvr-probe-config:/config channels-dvr:<VERSION>
docker logs -f channels-dvr-probe
forgetool containers test --image channels-dvr:<VERSION> --config ./apps/channels-dvr/container-test.yaml
docker rm -f channels-dvr-probe; docker volume rm channels-dvr-probe-config
```
Expected readiness: a log line showing the server listening on 8089 / web UI available (exact text UNVERIFIED); port 8089 open.

## 12. PR checklist

- Branch `feat/add-channels-dvr`; commit and PR title `feat(channels-dvr): add new container`; target `main`.
- Fill the PR template; Notes include `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: whole build, read-only operation, arm64, tve variant, licensing/redistribution question (ask maintainers first).

## Fix attempt (2026-11-28)

Done: verified `latest.txt` = 2026.10.24.0621 and that the per-version `linux-x86_64.sha256` / `linux-arm64.sha256` files exist on the CDN (format `<sha256>  <file>`); Dockerfile now verifies them with `sha256sum -c --ignore-missing` and no longer calls an unverified `--version` flag; the writable `data` dir that setup.sh creates next to the version directory is replaced by a symlink to `/config` so the image works with a read-only `/app`. Redistribution is a policy question and was accepted for this unreviewed draft.

Still unverified (needs a real run): that the server really uses `channels-dvr/data` for state (no env or flag for it was found in the docs or community posts), self-update behaviour on a read-only dir, shared libs for `/dev/dri`, the `/` web path, `video`/`render` group mapping, and the Renovate datasource for the version.
