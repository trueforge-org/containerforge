# convos-chat/convos Dockerfile (commit 63572e5cc48d821e9fe0d85b84dcea4ec837b466)
Source URL(s): https://raw.githubusercontent.com/convos-chat/convos/63572e5cc48d821e9fe0d85b84dcea4ec837b466/Dockerfile (also github blob URL, fetched 2026-11-27)

## Build
- `FROM ghcr.io/convos-chat/convos-base:main` (base image is ghcr, not Docker Hub).
- COPY Changes Makefile.PL, assets, lib, public, script, templates into /app (mkdir /app).
- ENV CONVOS_DEPENDENCIES=all
- apk add curl openssl perl perl-io-socket-ssl perl-net-ssleay wget; builddeps (build-base perl-dev) added then deleted after `/app/script/convos install --all`.
- Cleanup: rm -rf /root/.cpanm /var/cache/apk/*

## Runtime
- ENV CONVOS_HOME=/data; CONVOS_NO_ROOT_WARNING=1; MOJO_MODE=production
- VOLUME ["/data"]
- EXPOSE 3000
- CMD ["daemon"]; ENTRYPOINT ["/app/script/convos"]
- No USER directive (root). Image is Alpine-based (apk).

## Ports
- 3000 (container). Listen example in docs: `--listen http://*:8080`.

## Volumes
- /data (CONVOS_HOME: settings, logs).

## Env (documented at convos.chat/doc/config.html, fetched)
| Name | Default / note |
| --- | --- |
| CONVOS_HOME | $HOME/.local/share/convos/ (Dockerfile sets /data) |
| CONVOS_REVERSE_PROXY | enable behind reverse proxy |
| CONVOS_ACCESS_LOG | access log format (experimental) |
| CONVOS_BACKEND | default Convos::Core::Backend::File |
| CONVOS_CONNECT_DELAY | default 4 (seconds between user connects) |
| CONVOS_DEFAULT_THEME | default convos |
| CONVOS_DEFAULT_SCHEME | default light |
| CONVOS_INVITE_LINK_VALID_FOR | hours for invite/password links |
| CONVOS_LOCAL_SECRET | (listed, not detailed) |
| CONVOS_LOG_FILE / CONVOS_LOG_LEVEL | logging |
| CONVOS_MAX_UPLOAD_SIZE | upload size limit |
| CONVOS_PLUGINS | plugins |
| CONVOS_REQUEST_BASE | base path |
| CONVOS_SYSLOG | syslog |
| CONVOS_WEBIRC_PASSWORD_NNN | WEBIRC password |
- Env vars must be set before the process starts; restart needed on change.

## Config (docs)
- Listen: `./script/convos daemon --listen http://*:8080` (also IPv6, unix socket, https with cert/key).
- Global settings include organization name/URL, admin email, default connection URL, registration open.

## Gotchas
- Env var names above from config docs; Dockerfile only sets CONVOS_HOME, CONVOS_NO_ROOT_WARNING, MOJO_MODE.
