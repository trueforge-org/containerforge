# UNVERIFIED: golang:1.22 tag and digest are not pinned yet; 1.22 matches the upstream builder
FROM golang:1.22@sha256:1cf6c45ba39db9fd6db16922041d074a63c935556a05c5ccb62d181034df7f02 AS build

# build variables
ARG VERSION
USER root

ENV GOCACHE=/tmp/go-cache \
    npm_config_cache=/tmp/npm-cache

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    libde265-dev \
    libheif-dev \
    libwebp-dev \
    libx265-dev \
    nodejs \
    npm \
    pkg-config && \
  echo "**** fetch source code ****" && \
  mkdir -p /src && \
  curl -fL \
    "https://github.com/DenDianUgerah/reubah/archive/${VERSION}.tar.gz" | tar xz -C \
    /src --strip-components=1 && \
  echo "**** build frontend ****" && \
  cd /src/templates && \
  npm install && \
  npm run build && \
  echo "**** build reubah ****" && \
  cd /src && \
  go mod download && \
  CGO_ENABLED=1 go build -o /out/reubah ./cmd/server && \
  cp -r /src/templates /src/static /out/ && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
USER root

ENV HOME=/tmp \
    PORT=8081

# UNVERIFIED: ubuntu 26.04 package names, and whether the full libreoffice set is needed (plan section 4)
# UNVERIFIED: upstream ships openjdk11-jre; not included until its purpose is confirmed
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    bash \
    curl \
    fonts-liberation \
    libde265-0 \
    libheif1 \
    libreoffice \
    libwebp7 \
    libx265-199 && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

COPY --from=build --chmod=0755 /out/ /app/
COPY --from=build /src/LICENSE /usr/share/licenses/reubah/LICENSE

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8081
VOLUME /config

WORKDIR /app
