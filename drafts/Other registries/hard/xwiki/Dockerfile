# Build stage: fetch and verify Tomcat, the XWiki WAR, the PostgreSQL JDBC driver and LibreOffice.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
ARG TARGETARCH
USER root

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl unzip; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /tmp/dl /tmp/libreoffice /usr/local/tomcat

# Apache Tomcat 10.1.62, checked against the sha512 published next to the tarball.
RUN set -eux; \
    curl -fSL --retry 5 -o /tmp/dl/tomcat.tar.gz \
        https://downloads.apache.org/tomcat/tomcat-10/v10.1.62/bin/apache-tomcat-10.1.62.tar.gz; \
    echo "ca776bf4045d3eadc2ede1b9bb2c33fc52ce1d102b63ca635ec6c0e515140027c6be7a15b2c1e1d8d8692aeaf25a72de99ca0f14135c3e1d163eedaf3dac5a54  /tmp/dl/tomcat.tar.gz" | sha512sum -c -; \
    tar -xzf /tmp/dl/tomcat.tar.gz -C /usr/local/tomcat --strip-components=1; \
    rm -rf /usr/local/tomcat/webapps/* /tmp/dl/tomcat.tar.gz

# XWiki WAR (pinned to 18.9.0; update the sha256 together with VERSION) and the PostgreSQL JDBC driver.
# The unpacked WAR is kept as a template in webapps-src and copied to /tmp by start.sh on each start.
RUN set -eux; \
    curl -fSL --retry 5 -o /tmp/dl/xwiki.war \
        "https://maven.xwiki.org/releases/org/xwiki/platform/xwiki-platform-distribution-war/${VERSION}/xwiki-platform-distribution-war-${VERSION}.war"; \
    echo "e15f79ad379cca52cdeb22035c2fd4d04aad8b18acefbe429e770943bde2c823  /tmp/dl/xwiki.war" | sha256sum -c -; \
    mkdir -p /usr/local/tomcat/webapps-src/ROOT; \
    unzip -q /tmp/dl/xwiki.war -d /usr/local/tomcat/webapps-src/ROOT; \
    rm -f /tmp/dl/xwiki.war; \
    curl -fSL --retry 5 -o /usr/local/tomcat/webapps-src/ROOT/WEB-INF/lib/postgresql-42.7.14.jar \
        https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar; \
    echo "73914527305a40cce504b0d3d90b23caf565136912d607ae8ae7c5895512332c  /usr/local/tomcat/webapps-src/ROOT/WEB-INF/lib/postgresql-42.7.14.jar" | sha256sum -c -

# LGPL-2.1 license text. UNVERIFIED: pinned to master, not to a commit.
RUN set -eux; \
    curl -fSL --retry 5 -o /tmp/dl/LICENSE \
        https://raw.githubusercontent.com/xwiki/xwiki-docker/master/LICENSE

# LibreOffice 26.2.7 deb bundle for document conversion, selected by architecture.
# UNVERIFIED: the arm64 sha256 is taken from the upstream Dockerfile and the arm64 tarball was not downloaded.
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) \
            LO_URL="https://download.documentfoundation.org/libreoffice/stable/26.2.7/deb/x86_64/LibreOffice_26.2.7_Linux_x86-64_deb.tar.gz"; \
            LO_SHA256="8cd04a88396a9230264ff784ec89cc090cbfd0960c192483ba2b80fa53939416" ;; \
        arm64) \
            LO_URL="https://download.documentfoundation.org/libreoffice/stable/26.2.7/deb/aarch64/LibreOffice_26.2.7_Linux_aarch64_deb.tar.gz"; \
            LO_SHA256="d871da75fe387f9dab5acb7569d46d1098835c25b53695c89152f5194ad34411" ;; \
        *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fSL --retry 5 -o /tmp/dl/libreoffice.tar.gz "${LO_URL}"; \
    echo "${LO_SHA256}  /tmp/dl/libreoffice.tar.gz" | sha256sum -c -; \
    tar -xzf /tmp/dl/libreoffice.tar.gz -C /tmp/libreoffice; \
    rm -f /tmp/dl/libreoffice.tar.gz

# Final stage: JRE 25 base, as upstream runs on tomcat:10-jre25.
FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:3db5983d5bd504865ac842efb282bcbdbd286adbc116fc18645ec3c433eba44a

ENV CATALINA_HOME=/usr/local/tomcat \
    CATALINA_TMPDIR=/tmp/xwiki-tmp \
    HOME=/config

USER root

COPY --from=build /usr/local/tomcat /usr/local/tomcat
COPY --from=build /tmp/libreoffice /tmp/libreoffice
COPY --from=build /tmp/dl/LICENSE /usr/share/licenses/xwiki/LICENSE

# UNVERIFIED: package names are from the upstream Dockerfile. If dpkg reports missing
# dependencies for the LibreOffice debs, resolve them with apt-get before retrying.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        curl \
        libcairo2 \
        libcups2 \
        libdbus-glib-1-2 \
        libnss3 \
        libsm6 \
        libx11-xcb1 \
        libxi6 \
        libxinerama1 \
        libxml2 \
        libxslt1.1 \
        libxtst6 \
        procps \
        unzip; \
    find /tmp/libreoffice -name '*.deb' -print0 | xargs -0 dpkg -i; \
    ln -fns /opt/libreoffice26.2 /opt/libreoffice; \
    test -x /opt/libreoffice/program/soffice; \
    rm -rf /tmp/libreoffice /var/lib/apt/lists/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
