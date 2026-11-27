
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG FSM_SHA256
ARG TARGETARCH
USER root

# Factorio server manager is a prebuilt x86_64 binary and Factorio headless is x86_64 only.
# Factorio itself is NOT baked into the image: start.sh downloads it into /config on first start.
ENV HOME=/config

RUN echo "*** Installing Factorio Server Manager ***" && \
  if [ "${TARGETARCH}" != "amd64" ]; then echo "FSM and Factorio are x86_64 only"; exit 1; fi && \
  curl -fsSL -o /tmp/fsm.zip \
    "https://github.com/OpenFactorioServerManager/factorio-server-manager/releases/download/${VERSION}/factorio-server-manager-linux-${VERSION}.zip" && \
  echo "${FSM_SHA256}  /tmp/fsm.zip" | sha256sum -c - && \
  mkdir -p /tmp/fsm-extract /app && \
  unzip -q /tmp/fsm.zip -d /tmp/fsm-extract && \
  mv /tmp/fsm-extract/factorio-server-manager /app/fsm && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/factorioservermanager && \
  curl -fsSL -o /usr/share/licenses/factorioservermanager/LICENSE \
    "https://raw.githubusercontent.com/OpenFactorioServerManager/factorio-server-manager/${VERSION}/LICENSE.md" && \
  echo "*** Cleaning Up ***" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /


EXPOSE 8080
EXPOSE 34197/udp

VOLUME /config

WORKDIR /app/fsm
CMD ["/start.sh"]
