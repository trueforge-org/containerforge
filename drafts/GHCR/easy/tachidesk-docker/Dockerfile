
# Base: java25 (upstream image runs Temurin 25). Digest taken from apps/*/Dockerfile for the same tag.
FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:3db5983d5bd504865ac842efb282bcbdbd286adbc116fc18645ec3c433eba44a

ARG VERSION

ENV \
  HOME=/config \
  MALLOC_ARENA_MAX=2 \
  JDK_JAVA_OPTIONS="-XX:TrimNativeHeapInterval=60000 -XX:G1PeriodicGCInterval=300000 -XX:MaxHeapFreeRatio=30 -XX:MinHeapFreeRatio=10"

USER root

RUN echo "*** Installing Suwayomi-Server ***" && \
  mkdir -p /app/tachidesk && \
  curl -fsSL --proto '=https' -o \
    /app/tachidesk/Suwayomi-Server.jar \
    "https://github.com/Suwayomi/Suwayomi-Server/releases/download/v${VERSION}/Suwayomi-Server-v${VERSION}.jar" && \
  echo "dd05d523cc785b7acf90c9feac0bc84c53d5fb3af5ab2a33653646e2076e5217  /app/tachidesk/Suwayomi-Server.jar" | sha256sum -c - && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/tachidesk-docker && \
  curl -fsSL --proto '=https' -o \
    /usr/share/licenses/tachidesk-docker/LICENSE \
    "https://raw.githubusercontent.com/Suwayomi/Suwayomi-Server/v${VERSION}/LICENSE" && \
  chown -R apps:apps /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

WORKDIR /app/tachidesk

EXPOSE 4567

VOLUME /config
