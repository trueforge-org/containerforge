FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
ARG ARIANG_SHA256

USER root

RUN echo "*** Downloading AriaNg ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends unzip && \
  curl -fsSL -o /tmp/ariang.zip \
    "https://github.com/mayswind/AriaNg/releases/download/${VERSION}/AriaNg-${VERSION}.zip" && \
  echo "${ARIANG_SHA256}  /tmp/ariang.zip" | sha256sum -c - && \
  mkdir -p /tmp/dist && \
  unzip -q /tmp/ariang.zip -d /tmp/dist && \
  rm -f /tmp/ariang.zip && \
  rm -rf /var/lib/apt/lists/*

FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

USER root
COPY --from=build --chown=568:568 /tmp/dist/ /usr/share/nginx/html
COPY --from=build /tmp/dist/LICENSE /usr/share/licenses/ariang/LICENSE

COPY --chmod=755 ./ /

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
