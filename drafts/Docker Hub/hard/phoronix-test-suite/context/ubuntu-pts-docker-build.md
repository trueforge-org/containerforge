# ubuntu-pts-docker-build.sh (deploy/docker)

Source URL: https://raw.githubusercontent.com/phoronix-test-suite/phoronix-test-suite/master/deploy/docker/ubuntu-pts-docker-build.sh (fetched; master, unpinned)
Blob URL in urls.txt: https://github.com/phoronix-test-suite/phoronix-test-suite/blob/master/deploy/docker/ubuntu-pts-docker-build.sh

## What it does
- Host-side bash script: stages files, tars them, writes a Dockerfile, runs `docker build`.
- Build tree: ./phoronix-pts-docker/base/ becomes / in the image.

## Dockerfile it writes
- FROM ubuntu:20.04 (EOL base). LABEL maintainer Phoronix Media (commercial@phoronix-test-suite.com).
- ARG DEBIAN_FRONTEND=noninteractive
- apt: update; install unzip, php-cli, apt-utils, mesa-utils, php-xml, git-core, apt-file, sudo; then apt-file update.
- ADD base.tar.xz / (auto-extract)
- No ENV, EXPOSE, VOLUME, USER (runs as root), HEALTHCHECK.
- CMD ["/phoronix-test-suite/phoronix-test-suite", "shell"]; no ENTRYPOINT.
- Build: `docker build -t phoronix-pts-docker .` from ./phoronix-pts-docker

## Host-side steps
- `git clone` of PTS default branch (no tag/pin); `.git` removed.
- tar + `xz -T0` -> base.tar.xz
- Runs `make-openbenchmarking-cache lean` on host
- Deletes core.pt2so from user path
- Download-cache dir created; PTS_DOWNLOAD_CACHING_PLATFORM_LIMIT=1; make-download-cache commented out; TESTS_TO_PRECACHE empty.
- Host exports only (not in image): TESTS_TO_PRECACHE, PTS_USER_PATH_OVERRIDE, PTS_DOWNLOAD_CACHE_OVERRIDE, PTS_DOWNLOAD_CACHING_PLATFORM_LIMIT=1.
- Host needs: git, docker, tar, xz, working php CLI. Network for clone/apt/OpenBenchmarking.

## Image paths (from tar root)
- /phoronix-test-suite/ (PTS code)
- /var/lib/phoronix-test-suite/ (user path, cached metadata)
- /var/cache/phoronix-test-suite/download-cache/
- /root/.phoronix-test-suite not created.

## Gotchas
- Ubuntu 20.04 base and unpinned git master.
- No ENV in image: PTS_USER_PATH_OVERRIDE is not set at runtime, so default ~/.phoronix-test-suite (= /root/...) is used unless the environment sets it.
- Commented-out lines reference docker run -it, tag to phoronix/pts, push.
