FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:3db5983d5bd504865ac842efb282bcbdbd286adbc116fc18645ec3c433eba44a

# set version label
ARG VERSION
USER root

# the tarball is prebuilt, so no build stage is needed (upstream builds with ant on JDK 24)
RUN \
  echo "**** install yacy ****" && \
  mkdir -p /tmp/yacy-src /app /usr/share/licenses/yacy && \
  # UNVERIFIED: no published .sha256 found on download.yacy.net; record the SHA-256 of the fetched file in the PR.
  curl -fL -o /tmp/yacy.tar.gz "https://download.yacy.net/yacy_v${VERSION}.tar.gz" && \
  tar xzf /tmp/yacy.tar.gz -C /tmp/yacy-src --no-same-owner && \
  # UNVERIFIED: assumes the tarball has a single top-level directory
  mv /tmp/yacy-src/*/ /app/yacy_search_server && \
  # UNVERIFIED: LICENSE is at the top level of the tarball
  cp /app/yacy_search_server/LICENSE /usr/share/licenses/yacy/ && \
  find /app/yacy_search_server -maxdepth 1 \( -name '*.exe' -o -name '*.dmg' \) -delete && \
  echo "**** move shipped DATA aside, persistent DATA goes to /config ****" && \
  if [ -d /app/yacy_search_server/DATA ]; then \
    mv /app/yacy_search_server/DATA /app/yacy_search_server/DATA-default; \
  else \
    mkdir -p /app/yacy_search_server/DATA-default; \
  fi && \
  ln -s /config/DATA /app/yacy_search_server/DATA && \
  chmod -R a+rX /app/yacy_search_server && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/*

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8090 8443
VOLUME /config
WORKDIR /app/yacy_search_server
