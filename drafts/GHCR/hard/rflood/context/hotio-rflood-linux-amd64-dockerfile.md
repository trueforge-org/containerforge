# hotio/rflood linux-amd64.Dockerfile (commit 194a3cbe1452)

**Source URL(s):** https://raw.githubusercontent.com/hotio/rflood/194a3cbe1452/linux-amd64.Dockerfile (blob URL duplicate) · fetched 2026-11-27

## Build
- ARG `UPSTREAM_IMAGE`, `UPSTREAM_TAG_SHA` (hotio base image, not fixed here).
- Builder stage (same upstream base): apk build-base, linux-headers, curl-dev, ncurses-dev, tinyxml2-dev.
- libtorrent and rtorrent built from `https://github.com/rakshasa/rtorrent/releases/download/v${VERSION}/` tarballs (`libtorrent-${VERSION}.tar.gz`, `rtorrent-${VERSION}.tar.gz`), static, `--enable-static --disable-shared --with-xmlrpc-tinyxml2`, LTO flags.
- ARG `VERSION` (rtorrent/libtorrent version).

## Runtime stage
- `EXPOSE 3000`.
- ENV `IMAGE_STATS`, `FLOOD_AUTH="false"`, `WEBUI_PORTS="3000/tcp"`.
- apk: xmlrpc-c-tools, nginx, openssl, mediainfo; symlink `${APP_DIR}/basic_auth_credentials` -> `${CONFIG_DIR}/rpc2/basic_auth_credentials`.
- COPY built rtorrent to `${APP_DIR}/rtorrent`.
- ARG `VERSION_FLOOD`: download `https://github.com/jesec/flood/releases/download/v${VERSION_FLOOD}/flood-linux-x64` to `${APP_DIR}/flood` (chmod 755).
- COPY `root/` to /; chmod s6 run scripts.

## Gotchas
- Base is hotio s6-overlay image (CONFIG_DIR, APP_DIR vars from base). Not reproducible without the hotio base.
- Flood and rtorrent versions come from build args, not from this file.
