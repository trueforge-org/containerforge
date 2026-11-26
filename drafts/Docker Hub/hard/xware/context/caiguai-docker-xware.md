# caiguai/docker-xware: Dockerfile and README

## Source URL(s) + date
- https://raw.githubusercontent.com/caiguai/docker-xware/master/Dockerfile (fetched 2026-11-26; urls.txt pins blob/master)
- https://raw.githubusercontent.com/caiguai/docker-xware/master/README.md (fetched 2026-11-26, Chinese)
- Binary `xware.tar.bz` (raw URLs in urls.txt): NOT downloaded (binary, skipped by rule). Plan records size 1,821,102 bytes.

## What it is
- Docker image for Thunder (Xunlei) offline download ("xware") daemon, packaged from a bundled vendor tarball.
- README claims: smaller than yinheli/docker-thunder-xware, more stable than cuteribs/xware.

## Install/build steps (Dockerfile)
- `FROM debian:wheezy-slim` (Debian 7, EOL)
- `WORKDIR /xware`
- `COPY ./*.deb /xware/` (bundled debs; repo ships these next to the Dockerfile)
- `ADD ./xware.tar.bz /xware/bin/`
- `COPY start.sh /xware/`
- `RUN dpkg -i` in order: `libc6-*.deb`, `lib32z1_*.deb`, `libncursesw5_*.deb`, `libprocps0_*.deb`, `procps_*.deb`; `chmod +x /xware/bin/portal` and `/xware/start.sh`; `rm /xware/*.deb`

## Runtime deps
- i386 glibc (`libc6-*.deb`), lib32z1, libncursesw5, libprocps0, procps (all from bundled Debian wheezy debs).

## Entrypoint/flags
- `CMD ["./start.sh"]` (start.sh is not fetched in this pass; plan.md describes it).

## Env vars
- None in Dockerfile.

## Ports
- `EXPOSE 9000` (control port; README log shows "YOUR CONTROL PORT IS: 9000").

## Volumes/paths
- `VOLUME /xware/TDDOWNLOAD` (download dir; README mounts `$(pwd)/data:/xware/TDDOWNLOAD`).

## User/UID
- Not set (root by default).

## Config files
- None in Dockerfile.

## Healthcheck
- None.

## Version/asset naming
- No version. Only `latest` tag used in README and docs.

## Arch
- Bundled binaries are x86 (i386) only per plan.md; Dockerfile does not state arch.

## Run (README)
- `docker run -d --name=xware --net=host -v $(pwd)/data:/xware/TDDOWNLOAD caiguai/docker-xware`
- Activation: `docker logs xware` prints "THE ACTIVE CODE IS: ..." then "go to http://yuancheng.xunlei.com, bind your device with the active code."
- Log sample: "port: 9000 is usable", "YOUR CONTROL PORT IS: 9000", "starting xunlei service...".

## Gotchas
- Dockerfile is 2017-era; no pinned version beyond `latest`.
- README recommends `--net=host`.
- Bundled `.deb` files are required at build time (`COPY ./*.deb`); the repo file list was not fetched in this pass.
