
# java21 matches upstream JRE 21 (ARG JAVA_VERSION=21 in upstream deployment/Dockerfile)
FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:5651f46cebe5a42ff069da176dd7ab50f6b050169493fe06ebc1be2fe81cd15e

ARG VERSION

ENV HOME=/config

USER root

# nginx serves the static client on 3000 and proxies /api to the backend on 8080
# UNVERIFIED: pin nginx to the ubuntu 26.04 candidate (apt-cache policy nginx) at the build round
RUN echo "*** Installing nginx ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends nginx && \
  rm -rf /var/lib/apt/lists/*

# No upstream checksum is published; sha256 to be recorded at the build round and noted in the PR
RUN echo "*** Installing plant-it ${VERSION} ***" && \
  mkdir -p /app/plant-it/backend /app/plant-it/frontend/build/web /usr/share/licenses/plant-it && \
  curl -fsSL -o /app/plant-it/backend/app.jar \
    "https://github.com/MDeLuise/plant-it/releases/download/${VERSION}/server.jar" && \
  curl -fsSL -o /tmp/plant-it-client.tar.gz \
    "https://github.com/MDeLuise/plant-it/releases/download/${VERSION}/client.tar.gz" && \
  tar xzf /tmp/plant-it-client.tar.gz -C /app/plant-it/frontend/build/web && \
  curl -fsSL -o /usr/share/licenses/plant-it/LICENSE \
    "https://raw.githubusercontent.com/MDeLuise/plant-it/${VERSION}/LICENSE.txt" && \
  rm -f /tmp/plant-it-client.tar.gz && \
  chown -R apps:apps /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 3000 8080

VOLUME /config
WORKDIR /config
