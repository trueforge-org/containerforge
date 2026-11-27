# Base as used by apps/airsonic-advanced and apps/java21 (Java runtime, USER apps).
# UNVERIFIED: Komga 1.30.2 is built against Temurin 25 upstream. Confirm it starts on Java 21, else switch to java25.
FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:5651f46cebe5a42ff069da176dd7ab50f6b050169493fe06ebc1be2fe81cd15e

ARG VERSION
ARG JAR_SHA256

ENV KOMGA_CONFIGDIR=/config

USER root

# Verify the release jar against the sha256 from the release checksums_sha256.txt (see docker-bake.hcl).
# UNVERIFIED: the LICENSE URL pattern at the tag; check on the first build.
RUN set -eux; \
    mkdir -p /app/komga /usr/share/licenses/komga; \
    curl -fsSL -o /app/komga/komga.jar \
      "https://github.com/gotson/komga/releases/download/${VERSION}/komga-${VERSION}.jar"; \
    echo "${JAR_SHA256}  /app/komga/komga.jar" | sha256sum -c -; \
    curl -fsSL -o /usr/share/licenses/komga/LICENSE \
      "https://raw.githubusercontent.com/gotson/komga/${VERSION}/LICENSE"; \
    chown -R root:root /app/komga /usr/share/licenses/komga; \
    chmod -R 755 /app/komga /usr/share/licenses/komga

USER apps
COPY --chmod=0755 . /

WORKDIR /config
VOLUME ["/config"]
EXPOSE 25600
