# leonismoe/docker-images: ariang (upstream image source)
Source URL(s): https://raw.githubusercontent.com/leonismoe/docker-images/3b6bca6db6513787ad225d555778f7f31c7d3f36/ariang/Dockerfile (fetched; blob variant same). Repo page fetched as alt (description only: "Just a set of docker build files").

## What it is
Multi-stage build of AriaNg (static web UI) served by darkhttpd on `scratch`.

## Build (Dockerfile at 3b6bca6)
- `# syntax=docker/dockerfile:1`
- ARG VERSION=1.3.13 `# github-releases/mayswind/AriaNg`
- Stage xx: `tonistiigi/xx`; stage xbuild: `alpine:edge` (BUILDPLATFORM)
- apk: clang curl git libarchive-tools libcap lld make
- Builds ELFkickers `sstrip` from https://github.com/BR903/ELFkickers.git (git clone --depth 1)
- Clones https://github.com/emikulic/darkhttpd.git
- Downloads `https://github.com/mayswind/AriaNg/releases/download/$VERSION/AriaNg-$VERSION.zip` and unzips to /build/root/www
- xx-apk add gcc musl-dev
- darkhttpd built static: `make darkhttpd CC=xx-clang CFLAGS='-static -Os ... -Wl,-z,relro -Wl,-z,noexecstack'`, `setcap cap_net_bind_service=+ep darkhttpd`, `sstrip darkhttpd || true`, `xx-verify darkhttpd`
- Creates /etc/passwd and /etc/group entries for `nobody` (65534)
- Final stage: `FROM scratch`, `COPY --from=xbuild /build/root/ /`, `LABEL version=${VERSION}`

## Entrypoint / cmd
- `ENTRYPOINT ["/darkhttpd"]`
- `CMD ["/www", "--chroot", "--uid", "nobody", "--gid", "nobody", "--port", "8080"]`

## Ports
- EXPOSE 8080

## Volumes
- None

## User/UID
- nobody (65534:65534) via darkhttpd --uid/--gid after chroot

## Runtime deps
- None (static binary, scratch base). No shell in image.

## Config files
- None (AriaNg is static HTML/JS in /www)

## Healthcheck
- None in Dockerfile

## Version/asset naming
- Release zip: `AriaNg-<VERSION>.zip` on GitHub release tag `<VERSION>` (no `v` prefix)

## Arch
- Multi-platform via tonistiigi/xx (TARGETPLATFORM, TARGETARCH, TARGETVARIANT used)

## Gotchas
- Scratch final image: no shell, no ca-certs. Entry is darkhttpd only.
- Build fetches several sources at build time (ELFkickers, darkhttpd git HEAD, AriaNg zip); darkhttpd is not pinned to a commit
