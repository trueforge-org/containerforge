FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# Oracle publishes an amd64 deb only (arm64 returns 404), so fail fast elsewhere
RUN set -eux; \
  if [ "$TARGETARCH" != "amd64" ]; then \
    echo "mysql-workbench: no ${TARGETARCH} deb from Oracle" >&2; exit 1; \
  fi

# UNVERIFIED: add a SHA256 check once the deb has been downloaded and hashed.
# The MD5 below is the value Oracle publishes next to the deb.
RUN set -eux; \
  curl -fsSL -o /tmp/mysql-workbench.deb \
    "https://cdn.mysql.com/Downloads/MySQLGUITools/mysql-workbench-community_${VERSION}-1ubuntu24.04_amd64.deb"; \
  echo "15254a0e6c954d005b05ddbe0110d16e  /tmp/mysql-workbench.deb" | md5sum -c -

# UNVERIFIED: deps from the 24.04 deb must resolve on 26.04. Do not force with dpkg --force-depends.
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends /tmp/mysql-workbench.deb && \
  dpkg -s mysql-workbench-community >/dev/null && \
  rm -f /tmp/mysql-workbench.deb && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# UNVERIFIED: copyright path inside the deb, confirm on first build
RUN mkdir -p /usr/share/licenses/mysql-workbench && \
  cp /usr/share/doc/mysql-workbench-community/copyright /usr/share/licenses/mysql-workbench/LICENSE

ENV HOME=/config \
  XDG_CACHE_HOME=/tmp/.cache

USER apps
COPY --chmod=0755 . /

EXPOSE 3001
VOLUME /config
WORKDIR /config
