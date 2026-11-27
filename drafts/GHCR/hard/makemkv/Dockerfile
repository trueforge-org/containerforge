FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS makemkv-build

ARG VERSION
USER root

# UNVERIFIED: build dependencies for makemkv-oss (Qt5 GUI, zlib, expat, openssl).
# Confirm against the tarball's own build files, since upstream /build/build.sh was not read.
RUN \
    echo "**** install build deps ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        libexpat1-dev \
        libssl-dev \
        pkg-config \
        qtbase5-dev \
        zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download the vendor tarballs and the checksum list, then verify. The PGP signature of the
# checksum list is NOT verified here (known gap, state it in the PR).
WORKDIR /tmp/makemkv
RUN \
    echo "**** fetch and verify sources ****" && \
    curl -fsSL -o "makemkv-bin-${VERSION}.tar.gz" "https://www.makemkv.com/download/makemkv-bin-${VERSION}.tar.gz" && \
    curl -fsSL -o "makemkv-oss-${VERSION}.tar.gz" "https://www.makemkv.com/download/makemkv-oss-${VERSION}.tar.gz" && \
    curl -fsSL -o makemkv-sha.txt "https://www.makemkv.com/download/makemkv-sha-${VERSION}.txt" && \
    grep -E "makemkv-(bin|oss)-${VERSION}\.tar\.gz" makemkv-sha.txt | sha256sum -c -

# UNVERIFIED: build steps. The OSS part must be built on glibc ubuntu, not the upstream musl alpine stage.
# The exact make targets and the vendor EULA acceptance step must be read from the tarballs.
RUN \
    echo "**** build makemkv-oss ****" && \
    tar -xzf "makemkv-oss-${VERSION}.tar.gz" && \
    cd "makemkv-oss-${VERSION}" && \
    make -f makefile.linux && \
    make -f makefile.linux DESTDIR=/out PREFIX=/opt/makemkv install

RUN \
    echo "**** install makemkv-bin ****" && \
    tar -xzf "makemkv-bin-${VERSION}.tar.gz" && \
    cd "makemkv-bin-${VERSION}" && \
    make DESTDIR=/out PREFIX=/opt/makemkv install

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

# UNVERIFIED: runtime packages on ubuntu 26.04. Upstream also installs openjdk8-jre-base (Alpine); purpose not checked, not installed here.
RUN \
    echo "**** install runtime deps ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        fonts-croscore \
        libqt5core5t64 \
        libqt5gui5 \
        libqt5network5 \
        libqt5widgets5 \
        libqt5x11extras5 \
        libqt5xml5 \
        lsscsi \
        novnc \
        sg3-utils \
        websockify \
        x11vnc \
        x11-utils \
        xvfb && \
    echo "**** license ****" && \
    mkdir -p /usr/share/licenses/makemkv && \
    echo "UNVERIFIED: MakeMKV license texts (makemkv-oss and makemkv-bin EULA) to be copied from the tarballs in the build stage." \
        > /usr/share/licenses/makemkv/NOTICE && \
    echo "**** filesystem setup ****" && \
    mkdir -p /config /storage /output && \
    chown apps:apps /config /storage /output && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=makemkv-build /out/opt/makemkv /opt/makemkv
RUN chown -R apps:apps /opt/makemkv && chmod -R 0755 /opt/makemkv

ENV HOME=/config \
    XDG_CACHE_HOME=/tmp/xdg/cache \
    DISPLAY=:1

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 5800 5900
VOLUME /config

WORKDIR /tmp
