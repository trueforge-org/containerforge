FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  TZ=Etc/UTC

# Runtime libraries the prebuilt binary links against. Python is not included (UNVERIFIED need, see plan).
RUN echo "*** Installing runtime libraries ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libcurl3t64-gnutls \
    libmosquitto1 \
    libsqlite3-0 \
    libusb-0.1-4 \
    zlib1g && \
  rm -rf /var/lib/apt/lists/*

RUN echo "*** Installing Domoticz ***" && \
  case "${TARGETARCH}" in \
    amd64) arch=x86_64 ;; \
    arm64) arch=aarch64 ;; \
    *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fsSL -o /tmp/domoticz.tgz \
    "https://github.com/domoticz/domoticz/releases/download/${VERSION}/domoticz_linux_${arch}.tgz" && \
  curl -fsSL -o /tmp/domoticz.tgz.sha256sum \
    "https://github.com/domoticz/domoticz/releases/download/${VERSION}/domoticz_linux_${arch}.tgz.sha256sum" && \
  echo "$(awk '{print $1}' /tmp/domoticz.tgz.sha256sum)  /tmp/domoticz.tgz" | sha256sum -c - && \
  tar xzf /tmp/domoticz.tgz -C /app/ && \
  mkdir -p /usr/share/licenses/domoticz && \
  cp /app/License.txt /usr/share/licenses/domoticz/License.txt && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -f /tmp/domoticz.tgz /tmp/domoticz.tgz.sha256sum

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
