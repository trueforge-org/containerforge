
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# package versions

# environment variables.
ENV HOME=/config

RUN \
  echo "**** install packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    libicu74 \
    iputils-ping && \
  echo "**** install dotnet sdk ****" && \
  mkdir -p /app/dotnet && \
  curl -o /tmp/dotnet-install.sh -L \
    https://dot.net/v1/dotnet-install.sh && \
  chmod +x /tmp/dotnet-install.sh && \
  /tmp/dotnet-install.sh -c 9.0 --install-dir /app/dotnet --runtime dotnet && \
  echo "**** install webgrabplus ****" && \
  if [ -z "$VERSION" ]; then \
    VERSION=$(curl -fsL https://webgrabplus.com/download/sw | grep -m1 /download/sw/v | sed 's|.*/download/sw/v\(.*\)">V.*|\1|'); \
  fi && \
  echo "Found Webgrabplus version ${VERSION}" && \
  WEBGRAB_URL=$(curl -fsL https://webgrabplus.com/download/sw/v${VERSION} | grep -Eo 'https://[^"]+\\.gz' | head -n1) && \
  mkdir -p \
    /app/wg++ && \
  curl -o /tmp/wg++.tar.gz -L \
    "${WEBGRAB_URL}" && \
  tar xzf \
    /tmp/wg++.tar.gz -C \
    /app/wg++ --strip-components=1 && \
  echo "**** download siteini.pack ****" && \
  mkdir -p /defaults/ini && \
  curl -o \
    /tmp/ini.zip -L \
    https://www.webgrabplus.com/sites/default/files/download/ini/SiteIniPack_current.zip && \
  unzip -q /tmp/ini.zip -d /defaults/ini/ && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# copy files
USER apps
COPY . /
COPY ./root /

# ports and volumes
VOLUME /config
VOLUME /data

WORKDIR /config
