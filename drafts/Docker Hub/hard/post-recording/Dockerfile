
# UNVERIFIED: the ubuntu:26.04 digest comes from plan.md section 3; confirm it on ghcr.io before the first build.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
ARG COMSKIP_SHA256
ARG COMCHAP_COMMIT
USER root

# UNVERIFIED: package names on 26.04 (libsdl1.2-dev, libargtable2-dev); check with apt-cache.
RUN echo "*** Installing build dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    ca-certificates \
    curl \
    git \
    libargtable2-dev \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libsdl1.2-dev \
    libtool-bin \
    pkg-config && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /build

# COMSKIP_SHA256 and COMCHAP_COMMIT have no published value yet (see docker-bake.hcl). The build fails until they are set.
RUN echo "*** Building Comskip V${VERSION} ***" && \
  curl -fL -o /tmp/comskip.tar.gz \
    "https://github.com/erikkaashoek/Comskip/archive/refs/tags/V${VERSION}.tar.gz" && \
  echo "${COMSKIP_SHA256}  /tmp/comskip.tar.gz" | sha256sum -c - && \
  mkdir -p /build/comskip && \
  tar -xzf /tmp/comskip.tar.gz -C /build/comskip --strip-components=1 && \
  cd /build/comskip && \
  ./autogen.sh && \
  ./configure --prefix=/usr/local && \
  make -j"$(nproc)" && \
  make DESTDIR=/out install

RUN echo "*** Building comchap ***" && \
  git clone https://github.com/BrettSheleski/comchap.git /build/comchap && \
  cd /build/comchap && \
  git checkout "${COMCHAP_COMMIT}" && \
  install -D -m 0755 comchap /out/usr/local/bin/comchap && \
  install -D -m 0755 comcut /out/usr/local/bin/comcut

RUN echo "*** Collecting licenses ***" && \
  mkdir -p /out/usr/share/licenses/post-recording && \
  find /build/comskip -maxdepth 1 -type f \( -iname 'COPYING*' -o -iname 'LICENSE*' \) \
    -exec cp {} /out/usr/share/licenses/post-recording/ \;

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

# UNVERIFIED: ccextractor and libsdl1.2-compat are taken from the Ubuntu archive; the fallback is building ccextractor in the build stage.
RUN echo "*** Installing runtime packages ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ccextractor \
    expect \
    ffmpeg \
    inotify-tools \
    libargtable2-0 \
    libsdl1.2-compat \
    mediainfo \
    tcl && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /out/usr/local/ /usr/local/
COPY --from=build /out/usr/share/licenses/post-recording/ /usr/share/licenses/post-recording/

ENV HOME=/config \
    TMPDIR=/tmp

RUN install -d -o apps -g apps /watch /backup

USER apps
COPY --chmod=0755 . /

VOLUME /config

CMD ["/start.sh"]
