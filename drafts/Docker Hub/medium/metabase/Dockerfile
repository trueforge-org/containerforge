FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:22a0f8a73c79e2f733c7513aefceef24ab8a213fd35af0ab1946996efc21636d

# set version label
ARG VERSION
USER root

# environment settings (as upstream bin/docker/Dockerfile)
ENV FC_LANG="en-US" \
  LC_CTYPE="en_US.UTF-8"

RUN \
  echo "**** install metabase ****" && \
  mkdir -p /app /usr/share/licenses/metabase && \
  curl -fL -o /app/metabase.jar \
    "https://downloads.metabase.com/v${VERSION}/metabase.jar" && \
  # UNVERIFIED: no published checksum for the jar; pin a SHA-256 after a verified download.
  # UNVERIFIED: upstream installs fonts and CA packages on Alpine; not added until a failure shows they are needed.
  curl -fL -o /usr/share/licenses/metabase/LICENSE-AGPL.txt \
    "https://raw.githubusercontent.com/metabase/metabase/v${VERSION}/LICENSE-AGPL.txt" && \
  echo "**** link plugins dir to persistent storage ****" && \
  ln -sfn /config/plugins /plugins && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/*

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 3000
VOLUME /config
WORKDIR /config
