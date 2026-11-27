FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS buildstage

ARG VERSION
ARG TARGETARCH
USER root

# amd64: upstream portable tarball, pinned by sha256 (computed from the download, no published checksum).
# Update the checksum on every version bump.
# arm64: no vendor tarball, so the daemon is compiled with CMake.
# UNVERIFIED: the apt package list for the arm64 compile is inferred and not checked against CMakeLists.txt
RUN echo "*** Installing airdcpp-webclient ***" && \
  mkdir -p /app && \
  if [ "$TARGETARCH" = "amd64" ]; then \
    curl -fL -o \
      /tmp/airdcpp.tar.gz \
      "https://web-builds.airdcpp.net/stable/airdcpp_${VERSION}_webui-${VERSION}_64-bit_portable.tar.gz" && \
    echo "fe89c40d1bbb11350e5e175f60ca9de325dbc6e5a778024429ba1bdf633bad1a  /tmp/airdcpp.tar.gz" | sha256sum -c - && \
    tar xzf \
      /tmp/airdcpp.tar.gz -C \
      /app/ && \
    rm /tmp/airdcpp.tar.gz; \
  else \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential cmake git nodejs npm \
      libboost-all-dev libssl-dev libcurl4-openssl-dev libsqlite3-dev \
      libbz2-dev zlib1g-dev libicu-dev libminiupnpc-dev libnatpmp-dev \
      libmaxminddb-dev libtbb-dev && \
    git clone --depth 1 --branch "${VERSION}" --recurse-submodules \
      https://github.com/airdcpp-web/airdcpp-webclient /tmp/airdcpp-src && \
    mkdir -p /tmp/airdcpp-src/build && \
    cd /tmp/airdcpp-src/build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DINSTALL_WEB_UI=ON \
      -DCMAKE_INSTALL_PREFIX=/app/airdcpp-webclient .. && \
    make -j"$(nproc)" && \
    make install && \
    rm -rf /tmp/airdcpp-src; \
  fi && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/* /var/lib/apt/lists/*

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
USER root

ENV HOME=/config

COPY --from=buildstage /app /app

# No license file ships with the tarball or repo. The license comes from the GPL headers in the source.
RUN mkdir -p /usr/share/licenses/airdcpp-webclient && \
  printf '%s\n' \
    "AirDC++ Web Client is licensed under GPL-2.0-or-later (see the source file headers)." \
    "Source: https://github.com/airdcpp-web/airdcpp-webclient" \
    > /usr/share/licenses/airdcpp-webclient/NOTICE && \
  chown -R apps:apps /app && \
  chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 5600 5601 21248 21249

VOLUME /config
