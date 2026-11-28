# Build stage: guacd is compiled from the Apache source tarball. The draft's apt route does not work because resolute has no guacd package.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
# Must be changed together with VERSION. Renovate cannot update it.
ARG SHA256=8bc45675da96d7b6f39728160181e3d4ff3c08f460f6d26de5805b642bf13f2b
USER root

# UNVERIFIED: build package names on resolute (the first build confirms them). Drop any name that does not exist and note it in the PR.
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    autoconf automake build-essential dpkg-dev libtool libtool-bin pkg-config \
    libcairo2-dev libjpeg-turbo8-dev libpng-dev libpango1.0-dev libssh2-1-dev libssl-dev \
    libtelnet-dev uuid-dev libvncserver-dev libwebsockets-dev libwebp-dev libpulse-dev \
    libvorbis-dev freerdp3-dev libwinpr3-dev; \
  rm -rf /var/lib/apt/lists/*

RUN set -eux; \
  curl -fsSL -o /tmp/gs.tgz "https://archive.apache.org/dist/guacamole/${VERSION}/source/guacamole-server-${VERSION}.tar.gz"; \
  echo "${SHA256}  /tmp/gs.tgz" | sha256sum -c -; \
  tar xzf /tmp/gs.tgz -C /tmp

# --disable-guaclog as upstream does. --disable-guacenc also drops the ffmpeg dependency.
RUN set -eux; \
  cd "/tmp/guacamole-server-${VERSION}"; \
  ./configure --prefix=/usr/local --disable-guaclog --disable-guacenc; \
  make -j"$(nproc)"; \
  make install DESTDIR=/target; \
  install -D -m 0644 LICENSE /target/usr/share/licenses/guacd/LICENSE; \
  install -D -m 0644 NOTICE /target/usr/share/licenses/guacd/NOTICE

# Derive the runtime packages from the staged binaries with ldd, instead of hard-coding library package names.
# LD_LIBRARY_PATH points at the staged libguac. A missing library fails the build.
RUN set -eux; \
  export LD_LIBRARY_PATH=/target/usr/local/lib; \
  for f in $(find /target -type f \( -name guacd -o -name 'libguac*.so*' -o \( -path '*freerdp3*' -name '*guac*.so' \) \)); do \
    ldd "$f" > /tmp/ldd.out || true; \
    if grep -q 'not found' /tmp/ldd.out; then cat /tmp/ldd.out; exit 1; fi; \
    awk '/=>/ && $3 ~ /^\//{print $3}' /tmp/ldd.out; \
  done | sort -u > /tmp/libs.txt; \
  : > /tmp/deps.txt; \
  while read -r lib; do \
    case "$lib" in /target/*) continue ;; esac; \
    dpkg -S "$(readlink -f "$lib")" | cut -d: -f1; \
  done < /tmp/libs.txt | sort -u > /target/deps.txt; \
  rm -f /tmp/ldd.out /tmp/libs.txt /tmp/deps.txt; \
  rm -rf /tmp/gs.tgz "/tmp/guacamole-server-${VERSION}"

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

COPY --from=build /target/ /

# Runtime packages from the ldd step, plus fonts and ghostscript as upstream ships for terminal and PDF use.
# UNVERIFIED: fonts-dejavu-core, fonts-liberation and ghostscript package names on resolute.
RUN set -eux; \
  apt-get update; \
  xargs -r -a /deps.txt apt-get install -y --no-install-recommends fonts-dejavu-core fonts-liberation ghostscript; \
  rm -f /deps.txt; \
  rm -rf /var/lib/apt/lists/*; \
  ldconfig; \
  install -d -o apps -g apps /var/lib/guacamole/recordings /var/lib/guacamole/drive

# HOME must be writable: the FreeRDP plugin reads it. /tmp is the scratch path on a read-only rootfs.
ENV \
  HOME=/tmp \
  LC_ALL=C.UTF-8

USER apps
COPY --chmod=0755 . /

EXPOSE 4822

VOLUME /config /var/lib/guacamole/recordings /var/lib/guacamole/drive
