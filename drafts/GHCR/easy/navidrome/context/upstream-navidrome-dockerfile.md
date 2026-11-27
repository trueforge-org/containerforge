# navidrome upstream Dockerfile, release and license

Source URL(s) + date: https://raw.githubusercontent.com/navidrome/navidrome/master/Dockerfile ; https://api.github.com/repos/navidrome/navidrome/releases/latest ; https://raw.githubusercontent.com/navidrome/navidrome/master/LICENSE (fetched 2026-11-27)
License: GPL-3.0

## Build stages (master Dockerfile)
| Stage | Base | Notes |
| --- | --- | --- |
| osxcross | ghcr.io/crazy-max/osxcross:14.5-debian | darwin SDK source |
| xx-build | alpine:3.22 | clones tonistiigi/xx at pinned commit (v1.9.0), copies xx-* to /out |
| xx | scratch | cross-compile helpers copied to /usr/bin |
| ui | node:lts-alpine | `npm ci`, `npm run build -- --outDir=/build` |
| build-alpine | golang:1.27-alpine | dynamic musl build, CGO_ENABLED=1, `-tags` from release/build-tags.sh; verify via release/verify-binary.sh |
| base / build | golang:1.27-trixie | static glibc build (xx-apt gcc, libc6-dev, zlib1g-dev), `-linkmode` static, `xx-verify --static` |
| mpv-stubs | alpine:3.22 | generates empty libEGL.so.1 / libgbm.so.1 stubs |
| final | alpine:3.22 | runtime |

- Build ARGs used: TARGETPLATFORM, GIT_SHA, GIT_TAG.
- Output binary: /out/navidrome (plus .exe on windows).

## Final image
- `apk add -U --no-cache curl ffmpeg mpv sqlite libwebp libwebpdemux libwebpmux`
- Removes GL/Mesa libs from /usr/lib; installs mpv-stubs into /usr/lib/.
- `COPY --from=build-alpine /out/navidrome /app/`
- WORKDIR /app; ENV PATH includes /app
- ENTRYPOINT `["/app/navidrome"]`; CMD none
- VOLUME ["/data", "/music"]
- EXPOSE ${ND_PORT}
- LABEL maintainer deluan@navidrome.org; org.opencontainers.image.source https://github.com/navidrome/navidrome
- `RUN touch /.nddockerenv`

## Env vars (image ENV)
| Name | Default |
| --- | --- |
| ND_MUSICFOLDER | /music |
| ND_DATAFOLDER | /data |
| ND_CONFIGFILE | /data/navidrome.toml |
| ND_PORT | 4533 |

## Volumes / paths
- /data (DB, cache, config), /music (library, read only recommended).

## User/UID
- No USER instruction: runs as root by default.

## Healthcheck
- None in Dockerfile.

## Version / asset naming (GitHub release)
- Latest tag v0.64.2 (published 2026-09-24).
- Pattern: navidrome_<ver>_<os>_<arch>.tar.gz / .deb / .rpm (e.g. linux_amd64, linux_arm64, linux_armv7, linux_riscv64); windows .zip and _installer.msi; navidrome_checksums.txt.
- Release names use version without leading "v".

## Arch
- Image built for linux/amd64, linux/arm64, arm/v6, arm/v7 (per docs), plus riscv64 release asset.

## Gotchas
- Binary dynamically links musl (build-alpine) and mpv/ffmpeg are runtime deps in final image.
- Upstream Dockerfile base is alpine:3.22 and golang:1.27; keep aligned if building locally.
