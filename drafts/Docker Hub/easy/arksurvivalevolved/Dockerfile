FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1
# UNVERIFIED: no digest pinned yet. Run `docker buildx imagetools inspect` on this tag and add @sha256 before merging.

ARG VERSION

USER root

ENV \
  HOME=/config \
  XDG_DATA_HOME=/config

# arkmanager shells out to these tools. Not pinned: they are not the app version.
# UNVERIFIED: package names on ubuntu 26.04, and whether the steamcmd base already has some of them (check dpkg -l).
RUN echo "*** Installing arkmanager runtime deps ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    bzip2 \
    lsof \
    perl-modules \
    rsync \
    libc6-i386 && \
  rm -rf /var/lib/apt/lists/*

# Clone the release tag (no checksum is published for the tag tarball).
# UNVERIFIED: the install.sh option set. Upstream v1.6.69 takes <user> or --me and installs to
# /usr/local/bin and /etc/arkmanager. Confirm it creates no sudoers, cron or service files.
RUN echo "*** Installing arkmanager ${VERSION} ***" && \
  cd /tmp && \
  git clone --depth 1 --branch "v${VERSION}" https://github.com/arkmanager/ark-server-tools.git ast && \
  cd ast/tools && \
  ./install.sh --me && \
  mkdir -p /usr/share/licenses/arksurvivalevolved && \
  cp /tmp/ast/LICENSE /usr/share/licenses/arksurvivalevolved/LICENSE && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 7777/udp 7778/udp 27015/udp 27020/tcp

WORKDIR /config
VOLUME /config
