
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  BOLT_PATH=/config/chronograf-v1.db

# The vendor deb is verified against the InfluxData signing key before extraction.
RUN echo "*** Installing Chronograf ${VERSION} ***" && \
  mkdir -p /tmp/chronograf && \
  cd /tmp/chronograf && \
  curl -fsSLO "https://dl.influxdata.com/chronograf/releases/chronograf_${VERSION}_${TARGETARCH}.deb" && \
  curl -fsSLO "https://dl.influxdata.com/chronograf/releases/chronograf_${VERSION}_${TARGETARCH}.deb.asc" && \
  export GNUPGHOME="$(mktemp -d)" && \
  (gpg --batch --keyserver hkps://keyserver.ubuntu.com --recv-keys 24C975CBA61A024EE1B631787C3D57159FC2F927 || \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys 24C975CBA61A024EE1B631787C3D57159FC2F927) && \
  gpg --batch --verify "chronograf_${VERSION}_${TARGETARCH}.deb.asc" "chronograf_${VERSION}_${TARGETARCH}.deb" && \
  dpkg-deb -x "chronograf_${VERSION}_${TARGETARCH}.deb" /tmp/chronograf/root && \
  install -D -m 0755 /tmp/chronograf/root/usr/bin/chronograf /app/chronograf && \
  mkdir -p /usr/share/chronograf && \
  cp -a /tmp/chronograf/root/usr/share/chronograf/. /usr/share/chronograf/ && \
  mkdir -p /usr/share/licenses/chronograf && \
  # The vendor deb ships no license file, so the upstream repo LICENSE is fetched at the tag.
  curl -fsSL -o /usr/share/licenses/chronograf/LICENSE \
    "https://raw.githubusercontent.com/influxdata/chronograf/${VERSION}/LICENSE" && \
  chown -R apps:apps /app && \
  chmod -R 755 /app && \
  rm -rf /tmp/chronograf "$GNUPGHOME"

USER apps
COPY --chmod=0755 . /

EXPOSE 8888

VOLUME /config
