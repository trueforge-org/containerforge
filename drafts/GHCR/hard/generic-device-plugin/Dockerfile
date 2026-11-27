# UNVERIFIED: pin the golang build image digest at implementation time (plan section 3).
FROM docker.io/library/golang:1.27 AS build

# build variables
ARG VERSION
ARG TARGETOS
ARG TARGETARCH
USER root

RUN \
  echo "**** fetch source code ****" && \
  mkdir -p /tmp/src /tmp/out && \
  curl -fL -o /tmp/generic-device-plugin-src.tar.gz \
    "https://github.com/squat/generic-device-plugin/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/generic-device-plugin-src.tar.gz -C /tmp/src --strip-components=1

# UNVERIFIED: no upstream checksum for the source tarball; record sha256 at implementation time.
RUN \
  echo "**** compile generic-device-plugin ****" && \
  cd /tmp/src && \
  CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
  GOCACHE=/tmp/gocache GOPATH=/tmp/gopath \
  go build -trimpath \
    -ldflags "-s -w -X github.com/squat/generic-device-plugin/version.Version=${VERSION}" \
    -o /tmp/out/generic-device-plugin .

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
USER root

# add generic-device-plugin
COPY --from=build /tmp/out/generic-device-plugin /app/generic-device-plugin/generic-device-plugin
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/generic-device-plugin/LICENSE

RUN \
  echo "**** set permissions ****" && \
  chown -R apps:apps /app/generic-device-plugin && \
  chmod -R 755 /app/generic-device-plugin

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080

WORKDIR /config
VOLUME /config
