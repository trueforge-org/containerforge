FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
ARG BUILD
ARG TARGETARCH
USER root

# UNVERIFIED: sha256 per arch is not yet read from the v13.3.2 release page. The build must fail until these are filled in.
RUN echo "*** Downloading Grafana OSS ${VERSION} ***" && \
  case "${TARGETARCH}" in \
    amd64) GRAFANA_SHA256="<UNVERIFIED-sha256-amd64>" ;; \
    arm64) GRAFANA_SHA256="<UNVERIFIED-sha256-arm64>" ;; \
    *) echo "unsupported arch: ${TARGETARCH}" && exit 1 ;; \
  esac && \
  curl -fL -o \
    /tmp/grafana.deb \
    "https://github.com/grafana/grafana/releases/download/v${VERSION}/grafana_${VERSION}_${BUILD}_linux_${TARGETARCH}.deb" && \
  echo "${GRAFANA_SHA256}  /tmp/grafana.deb" | sha256sum -c - && \
  dpkg-deb -x /tmp/grafana.deb /tmp/grafana-root && \
  rm /tmp/grafana.deb

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

COPY --from=build /tmp/grafana-root/usr/share/grafana /app/grafana
COPY --from=build /tmp/grafana-root/etc/grafana /etc/grafana
# UNVERIFIED: copyright file path inside the .deb; replace with the LICENSE from the release tag if it is missing.
COPY --from=build /tmp/grafana-root/usr/share/doc/grafana/copyright /usr/share/licenses/grafana/LICENSE

ENV \
  GF_PATHS_CONFIG=/etc/grafana/grafana.ini \
  GF_PATHS_HOME=/app/grafana \
  GF_PATHS_DATA=/config/data \
  GF_PATHS_LOGS=/config/log \
  GF_PATHS_PLUGINS=/config/plugins \
  GF_PATHS_PROVISIONING=/etc/grafana/provisioning \
  PATH=/app/grafana/bin:$PATH

USER apps
COPY --chmod=0755 . /

EXPOSE 3000

VOLUME /config

WORKDIR /config
