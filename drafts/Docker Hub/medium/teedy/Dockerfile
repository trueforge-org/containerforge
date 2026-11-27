# syntax=docker/dockerfile:1

# JDK 25 base matches the upstream runtime (ubuntu:26.04 with openjdk-25).
FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:22a0f8a73c79e2f733c7513aefceef24ab8a213fd35af0ab1946996efc21636d

ARG VERSION
USER root

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    JAVA_OPTIONS="-Dfile.encoding=UTF-8 -Xmx1g" \
    JETTY_VERSION=12.1.6 \
    JETTY_HOME=/opt/jetty

# Runtime tools: ffmpeg and mediainfo for media, tesseract for OCR.
# Only the English OCR language is installed here; add tesseract-ocr-<lang> packages if needed.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        mediainfo \
        tesseract-ocr \
        tesseract-ocr-eng; \
    rm -rf /var/lib/apt/lists/*

# Jetty 12.1.6 home, verified against the .sha256 published next to the tarball on Maven Central.
RUN set -eux; \
    mkdir -p /opt/jetty; \
    curl -fsSL -o /tmp/jetty.tar.gz "https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-home/${JETTY_VERSION}/jetty-home-${JETTY_VERSION}.tar.gz"; \
    curl -fsSL -o /tmp/jetty.tar.gz.sha256 "https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-home/${JETTY_VERSION}/jetty-home-${JETTY_VERSION}.tar.gz.sha256"; \
    echo "$(cut -d' ' -f1 /tmp/jetty.tar.gz.sha256)  /tmp/jetty.tar.gz" | sha256sum -c -; \
    tar xzf /tmp/jetty.tar.gz -C /opt/jetty --strip-components=1; \
    rm -f /tmp/jetty.tar.gz /tmp/jetty.tar.gz.sha256

# Teedy WAR and Jetty context, then the Jetty modules the upstream image adds at build time.
# UNVERIFIED: release asset name docs-web-<ver>.war and its SHA-256 are not checked yet; pin the checksum after the first download.
# UNVERIFIED: the docs.home value in docs.xml is assumed to be /data; the sed below rewrites it to /config/data.
RUN set -eux; \
    mkdir -p /app/webapps; \
    curl -fsSL -o /app/webapps/docs.war "https://github.com/sismics/docs/releases/download/v${VERSION}/docs-web-${VERSION}.war"; \
    curl -fsSL -o /app/webapps/docs.xml "https://raw.githubusercontent.com/sismics/docs/v${VERSION}/docs.xml"; \
    sed -i 's#/data#/config/data#g' /app/webapps/docs.xml; \
    cd /app; \
    java -jar /opt/jetty/start.jar --add-modules=server,http,ee11-webapp,ee11-deploy

# UNVERIFIED: the LICENSE file name on the upstream tag.
RUN set -eux; \
    mkdir -p /usr/share/licenses/teedy; \
    curl -fsSL -o /usr/share/licenses/teedy/LICENSE "https://raw.githubusercontent.com/sismics/docs/v${VERSION}/LICENSE"

RUN set -eux; \
    chown -R root:root /app /opt/jetty; \
    chmod -R 755 /app /opt/jetty

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /config
