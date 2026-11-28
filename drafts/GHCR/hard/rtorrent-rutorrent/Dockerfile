# Draft from plan.md (rtorrent-rutorrent). Not built or tested. UNVERIFIED items are marked.
# The upstream image is Alpine (crazymax/alpine-s6). This one is built on Ubuntu 26.04 because rTorrent
# is an apt package there and the musl image cannot be reused (plan section 3).

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# ruTorrent git commit SHA, used as the content address for the web UI.
ARG VERSION
# sha256 of the ruTorrent archive, recorded at build time. No checksum is published.
ARG RUTORRENT_SHA256=""

USER root
RUN echo "*** Installing rTorrent and web stack ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    rtorrent=0.9.8-1.1ubuntu2 \
    nginx \
    php-fpm php-xml php-mbstring php-curl \
    ffmpeg mediainfo sox && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: nginx and php-fpm versions are not pinned yet. Pin them against the 26.04 archive before the PR.
# ruTorrent is read-only in /app. Its share/ and conf/users are symlinks into /config (plan section 9).
# UNVERIFIED: /usr/share/doc/rtorrent/copyright is the Debian-style licence path. rTorrent is GPL-2.0-only.
RUN echo "*** Fetching ruTorrent ***" && \
  curl -fL -o /tmp/rutorrent.tar.gz \
    "https://github.com/Novik/ruTorrent/archive/${VERSION}.tar.gz" && \
  if [ -n "${RUTORRENT_SHA256}" ]; then \
    echo "${RUTORRENT_SHA256}  /tmp/rutorrent.tar.gz" | sha256sum -c -; \
  fi && \
  mkdir -p /app/rutorrent && \
  tar -xzf /tmp/rutorrent.tar.gz -C /app/rutorrent --strip-components=1 && \
  rm -rf /app/rutorrent/conf/users /app/rutorrent/share /tmp/rutorrent.tar.gz && \
  ln -s /config/rutorrent/share /app/rutorrent/share && \
  ln -s /config/rutorrent/users /app/rutorrent/conf/users && \
  mkdir -p /usr/share/licenses/rtorrent-rutorrent && \
  cp /usr/share/doc/rtorrent/copyright /usr/share/licenses/rtorrent-rutorrent/rtorrent-copyright && \
  chmod -R a=rX /app/rutorrent

ENV HOME=/config \
  TMPDIR=/tmp

USER apps
COPY --chmod=0755 . /

# Non-root cannot bind port 80, so nginx listens on 8080 (plan section 9).
# SCGI (5000) and the peer port (50000) are not exposed here (plan section 4, 6).
EXPOSE 8080
VOLUME /config
VOLUME /downloads
