# linuxserver/docker-nntp2nntp (upstream image build, Dockerfile at e9a4fd33a54b; defaults at master)

**Source URL(s):** https://github.com/linuxserver/docker-nntp2nntp/blob/e9a4fd33a54b/Dockerfile (fetched via https://raw.githubusercontent.com/linuxserver/docker-nntp2nntp/e9a4fd33a54b/Dockerfile); https://raw.githubusercontent.com/linuxserver/docker-nntp2nntp/master/root/defaults/nntp2nntp.conf (default config, master; the plan's source)
**Fetched:** 2026-11-26

## Base
- `ghcr.io/linuxserver/baseimage-alpine:3.15` (Alpine 3.15). Not reused in this plan (Alpine, Python 2): `copy-from` is `no`.

## Build args and labels
- ARGs: `BUILD_DATE`, `VERSION`, `NNTP2NNTP_RELEASE`. `build_version` label combines version and date. Maintainer label names the upstream maintainer (omitted here).

## RUN step (one layer)
1. Virtual build deps: build-base (compiler), cargo, libffi-dev, libressl-dev, openssl-dev, python2-dev.
2. Runtime: libffi, libressl, python2.
3. Downloads the Python 2.7 `get-pip.py` from bootstrap.pypa.io and runs it.
4. If `NNTP2NNTP_RELEASE` is unset, queries the GitHub API for the latest `linuxserver/nntp2nntp` release tag.
5. `pip install` with LinuxServer's Alpine 3.15 wheel index: `typing`.
6. `pip install` the nntp2nntp tarball `https://github.com/linuxserver/nntp2nntp/archive/<release>.tar.gz` plus `service_identity`.
7. Removes build deps, pip cache and `/tmp`.

## Remaining
- `COPY root/ /` (s6 service files and defaults).
- `EXPOSE 1563`, `VOLUME /config`.
- No ENV, USER, ENTRYPOINT or CMD: s6 init from the base starts the service.

## Default config (`root/defaults/nntp2nntp.conf`, master)
These are example values, not all marked as defaults on the page.
- `[server]`: `use ssl = true`, `host = nntp.example.com`, `port = 563`, `login = myuser`, `password = mypwd`, `max connections = 50`.
- `[proxy]`: `use ssl = false`, `port = 1563`, `cert file = /config/keys/certificate.pem`, `cert key = /config/keys/private-key.pem`, `ca verification = false`, `ca file = myca.pem`, `logfile = /config/logs/nntp2nntp.log`, `pidfile = /config/logs/nntp2nntp.pid`. No bind address key.
- `[users]`: `user1 =`, `user2 =` (empty; to be filled with SHA-256 digests).
- `[connections]`: `user1 = 10`, `user2 = 20`.
- Note: the sample `[server]` has placeholder credentials, so a readiness test with this default would not reach a real upstream. Plan.md flags this as UNVERIFIED (proxy start with placeholder upstream settings).

## Gotchas for our build
- The upstream image is Python 2 on Alpine 3.15; our base (Ubuntu + python 3.15) cannot run the Python 2 source as-is (see github-linuxserver-nntp2nntp.md).
- The Python 2.7 `get-pip.py` route is not a Python 3 path.
- Default config paths point to `/config` (good for read-only rootfs), but the code's built-in defaults point to `/var/log` and `/var/run`.
