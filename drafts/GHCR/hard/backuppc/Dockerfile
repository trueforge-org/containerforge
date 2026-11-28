
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
ARG BACKUPPC_XS_VERSION=0.62
ARG RSYNC_BPC_COMMIT=1ad3f70
# UNVERIFIED: SHA256 of BackupPC-${VERSION}.tar.gz. The release has no checksum file, so compute it once by hand and record it here.
# The build fails while this is empty.
ARG BACKUPPC_SHA256=""
USER root

# environment variables.
ENV HOME=/config \
  XDG_CONFIG_HOME=/config

# UNVERIFIED: Ubuntu package names. The web server (lighttpd or Apache) is not chosen yet, so it is not installed here.
# UNVERIFIED: par2 comes from Alpine edge upstream, so the Ubuntu package may differ.
# UNVERIFIED: sshd (openssh-server) and port 22 are not part of this draft.
RUN \
  echo "**** install packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    rsync \
    openssh-client \
    samba-client \
    rrdtool \
    supervisor \
    msmtp \
    pigz \
    par2 \
    tzdata \
    perl \
    libarchive-zip-perl \
    libxml-rss-perl \
    libcgi-pm-perl \
    libfile-listing-perl \
    libjson-xs-perl \
    libtime-parsedate-perl \
    ca-certificates && \
  echo "**** build backuppc xs and rsync-bpc ****" && \
  apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    make \
    autoconf \
    automake \
    libperl-dev \
    libacl1-dev \
    git && \
  git clone --depth 1 --branch "${BACKUPPC_XS_VERSION}" \
    https://github.com/backuppc/backuppc-xs.git /tmp/backuppc-xs && \
  cd /tmp/backuppc-xs && \
  perl Makefile.PL && \
  make -j"$(nproc)" && \
  make test && \
  make install && \
  cd / && \
  git clone https://github.com/backuppc/rsync-bpc.git /tmp/rsync-bpc && \
  cd /tmp/rsync-bpc && \
  git checkout "${RSYNC_BPC_COMMIT}" && \
  ./configure \
    --disable-md2man \
    --disable-openssl \
    --disable-xxhash \
    --disable-zstd \
    --disable-lz4 && \
  make && \
  make install && \
  cd / && \
  echo "**** download and verify backuppc ****" && \
  mkdir -p \
    /tmp/backuppc \
    /app/backuppc && \
  curl -fsSL -o \
    "/tmp/backuppc/BackupPC-${VERSION}.tar.gz" \
    "https://github.com/backuppc/backuppc/releases/download/${VERSION}/BackupPC-${VERSION}.tar.gz" && \
  echo "${BACKUPPC_SHA256}  /tmp/backuppc/BackupPC-${VERSION}.tar.gz" | sha256sum -c - && \
  tar -xzf \
    "/tmp/backuppc/BackupPC-${VERSION}.tar.gz" \
    -C /app/backuppc \
    --strip-components=1 && \
  # UNVERIFIED: the LICENSE path inside the tarball.
  mkdir -p \
    /usr/share/licenses/backuppc && \
  install -m 0644 \
    /app/backuppc/LICENSE \
    /usr/share/licenses/backuppc/LICENSE && \
  echo "**** set permissions ****" && \
  chown -R root:root \
    /app/backuppc && \
  chmod -R a+rX \
    /app/backuppc && \
  echo "**** cleanup ****" && \
  apt-get purge -y --auto-remove \
    gcc \
    g++ \
    make \
    autoconf \
    automake \
    libperl-dev \
    libacl1-dev \
    git && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

# copy files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 8080
VOLUME /config
WORKDIR /config
ENTRYPOINT ["/start.sh"]
