# hadolint ignore=DL3007
# UNVERIFIED: every source build below is a draft. The build has not been run.
# tcllauncher, piaware-web and mlat-client are cloned from their default branch because the upstream
# sdr-enthusiasts Dockerfile does the same. Pin them to tags before merge.
# UNVERIFIED: ubuntu 26.04 package names for the build and runtime lists are copied from the upstream
# Dockerfile (bedde2040). Check each one on packages.ubuntu.com.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION

USER root
WORKDIR /src

# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        automake \
        build-essential \
        cmake \
        file \
        git \
        libboost-program-options-dev \
        libboost-regex-dev \
        libboost-system-dev \
        libncurses-dev \
        librtlsdr-dev \
        libusb-1.0-0-dev \
        pkg-config \
        python3-dev \
        python3-setuptools \
        python3-venv \
        tcl-dev \
    && rm -rf /var/lib/apt/lists/*

# piaware and dump1090-fa are released together, so both use the same tag as VERSION (no "v" in VERSION).
# UNVERIFIED: dump1090 repository name (flightaware/dump1090) for dump1090-fa.
RUN git clone --depth 1 --branch "v${VERSION}" https://github.com/flightaware/piaware.git /src/piaware && \
    git clone --depth 1 --branch "v${VERSION}" https://github.com/flightaware/dump1090.git /src/dump1090 && \
    git clone --depth 1 https://github.com/flightaware/tcllauncher.git /src/tcllauncher && \
    git clone --depth 1 https://github.com/flightaware/piaware-web.git /src/piaware-web && \
    git clone --depth 1 https://github.com/mutability/mlat-client.git /src/mlat-client

# Build caches go to /tmp.
ENV HOME=/tmp \
    PIP_CACHE_DIR=/tmp/pip

RUN cd /src/tcllauncher && \
    autoconf && \
    ./configure --prefix=/usr/local && \
    make && \
    make DESTDIR=/out install

# UNVERIFIED: `make install DESTDIR` support for piaware. Upstream writes /etc/piaware.conf and /run/piaware itself.
RUN cd /src/piaware && \
    make && \
    make DESTDIR=/out install

# RTLSDR=yes is required for the RTL-SDR receiver. The upstream image ships the binaries under these names.
RUN cd /src/dump1090 && \
    make RTLSDR=yes && \
    install -Dm0755 dump1090 /out/usr/local/bin/dump1090-fa && \
    install -Dm0755 faup1090 /out/usr/lib/piaware/helpers/faup1090

RUN mkdir -p /out/app/www && \
    cp -a /src/piaware-web/web/. /out/app/www/

# mlat-client runs from a venv at /app/venv. It is read-only at runtime.
RUN python3 -m venv /app/venv && \
    /app/venv/bin/pip install --no-cache-dir /src/mlat-client && \
    rm -rf /tmp/*

# UNVERIFIED: license file names inside the upstream repositories.
RUN install -Dm0644 /src/piaware/LICENSE /out/usr/share/licenses/piaware/LICENSE && \
    install -Dm0644 /src/dump1090/COPYING /out/usr/share/licenses/piaware/dump1090-COPYING && \
    install -Dm0644 /src/dump1090/MLAT-RESULTS-LICENSE.md /out/usr/share/licenses/piaware/MLAT-RESULTS-LICENSE.md

# ---------------------------------------------------------------------------
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

USER root

# UNVERIFIED: the boost runtime libraries are versioned package names. Add the 26.04 runtime package names
# for libboost-system, libboost-program-options and libboost-regex after checking packages.ubuntu.com.
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libatomic1 \
        libncurses6 \
        libusb-1.0-0 \
        librtlsdr0 \
        lighttpd \
        lighttpd-mod-deflate \
        net-tools \
        procps \
        python3-minimal \
        socat \
        tcl \
        tcl-tls \
        tcllib \
        tclx \
        itcl3 \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=build /out/ /
COPY --from=build /app/venv /app/venv

ENV HOME=/tmp \
    TZ=Etc/UTC

USER apps
COPY --chmod=0755 . /

EXPOSE 8080 30003 30005

VOLUME /config
WORKDIR /config

CMD ["/start.sh"]
